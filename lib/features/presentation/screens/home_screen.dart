import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Awareness'),
      ),

      // Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [


            
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),

            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('Phq9 Questionnaire'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/phq9');
              },
            ),

            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('General_Questionnaire'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/questionnaire');
              },
            ),

            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('DASS-21 Questionnaire'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dass21');
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildCard(
              context,
              title: '🧠 What is Mental Health?',
              imagePath: 'assets/images/whats_mental_health.png',
              content:
                  'Mental health is about how we think, feel, and act. '
                  'It affects how we handle stress, relate to others, and make choices.',
            ),

            _buildCard(
              context,
              title: '💬 It’s Okay to Talk',
              imagePath: 'assets/images/talk_ur_feeling.png',
              content:
                  'Talking about your feelings is not a weakness. '
                  'Sharing your worries with parents, teachers, or friends can help.',
            ),

            _buildCard(
              context,
              title: '😌 Ways to Stay Mentally Healthy',
              imagePath: 'assets/images/sleep_eat_play.png',
              content:
                  '• Get enough sleep\n'
                  '• Eat healthy food\n'
                  '• Exercise or play daily\n'
                  '• Limit screen time\n'
                  '• Practice relaxation like deep breathing',
            ),

            _buildCard(
              context,
              title: '🤝 You Are Not Alone',
              imagePath:'assets/images/u_r_not_alone.png',
              content:
                  'Everyone feels sad, angry, or worried sometimes. '
                  'If these feelings last long, asking for help is the best step.',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/questionnaire');
                },
                child: const Text('Start Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated card with optional image
  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 10),

            if (imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  height: 215,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],

            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

