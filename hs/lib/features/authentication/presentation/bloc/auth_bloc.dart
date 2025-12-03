import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
	// final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

	AuthBloc() : super(const AuthInitial()) {
		on<AuthStarted>((event, emit) {
			emit(const AuthInitial());
		});

		on<LoginRequested>((event, emit) async {
			emit(const AuthLoading());
			try {
				// TODO: Replace with Firebase Auth when configured
				// await _firebaseAuth.signInWithEmailAndPassword(
				//   email: event.email,
				//   password: event.password,
				// );
				// Mock authentication - simulate network delay
				await Future.delayed(const Duration(seconds: 1));
				
				// Basic validation for demo
				if (event.email.contains('@') && event.password.length >= 6) {
					emit(AuthSuccess(user: event.email));
				} else {
					emit(const AuthFailure(error: 'Email hoặc mật khẩu không hợp lệ'));
				}
			} catch (e) {
				emit(AuthFailure(error: 'Đăng nhập thất bại: ${e.toString()}'));
			}
		});

		on<SignUpRequested>((event, emit) async {
			emit(const AuthLoading());
			try {
				// TODO: Replace with Firebase Auth when configured
				// await _firebaseAuth.createUserWithEmailAndPassword(
				//   email: event.email,
				//   password: event.password,
				// );
				// Mock signup - simulate network delay
				await Future.delayed(const Duration(seconds: 1));
				
				if (event.email.contains('@') && event.password.length >= 6) {
					emit(AuthSuccess(user: event.email));
				} else {
					emit(const AuthFailure(error: 'Email hoặc mật khẩu không hợp lệ'));
				}
			} catch (e) {
				emit(AuthFailure(error: 'Đăng ký thất bại: ${e.toString()}'));
			}
		});

		on<LogoutRequested>((event, emit) async {
			emit(const AuthLoading());
			try {
				// TODO: Replace with Firebase Auth when configured
				// await _firebaseAuth.signOut();
				// Mock logout - simulate network delay
				await Future.delayed(const Duration(milliseconds: 500));
				emit(const AuthLoggedOut());
				emit(const AuthInitial());
			} catch (e) {
				emit(AuthFailure(error: 'Đăng xuất thất bại: ${e.toString()}'));
			}
		});
	}
}
