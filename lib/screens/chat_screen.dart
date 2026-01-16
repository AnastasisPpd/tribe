import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this import
import '../utils/constants.dart';
import '../firebase_helper.dart';
import '../widgets/participants_bottom_sheet.dart';
import '../services/notification_service.dart';
import 'public_user_profile.dart';

class ChatScreen extends StatefulWidget {
  final String activityId;
  final String title;
  final Map<String, dynamic>?
  activity; // Optional, strict check might not need it

  const ChatScreen({
    super.key,
    required this.activityId,
    required this.title,
    this.activity,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Track that user is viewing this chat (suppress notifications for it)
    NotificationService.instance.currentChatId = widget.activityId;
  }

  @override
  void dispose() {
    // Clear current chat tracking
    NotificationService.instance.currentChatId = null;
    _msgController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    FirebaseHelper.instance.sendMessage(widget.activityId, text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Parse activity data for header
    final date = widget.activity?['date'] ?? '';
    final location = widget.activity?['locationName'] ?? '';
    final time = widget.activity?['time'] ?? '';
    final subtitle = [
      date,
      location,
      time,
    ].where((s) => s.isNotEmpty).join(' • ');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.activity != null)
            IconButton(
              icon: const Icon(Icons.group, color: Colors.white70),
              tooltip: 'Συμμετέχοντες',
              onPressed: () =>
                  showParticipantsBottomSheet(context, widget.activity!),
            ),
        ],
        // Add Tribe Header if desired or keep standard back button
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseHelper.instance.getMessages(widget.activityId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: kBlue),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Δεν υπάρχουν μηνύματα ακόμα.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                // If using reverse: false (standard top-to-bottom list), logic:
                // Data comes Oldest -> Newest (from getMessages which is descending: false)
                // ListView Index 0 -> Top.
                // So Index 0 should be Oldest.

                return ListView.builder(
                  reverse: false, // Changed from true
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = FirebaseHelper.instance.isMe(data['senderId']);
                    final time = (data['timestamp'] as Timestamp?)?.toDate();
                    final timeStr = time != null
                        ? DateFormat('HH:mm').format(time)
                        : '';

                    return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          GestureDetector(
                            onTap: () {
                              final senderId = data['senderId'] as String?;
                              if (senderId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PublicUserProfile(userId: senderId),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[800],
                              backgroundImage:
                                  (data['senderPhotoUrl'] != null &&
                                      (data['senderPhotoUrl'] as String)
                                          .isNotEmpty)
                                  ? NetworkImage(
                                      data['senderPhotoUrl'] as String,
                                    )
                                  : null,
                              child:
                                  (data['senderPhotoUrl'] == null ||
                                      (data['senderPhotoUrl'] as String)
                                          .isEmpty)
                                  ? Text(
                                      (data['senderName'] ?? '?')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? kBlue : kCard,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    data['senderName'] ?? 'Χρήστης',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(data['text'] ?? ''),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  timeStr,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: kCard,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Γράψε ένα μήνυμα...',
                      filled: true,
                      fillColor: kInputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: kBlue,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
