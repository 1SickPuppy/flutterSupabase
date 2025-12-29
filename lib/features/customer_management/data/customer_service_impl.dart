// lib/features/customer_management/data/customer_service_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/customer_model.dart';
import '../domain/customer_service.dart';

class CustomerServiceImpl implements CustomerService {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all customers: $e');
      return [];
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(int id) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', id)
          .single();

      return CustomerModel.fromJson(response);
    } catch (e) {
      print('Error getting customer by ID: $e');
      return null;
    }
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    if (query.isEmpty) {
      return getAllCustomers();
    }

    try {
      // Search in multiple fields using ilike (case-insensitive)
      final response = await _supabase
          .from('customers')
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%,mobile.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }

  @override
  Future<List<CustomerModel>> getCustomersByCategory(String category) async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('category', category)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => CustomerModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting customers by category: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> createCustomer(CustomerModel customer) async {
    try {
      final data = customer.toJson();
      // Remove id and timestamps, let database handle them
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from('customers')
          .insert(data)
          .select()
          .single();

      return {
        'success': true,
        'customer': CustomerModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateCustomer(int id, CustomerModel customer) async {
    try {
      final data = customer.toJson();
      // Remove id and timestamps
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _supabase
          .from('customers')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return {
        'success': true,
        'customer': CustomerModel.fromJson(response),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteCustomer(int id) async {
    try {
      await _supabase
          .from('customers')
          .delete()
          .eq('id', id);

      return {
        'success': true,
        'message': 'Kunde slettet',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> importCustomersFromCsv(String csvContent) async {
    // This will be implemented in the CSV import service
    // For now, return a placeholder
    return {
      'success': false,
      'error': 'Not implemented - use CSV Import Service',
    };
  }

  @override
  Future<int> getCustomerCount() async {
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .count();

      return response.count;
    } catch (e) {
      print('Error getting customer count: $e');
      return 0;
    }
  }
}
