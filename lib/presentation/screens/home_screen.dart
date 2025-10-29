import 'package:flutter/material.dart';
import '../../features/voice_input/presentation/voice_input_widget.dart';
import '../../features/data_extraction/presentation/data_extraction_widget.dart';
import '../../features/pdf_generation/presentation/pdf_generation_widget.dart';
import '../../features/supabase_integration/presentation/supabase_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const VoiceInputWidget(),
    const DataExtractionWidget(),
    const PdfGenerationWidget(),
    const SupabaseWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeveloperCat DK'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
        ],
      ),
    );
  }
}