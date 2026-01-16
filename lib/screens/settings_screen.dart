import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../localization.dart';
import '../../firebase_helper.dart';
import '../../services/notification_service.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = false;
  bool _darkMode = true;
  bool _isLoadingNotifications = false;

  @override
  void initState() {
    super.initState();
    // Load notification preference from service
    _notifications = NotificationService.instance.isEnabled;
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _isLoadingNotifications = true);
    try {
      if (enabled) {
        // Request permission when enabling
        final granted = await NotificationService.instance.requestPermission();
        if (!granted) {
          // Permission denied, show message and keep toggle off
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Οι ειδοποιήσεις δεν επιτράπηκαν'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() => _isLoadingNotifications = false);
          return;
        }
      }
      await NotificationService.instance.setEnabled(enabled);
      setState(() {
        _notifications = enabled;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotifications = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ρυθμίσεις',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _sectionTitle('Λογαριασμός'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingsTile(
                icon: Icons.person_outline,
                iconColor: kBlue,
                title: 'Προφίλ',
                subtitle: 'Επεξεργασία προφίλ',
                onTap: () async {
                  // Fetch current profile and navigate to edit
                  final profile = await FirebaseHelper.instance.getProfile();
                  if (profile != null && mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(profile: profile),
                      ),
                    );
                  }
                },
              ),
              _divider(),
              _settingsTile(
                icon: Icons.lock_outline,
                iconColor: Colors.orange,
                title: 'Ασφάλεια',
                subtitle: 'Αλλαγή κωδικού',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Preferences Section
            _sectionTitle('Προτιμήσεις'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingsToggle(
                icon: Icons.notifications_outlined,
                iconColor: Colors.purple,
                title: 'Ειδοποιήσεις',
                subtitle: _isLoadingNotifications
                    ? 'Φόρτωση...'
                    : 'Push notifications',
                value: _notifications,
                onChanged: _isLoadingNotifications
                    ? null
                    : (v) => _toggleNotifications(v),
              ),
              _divider(),
              _settingsToggle(
                icon: Icons.dark_mode_outlined,
                iconColor: Colors.indigo,
                title: 'Σκούρο θέμα',
                subtitle: 'Πάντα ενεργοποιημένο',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.language,
                iconColor: Colors.teal,
                title: 'Γλώσσα',
                subtitle: AppLocalization.instance.isGreek
                    ? 'Ελληνικά'
                    : 'English',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalization.instance.isGreek ? 'EL' : 'EN',
                    style: const TextStyle(
                      color: kBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () async {
                  await AppLocalization.instance.toggleLanguage();
                  setState(() {});
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _sectionTitle('Υποστήριξη'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingsTile(
                icon: Icons.help_outline,
                iconColor: Colors.green,
                title: 'Βοήθεια & FAQ',
                subtitle: 'Συχνές ερωτήσεις',
                onTap: () => _showHelpDialog(),
              ),
              _divider(),
              _settingsTile(
                icon: Icons.info_outline,
                iconColor: Colors.blueGrey,
                title: 'Σχετικά',
                subtitle: 'Tribe v1.0.0',
                onTap: () => _showAboutDialog(),
              ),
            ]),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseHelper.instance.signOut();
                  if (mounted) {
                    // Navigate to root - AuthWrapper will show LoginScreen
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Αποσύνδεση',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white24,
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kBlue,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white54,
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Βοήθεια & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Πώς δημιουργώ μια δραστηριότητα;',
                style: TextStyle(fontWeight: FontWeight.bold, color: kBlue),
              ),
              SizedBox(height: 4),
              Text(
                'Πάτα το + στην αρχική σελίδα και συμπλήρωσε τα στοιχεία.',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Πώς μπορώ να συμμετέχω σε μια δραστηριότητα;',
                style: TextStyle(fontWeight: FontWeight.bold, color: kBlue),
              ),
              SizedBox(height: 4),
              Text(
                'Βρες μια δραστηριότητα που σε ενδιαφέρει και πάτα "Συμμετοχή".',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Πώς επικοινωνώ με την ομάδα μου;',
                style: TextStyle(fontWeight: FontWeight.bold, color: kBlue),
              ),
              SizedBox(height: 4),
              Text(
                'Αφού συμμετέχεις σε μια δραστηριότητα, μπορείς να στείλεις μηνύματα στο chat της ομάδας.',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Έχω πρόβλημα με την εφαρμογή.',
                style: TextStyle(fontWeight: FontWeight.bold, color: kBlue),
              ),
              SizedBox(height: 4),
              Text(
                'Επικοινώνησε μαζί μας στο support@tribe.app',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Κλείσιμο'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sports_soccer, color: kBlue),
            SizedBox(width: 12),
            Text('Tribe'),
          ],
        ),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Έκδοση 1.0.0', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 16),
            Text(
              'Η εφαρμογή που σε βοηθά να βρεις ομάδα για τα αγαπημένα σου αθλήματα.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              '© 2026 Tribe',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            Text(
              'Όλα τα δικαιώματα κατοχυρωμένα.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Κλείσιμο'),
          ),
        ],
      ),
    );
  }
}
