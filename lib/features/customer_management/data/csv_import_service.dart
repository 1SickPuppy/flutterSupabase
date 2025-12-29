// lib/features/customer_management/data/csv_import_service.dart

import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/customer_model.dart';

class CsvImportService {
  final _supabase = Supabase.instance.client;

  /// Import customers from CSV file in assets
  Future<Map<String, dynamic>> importCustomersFromAsset(String assetPath) async {
    try {
      // Load CSV file from assets
      final csvString = await rootBundle.loadString(assetPath);

      return await importCustomersFromString(csvString);
    } catch (e) {
      return {
        'success': false,
        'error': 'Fejl ved læsning af CSV fil: $e',
      };
    }
  }

  /// Import customers from CSV string
  Future<Map<String, dynamic>> importCustomersFromString(String csvContent) async {
    try {
      // Parse CSV
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(
        csvContent,
        fieldDelimiter: ',',
        eol: '\n',
      );

      if (csvData.isEmpty) {
        return {
          'success': false,
          'error': 'CSV filen er tom',
        };
      }

      // First row is header
      final headers = csvData[0].map((e) => e.toString()).toList();
      print('CSV Headers: $headers');

      // Map headers to indices
      final nameIdx = _findColumnIndex(headers, ['Navn', 'name']);
      final numberIdx = _findColumnIndex(headers, ['Nummer', 'number', 'customer_number']);
      final categoryIdx = _findColumnIndex(headers, ['Kategori', 'category']);
      final addressIdx = _findColumnIndex(headers, ['Adresse', 'address']);
      final postalCodeIdx = _findColumnIndex(headers, ['Postnummer', 'postal_code']);
      final cityIdx = _findColumnIndex(headers, ['By', 'city']);
      final phoneIdx = _findColumnIndex(headers, ['Telefonnummer', 'phone']);
      final mobileIdx = _findColumnIndex(headers, ['Mobilnummer', 'mobile']);
      final emailIdx = _findColumnIndex(headers, ['E-mail', 'email']);
      final cvrIdx = _findColumnIndex(headers, ['CVR nummer', 'cvr_number', 'CVR']);
      final invoiceNameIdx = _findColumnIndex(headers, ['Fakturanavn', 'invoice_name']);
      final invoiceAddressIdx = _findColumnIndex(headers, ['Fakturaadresse', 'invoice_address']);
      final invoicePostalCodeIdx = _findColumnIndex(headers, ['Faktura postnummer', 'invoice_postal_code']);
      final invoiceCityIdx = _findColumnIndex(headers, ['Faktura by', 'invoice_city']);
      final invoiceEmailIdx = _findColumnIndex(headers, ['Faktura e-mail', 'invoice_email']);
      final invoicePhoneIdx = _findColumnIndex(headers, ['Faktura telefonnummer', 'invoice_phone']);
      final paymentTermsIdx = _findColumnIndex(headers, ['Betalingsbetingelser', 'payment_terms']);
      final contactPersonIdx = _findColumnIndex(headers, ['Rekvirenten', 'contact_person', 'Reference']);

      // Convert rows to CustomerModel objects
      final List<Map<String, dynamic>> customersData = [];
      int importedCount = 0;
      int skippedCount = 0;
      List<String> errors = [];

      for (int i = 1; i < csvData.length; i++) {
        try {
          final row = csvData[i];

          // Skip empty rows
          if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
            skippedCount++;
            continue;
          }

          // Name is required
          final name = _getCellValue(row, nameIdx);
          if (name == null || name.isEmpty) {
            skippedCount++;
            errors.add('Row $i: Mangler navn');
            continue;
          }

          // Create customer data
          final customerData = {
            'customer_number': _getCellValue(row, numberIdx),
            'name': name,
            'category': _getCellValue(row, categoryIdx),
            'address': _getCellValue(row, addressIdx),
            'postal_code': _getCellValue(row, postalCodeIdx),
            'city': _getCellValue(row, cityIdx),
            'phone': _getCellValue(row, phoneIdx),
            'mobile': _getCellValue(row, mobileIdx),
            'email': _getCellValue(row, emailIdx),
            'cvr_number': _getCellValue(row, cvrIdx),
            'invoice_name': _getCellValue(row, invoiceNameIdx),
            'invoice_address': _getCellValue(row, invoiceAddressIdx),
            'invoice_postal_code': _getCellValue(row, invoicePostalCodeIdx),
            'invoice_city': _getCellValue(row, invoiceCityIdx),
            'invoice_email': _getCellValue(row, invoiceEmailIdx),
            'invoice_phone': _getCellValue(row, invoicePhoneIdx),
            'payment_terms': _getCellValue(row, paymentTermsIdx),
            'contact_person': _getCellValue(row, contactPersonIdx),
          };

          // Remove null values
          customerData.removeWhere((key, value) => value == null);

          customersData.add(customerData);
          importedCount++;
        } catch (e) {
          skippedCount++;
          errors.add('Row $i: $e');
        }
      }

      // Bulk insert to Supabase
      if (customersData.isNotEmpty) {
        try {
          await _supabase.from('customers').insert(customersData);

          return {
            'success': true,
            'imported': importedCount,
            'skipped': skippedCount,
            'errors': errors,
            'message': 'Importeret $importedCount kunder (sprang $skippedCount over)',
          };
        } catch (e) {
          // If bulk insert fails, try one by one
          return await _importOneByOne(customersData);
        }
      } else {
        return {
          'success': false,
          'error': 'Ingen gyldige kunder fundet i CSV',
          'skipped': skippedCount,
          'errors': errors,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Fejl ved import: $e',
      };
    }
  }

  /// Fallback: Import customers one by one (slower but handles duplicates)
  Future<Map<String, dynamic>> _importOneByOne(List<Map<String, dynamic>> customersData) async {
    int successCount = 0;
    int failCount = 0;
    List<String> errors = [];

    for (final customerData in customersData) {
      try {
        await _supabase.from('customers').insert(customerData);
        successCount++;
      } catch (e) {
        failCount++;
        errors.add('${customerData['name']}: $e');
      }
    }

    return {
      'success': successCount > 0,
      'imported': successCount,
      'failed': failCount,
      'errors': errors,
      'message': 'Importeret $successCount kunder ($failCount fejlede)',
    };
  }

  /// Find column index by possible names
  int? _findColumnIndex(List<String> headers, List<String> possibleNames) {
    for (final name in possibleNames) {
      for (int i = 0; i < headers.length; i++) {
        if (headers[i].toLowerCase().trim() == name.toLowerCase().trim()) {
          return i;
        }
      }
    }
    return null;
  }

  /// Get cell value safely
  String? _getCellValue(List<dynamic> row, int? index) {
    if (index == null || index >= row.length) return null;
    final value = row[index]?.toString().trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  /// Delete all customers (use with caution!)
  Future<Map<String, dynamic>> deleteAllCustomers() async {
    try {
      await _supabase.from('customers').delete().neq('id', 0);

      return {
        'success': true,
        'message': 'Alle kunder slettet',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
