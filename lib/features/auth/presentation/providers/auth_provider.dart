import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.hasCheckedSession = false,
  });

  final AuthUser? user;
  final bool isLoading;
  final bool hasCheckedSession;

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.role == 'admin';

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    bool? hasCheckedSession,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      hasCheckedSession: hasCheckedSession ?? this.hasCheckedSession,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(checkSession);
    return const AuthState();
  }

  Future<void> checkSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.readToken();
    if (token == null) {
      state = state.copyWith(hasCheckedSession: true, clearUser: true);
      return;
    }

    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = state.copyWith(user: user, hasCheckedSession: true);
    } catch (_) {
      await storage.clearToken();
      state = state.copyWith(hasCheckedSession: true, clearUser: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .login(email, password);
      await ref.read(secureStorageProvider).saveToken(result.token);
      state = state.copyWith(
        user: result.user,
        isLoading: false,
        hasCheckedSession: true,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, hasCheckedSession: true);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(name: name, email: email, phone: phone, password: password);
      await login(email, password);
    } catch (_) {
      state = state.copyWith(isLoading: false, hasCheckedSession: true);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clearToken();
    state = state.copyWith(clearUser: true, hasCheckedSession: true);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
