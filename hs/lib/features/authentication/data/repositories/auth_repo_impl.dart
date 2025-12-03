import 'package:hs/features/authentication/domain/entities/user_entity.dart';
import 'package:hs/features/authentication/domain/repositories/auth_repo.dart';

class AuthRepoImpl implements AuthRepository{
  @override
  Future<void> signIn(String email, String password)async {

  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> signUp(UserEntity user, String password) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  // TODO: implement user
  Stream<UserEntity> get user => throw UnimplementedError();
}