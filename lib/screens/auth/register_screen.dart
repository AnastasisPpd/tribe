import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../firebase_helper.dart';

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
    } on Exception catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      if (mounted) setState(() => _error = 'Αποτυχία εγγραφής');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: kBlue.withOpacity(0.5), width: 2),
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
                Center(
                  child: Image.asset(
                    'assets/images/tribe_logo.png',
                    height: 50,
                    fit: BoxFit.contain,
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
