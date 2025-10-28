import 'package:flutter/material.dart';
import '../domain/supabase_service.dart';
import '../../../core/di/service_locator.dart';

class SupabaseWidget extends StatefulWidget {
  const SupabaseWidget({super.key});

  @override
  State<SupabaseWidget> createState() => _SupabaseWidgetState();
}

class _SupabaseWidgetState extends State<SupabaseWidget> {
  final SupabaseService _supabaseService = supabaseService;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>>? _tableData;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Udfyld venligst både email og password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _supabaseService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login succesfuldt')),
        );
        _getCurrentUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login fejlede: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Udfyld venligst både email og password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _supabaseService.signUp(
        _emailController.text,
        _passwordController.text,
      );
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bruger oprettet succesfuldt')),
        );
        _getCurrentUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Brugeroprettelse fejlede: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _supabaseService.signOut();
      setState(() {
        _currentUser = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logget ud')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved logout: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _supabaseService.getCurrentUser();
      setState(() {
        _currentUser = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved hentning af bruger: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _supabaseService.getData('example_table');
      setState(() {
        _tableData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl ved hentning af data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _insertData() async {
    if (_dataController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indtast venligst data')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'content': _dataController.text,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final result = await _supabaseService.insertData('example_table', data);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data gemt succesfuldt')),
        );
        _dataController.clear();
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fejl ved gemning af data: ${result['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fejl: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Supabase Integration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Authentication Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Authentication',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            child: const Text('Log ind'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            child: const Text('Opret bruger'),
                          ),
                        ),
                      ],
                    ),
                    if (_currentUser != null) ...[
                      const SizedBox(height: 16),
                      const Text('Bruger info:'),
                      Text(_currentUser.toString()),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signOut,
                        child: const Text('Log ud'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Database Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Database',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Data til indsættelse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _insertData,
                            child: const Text('Indsæt data'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _fetchData,
                            child: const Text('Hent data'),
                          ),
                        ),
                      ],
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_tableData != null) ...[
                      const SizedBox(height: 16),
                      const Text('Database data:'),
                      const SizedBox(height: 10),
                      ..._tableData!.map((item) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.toString()),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}