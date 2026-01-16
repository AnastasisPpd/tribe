import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../firebase_helper.dart';
import '../screens/public_user_profile.dart';

/// Shows a modal bottom sheet listing participants of an event.
/// Each participant shows their avatar and name, tappable to view their profile.
void showParticipantsBottomSheet(
  BuildContext context,
  Map<String, dynamic> activity,
) {
  final participantIds = List<String>.from(activity['participants'] ?? []);
  final activityTitle = activity['title'] ?? 'Δραστηριότητα';

  showModalBottomSheet(
    context: context,
    backgroundColor: kCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.group, color: kBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Συμμετέχοντες',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        activityTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${participantIds.length}',
                    style: const TextStyle(
                      color: kBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Participants list
          Expanded(
            child: participantIds.isEmpty
                ? const Center(
                    child: Text(
                      'Δεν υπάρχουν συμμετέχοντες',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: FirebaseHelper.instance.getProfilesByIds(
                      participantIds,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kBlue),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Σφάλμα φόρτωσης: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      final profiles = snapshot.data ?? [];
                      if (profiles.isEmpty) {
                        return const Center(
                          child: Text(
                            'Δεν βρέθηκαν προφίλ',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          return _ParticipantTile(profile: profile);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

class _ParticipantTile extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ParticipantTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile['name'] ?? 'Χρήστης';
    final photoUrl = profile['photoUrl'] as String?;
    final userId = profile['id'] as String?;
    final isCurrentUser =
        userId != null && FirebaseHelper.instance.isMe(userId);

    return ListTile(
      onTap: userId != null
          ? () {
              Navigator.pop(context); // Close bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicUserProfile(userId: userId),
                ),
              );
            }
          : null,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: kBlue,
        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
            ? NetworkImage(photoUrl)
            : null,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCurrentUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Εσύ',
                style: TextStyle(fontSize: 10, color: kBlue),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}
