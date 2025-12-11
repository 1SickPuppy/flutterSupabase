// lib/features/supabase_integration/presentation/supabase_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../domain/supabase_service.dart';
import '../../job_flow/job_flow_notifier.dart';

class SupabaseWidget extends StatefulWidget {
  const SupabaseWidget({super.key});

  @override
  State<SupabaseWidget> createState() => _SupabaseWidgetState();
}

class _SupabaseWidgetState extends State<SupabaseWidget> {
  late final SupabaseService _supabaseService;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _errorMessage;

  List<Map<String, dynamic>> _savedJobs = [];
  bool _isLoadingJobs = false;

  @override
  void initState() {
    super.initState();
    _supabaseService = getIt<SupabaseService>();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentUser() async {
    setState(() => _isLoading = true);
    final result = await _supabaseService.getCurrentUser();
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _isLoggedIn = true;
        _userEmail = result['user']?['email'];
        _loadJobs();
      }
    });
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email og password er påkrævet');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _supabaseService.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _isLoggedIn = true;
        _userEmail = result['user']?['email'];
        _errorMessage = null;
        _loadJobs();
      } else {
        _errorMessage = result['error'];
      }
    });
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Email og password er påkrævet');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _supabaseService.signUp(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _isLoggedIn = true;
        _userEmail = result['user']?['email'];
        _errorMessage = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konto oprettet! Tjek din email for verifikation.')),
        );
      } else {
        _errorMessage = result['error'];
      }
    });
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    await _supabaseService.signOut();
    setState(() {
      _isLoading = false;
      _isLoggedIn = false;
      _userEmail = null;
      _savedJobs = [];
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoadingJobs = true);
    final jobs = await _supabaseService.getData('job_analyses');
    setState(() {
      _isLoadingJobs = false;
      _savedJobs = jobs;
    });
  }

  Future<void> _saveCurrentJob() async {
    final notifier = Provider.of<JobFlowNotifier>(context, listen: false);
    final jobAnalysis = notifier.jobAnalysis;

    if (jobAnalysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingen data at gemme')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final jobData = jobAnalysis.toJson();
    jobData['user_email'] = _userEmail;
    jobData['created_at'] = DateTime.now().toIso8601String();

    final result = await _supabaseService.insertData('job_analyses', jobData);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job gemt til Supabase!')),
      );
      _loadJobs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${result['error']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Supabase Integration',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (_isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _signOut,
                  tooltip: 'Log ud',
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoading && !_isLoggedIn)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          // Login/Signup Form
          if (!_isLoggedIn && !_isLoading)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud, size: 64, color: Colors.blue),
                            const SizedBox(height: 16),
                            const Text(
                              'Log ind for at synkronisere',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Log ind'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _signUp,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('Opret konto'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Logged In View
          if (_isLoggedIn)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Logget ind som:',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  _userEmail ?? 'Ukendt',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Gem Nuværende Job'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isLoading ? null : _saveCurrentJob,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gemte Job Analyser',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoadingJobs ? null : _loadJobs,
                        tooltip: 'Genindlæs',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingJobs)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_isLoadingJobs && _savedJobs.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Ingen gemte jobs endnu.\nGem dit første job analyse!',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!_isLoadingJobs && _savedJobs.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _savedJobs.length,
                        itemBuilder: (context, index) {
                          final job = _savedJobs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.work, color: Colors.white),
                              ),
                              title: Text(
                                job['customerName'] ?? 'Ukendt kunde',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${job['job'] ?? 'Ukendt job'}\n${job['created_at'] ?? ''}',
                              ),
                              trailing: Text(
                                '${job['totalEstimate']} kr',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              isThreeLine: true,
                              onTap: () {
                                // TODO: Load job details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Job: ${job['customerName']}')),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}