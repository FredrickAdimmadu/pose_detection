import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pose_detector/gainz_ai/workout_screen.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Workout Summary'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(child: Text('No user is signed in')),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Workout Summary'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => WorkoutScreen()),
              );
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('workout_users')
              .doc(user.uid)
              .collection('workout_summary')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error fetching workout summary'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No workout summary found'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final totalReps = data['total_reps'] ?? 0;
                final duration = data['duration'] ?? 0;
                final formConsistency = data['form_consistency'] ?? 'No feedback available';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildSummaryCard(
                    'Workout #${index + 1}',
                    'Reps: $totalReps\nDuration: ${_formatDuration(duration)}\nFeedback: $formConsistency',
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String content) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }


  String _formatDuration(int durationMillis) {
    final duration = Duration(milliseconds: durationMillis);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes minutes $seconds seconds';
  }
}
