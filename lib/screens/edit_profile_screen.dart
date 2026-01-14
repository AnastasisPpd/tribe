import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import '../../firebase_helper.dart';
import '../../widgets/map_location_picker.dart';

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
  File? _selectedImage;
  String? _existingPhotoUrl;
  final ImagePicker _imagePicker = ImagePicker();

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
    _existingPhotoUrl = widget.profile['photoUrl'];
    _favoriteSports = List<String>.from(widget.profile['favoriteSports'] ?? []);
  }

  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Επιλογή Φωτογραφίας',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: kBlue),
                ),
                title: const Text(
                  'Τράβηξε Φωτογραφία',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Χρησιμοποίησε την κάμερα',
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: kBlue),
                ),
                title: const Text(
                  'Διάλεξε από Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Επέλεξε από τις φωτογραφίες σου',
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _selectedImage = imageFile;
        });

        // Upload to Firebase Storage
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ανέβασμα φωτογραφίας...'),
              backgroundColor: kBlue,
              duration: Duration(seconds: 1),
            ),
          );
        }

        try {
          await FirebaseHelper.instance.uploadProfilePhoto(imageFile);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Η φωτογραφία αποθηκεύτηκε!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Σφάλμα αποθήκευσης: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const MapLocationPicker(), // Removed initialAddress as it is not supported
      ),
    );

    if (result != null && result is LocationResult) {
      setState(() {
        _cityController.text = result.address;
        _address =
            '${result.coordinates.latitude}, ${result.coordinates.longitude}';
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
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kBlue,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_existingPhotoUrl != null &&
                                _existingPhotoUrl!.isNotEmpty)
                          ? NetworkImage(_existingPhotoUrl!)
                          : null,
                      child:
                          (_selectedImage == null &&
                              (_existingPhotoUrl == null ||
                                  _existingPhotoUrl!.isEmpty))
                          ? Text(
                              (_nameController.text.isNotEmpty
                                      ? _nameController.text[0]
                                      : '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
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
