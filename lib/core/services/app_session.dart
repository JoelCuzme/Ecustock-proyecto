import '../models/user_profile.dart';

class AppSession {
  AppSession._();

  static final AppSession _instance = AppSession._();

  factory AppSession() => _instance;

  UserProfile? currentUser;

  bool get isAuthenticated => currentUser != null;

  void clear() {
    currentUser = null;
  }
}
