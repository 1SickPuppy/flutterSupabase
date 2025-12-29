// lib/features/customer_management/domain/customer_service.dart

import '../../../models/customer_model.dart';

/// Interface for Customer Service (følger Interface Segregation Principle)
abstract class CustomerService {
  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers();

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(int id);

  /// Search customers by name, email, phone, or address
  Future<List<CustomerModel>> searchCustomers(String query);

  /// Filter customers by category
  Future<List<CustomerModel>> getCustomersByCategory(String category);

  /// Create new customer
  Future<Map<String, dynamic>> createCustomer(CustomerModel customer);

  /// Update existing customer
  Future<Map<String, dynamic>> updateCustomer(int id, CustomerModel customer);

  /// Delete customer
  Future<Map<String, dynamic>> deleteCustomer(int id);

  /// Import customers from CSV data
  Future<Map<String, dynamic>> importCustomersFromCsv(String csvContent);

  /// Get customer count
  Future<int> getCustomerCount();
}
