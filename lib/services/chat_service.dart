import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // Replace with your Groq API key later
  static const String _apiKey = 'YOUR_GROQ_API_KEY';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> solveDoubt(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an NCERT expert for classes 6-12. Solve doubts step-by-step in simple language. Use markdown for formatting. Always explain concepts from NCERT books.'
            },
            {
              'role': 'user',
              'content': question
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['choices'][0]['message']['content'];
        await _saveToHistory(question, answer);
        return answer;
      } else {
        return 'Error: Could not solve. Check your internet or try again.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<String> generatePaper(int classNum, String subject) async {
    try {
      final prompt = 'Create a practice question paper for Class $classNum $subject based on NCERT syllabus. Include 5 MCQs, 5 short answers, 3 long answers. Add marking scheme. Use markdown formatting.';
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an NCERT paper setter for classes 6-12. Create exam papers strictly from NCERT textbooks.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.4,
          'max_tokens': 2048,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error generating paper. Try again.';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  static Future<void> _saveToHistory(String question, String answer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('doubts')
        .add({
      'question': question,
      'answer': answer,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}