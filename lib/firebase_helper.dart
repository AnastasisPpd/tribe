import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Singleton helper class for all Firebase operations
class FirebaseHelper {
  FirebaseHelper._();
  static final FirebaseHelper instance = FirebaseHelper._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }

  // Alias for saveProfile
  Future<void> updateProfile(Map<String, dynamic> data) => saveProfile(data);

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

  // ==================== ACTIVITIES ====================
  Future<String> createActivity(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Must be logged in');

    // Get creator name from profile
    final profile = await getProfile();
    final creatorName = profile?['name'] ?? user.email ?? 'Anonymous';

    data['creatorId'] = user.uid;
    data['creatorName'] = creatorName;
    data['participants'] = [user.uid]; // Creator auto-joins
    data['createdAt'] = FieldValue.serverTimestamp();

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

  Future<void> updateActivity(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _activities.doc(id).update(data);
  }

  Future<void> deleteActivity(String id) async {
    await _activities.doc(id).delete();
    // Also delete associated chat
    await _chats.doc(id).delete();
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

  // ==================== CHAT ====================
  Future<void> sendMessage(String activityId, String text) async {
    final user = currentUser;
    if (user == null) return;

    final profile = await getProfile();
    final senderName = profile?['name'] ?? user.email ?? 'Anonymous';

    await _chats.doc(activityId).collection('messages').add({
      'senderId': user.uid,
      'senderName': senderName,
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
