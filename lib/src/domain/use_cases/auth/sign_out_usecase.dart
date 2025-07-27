import '../../repositories/auth/authentication_repository.dart';

class SignOutUseCase {
  final AuthenticationRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
