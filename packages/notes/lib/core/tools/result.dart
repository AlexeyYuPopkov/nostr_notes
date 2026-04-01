sealed class Result<T, E> {}

final class Success<T> extends Result<T, Never> {
  final T value;
  Success(this.value);
}

final class Failure<E> extends Result<Never, E> {
  final E error;
  Failure(this.error);
}
