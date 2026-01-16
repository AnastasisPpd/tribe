import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../firebase_helper.dart';
import '../localization.dart';
import '../screens/chat_screen.dart';
import '../screens/create_activity_screen.dart';
import '../screens/public_user_profile.dart';
import 'participants_bottom_sheet.dart';

class ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final isCreator = FirebaseHelper.instance.isCreator(activity);
    final isParticipant = FirebaseHelper.instance.isParticipant(activity);
    final participants = List<String>.from(activity['participants'] ?? []);
    final maxPlayers = activity['maxPlayers'] ?? 10;
    final progress = participants.length / maxPlayers;

    return GestureDetector(
      onTap: isParticipant ? () => _openChat(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isParticipant ? () => _openChat(context) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar, Name, Sport Badge, and Actions (popup menu for creator)
                  Row(
                    children: [
                      // Creator Avatar + Name - tappable to view profile
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final creatorId = activity['creatorId'] as String?;
                            if (creatorId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PublicUserProfile(userId: creatorId),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: kBlue,
                                radius: 20,
                                backgroundImage:
                                    (activity['creatorPhotoUrl'] != null &&
                                        (activity['creatorPhotoUrl'] as String)
                                            .isNotEmpty)
                                    ? NetworkImage(
                                        activity['creatorPhotoUrl'] as String,
                                      )
                                    : null,
                                child:
                                    (activity['creatorPhotoUrl'] == null ||
                                        (activity['creatorPhotoUrl'] as String)
                                            .isEmpty)
                                    ? Text(
                                        (activity['creatorName'] ?? 'U')[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  activity['creatorName'] ?? tr('user'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sport Badge - Always visible
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBlue),
                        ),
                        child: Text(
                          AppLocalization.instance.sportToDisplay(
                            activity['sport'] ?? 'Other',
                          ),
                          style: const TextStyle(
                            color: kBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Action icons grouped together
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // View Participants button
                          IconButton(
                            icon: const Icon(
                              Icons.group,
                              color: Colors.white70,
                              size: 22,
                            ),
                            tooltip: tr('participants'),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () =>
                                showParticipantsBottomSheet(context, activity),
                          ),
                          // Creator actions (popup menu)
                          if (isCreator) ...[
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white70,
                              ),
                              padding: const EdgeInsets.all(8),
                              color: kCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editActivity(context);
                                } else if (value == 'delete') {
                                  _confirmDelete(context);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(tr('edit')),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        tr('delete'),
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title & Description
                  Text(
                    activity['title'] ?? tr('noTitle'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if ((activity['description'] ?? '').isNotEmpty)
                    Text(
                      activity['description'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  // Info Column (Left-aligned, stacked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: kBlue),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              activity['locationName'] ?? '-',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: kBlue),
                          const SizedBox(width: 6),
                          Text(
                            activity['time'] ?? '-',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: kBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            activity['date'] ?? '-',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Price row
                      Builder(
                        builder: (context) {
                          // Robust price parsing: handles int, double, String, null
                          // Field is stored as 'cost' in the database
                          final rawPrice = activity['cost'];
                          num priceValue = 0;
                          if (rawPrice is num) {
                            priceValue = rawPrice;
                          } else if (rawPrice is String &&
                              rawPrice.isNotEmpty) {
                            // Strip € symbol and whitespace before parsing
                            final cleaned = rawPrice.replaceAll('€', '').trim();
                            priceValue = num.tryParse(cleaned) ?? 0;
                          }
                          final isFree = priceValue <= 0;

                          return Row(
                            children: [
                              Icon(
                                Icons.euro,
                                size: 16,
                                color: isFree ? Colors.green : kBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isFree ? tr('free') : '$priceValue€',
                                style: TextStyle(
                                  color: isFree ? Colors.green : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isFree
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Players Progress (Left-aligned)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('players'),
                            style: const TextStyle(color: Colors.white54),
                          ),
                          Text(
                            '${participants.length}/$maxPlayers',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: kInputFill,
                          valueColor: const AlwaysStoppedAnimation(kBlue),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons / Completed Label
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: _buildActionWidget(context, isParticipant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the action button or completed label based on event status
  Widget _buildActionWidget(BuildContext context, bool isParticipant) {
    final isCompleted = FirebaseHelper.instance.isActivityCompleted(activity);

    if (isCompleted) {
      // Show static "Completed" label for past events - RED to stand out
      return Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            tr('completedStatus'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Show join/leave buttons for upcoming events
    if (isParticipant) {
      return ElevatedButton(
        onPressed: () => _leave(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          tr('leave'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _join(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: kBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        tr('join'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          activityId: activity['id'],
          title: activity['title'] ?? 'Chat',
          activity: activity,
        ),
      ),
    );
  }

  void _editActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateActivityScreen(activity: activity),
      ),
    );
  }

  Future<void> _join(BuildContext context) async {
    try {
      await FirebaseHelper.instance.joinActivity(activity['id']);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('joinedSuccess')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leave(BuildContext context) async {
    try {
      await FirebaseHelper.instance.leaveActivity(activity['id']);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('leftActivity'))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('error')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: Text(tr('deleteActivity')),
        content: Text(
          tr('deleteConfirmMessage'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseHelper.instance.deleteActivity(activity['id']);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tr('error')}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
