import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_options.dart';
import 'firebase_helper.dart';
import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TribeApp());
}

// ==================== THEME CONSTANTS ====================
const Color kBackground = Color(0xFF0F172A);
const Color kCard = Color(0xFF1E293B);
const Color kBlue = Color(0xFF2563EB);
const Color kInputFill = Color(0xFF161F32);

class TribeApp extends StatelessWidget {
  const TribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kBlue,
        scaffoldBackgroundColor: kBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBackground,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseHelper.instance.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigation();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => _error = 'Συμπλήρωσε όλα τα πεδία');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseHelper.instance.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } on FirebaseException catch (e) {
      setState(() => _error = e.message ?? 'Αποτυχία σύνδεσης');
    } catch (e) {
      setState(() => _error = 'Αποτυχία σύνδεσης');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.link, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tribe',
                style: TextStyle(
                  fontSize: 36,
                  color: kBlue,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Βρες την ομάδα σου για αθλητικές\nδραστηριότητες',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 40),
              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBlue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Σύνδεση',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Email',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: _inputDeco('το_email_σου@example.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Κωδικός',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      decoration: _inputDeco('••••••••'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ξέχασες τον κωδικό;',
                          style: TextStyle(color: kBlue),
                        ),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Σύνδεση',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text('ή', style: TextStyle(color: Colors.white38)),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Δεν έχεις λογαριασμό;',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Εγγραφή',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tribe v1.0.0',
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: kInputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}

// ==================== REGISTER SCREEN ====================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  DateTime? _birthDate;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _birthDate = date);
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final city = _cityController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || city.isEmpty) {
      setState(() => _error = 'Συμπλήρωσε όλα τα πεδία');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _error = 'Οι κωδικοί δεν ταιριάζουν');
      return;
    }
    if (password.length < 6) {
      setState(
        () => _error = 'Ο κωδικός πρέπει να έχει τουλάχιστον 6 χαρακτήρες',
      );
      return;
    }
    if (_birthDate == null) {
      setState(() => _error = 'Επίλεξε ημερομηνία γέννησης');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseHelper.instance.signUp(email, password);
      await FirebaseHelper.instance.saveProfile({
        'name': name,
        'email': email,
        'city': city,
        'birthDate': _birthDate!.toIso8601String(),
        'bio': '',
        'favoriteSports': [],
      });
      await FirebaseHelper.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ο λογαριασμός δημιουργήθηκε! Συνδέσου.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      setState(() => _error = e.message ?? 'Αποτυχία εγγραφής');
    } catch (e) {
      setState(() => _error = 'Αποτυχία εγγραφής');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBlue.withValues(alpha: 0.5), width: 2),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Πίσω', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Tribe',
                    style: TextStyle(
                      fontSize: 36,
                      color: kBlue,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Βρες την ομάδα σου, ζήσε το αθλητικό πάθος!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 30),
                _buildField(
                  'Ονοματεπώνυμο *',
                  _nameController,
                  'π.χ. Γιάννης Παπαδόπουλος',
                  Icons.person_outline,
                ),
                _buildField(
                  'Email *',
                  _emailController,
                  'email@example.com',
                  Icons.email_outlined,
                ),
                _buildField(
                  'Κωδικός *',
                  _passwordController,
                  'Τουλάχιστον 6 χαρακτήρες',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                _buildField(
                  'Επιβεβαίωση Κωδικού *',
                  _confirmPasswordController,
                  'Επανάληψη κωδικού',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const Text(
                  'Ημερομηνία Γέννησης *',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: kInputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _birthDate == null
                              ? 'Επίλεξε ημερομηνία'
                              : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                          style: TextStyle(
                            color: _birthDate == null
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  'Πόλη *',
                  _cityController,
                  'π.χ. Αθήνα',
                  Icons.location_on_outlined,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Εγγραφή',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        'Με την εγγραφή συμφωνείς με τους ',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Όρους Χρήσης',
                          style: TextStyle(
                            color: kBlue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text(
                        ' και την ',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Πολιτική Απορρήτου',
                          style: TextStyle(
                            color: kBlue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Έχεις ήδη λογαριασμό; ',
                      style: TextStyle(color: Colors.white54),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Σύνδεση',
                        style: TextStyle(
                          color: kBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            obscureText: isPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white38, size: 20),
              hintText: hint,
              filled: true,
              fillColor: kInputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MAIN NAVIGATION ====================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final _screens = const [
    DiscoverScreen(),
    ChatsScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: kCard,
        selectedItemColor: kBlue,
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== DISCOVER SCREEN ====================
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Tribe logo and settings
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: kBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBlue),
                    ),
                    child: const Text(
                      'Tribe',
                      style: TextStyle(
                        fontSize: 20,
                        color: kBlue,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ανακάλυψε Δραστηριότητες',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Βρες την επόμενη αθλητική σου περιπέτεια',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Activities List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseHelper.instance.streamActivities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Δεν υπάρχουν δραστηριότητες.\nΠάτα + για να δημιουργήσεις!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) =>
                        ActivityCard(activity: snapshot.data![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlue,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateActivityScreen()),
        ),
      ),
    );
  }
}

// ==================== ACTIVITY CARD ====================
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Name, Sport Tag
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: kBlue,
                  radius: 20,
                  child: Text(
                    (activity['creatorName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity['creatorName'] ?? 'Χρήστης',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
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
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              activity['title'] ?? 'Δραστηριότητα',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Details
            _info(Icons.calendar_today, activity['date'] ?? 'Ημερομηνία'),
            _info(Icons.access_time, activity['time'] ?? 'Ώρα'),
            _info(Icons.location_on, activity['location'] ?? 'Τοποθεσία'),
            if ((activity['cost'] ?? '').isNotEmpty)
              _info(Icons.euro, '${activity['cost']} ανά άτομο'),
            if ((activity['description'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  activity['description'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            const SizedBox(height: 12),
            // Participants progress
            Row(
              children: [
                const Icon(Icons.people_outline, color: kBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${participants.length}/$maxPlayers',
                  style: const TextStyle(
                    color: kBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(kBlue),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            // Actions: Edit/Delete for creator, Join/Leave button
            Row(
              children: [
                if (isCreator) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateActivityScreen(activity: activity),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
                const Spacer(),
              ],
            ),
            // Join/Leave Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    isParticipant ? _leave(context) : _join(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isParticipant ? Colors.grey[700] : kBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isParticipant ? tr('alreadyJoined') : tr('joinTeam'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    ),
  );

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          activityId: activity['id'],
          activityTitle: activity['title'] ?? 'Chat',
          activity: activity,
        ),
      ),
    );
  }

  Future<void> _join(BuildContext context) async {
    await FirebaseHelper.instance.joinActivity(activity['id']);
  }

  Future<void> _leave(BuildContext context) async {
    await FirebaseHelper.instance.leaveActivity(activity['id']);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Διαγραφή;'),
        content: const Text('Αυτή η ενέργεια δεν μπορεί να αναιρεθεί.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Άκυρο'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Διαγραφή', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true)
      await FirebaseHelper.instance.deleteActivity(activity['id']);
  }
}

// ==================== MAP LOCATION PICKER ====================
class MapLocationPicker extends StatefulWidget {
  final String? initialLocation;
  final String? initialAddress;
  const MapLocationPicker({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });
  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng _center = const LatLng(40.6401, 22.9444); // Thessaloniki default
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialAddress ?? '';
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _center = latLng;
      // Set a location reference when pin is placed
      _searchController.text =
          '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('location')),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Current selected location display
          if (_searchController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: kBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _searchController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: tr('addressHint'),
                prefixIcon: const Icon(Icons.edit_location_alt),
                filled: true,
                fillColor: kInputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tr('tapToSelectLocation'),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 14.0,
                onTap: (tapPos, latLng) => _onMapTap(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tribe.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                  'lat': _center.latitude,
                  'lng': _center.longitude,
                  'address': _searchController.text,
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(tr('save')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CREATE/EDIT ACTIVITY ====================
class CreateActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? activity;
  const CreateActivityScreen({super.key, this.activity});
  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _costController = TextEditingController(text: '0');
  final _maxPlayersController = TextEditingController(text: '10');
  String? _sport;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  List<String> get _sports => AppLocalization.instance.sports;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      _titleController.text = widget.activity!['title'] ?? '';
      _descController.text = widget.activity!['description'] ?? '';
      _locationController.text = widget.activity!['location'] ?? '';
      _addressController.text = widget.activity!['address'] ?? '';
      _costController.text = (widget.activity!['cost'] ?? '0').toString();
      _maxPlayersController.text = (widget.activity!['maxPlayers'] ?? 10)
          .toString();
      // Convert stored sport (English) to display language
      final storedSport = widget.activity!['sport'] as String?;
      if (storedSport != null) {
        _sport = AppLocalization.instance.sportToDisplay(storedSport);
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  String get _formattedDate {
    if (_selectedDate == null) return '';
    final days = ['Δευ', 'Τρ', 'Τετ', 'Πεμ', 'Παρ', 'Σαβ', 'Κυρ'];
    return '${days[_selectedDate!.weekday - 1]} ${_selectedDate!.day}/${_selectedDate!.month}';
  }

  String get _formattedTime {
    if (_selectedTime == null) return '';
    return '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty || _sport == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('fillAllFields'))));
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'location': _locationController.text.trim(),
      'address': _addressController.text.trim(),
      'date': _formattedDate,
      'time': _formattedTime,
      'cost': _costController.text.trim(),
      'maxPlayers': int.tryParse(_maxPlayersController.text) ?? 10,
      'sport': AppLocalization.instance.sportToEnglish(
        _sport!,
      ), // Store in English
    };

    try {
      if (widget.activity != null) {
        await FirebaseHelper.instance.updateActivity(
          widget.activity!['id'],
          data,
        );
      } else {
        await FirebaseHelper.instance.createActivity(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? tr('editActivity') : tr('createActivity')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBlue.withValues(alpha: 0.3)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  tr('createActivity'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  tr('createSubtitle'),
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Sport Dropdown
              Text(
                '${tr('sport')} *',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: kInputFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _sport,
                  hint: Text(
                    tr('selectSport'),
                    style: const TextStyle(color: Colors.white38),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: kCard,
                  items: _sports
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sport = v),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(
                '${tr('title')} *',
                _titleController,
                tr('titleHint'),
              ),
              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      '${tr('date')} *',
                      _formattedDate,
                      tr('dateHint'),
                      _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      '${tr('time')} *',
                      _formattedTime,
                      tr('timeHint'),
                      _pickTime,
                    ),
                  ),
                ],
              ),
              // Location with Map Picker
              Text(
                '${tr('location')} *',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapLocationPicker(
                        initialAddress: _addressController.text,
                      ),
                    ),
                  );
                  if (result != null) {
                    _locationController.text = result['address'] ?? '';
                    _addressController.text = result['address'] ?? '';
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kInputFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Colors.white38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _locationController.text.isEmpty
                              ? tr('locationHint')
                              : _locationController.text,
                          style: TextStyle(
                            color: _locationController.text.isEmpty
                                ? Colors.white38
                                : Colors.white,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildField(tr('address'), _addressController, tr('addressHint')),
              // Cost & Max Players Row
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      tr('cost'),
                      _costController,
                      '0',
                      keyboard: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      '${tr('maxPlayers')} *',
                      _maxPlayersController,
                      'π.χ. 10',
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildField(
                tr('description'),
                _descController,
                tr('descriptionHint'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: Text(
                        tr('cancel'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? tr('save') : tr('create')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboard,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: kInputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String value,
    String hint,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: kInputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.isEmpty ? hint : value,
                style: TextStyle(
                  color: value.isEmpty ? Colors.white38 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CHATS SCREEN ====================
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (no Tribe logo - only on Discover)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    tr('yourTeams'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tr('chatSubtitle'),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseHelper.instance.streamActivities(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final myActivities = snapshot.data!
                      .where((a) => FirebaseHelper.instance.isParticipant(a))
                      .toList();
                  if (myActivities.isEmpty)
                    return Center(
                      child: Text(
                        tr('joinToChat'),
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    );
                  return ListView.builder(
                    itemCount: myActivities.length,
                    itemBuilder: (context, index) {
                      final activity = myActivities[index];
                      final participants = List<String>.from(
                        activity['participants'] ?? [],
                      );
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: kBlue,
                            child: Text(
                              (activity['title'] ?? 'C')[0].toUpperCase(),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  activity['title'] ?? 'Chat',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  AppLocalization.instance.sportToDisplay(
                                    activity['sport'] ?? 'Other',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${participants.length} ${tr('members')}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                activityId: activity['id'],
                                activityTitle: activity['title'] ?? 'Chat',
                                activity: activity,
                              ),
                            ),
                          ),
                        ),
                      );
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
}

// ==================== CHAT SCREEN ====================
class ChatScreen extends StatefulWidget {
  final String activityId;
  final String activityTitle;
  final Map<String, dynamic> activity; // Full activity data

  const ChatScreen({
    super.key,
    required this.activityId,
    required this.activityTitle,
    required this.activity,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    FirebaseHelper.instance.sendMessage(widget.activityId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final participants = List<String>.from(
      widget.activity['participants'] ?? [],
    );
    final maxPlayers = widget.activity['maxPlayers'] ?? 10;
    final sport = AppLocalization.instance.sportToDisplay(
      widget.activity['sport'] ?? 'Other',
    );
    final date = widget.activity['date'] ?? '';
    final time = widget.activity['time'] ?? '';
    final location = widget.activity['location'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.activityTitle), backgroundColor: kCard),
      body: Column(
        children: [
          // Activity Info Header (like mockup)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: kCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: kBlue,
                      child: Text(
                        (widget.activityTitle)[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.activityTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${participants.length}/$maxPlayers ${tr('members')}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        sport,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (date.isNotEmpty || location.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (date.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBlue),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: kBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$date${time.isNotEmpty ? ', $time' : ''}',
                                style: const TextStyle(
                                  color: kBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (location.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBlue),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: kBlue,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                location,
                                style: const TextStyle(
                                  color: kBlue,
                                  fontSize: 12,
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
          ),
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseHelper.instance.streamMessages(widget.activityId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      tr('noMessagesYet'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe =
                        msg['senderId'] ==
                        FirebaseHelper.instance.currentUser?.uid;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: kBlue,
                              child: Text(
                                (msg['senderName'] ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? kBlue : kCard,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      msg['senderName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  Text(msg['text'] ?? ''),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: kCard,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: kInputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: kBlue),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PROFILE SCREEN ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await FirebaseHelper.instance.getProfile();
    final activities = await FirebaseHelper.instance.getActivities();
    final myActivities = activities
        .where(
          (a) =>
              FirebaseHelper.instance.isParticipant(a) ||
              FirebaseHelper.instance.isCreator(a),
        )
        .take(3)
        .toList();
    if (mounted)
      setState(() {
        _profile = profile;
        _recentActivities = myActivities;
        _isLoading = false;
      });
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: _profile ?? {}),
      ),
    );
    if (result != null) setState(() => _profile = result);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name = _profile?['name'] ?? 'Χρήστης';
    final bio =
        _profile?['bio'] ??
        'Λάτρης του αθλητισμού και της ομαδικής δουλειάς! 🏃‍♂️⚽🏀';
    final city = _profile?['city'] ?? _profile?['location'] ?? '';
    // Only show favorites if user has set them (not dummy data)
    final storedFavs = _profile?['favoriteSports'] as List<dynamic>?;
    final favSports = storedFavs != null && storedFavs.isNotEmpty
        ? storedFavs
              .map((s) => AppLocalization.instance.sportToDisplay(s.toString()))
              .toList()
        : <String>[];
    final memberSince = _profile?['createdAt'] ?? 'Ιανουάριο 2024';
    final participations = _profile?['participations'] ?? 24;
    final creations = _profile?['creations'] ?? 8;
    final connections = _profile?['connections'] ?? 47;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header (no Tribe logo - only on Discover)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      tr('profile'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBlue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + Name + Edit
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [kBlue, kBlue.withValues(alpha: 0.5)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: kCard,
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _editProfile,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: kBlue),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 14,
                                            color: kBlue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            tr('editProfile'),
                                            style: const TextStyle(
                                              color: kBlue,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bio,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (city.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tr('memberSince')} $memberSince',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white12),
                          bottom: BorderSide(color: Colors.white12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem('$participations', tr('participations')),
                          _statItem('$creations', tr('creations')),
                          _statItem('$connections', tr('connections')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Favorite Sports (only show if user has set them)
              if (favSports.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sports_soccer_outlined,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tr('favoriteSports'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: favSports
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: kBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Recent Activities
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: Colors.white54),
                        const SizedBox(width: 8),
                        Text(
                          tr('recentActivities'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_recentActivities.isEmpty)
                      const Text(
                        'Καμία πρόσφατη δραστηριότητα',
                        style: TextStyle(color: Colors.white54),
                      )
                    else
                      ..._recentActivities.map(
                        (a) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kInputFill,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  a['sport'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      a['date'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: kBlue),
                                ),
                                child: Text(
                                  tr('upcoming'),
                                  style: const TextStyle(
                                    color: kBlue,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kBlue,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ],
  );
}

// ==================== EDIT PROFILE ====================
class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nameController = TextEditingController(
    text: widget.profile['name'] ?? '',
  );
  late final _bioController = TextEditingController(
    text: widget.profile['bio'] ?? '',
  );
  late final _locationController = TextEditingController(
    text: widget.profile['location'] ?? '',
  );
  late List<String> _selectedSports = List<String>.from(
    widget.profile['favoriteSports'] ?? [],
  );
  bool _isLoading = false;

  List<String> get _allSports => [
    'Football',
    'Basketball',
    'Tennis',
    'Volleyball',
    'Yoga',
    'Other',
  ];

  void _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MapLocationPicker(initialAddress: _locationController.text),
      ),
    );
    if (result != null && result['address'] != null) {
      setState(() => _locationController.text = result['address']);
    }
  }

  void _toggleSport(String sport) {
    setState(() {
      if (_selectedSports.contains(sport)) {
        _selectedSports.remove(sport);
      } else {
        _selectedSports.add(sport);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final data = {
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'location': _locationController.text.trim(),
      'favoriteSports': _selectedSports,
    };
    try {
      await FirebaseHelper.instance.saveProfile(data);
      if (mounted) Navigator.pop(context, {...widget.profile, ...data});
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('editProfile')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Photo (placeholder for future image picker)
            Center(
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('photoUploadComingSoon'))),
                ),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kCard,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white54,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Name
            TextField(
              controller: _nameController,
              decoration: _inputDeco(tr('fullName')),
            ),
            const SizedBox(height: 16),
            // Location with Map
            Text(tr('location'), style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kInputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: Colors.white38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationController.text.isEmpty
                            ? tr('locationHint')
                            : _locationController.text,
                        style: TextStyle(
                          color: _locationController.text.isEmpty
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            TextField(
              controller: _bioController,
              decoration: _inputDeco(tr('bio')),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Favorite Sports
            Text(
              tr('favoriteSports'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSports.map((sport) {
                final isSelected = _selectedSports.contains(sport);
                final displayName = AppLocalization.instance.sportToDisplay(
                  sport,
                );
                return GestureDetector(
                  onTap: () => _toggleSport(sport),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? kBlue : kInputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(tr('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: kInputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

// ==================== SEARCH SCREEN ====================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;

  List<String> get _sports => AppLocalization.instance.sports;

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tr('filters'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                tr('selectSportFilter'),
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _filterOption(tr('all'), _selectedSport == null, () {
                      setModalState(() => _selectedSport = null);
                      setState(() {});
                      Navigator.pop(ctx);
                    }),
                    ..._sports.map(
                      (s) => _filterOption(s, _selectedSport == s, () {
                        setModalState(() => _selectedSport = s);
                        setState(() {});
                        Navigator.pop(ctx);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterOption(String title, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? kBlue : kInputFill,
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: kBlue, width: 2) : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (no Tribe logo - only on Discover)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    tr('searchTitle'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tr('searchSubtitle'),
                style: const TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar + Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: tr('searchHint'),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: kInputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showFilterPanel,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedSport != null ? kBlue : kInputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedSport != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Chip(
                  label: Text(_selectedSport!),
                  onDeleted: () => setState(() => _selectedSport = null),
                  backgroundColor: kBlue,
                ),
              ),
            const SizedBox(height: 8),
            // Results
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseHelper.instance.streamActivities(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  var activities = snapshot.data!;
                  final query = _searchController.text.toLowerCase();
                  if (query.isNotEmpty)
                    activities = activities
                        .where(
                          (a) =>
                              (a['title']?.toString().toLowerCase().contains(
                                    query,
                                  ) ??
                                  false) ||
                              (a['location']?.toString().toLowerCase().contains(
                                    query,
                                  ) ??
                                  false) ||
                              (a['sport']?.toString().toLowerCase().contains(
                                    query,
                                  ) ??
                                  false),
                        )
                        .toList();
                  if (_selectedSport != null)
                    activities = activities
                        .where(
                          (a) => AppLocalization.instance.sportMatches(
                            a['sport'],
                            _selectedSport,
                          ),
                        )
                        .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${activities.length} ${tr('results')}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(
                        child: activities.isEmpty
                            ? Center(
                                child: Text(
                                  tr('noResults'),
                                  style: const TextStyle(color: Colors.white54),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: activities.length,
                                itemBuilder: (context, index) =>
                                    ActivityCard(activity: activities[index]),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SETTINGS SCREEN ====================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifyMessages = true;
  bool _notifyActivities = true;
  bool _notifyReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          Text(
            tr('notifications'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          _buildToggle(
            Icons.notifications_outlined,
            tr('newMessages'),
            tr('newMessagesDesc'),
            _notifyMessages,
            (v) => setState(() => _notifyMessages = v),
          ),
          _buildToggle(
            Icons.sports_soccer_outlined,
            tr('newActivities'),
            tr('newActivitiesDesc'),
            _notifyActivities,
            (v) => setState(() => _notifyActivities = v),
          ),
          _buildToggle(
            Icons.alarm_outlined,
            tr('reminders'),
            tr('remindersDesc'),
            _notifyReminders,
            (v) => setState(() => _notifyReminders = v),
          ),
          const SizedBox(height: 24),
          // Preferences
          Text(
            tr('preferences'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          _buildButton(
            Icons.language_outlined,
            tr('language'),
            AppLocalization.instance.isGreek ? 'Ελληνικά' : 'English',
            () => _showLanguageDialog(),
          ),
          _buildButton(
            Icons.lock_outline,
            tr('privacy'),
            tr('privacyDesc'),
            () => _showPrivacyDialog(),
          ),
          const SizedBox(height: 24),
          // Support
          Text(
            tr('support'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 12),
          _buildButton(
            Icons.help_outline,
            tr('helpFaq'),
            tr('helpFaqDesc'),
            () {},
          ),
          const SizedBox(height: 32),
          // Logout
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    await FirebaseHelper.instance.signOut();
                    if (mounted)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    tr('logout'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Tribe v1.0.0',
              style: const TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBlue,
            activeTrackColor: kBlue.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCard,
        title: Text(tr('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Ελληνικά'),
              leading: Icon(
                AppLocalization.instance.isGreek
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: kBlue,
              ),
              onTap: () {
                AppLocalization.instance.setLanguage('el');
                Navigator.pop(ctx);
                setState(() {});
              },
            ),
            ListTile(
              title: const Text('English'),
              leading: Icon(
                !AppLocalization.instance.isGreek
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: kBlue,
              ),
              onTap: () {
                AppLocalization.instance.setLanguage('en');
                Navigator.pop(ctx);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        title: Text(tr('privacy')),
        content: Text(tr('privacyMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
