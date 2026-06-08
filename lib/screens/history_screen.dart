import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('History')),
        body: const Center(
          child: Text('Login to see your doubt history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Doubt History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
           .collection('users')
           .doc(user.uid)
           .collection('doubts')
           .orderBy('timestamp', descending: true)
           .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No doubts solved yet.\nScan your first question!'),
            );
          }
          
          final doubts = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: doubts.length,
            itemBuilder: (context, index) {
              final doubt = doubts[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ExpansionTile(
                  title: Text(
                    doubt['question']?? 'No question',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    doubt['timestamp']!= null
                       ? (doubt['timestamp'] as Timestamp).toDate().toString().split('.')[0]
                        : 'No date',
                    style: const TextStyle(fontSize: 12),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          MarkdownBody(data: doubt['answer']?? 'No answer'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}