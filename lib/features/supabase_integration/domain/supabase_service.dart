// Interface for Supabase service (følger Interface Segregation Principle)
abstract class SupabaseService {
  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>> getCurrentUser();
  Future<List<Map<String, dynamic>>> getData(String tableName);
  Future<Map<String, dynamic>> insertData(String tableName, Map<String, dynamic> data);
  Future<bool> checkConnection();
}