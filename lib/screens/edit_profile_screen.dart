import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../firebase_helper.dart';
import '../../widgets/map_location_picker.dart';
import 'package:latlong2/latlong.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  String _address = '';
  List<String> _favoriteSports = [];
  bool _isLoading = false;

  final List<String> _allSports = [
    'Football',
    'Basketball',
    'Tennis',
    'Running',
    'Volleyball',
    'Padel',
    'Gym',
    'Cycling',
    'Swimming',
    'Yoga',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile['name'] ?? '';
    _bioController.text = widget.profile['bio'] ?? '';
    _cityController.text = widget.profile['city'] ?? '';
    _address = widget.profile['address'] ?? '';
    _favoriteSports = List<String>.from(widget.profile['favoriteSports'] ?? []);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MapLocationPicker(), // Removed initialAddress as it is not supported
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _address =
            '${result.latitude}, ${result.longitude}'; // Temporary: store coords as address since no geocoding
        // _cityController.text = ... // You might want to let user type city manually
      });
    }
  }

  void _toggleSport(String sport) {
    setState(() {
      if (_favoriteSports.contains(sport)) {
        _favoriteSports.remove(sport);
      } else {
        if (_favoriteSports.length < 5) {
          _favoriteSports.add(sport);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Μπορείς να επιλέξεις μέχρι 5 αθλήματα'),
            ),
          );
        }
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseHelper.instance.updateProfile({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _address,
        'favoriteSports': _favoriteSports,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Επεξεργασία Προφίλ'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: kBlue,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check, color: kBlue),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: kBlue,
                    child: Text(
                      (_nameController.text.isNotEmpty
                              ? _nameController.text[0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: _inputDeco('Ονοματεπώνυμο'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: _inputDeco('Λίγα λόγια για εσένα...'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickLocation,
              child: AbsorbPointer(
                child: TextField(
                  controller: _cityController,
                  decoration: _inputDeco('Πόλη / Περιοχή').copyWith(
                    suffixIcon: const Icon(Icons.map, color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Αγαπημένα Αθλήματα (max 5)',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSports.map((sport) {
                final isSelected = _favoriteSports.contains(sport);
                return ChoiceChip(
                  label: Text(sport),
                  selected: isSelected,
                  onSelected: (_) => _toggleSport(sport),
                  selectedColor: kBlue,
                  backgroundColor: kInputFill,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? kBlue : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: kInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBlue),
      ),
    );
  }
}
