import 'package:dartz/dartz.dart';

class Response<T> {
  final Either<String, T> _either;

  Response.success(T data) : _either = Right(data);
  Response.failure(String error) : _either = Left(error);

  bool get isSuccess => _either.isRight();
  bool get isFailure => _either.isLeft();

  T? get data => _either.fold((_) => null, (r) => r);
  String? get error => _either.fold((l) => l, (_) => null);

  R fold<R>(R Function(String error) onFailure, R Function(T data) onSuccess) {
    return _either.fold(onFailure, onSuccess);
  }
}
