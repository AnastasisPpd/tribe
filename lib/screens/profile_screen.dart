import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../localization.dart';
import '../../firebase_helper.dart';
import '../../widgets/activity_card.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import '../../tribe_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to parse activity date and check if upcoming
  bool _isUpcoming(Map<String, dynamic> activity) {
    try {
      final dateStr = activity['date'] as String?;
      final timeStr = activity['time'] as String?;
      if (dateStr == null) return true; // Assume upcoming if no date

      final dParts = dateStr.split('/');
      if (dParts.length < 3) return true;

      int hour = 0, minute = 0;
      if (timeStr != null && timeStr.contains(':')) {
        final tParts = timeStr.split(':');
        hour = int.tryParse(tParts[0]) ?? 0;
        minute = int.tryParse(tParts[1]) ?? 0;
      }

      final activityDate = DateTime(
        int.parse(dParts[2]),
        int.parse(dParts[1]),
        int.parse(dParts[0]),
        hour,
        minute,
      );

      return activityDate.isAfter(DateTime.now());
    } catch (e) {
      return true; // Assume upcoming on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Profile Header as Sliver
        SliverToBoxAdapter(
          child: StreamBuilder<Map<String, dynamic>?>(
            stream: FirebaseHelper.instance.streamUserProfile(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final name = user?['name'] ?? 'User';
              final bio = user?['bio'] ?? '';
              final location = user?['city'] ?? user?['location'] ?? '';
              final photoUrl = user?['photoUrl'] as String?;
              final sports = List<String>.from(user?['favoriteSports'] ?? []);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Header Row: Tribe Logo + Settings Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TribeHeader(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProfileScreen(profile: user ?? {}),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: kBlue,
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: kBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      if (bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // Stats
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: FirebaseHelper.instance.streamActivities(),
                        builder: (context, actSnap) {
                          final myActivities = (actSnap.data ?? [])
                              .where(
                                (a) => FirebaseHelper.instance.isParticipant(a),
                              )
                              .toList();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _statItem(
                                myActivities.length.toString(),
                                tr('activities'),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.white24,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                              ),
                              _statItem(sports.length.toString(), tr('sports')),
                            ],
                          );
                        },
                      ),
                      // Favorite Sports Section
                      if (sports.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          tr('favoriteSports'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: sports.map((sport) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: kBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kBlue),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 14,
                                    color: kBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppLocalization.instance.sportToDisplay(
                                      sport,
                                    ),
                                    style: const TextStyle(
                                      color: kBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Tab Bar as Sliver
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: kBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: tr('upcomingTab')),
                  Tab(text: tr('completedTab')),
                ],
              ),
            ),
          ),
        ),
      ],
      // Activities TabBarView
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseHelper.instance.streamActivities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final myActivities = snapshot.data!
              .where((a) => FirebaseHelper.instance.isParticipant(a))
              .toList();

          final upcoming = myActivities.where((a) => _isUpcoming(a)).toList();
          final completed = myActivities.where((a) => !_isUpcoming(a)).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Tab
              _buildActivityList(upcoming, tr('noUpcoming')),
              // Completed Tab
              _buildActivityList(completed, tr('noCompleted')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityList(
    List<Map<String, dynamic>> activities,
    String emptyMessage,
  ) {
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMessage,
            style: const TextStyle(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: activities.length,
      itemBuilder: (context, index) =>
          ActivityCard(activity: activities[index]),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}
