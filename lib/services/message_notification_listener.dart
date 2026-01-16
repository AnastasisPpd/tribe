import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_helper.dart';
import 'notification_service.dart';

/// Service to listen for new chat messages and trigger notifications
class MessageNotificationListener {
  MessageNotificationListener._();
  static final MessageNotificationListener instance =
      MessageNotificationListener._();

  final Map<String, StreamSubscription<QuerySnapshot>> _subscriptions = {};
  final Map<String, DateTime> _lastMessageTimes = {};
  bool _isListening = false;

  /// Start listening for messages in all activities the user has joined
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    // Listen to all activities and filter to ones we're participants of
    FirebaseHelper.instance.streamActivities().listen((activities) {
      final joinedActivities = activities
          .where((a) => FirebaseHelper.instance.isParticipant(a))
          .toList();

      // Get set of current activity IDs we should be listening to
      final activeIds = joinedActivities.map((a) => a['id'] as String).toSet();

      // Cancel subscriptions for activities we're no longer part of
      final toRemove = _subscriptions.keys
          .where((id) => !activeIds.contains(id))
          .toList();
      for (final id in toRemove) {
        _subscriptions[id]?.cancel();
        _subscriptions.remove(id);
        _lastMessageTimes.remove(id);
      }

      // Subscribe to new activities
      for (final activity in joinedActivities) {
        final activityId = activity['id'] as String;
        final activityTitle = activity['title'] as String? ?? 'Chat';

        if (!_subscriptions.containsKey(activityId)) {
          _subscribeToActivity(activityId, activityTitle);
        }
      }
    });
  }

  void _subscribeToActivity(String activityId, String activityTitle) {
    // Initialize last message time to now (don't notify for existing messages)
    _lastMessageTimes[activityId] = DateTime.now();

    final subscription = FirebaseHelper.instance
        .streamMessages(activityId)
        .listen((snapshot) {
          _handleNewMessages(activityId, activityTitle, snapshot);
        });

    _subscriptions[activityId] = subscription;
  }

  void _handleNewMessages(
    String activityId,
    String activityTitle,
    QuerySnapshot snapshot,
  ) {
    if (snapshot.docs.isEmpty) return;

    final currentUserId = FirebaseHelper.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final lastTime = _lastMessageTimes[activityId] ?? DateTime.now();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp == null) continue;

      final messageTime = timestamp.toDate();
      final senderId = data['senderId'] as String?;
      final senderName = data['senderName'] as String? ?? 'Χρήστης';
      final messageText = data['text'] as String? ?? '';

      // Only notify for new messages from other users
      if (messageTime.isAfter(lastTime) && senderId != currentUserId) {
        NotificationService.instance.showChatNotification(
          activityId: activityId,
          activityTitle: activityTitle,
          senderName: senderName,
          messageText: messageText,
        );
      }
    }

    // Update last message time to the most recent
    final newestTimestamp = snapshot.docs.last.get('timestamp') as Timestamp?;
    if (newestTimestamp != null) {
      _lastMessageTimes[activityId] = newestTimestamp.toDate();
    }
  }

  /// Stop all message subscriptions
  void stopListening() {
    _isListening = false;
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _lastMessageTimes.clear();
  }
}
