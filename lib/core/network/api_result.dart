sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure(this.message, {this.statusCode, this.error});
}
