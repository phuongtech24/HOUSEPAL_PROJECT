import 'package:hs/features/authentication/domain/entities/user_entity.dart';

abstract  class AuthRepository {
  Stream<UserEntity> get user;
  
  Future<UserEntity> signUp(UserEntity user, String password);

  Future<void> signIn(String email, String password);

  Future<void> signOut();
}