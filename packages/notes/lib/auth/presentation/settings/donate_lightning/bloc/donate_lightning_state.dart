import 'package:equatable/equatable.dart';
import 'donate_lightning_data.dart';

sealed class DonateLightningState extends Equatable {
  final DonateLightningData data;
  const DonateLightningState({required this.data});

  @override
  List<Object?> get props => [data];

  const factory DonateLightningState.idle({required DonateLightningData data}) =
      IdleState;

  const factory DonateLightningState.loading({
    required DonateLightningData data,
  }) = LoadingState;

  // const factory DonateLightningState.invoiceReady({
  //   required DonateLightningData data,
  //   required String invoice,
  // }) = InvoiceReadyState;

  const factory DonateLightningState.error({
    required DonateLightningData data,
    required Object error,
  }) = ErrorState;
}

final class IdleState extends DonateLightningState {
  const IdleState({required super.data});
}

final class LoadingState extends DonateLightningState {
  const LoadingState({required super.data});
}

// final class InvoiceReadyState extends DonateLightningState {
//   final String invoice;
//   const InvoiceReadyState({required super.data, required this.invoice});

//   @override
//   List<Object?> get props => [data, invoice];
// }

final class ErrorState extends DonateLightningState {
  final Object error;
  const ErrorState({required super.data, required this.error});

  @override
  List<Object?> get props => [data, error];
}
