import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_demo.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserDemo?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<UserDemo?> {
  AuthNotifier() : super(null);

  void login(String email, String password) {
    if (email == demoUser.email && password == demoUser.password) {
      state = demoUser;
    } else {
      state = null;
    }
  }

  void logout() {
    state = null;
  }
}
