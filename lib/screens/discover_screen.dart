import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../localization.dart';
import '../../firebase_helper.dart';
import '../../widgets/activity_card.dart';
import '../../tribe_header.dart';
import 'settings_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Tribe Logo + Settings Icon
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TribeHeader(),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white70,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Text(
            'Ανακάλυψε',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kBlue,
              letterSpacing: -1,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseHelper.instance.streamActivities(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kBlue),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Σφάλμα: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final activities = snapshot.data ?? [];
              if (activities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_soccer_outlined,
                        size: 64,
                        color: Colors.white10,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('noActivities'),
                        style: const TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return ActivityCard(activity: activities[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
