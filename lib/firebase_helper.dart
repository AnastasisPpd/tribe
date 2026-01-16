import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Singleton helper class for all Firebase operations
class FirebaseHelper {
  FirebaseHelper._();
  static final FirebaseHelper instance = FirebaseHelper._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  CollectionReference get _activities => _firestore.collection('activities');
  CollectionReference get _profiles => _firestore.collection('profiles');
  CollectionReference get _chats => _firestore.collection('chats');

  // ==================== AUTH ====================
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==================== PROFILES ====================
  Future<Map<String, dynamic>?> getProfile({String? userId}) async {
    final uid = userId ?? currentUser?.uid;
    if (uid == null) return null;

    final doc = await _profiles.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Must be logged in');

    data['email'] = user.email;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _profiles.doc(user.uid).set(data, SetOptions(merge: true));

    // Sync photoUrl to activities if present in data or if we can fetch it
    String? photoUrl = data['photoUrl'];
    if (photoUrl == null) {
      // If not in update data, try to get from current profile to ensure consistency
      // This is a "heavy" check but ensures consistency as requested
      final currentProfile = await getProfile(userId: user.uid);
      photoUrl = currentProfile?['photoUrl'];
    }

    if (photoUrl != null && photoUrl.isNotEmpty) {
      await _updateCreatorPhotoInActivities(user.uid, photoUrl);
    }
  }

  // Alias for saveProfile
  Future<void> updateProfile(Map<String, dynamic> data) => saveProfile(data);

  /// Upload profile photo to Firebase Storage and save URL to profile
  Future<String?> uploadProfilePhoto(File imageFile) async {
    final user = currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      // Create a unique filename
      final fileName = 'profile_${user.uid}.jpg';
      final ref = _storage.ref().child('profile_photos').child(fileName);

      // Upload file
      await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update profile with photo URL
      await updateProfile({'photoUrl': downloadUrl});

      // Also update all activities created by this user
      await _updateCreatorPhotoInActivities(user.uid, downloadUrl);

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Update creatorPhotoUrl in all activities created by a user
  Future<void> _updateCreatorPhotoInActivities(
    String userId,
    String photoUrl,
  ) async {
    try {
      final snapshot = await _activities
          .where('creatorId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'creatorPhotoUrl': photoUrl});
      }
      await batch.commit();
    } catch (e) {
      // Silently fail - not critical if activities don't update immediately
    }
  }

  Stream<Map<String, dynamic>?> streamUserProfile() {
    final user = currentUser;
    if (user == null) return Stream.value(null);
    return _profiles.doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    });
  }

  bool isMe(String userId) => currentUser?.uid == userId;

  /// Fetch multiple profiles by their user IDs
  Future<List<Map<String, dynamic>>> getProfilesByIds(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return [];
    final futures = userIds.map((id) => getProfile(userId: id));
    final results = await Future.wait(futures);
    return results.whereType<Map<String, dynamic>>().toList();
  }

  // ==================== ACTIVITIES ====================

  /// Parse date (DD/MM/YYYY) and time (HH:mm) strings into DateTime
  DateTime? _parseScheduledDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return null;
    try {
      final dateParts = dateStr.split('/');
      final timeParts = timeStr.split(':');
      if (dateParts.length >= 3 && timeParts.length >= 2) {
        return DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[0]), // day
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
        );
      }
    } catch (_) {}
    return null;
  }

  Future<String> createActivity(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Must be logged in');

    // Get creator info from profile
    final profile = await getProfile();
    final creatorName = profile?['name'] ?? user.email ?? 'Anonymous';
    final creatorPhotoUrl = profile?['photoUrl'] as String?;

    data['creatorId'] = user.uid;
    data['creatorName'] = creatorName;
    if (creatorPhotoUrl != null && creatorPhotoUrl.isNotEmpty) {
      data['creatorPhotoUrl'] = creatorPhotoUrl;
    }
    data['participants'] = [user.uid]; // Creator auto-joins
    data['createdAt'] = FieldValue.serverTimestamp();

    // Compute scheduledDateTime from date and time strings
    final scheduledDt = _parseScheduledDateTime(
      data['date'] as String?,
      data['time'] as String?,
    );
    if (scheduledDt != null) {
      data['scheduledDateTime'] = Timestamp.fromDate(scheduledDt);
    }

    final docRef = await _activities.add(data);
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getAllActivities() async {
    final snapshot = await _activities
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Alias for getAllActivities
  Future<List<Map<String, dynamic>>> getActivities() => getAllActivities();

  /// Stream all activities (unfiltered, for internal use)
  Stream<List<Map<String, dynamic>>> streamActivities() {
    return _activities
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Stream only upcoming activities (scheduledDateTime >= now)
  Stream<List<Map<String, dynamic>>> streamUpcomingActivities() {
    final now = DateTime.now();
    return _activities
        .where(
          'scheduledDateTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(now),
        )
        .orderBy('scheduledDateTime', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Stream completed activities within 24-hour retention window
  /// Condition: (now - 24h) < scheduledDateTime < now
  Stream<List<Map<String, dynamic>>> streamCompletedActivities() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));
    return _activities
        .where('scheduledDateTime', isGreaterThan: Timestamp.fromDate(cutoff))
        .where('scheduledDateTime', isLessThan: Timestamp.fromDate(now))
        .orderBy('scheduledDateTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();

    // Recompute scheduledDateTime if date or time is being updated
    if (data.containsKey('date') || data.containsKey('time')) {
      // Fetch current values if partial update
      String? dateStr = data['date'] as String?;
      String? timeStr = data['time'] as String?;

      if (dateStr == null || timeStr == null) {
        final doc = await _activities.doc(id).get();
        if (doc.exists) {
          final existing = doc.data() as Map<String, dynamic>;
          dateStr ??= existing['date'] as String?;
          timeStr ??= existing['time'] as String?;
        }
      }

      final scheduledDt = _parseScheduledDateTime(dateStr, timeStr);
      if (scheduledDt != null) {
        data['scheduledDateTime'] = Timestamp.fromDate(scheduledDt);
      }
    }

    await _activities.doc(id).update(data);
  }

  Future<void> deleteActivity(String id) async {
    // Delete all messages in the chat subcollection first
    final messagesSnapshot = await _chats.doc(id).collection('messages').get();
    final batch = _firestore.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete the chat document and activity
    await _chats.doc(id).delete();
    await _activities.doc(id).delete();
  }

  Future<bool> joinActivity(String activityId) async {
    final user = currentUser;
    if (user == null) return false;

    await _activities.doc(activityId).update({
      'participants': FieldValue.arrayUnion([user.uid]),
    });
    return true;
  }

  Future<bool> leaveActivity(String activityId) async {
    final user = currentUser;
    if (user == null) return false;

    await _activities.doc(activityId).update({
      'participants': FieldValue.arrayRemove([user.uid]),
    });
    return true;
  }

  bool isParticipant(Map<String, dynamic> activity) {
    final user = currentUser;
    if (user == null) return false;
    final participants = List<String>.from(activity['participants'] ?? []);
    return participants.contains(user.uid);
  }

  bool isCreator(Map<String, dynamic> activity) {
    final user = currentUser;
    if (user == null) return false;
    return activity['creatorId'] == user.uid;
  }

  /// Check if an activity is completed (scheduledDateTime has passed)
  bool isActivityCompleted(Map<String, dynamic> activity) {
    final scheduledDateTime = activity['scheduledDateTime'];
    if (scheduledDateTime == null) {
      // Fallback: parse from date/time strings
      final dt = _parseScheduledDateTime(
        activity['date'] as String?,
        activity['time'] as String?,
      );
      if (dt == null) return false;
      return dt.isBefore(DateTime.now());
    }
    if (scheduledDateTime is Timestamp) {
      return scheduledDateTime.toDate().isBefore(DateTime.now());
    }
    return false;
  }

  /// Clean up expired activities (scheduledDateTime < now - 24 hours)
  /// This deletes the activity and all associated chat messages
  Future<int> cleanupExpiredActivities() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final snapshot = await _activities
        .where('scheduledDateTime', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    int deletedCount = 0;
    for (final doc in snapshot.docs) {
      try {
        await deleteActivity(doc.id);
        deletedCount++;
      } catch (e) {
        // Log error but continue with other deletions
        debugPrint('Failed to delete activity ${doc.id}: $e');
      }
    }
    return deletedCount;
  }

  // ==================== CHAT ====================
  Future<void> sendMessage(String activityId, String text) async {
    final user = currentUser;
    if (user == null) return;

    final profile = await getProfile();
    final senderName = profile?['name'] ?? user.email ?? 'Anonymous';
    final senderPhotoUrl = profile?['photoUrl'];

    await _chats.doc(activityId).collection('messages').add({
      'senderId': user.uid,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamMessages(String activityId) {
    return _chats
        .doc(activityId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Alias for streamMessages
  Stream<QuerySnapshot> getMessages(String activityId) =>
      streamMessages(activityId);
}
