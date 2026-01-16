import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../localization.dart';
import '../../firebase_helper.dart';
import '../../tribe_header.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            tr('myTeams'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kBlue,
              letterSpacing: -1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            tr('chatSubtitle'),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
        Expanded(child: _ChatsBody()),
      ],
    );
  }
}

/// Body widget that shows both upcoming and completed chats
class _ChatsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseHelper.instance.streamActivities(),
      builder: (context, allSnapshot) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseHelper.instance.streamCompletedActivities(),
          builder: (context, completedSnapshot) {
            if (allSnapshot.connectionState == ConnectionState.waiting &&
                completedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kBlue),
              );
            }

            final allActivities = allSnapshot.data ?? [];
            final completedActivities = completedSnapshot.data ?? [];

            // Filter for my upcoming activities
            final upcomingActivities = allActivities
                .where(
                  (a) =>
                      FirebaseHelper.instance.isParticipant(a) &&
                      !FirebaseHelper.instance.isActivityCompleted(a),
                )
                .toList();

            // Filter for my completed activities (within 24h)
            final myCompletedActivities = completedActivities
                .where((a) => FirebaseHelper.instance.isParticipant(a))
                .toList();

            if (upcomingActivities.isEmpty && myCompletedActivities.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: kBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: kBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        tr('noChats'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr('joinToChat'),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Upcoming Activities Section
                if (upcomingActivities.isNotEmpty) ...[
                  ...upcomingActivities.map((activity) {
                    final participants = List<String>.from(
                      activity['participants'] ?? [],
                    );
                    return _ChatTile(
                      activity: activity,
                      sport: activity['sport'] ?? 'Other',
                      participantCount: participants.length,
                      date: activity['date'] ?? '',
                      time: activity['time'] ?? '',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            activityId: activity['id'],
                            title: activity['title'],
                            activity: activity,
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                // Completed Activities Section (within 24h retention)
                if (myCompletedActivities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      tr('completed'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  ...myCompletedActivities.map((activity) {
                    final participants = List<String>.from(
                      activity['participants'] ?? [],
                    );
                    return _ChatTile(
                      activity: activity,
                      sport: activity['sport'] ?? 'Other',
                      participantCount: participants.length,
                      date: activity['date'] ?? '',
                      time: activity['time'] ?? '',
                      isCompleted: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            activityId: activity['id'],
                            title: activity['title'],
                            activity: activity,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> activity;
  final String sport;
  final int participantCount;
  final String date;
  final String time;
  final VoidCallback onTap;
  final bool isCompleted;

  const _ChatTile({
    required this.activity,
    required this.sport,
    required this.participantCount,
    required this.date,
    required this.time,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = activity['title'] ?? '';
    final firstLetter = title.isNotEmpty ? title[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with sport icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kBlue, kBlue.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              AppLocalization.instance.sportToDisplay(sport),
                              style: const TextStyle(
                                color: kBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$participantCount ${tr('members')}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: kBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
