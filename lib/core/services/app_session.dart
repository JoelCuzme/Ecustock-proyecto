import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession _instance = AppSession._();

  factory AppSession() => _instance;

  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;

  set currentUser(UserProfile? user) {
    _currentUser = user;
    notifyListeners();
  }

  bool get isAuthenticated => _currentUser != null;

  void clear() {
    if (_currentUser == null) return;
    _currentUser = null;
    notifyListeners();
  }
}
