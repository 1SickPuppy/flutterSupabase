// lib/features/calendar/presentation/appointment_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/appointment_model.dart';
import '../../../models/customer_model.dart';
import '../domain/appointment_service.dart';
import '../../customer_management/domain/customer_service.dart';

class AppointmentDialog extends StatefulWidget {
  final DateTime selectedDate;
  final AppointmentModel? existingAppointment;

  const AppointmentDialog({
    super.key,
    required this.selectedDate,
    this.existingAppointment,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _appointmentService = getIt<AppointmentService>();
  final _customerService = getIt<CustomerService>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late DateTime _startTime;
  late DateTime _endTime;
  String _status = 'planned';
  String _quoteStatus = 'draft';

  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;
  bool _isLoadingCustomers = false;
  bool _isSaving = false;

  final List<String> _statusOptions = [
    'planned',
    'in_progress',
    'awaiting_parts',
    'completed',
    'cancelled',
  ];

  final Map<String, String> _statusLabels = {
    'planned': 'Planlagt',
    'in_progress': 'I gang',
    'awaiting_parts': 'Afventer dele',
    'completed': 'Færdig',
    'cancelled': 'Aflyst',
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('da', null);

    if (widget.existingAppointment != null) {
      // Edit mode
      final appointment = widget.existingAppointment!;
      _titleController = TextEditingController(text: appointment.title);
      _descriptionController = TextEditingController(text: appointment.description);
      _locationController = TextEditingController(text: appointment.location);
      _startTime = appointment.startTime;
      _endTime = appointment.endTime;
      _status = appointment.status;
      _quoteStatus = appointment.quoteStatus;
    } else {
      // Create mode
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        9, // Default 9:00
      );
      _endTime = _startTime.add(const Duration(hours: 1));
    }

    _loadCustomers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);

    try {
      final customers = await _customerService.getAllCustomers();
      setState(() {
        _customers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final appointment = AppointmentModel(
        id: widget.existingAppointment?.id,
        jobAnalysisId: widget.existingAppointment?.jobAnalysisId,
        customerId: _selectedCustomer?.id,
        userEmail: '', // Will be set by service
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        status: _status,
        quoteStatus: _quoteStatus,
      );

      Map<String, dynamic> result;
      if (widget.existingAppointment != null) {
        result = await _appointmentService.updateAppointment(
          widget.existingAppointment!.id!,
          appointment,
        );
      } else {
        result = await _appointmentService.createAppointment(appointment);
      }

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (result['success'] == true) {
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );

    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );

        // Auto-adjust end time to be 1 hour after start
        if (_endTime.isBefore(_startTime) || _endTime == _startTime) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );

    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingAppointment != null
                          ? 'Rediger aftale'
                          : 'Ny aftale',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Date display
                Text(
                  DateFormat('EEEE d. MMMM yyyy', 'da').format(widget.selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titel *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Titel er påkrævet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Customer selection
                DropdownButtonFormField<CustomerModel>(
                  value: _selectedCustomer,
                  decoration: const InputDecoration(
                    labelText: 'Kunde',
                    border: OutlineInputBorder(),
                  ),
                  items: _customers.map((customer) {
                    return DropdownMenuItem<CustomerModel>(
                      value: customer,
                      child: Text(customer.name),
                    );
                  }).toList(),
                  onChanged: (customer) {
                    setState(() => _selectedCustomer = customer);
                  },
                  hint: _isLoadingCustomers
                      ? const Text('Indlæser kunder...')
                      : const Text('Vælg kunde (valgfrit)'),
                ),
                const SizedBox(height: 16),

                // Time selection
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start tid',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('HH:mm').format(_startTime)),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Slut tid',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('HH:mm').format(_endTime)),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Lokation',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Beskrivelse',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Status
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(_statusLabels[status] ?? status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Annuller'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveAppointment,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.existingAppointment != null
                              ? 'Gem ændringer'
                              : 'Opret aftale'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
