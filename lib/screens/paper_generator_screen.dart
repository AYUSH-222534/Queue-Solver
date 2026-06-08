import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/chat_service.dart';

class PaperGeneratorScreen extends StatefulWidget {
  const PaperGeneratorScreen({super.key});

  @override
  State<PaperGeneratorScreen> createState() => _PaperGeneratorScreenState();
}

class _PaperGeneratorScreenState extends State<PaperGeneratorScreen> {
  int _selectedClass = 6;
  String _selectedSubject = 'Maths';
  String _paper = '';
  bool _isLoading = false;

  final List<String> _subjects = [
    'Maths', 'Science', 'English', 'Hindi', 'Social Science'
  ];

  Future<void> _generatePaper() async {
    setState(() => _isLoading = true);
    final response = await ChatService.generatePaper(_selectedClass, _selectedSubject);
    setState(() {
      _paper = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Practice Paper')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Class:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _selectedClass,
              isExpanded: true,
              items: List.generate(7, (index) => index + 6)
                 .map((e) => DropdownMenuItem(value: e, child: Text('Class $e')))
                 .toList(),
              onChanged: (val) => setState(() => _selectedClass = val!),
            ),
            const SizedBox(height: 16),
            const Text('Select Subject:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedSubject,
              isExpanded: true,
              items: _subjects
                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                 .toList(),
              onChanged: (val) => setState(() => _selectedSubject = val!),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _generatePaper,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Generate Paper'),
              ),
            const SizedBox(height: 24),
            if (_paper.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Generated Paper:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () {
                      // TODO: Add PDF download logic later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download coming soon')),
                      );
                    },
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MarkdownBody(data: _paper),
              ),
            ],
          ],
        ),
      ),
    );
  }
}