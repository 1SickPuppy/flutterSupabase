// lib/core/auth/auth_notifier.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global authentication state manager
/// Listens to Supabase auth changes and provides auth state across the app
class AuthNotifier extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;

  bool _isAuthenticated = false;
  String? _userEmail;
  User? _currentUser;
  bool _isInitialized = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  User? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;

  AuthNotifier() {
    _initialize();
  }

  /// Initialize authentication state and listen to changes
  Future<void> _initialize() async {
    // Check for existing session on startup
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _updateAuthState(session.user);
    }

    _isInitialized = true;
    notifyListeners();

    // Listen to auth state changes (login/logout events)
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      (AuthState authState) {
        final user = authState.session?.user;
        _updateAuthState(user);
      },
      onError: (error) {
        debugPrint('Auth state error: $error');
      },
    );
  }

  /// Update internal auth state when changes occur
  void _updateAuthState(User? user) {
    final wasAuthenticated = _isAuthenticated;

    _currentUser = user;
    _isAuthenticated = user != null;
    _userEmail = user?.email;

    // Only notify if state actually changed
    if (wasAuthenticated != _isAuthenticated) {
      debugPrint('Auth state changed: ${_isAuthenticated ? "Logged in" : "Logged out"}');
      notifyListeners();
    }
  }

  /// Manually refresh auth state (useful for debugging or forced refresh)
  Future<void> refreshAuthState() async {
    final session = _supabase.auth.currentSession;
    _updateAuthState(session?.user);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
