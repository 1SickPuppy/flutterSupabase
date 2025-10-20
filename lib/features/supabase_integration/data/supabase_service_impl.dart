import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/supabase_service.dart';

class SupabaseServiceImpl implements SupabaseService {
  final _supabase = Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'user': response.user?.toJson(),
        'session': response.session?.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'user': response.user?.toJson(),
        'session': response.session?.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    
    if (user != null) {
      return {
        'success': true,
        'user': user.toJson(),
      };
    } else {
      return {
        'success': false,
        'error': 'Ingen bruger er logget ind',
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [
        {
          'success': false,
          'error': e.toString(),
        }
      ];
    }
  }

  @override
  Future<Map<String, dynamic>> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(data)
          .select()
          .single();
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  @override
  Future<bool> checkConnection() async {
    // A simple, quick check to see if the client is initialized and can reach the API
    final user = _supabase.auth.currentUser;
    return user != null || _supabase.auth.currentSession != null;
  }
}