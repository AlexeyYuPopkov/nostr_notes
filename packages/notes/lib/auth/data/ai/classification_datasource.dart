import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/services.dart';

final class ClassificationDatasource {
  final List<String> _classNames;
  final int _vocabSize;
  final int _embDim;
  final int _ngramMin;
  final int _ngramMax;

  // Embedding tables: map n -> Float32List [vocabSize * embDim]
  final Map<int, Float32List> _embeddings;

  // LayerNorm
  final Float32List _bnWeight;
  final Float32List _bnBias;

  // FC layers
  final Float32List _fc1Weight; // [128, totalDim]
  final Float32List _fc1Bias; // [128]
  final Float32List _fc2Weight; // [64, 128]
  final Float32List _fc2Bias; // [64]
  final Float32List _fc3Weight; // [numClasses, 64]
  final Float32List _fc3Bias; // [numClasses]

  const ClassificationDatasource._({
    required List<String> classNames,
    required int vocabSize,
    required int embDim,
    required int ngramMin,
    required int ngramMax,
    required Map<int, Float32List> embeddings,
    required Float32List bnWeight,
    required Float32List bnBias,
    required Float32List fc1Weight,
    required Float32List fc1Bias,
    required Float32List fc2Weight,
    required Float32List fc2Bias,
    required Float32List fc3Weight,
    required Float32List fc3Bias,
  }) : _classNames = classNames,
       _vocabSize = vocabSize,
       _embDim = embDim,
       _ngramMin = ngramMin,
       _ngramMax = ngramMax,
       _embeddings = embeddings,
       _bnWeight = bnWeight,
       _bnBias = bnBias,
       _fc1Weight = fc1Weight,
       _fc1Bias = fc1Bias,
       _fc2Weight = fc2Weight,
       _fc2Bias = fc2Bias,
       _fc3Weight = fc3Weight,
       _fc3Bias = fc3Bias;

  static Future<ClassificationDatasource> fromAssets([
    String path = 'assets/ai/classification_model.bin',
  ]) async {
    final bytes = await rootBundle.load(path);
    return fromBytes(bytes.buffer.asUint8List());
  }

  /// Загрузка модели из бинарного файла
  static ClassificationDatasource fromBytes(Uint8List bytes) {
    final bd = ByteData.sublistView(bytes);
    int offset = 0;

    // Магия "NGCL"
    final magic = String.fromCharCodes(bytes.sublist(0, 4));
    assert(magic == 'NGCL', 'Invalid model file');
    offset += 4;

    // ignore: unused_local_variable
    final version = bd.getInt32(offset, Endian.little);
    offset += 4;
    final vocabSize = bd.getInt32(offset, Endian.little);
    offset += 4;
    final embDim = bd.getInt32(offset, Endian.little);
    offset += 4;
    final ngramMin = bd.getInt32(offset, Endian.little);
    offset += 4;
    final ngramMax = bd.getInt32(offset, Endian.little);
    offset += 4;
    final numClasses = bd.getInt32(offset, Endian.little);
    offset += 4;
    final classesBlobLen = bd.getInt32(offset, Endian.little);
    offset += 4;

    // Имена классов (null-terminated strings)
    final classesBlob = bytes.sublist(offset, offset + classesBlobLen);
    offset += classesBlobLen;
    final classNames = utf8
        .decode(classesBlob)
        .split('\x00')
        .where((s) => s.isNotEmpty)
        .toList();

    // Embedding tables
    final embeddings = <int, Float32List>{};
    for (int n = ngramMin; n <= ngramMax; n++) {
      final count = vocabSize * embDim;
      final floats = Float32List(count);
      for (int i = 0; i < count; i++) {
        floats[i] = bd.getFloat32(offset, Endian.little);
        offset += 4;
      }
      embeddings[n] = floats;
    }

    // LayerNorm
    final totalDim = embDim * (ngramMax - ngramMin + 1);
    Float32List readFloats(int count) {
      final f = Float32List(count);
      for (int i = 0; i < count; i++) {
        f[i] = bd.getFloat32(offset, Endian.little);
        offset += 4;
      }
      return f;
    }

    final bnWeight = readFloats(totalDim);
    final bnBias = readFloats(totalDim);

    // FC слои
    final fc1Weight = readFloats(128 * totalDim);
    final fc1Bias = readFloats(128);
    final fc2Weight = readFloats(64 * 128);
    final fc2Bias = readFloats(64);
    final fc3Weight = readFloats(numClasses * 64);
    final fc3Bias = readFloats(numClasses);

    return ClassificationDatasource._(
      classNames: classNames,
      vocabSize: vocabSize,
      embDim: embDim,
      ngramMin: ngramMin,
      ngramMax: ngramMax,
      embeddings: embeddings,
      bnWeight: bnWeight,
      bnBias: bnBias,
      fc1Weight: fc1Weight,
      fc1Bias: fc1Bias,
      fc2Weight: fc2Weight,
      fc2Bias: fc2Bias,
      fc3Weight: fc3Weight,
      fc3Bias: fc3Bias,
    );
  }

  /// Классификация текста. Возвращает map {className: probability}
  Map<String, double> classify(String text) {
    final logits = _forward(text);
    final probs = _softmax(logits);
    final result = <String, double>{};
    for (int i = 0; i < _classNames.length; i++) {
      result[_classNames[i]] = probs[i];
    }
    return result;
  }

  List<double> _forward(String text) {
    final numNgrams = _ngramMax - _ngramMin + 1;
    final totalDim = _embDim * numNgrams;

    // 1. Embeddings
    final x = List<double>.filled(totalDim, 0.0);
    int xOffset = 0;
    for (int n = _ngramMin; n <= _ngramMax; n++) {
      final ngrams = _getNgrams(text, n);
      final emb = _embeddings[n]!;
      if (ngrams.isEmpty) {
        xOffset += _embDim;
        continue;
      }
      // mean pooling
      final vec = List<double>.filled(_embDim, 0.0);
      for (final idx in ngrams) {
        for (int d = 0; d < _embDim; d++) {
          vec[d] += emb[idx * _embDim + d];
        }
      }
      for (int d = 0; d < _embDim; d++) {
        x[xOffset + d] = vec[d] / ngrams.length;
      }
      xOffset += _embDim;
    }

    // 2. LayerNorm
    final ln = _layerNorm(x, _bnWeight, _bnBias);

    // 3. FC1 + ReLU
    final h1 = _relu(_linear(ln, _fc1Weight, _fc1Bias, 128, totalDim));

    // 4. FC2 + ReLU
    final h2 = _relu(_linear(h1, _fc2Weight, _fc2Bias, 64, 128));

    // 5. FC3 (logits)
    return _linear(h2, _fc3Weight, _fc3Bias, _classNames.length, 64);
  }

  List<int> _getNgrams(String text, int n) {
    final padded = '<$text>';
    final result = <int>[];
    for (int i = 0; i <= padded.length - n; i++) {
      final ngram = padded.substring(i, i + n);
      final hash = _md5Hash(ngram) % _vocabSize;
      result.add(hash);
    }
    return result;
  }

  /// MD5 хэш первых 4 байт little-endian (как в Python)
  int _md5Hash(String s) {
    final bytes = utf8.encode(s);
    final digest = crypto.md5.convert(bytes);
    final b = digest.bytes;
    return (b[0] | (b[1] << 8) | (b[2] << 16) | (b[3] << 24)) & 0xFFFFFFFF;
  }

  List<double> _layerNorm(
    List<double> x,
    Float32List weight,
    Float32List bias,
  ) {
    final n = x.length;
    double mean = 0;
    for (final v in x) {
      mean += v;
    }
    mean /= n;
    double variance = 0;
    for (final v in x) {
      variance += (v - mean) * (v - mean);
    }
    variance /= n;
    final std = sqrt(variance + 1e-5);
    return List.generate(n, (i) => (x[i] - mean) / std * weight[i] + bias[i]);
  }

  List<double> _linear(
    List<double> input,
    Float32List weight,
    Float32List bias,
    int outFeatures,
    int inFeatures,
  ) {
    final output = List<double>.filled(outFeatures, 0.0);
    for (int o = 0; o < outFeatures; o++) {
      double sum = bias[o];
      for (int i = 0; i < inFeatures; i++) {
        sum += weight[o * inFeatures + i] * input[i];
      }
      output[o] = sum;
    }
    return output;
  }

  List<double> _relu(List<double> x) => x.map((v) => v < 0 ? 0.0 : v).toList();

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(max);
    final exps = logits.map((v) => exp(v - maxLogit)).toList();
    final total = exps.fold(0.0, (sum, v) => sum + v);
    return exps.map((v) => v / total).toList();
  }
}
