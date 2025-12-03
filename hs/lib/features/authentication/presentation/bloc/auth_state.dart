part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
	const AuthState();

	@override
	List<Object?> get props => [];
}

class AuthInitial extends AuthState {
	const AuthInitial();
}

class AuthLoading extends AuthState {
	const AuthLoading();
}

class AuthSuccess extends AuthState {
	const AuthSuccess({required this.user});

	final String user;

	@override
	List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
	const AuthFailure({required this.error});

	final String error;

	@override
	List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {
	const AuthLoggedOut();
}