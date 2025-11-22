// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';
class UserEntity extends Equatable{
  final String memberId;
  final String name;
  final String email;
  final String avatar;
  final int point;
  final String role;

  const UserEntity({
    required this.memberId,
    required this.name,
    required this.email,
    required this.avatar,
    required this.point,
    required this.role,
  });
  
static const empty = UserEntity(
    memberId: '',
    name: '',
    email: '',
    avatar: '',
    point: 0,
    role: '',
  );

  bool get isEmpty => this == UserEntity.empty;
  bool get isNotEmpty => this != UserEntity.empty;

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}