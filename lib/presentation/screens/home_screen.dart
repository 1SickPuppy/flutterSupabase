// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/job_flow/job_flow_notifier.dart'; // Importér notifieren
import '../../features/voice_input/presentation/voice_input_widget.dart';
import '../../features/data_extraction/presentation/data_extraction_widget.dart';
import '../../features/pdf_generation/presentation/pdf_generation_widget.dart';
import '../../features/supabase_integration/presentation/supabase_widget.dart';
import '../../features/customer_management/presentation/customer_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Fjern den private _selectedIndex variabel herfra, da vi bruger Notifier

  final List<Widget> _pages = [
    const VoiceInputWidget(),
    const DataExtractionWidget(),
    const PdfGenerationWidget(),
    const SupabaseWidget(),
    const CustomerListWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    // ⭐️ Lytter til JobFlowNotifier ⭐️
    final notifier = Provider.of<JobFlowNotifier>(context);
    final selectedIndex = notifier.selectedIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeveloperCat DK'),
      ),
      body: _pages[selectedIndex], // Bruger index fra Notifier
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex, // Bruger index fra Notifier
        onTap: (index) {
          // ⭐️ Opdaterer index via Notifier-metoden ⭐️
          notifier.setSelectedIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_array),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'PDF',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Supabase',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Kunder',
          ),
        ],
      ),
    );
  }
}