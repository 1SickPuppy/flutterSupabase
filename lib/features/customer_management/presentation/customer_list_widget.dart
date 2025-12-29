// lib/features/customer_management/presentation/customer_list_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../models/customer_model.dart';
import '../domain/customer_service.dart';
import '../data/csv_import_service.dart';

class CustomerListWidget extends StatefulWidget {
  const CustomerListWidget({super.key});

  @override
  State<CustomerListWidget> createState() => _CustomerListWidgetState();
}

class _CustomerListWidgetState extends State<CustomerListWidget> {
  final _customerService = getIt<CustomerService>();
  final _csvImportService = CsvImportService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  bool _isLoading = false;
  String? _errorMessage;

  final _searchController = TextEditingController();
  String _selectedCategory = 'Alle';
  final List<String> _categories = ['Alle', 'Erhverv', 'Privat', 'Offentlig'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<CustomerModel>.from(_customers);

    // Apply category filter
    if (_selectedCategory != 'Alle') {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    // Apply search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(query) ||
            (c.email?.toLowerCase().contains(query) ?? false) ||
            (c.phone?.contains(query) ?? false) ||
            (c.mobile?.contains(query) ?? false) ||
            (c.address?.toLowerCase().contains(query) ?? false) ||
            (c.city?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    setState(() {
      _filteredCustomers = filtered;
    });
  }

  Future<void> _importCsv() async {
    // Check if user is authenticated
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    if (!authNotifier.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Du skal være logget ind for at importere kunder.\nGå til Supabase tab og log ind først.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bekræft CSV Import'),
        content: const Text(
          'Dette vil importere alle kunder fra CSV filen til Supabase.\n\nFortsæt?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await _csvImportService.importCustomersFromAsset(
        'developercatfiles/1dscoolcustomers.csv',
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Import vellykket!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadCustomers();
      } else {
        // Show detailed error
        final errors = result['errors'] as List<String>? ?? [];
        final errorText = errors.isNotEmpty
            ? '${result['error']}\n\nFørste fejl: ${errors.first}'
            : result['error'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl: $errorText'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved import: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        final isAuthenticated = authNotifier.isAuthenticated;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kunder',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Row(
                    children: [
                      // Import CSV button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Importer CSV'),
                        onPressed: _isLoading ? null : _importCsv,
                      ),
                      const SizedBox(width: 8),
                      // Refresh button
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadCustomers,
                        tooltip: 'Genindlæs',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Authentication warning
              if (!isAuthenticated)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Du er ikke logget ind. Log ind i Supabase tab for at importere kunder.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),

          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Søg efter navn, email, telefon, adresse...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 16),

          // Category filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Customer count
          Text(
            '${_filteredCustomers.length} kunder',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),

          // Customer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCustomers,
                              child: const Text('Prøv igen'),
                            ),
                          ],
                        ),
                      )
                    : _filteredCustomers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  _customers.isEmpty
                                      ? 'Ingen kunder endnu.\nKlik "Importer CSV" for at importere kunder.'
                                      : 'Ingen kunder matchede søgningen.',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getCategoryColor(customer.category),
                                    child: Text(
                                      customer.name
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    customer.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (customer.category != null)
                                        Text(customer.category!),
                                      if (customer.email != null)
                                        Text(customer.email!),
                                      if (customer.fullAddress.isNotEmpty)
                                        Text(customer.fullAddress),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  isThreeLine: true,
                                  onTap: () {
                                    // TODO: Navigate to customer detail
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Kunde: ${customer.name}')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
          ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Erhverv':
        return Colors.blue;
      case 'Privat':
        return Colors.green;
      case 'Offentlig':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
