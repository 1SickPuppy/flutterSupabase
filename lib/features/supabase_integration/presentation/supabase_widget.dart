import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/supabase_service.dart';

class SupabaseWidget extends StatelessWidget {
  const SupabaseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabaseService = context.read<SupabaseService>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Supabase Integration',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          FutureBuilder<bool>(
            future: supabaseService.checkConnection(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final isConnected = snapshot.data ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected to Supabase' : 'Connection Failed',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
