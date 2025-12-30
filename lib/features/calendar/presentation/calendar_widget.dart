// lib/features/calendar/presentation/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/appointment_model.dart';
import '../../../models/customer_model.dart';
import '../domain/appointment_service.dart';
import '../../customer_management/domain/customer_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'appointment_dialog.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final _appointmentService = getIt<AppointmentService>();
  final _customerService = getIt<CustomerService>();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AppointmentModel>> _appointments = {};
  List<AppointmentModel> _selectedDayAppointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    initializeDateFormatting('da', null);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointments = await _appointmentService.getAllAppointments();

      // Group appointments by date
      final Map<DateTime, List<AppointmentModel>> appointmentMap = {};
      for (final appointment in appointments) {
        final date = DateTime(
          appointment.startTime.year,
          appointment.startTime.month,
          appointment.startTime.day,
        );

        if (appointmentMap[date] == null) {
          appointmentMap[date] = [];
        }
        appointmentMap[date]!.add(appointment);
      }

      setState(() {
        _appointments = appointmentMap;
        _selectedDayAppointments = _getAppointmentsForDay(_selectedDay!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fejl ved indlæsning: $e';
        _isLoading = false;
      });
    }
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _appointments[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayAppointments = _getAppointmentsForDay(selectedDay);
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planned':
        return AppTheme.statusInfo;
      case 'in_progress':
        return AppTheme.statusWarning;
      case 'awaiting_parts':
        return AppTheme.statusPurple;
      case 'completed':
        return AppTheme.statusSuccess;
      case 'cancelled':
        return AppTheme.statusError;
      default:
        return AppTheme.statusInfo;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'planned':
        return 'Planlagt';
      case 'in_progress':
        return 'I gang';
      case 'awaiting_parts':
        return 'Afventer dele';
      case 'completed':
        return 'Færdig';
      case 'cancelled':
        return 'Aflyst';
      default:
        return status;
    }
  }

  Future<void> _showAppointmentDialog({AppointmentModel? appointment}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppointmentDialog(
        selectedDate: _selectedDay ?? _focusedDay,
        existingAppointment: appointment,
      ),
    );

    if (result == true) {
      // Reload appointments after successful save
      _loadAppointments();
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
                    'Kalender',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Row(
                    children: [
                      // New appointment button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Ny aftale'),
                        onPressed: isAuthenticated
                            ? () => _showAppointmentDialog()
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Toggle calendar format button
                      OutlinedButton.icon(
                        icon: Icon(_calendarFormat == CalendarFormat.month
                            ? Icons.view_week
                            : Icons.calendar_month),
                        label: Text(_calendarFormat == CalendarFormat.month
                            ? 'Uge'
                            : 'Måned'),
                        onPressed: () {
                          setState(() {
                            _calendarFormat = _calendarFormat == CalendarFormat.month
                                ? CalendarFormat.week
                                : CalendarFormat.month;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      // Refresh button
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoading ? null : _loadAppointments,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.statusWarningDarkBg
                        : AppTheme.statusWarningLightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.statusWarning.withOpacity(0.3)
                          : AppTheme.statusWarning.withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppTheme.statusWarning),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Du er ikke logget ind. Log ind i Supabase tab for at se og oprette aftaler.',
                          style: TextStyle(color: AppTheme.statusWarning),
                        ),
                      ),
                    ],
                  ),
                ),

              // Calendar
              TableCalendar<AppointmentModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getAppointmentsForDay,
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentPrimary.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.statusError,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),

              // Selected day appointments
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 64, color: AppTheme.statusError),
                                const SizedBox(height: 16),
                                Text(_errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadAppointments,
                                  child: const Text('Prøv igen'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Day header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE d. MMMM yyyy', 'da')
                                        .format(_selectedDay!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_selectedDayAppointments.length} aftaler',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Appointments list
                              Expanded(
                                child: _selectedDayAppointments.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.event_available,
                                              size: 64,
                                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Ingen aftaler denne dag',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount:
                                            _selectedDayAppointments.length,
                                        itemBuilder: (context, index) {
                                          final appointment =
                                              _selectedDayAppointments[index];
                                          return _buildAppointmentCard(
                                              appointment);
                                        },
                                      ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final statusLabel = _getStatusLabel(appointment.status);
    final startTime = DateFormat('HH:mm').format(appointment.startTime);
    final endTime = DateFormat('HH:mm').format(appointment.endTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          color: statusColor,
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text('$startTime - $endTime'),
              ],
            ),
            if (appointment.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: Text(appointment.location!)),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () {
          _showAppointmentDialog(appointment: appointment);
        },
      ),
    );
  }
}
