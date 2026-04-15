import 'package:equatable/equatable.dart';

final class RelayInfo extends Equatable {
  final Uri url;

  const RelayInfo({required this.url});

  @override
  List<Object?> get props => [url];
}
