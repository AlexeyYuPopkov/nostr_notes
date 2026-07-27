import 'package:equatable/equatable.dart';

final class AccsData extends Equatable {
  final String searchString;
  const AccsData._({required this.searchString});

  factory AccsData.initial() {
    return const AccsData._(searchString: '');
  }

  @override
  List<Object?> get props => [searchString];
}
