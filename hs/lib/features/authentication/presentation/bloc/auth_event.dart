part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
	const AuthEvent();

	@override
	List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
	const AuthStarted();
}

class LoginRequested extends AuthEvent {
	const LoginRequested({required this.email, required this.password});

	final String email;
	final String password;

	@override
	List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
	const LogoutRequested();
}

class SignUpRequested extends AuthEvent {
	const SignUpRequested({required this.email, required this.password});

	final String email;
	final String password;

	@override
	List<Object?> get props => [email, password];
}