import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../firebase_helper.dart';
import '../../widgets/map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../localization.dart';

class CreateActivityScreen extends StatefulWidget {
  final Map<String, dynamic>? activity;
  const CreateActivityScreen({super.key, this.activity});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController(); // Optional cost
  DateTime? _date;
  TimeOfDay? _time;
  LatLng? _locationCoords;
  String _locationName = '';
  String _locationAddress = '';
  String _selectedSport = 'Football';
  int _maxPlayers = 10;
  String? _skillLevel = 'Medium'; // New: Skill level
  final List<String> _sports = [
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
  final List<String> _skillLevels = ['Beginner', 'Medium', 'Pro'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      final a = widget.activity!;
      _titleController.text = a['title'];
      _descController.text = a['description'];
      _costController.text = a['cost'] ?? ''; // Load cost
      _selectedSport = a['sport'];
      _maxPlayers = a['maxPlayers'];
      _skillLevel = a['skillLevel'] ?? 'Medium'; // Load skill level

      // Parse Date - handle various formats
      try {
        final dateStr = a['date'] as String?;
        debugPrint('Date string from activity: $dateStr');
        if (dateStr != null && dateStr.contains('/')) {
          final dParts = dateStr.split('/');
          debugPrint('Date parts: $dParts');
          if (dParts.length >= 3) {
            _date = DateTime(
              int.parse(dParts[2]),
              int.parse(dParts[1]),
              int.parse(dParts[0]),
            );
            debugPrint('Parsed date: $_date');
          }
        }
      } catch (e) {
        debugPrint('Error parsing date: ${a['date']} - $e');
      }

      // Parse Time
      try {
        final timeStr = a['time'] as String?;
        if (timeStr != null && timeStr.contains(':')) {
          final tParts = timeStr.split(':');
          if (tParts.length >= 2) {
            _time = TimeOfDay(
              hour: int.parse(tParts[0]),
              minute: int.parse(tParts[1]),
            );
          }
        }
      } catch (_) {
        debugPrint('Error parsing time: ${a['time']}');
      }

      _locationName = a['locationName'] ?? '';
      _locationAddress = a['locationAddress'] ?? '';

      // Handle location coords - could be GeoPoint or Map
      final coords = a['locationCoords'];
      if (coords != null) {
        if (coords is GeoPoint) {
          _locationCoords = LatLng(coords.latitude, coords.longitude);
        } else if (coords is Map) {
          final lat = coords['lat'] ?? coords['latitude'];
          final lng = coords['lng'] ?? coords['longitude'];
          if (lat != null && lng != null) {
            _locationCoords = LatLng(
              (lat as num).toDouble(),
              (lng as num).toDouble(),
            );
          }
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _time = time);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(initialLocation: _locationCoords),
      ),
    );

    if (result != null && result is LocationResult) {
      setState(() {
        _locationCoords = result.coordinates;
        _locationName = result.address;
        _locationAddress = result.address;
      });
    }
  }

  Future<void> _save() async {
    // Validate required fields
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ εισάγετε τίτλο'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ επιλέξτε ημερομηνία'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ επιλέξτε ώρα'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_locationCoords == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Παρακαλώ επιλέξτε τοποθεσία'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final dateStr =
        '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}';
    final timeStr =
        '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'cost': _costController.text,
      'sport': _selectedSport,
      'date': dateStr,
      'time': timeStr,
      'maxPlayers': _maxPlayers,
      'skillLevel': _skillLevel,
      'locationName': _locationName,
      'locationAddress': _locationAddress,
      'locationCoords': {
        'lat': _locationCoords!.latitude,
        'lng': _locationCoords!.longitude,
      },
    };

    try {
      if (widget.activity == null) {
        await FirebaseHelper.instance.createActivity(data);
      } else {
        await FirebaseHelper.instance.updateActivity(
          widget.activity!['id'],
          data,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Αποθηκεύτηκε επιτυχώς!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
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
        title: Text(
          widget.activity == null ? 'Δημιουργία Activity' : 'Επεξεργασία',
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField('Τίτλος *', _titleController, 'π.χ. 5x5 Πέμπτης'),

            // Sport Dropdown
            const Text('Άθλημα', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kInputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSport,
                  isExpanded: true,
                  dropdownColor: kCard,
                  items: _sports
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            AppLocalization.instance.sportToDisplay(s),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSport = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skill Level Dropdown
            const Text('Επίπεδο', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kInputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _skillLevel,
                  isExpanded: true,
                  dropdownColor: kCard,
                  items: _skillLevels
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _skillLevel = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Ημερομηνία *',
                    _date == null
                        ? 'Επιλογή'
                        : '${_date!.day}/${_date!.month}/${_date!.year}',
                    'dd/mm/yyyy',
                    _pickDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    'Ώρα *',
                    _time == null
                        ? 'Επιλογή'
                        : '${_time!.hour}:${_time!.minute.toString().padLeft(2, '0')}',
                    'hh:mm',
                    _pickTime,
                  ),
                ),
              ],
            ),

            const Text('Τοποθεσία *', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kInputFill,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _locationCoords == null ? Colors.transparent : kBlue,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: _locationCoords == null ? Colors.white38 : kBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationAddress.isEmpty
                            ? 'Επιλογή στον χάρτη'
                            : _locationAddress,
                        style: TextStyle(
                          color: _locationAddress.isEmpty
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Max Players Slider
            Text(
              'Άτομα: $_maxPlayers',
              style: const TextStyle(color: Colors.white70),
            ),
            Slider(
              value: _maxPlayers.toDouble(),
              min: 2,
              max: 22,
              divisions: 20,
              activeColor: kBlue,
              label: _maxPlayers.toString(),
              onChanged: (val) => setState(() => _maxPlayers = val.toInt()),
            ),
            const SizedBox(height: 16),

            _buildField(
              'Κόστος (προαιρετικό)',
              _costController,
              'π.χ. 5€',
              keyboard: TextInputType.number,
            ),

            _buildField('Περιγραφή', _descController, '', maxLines: 3),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  disabledBackgroundColor: kBlue.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Αποθήκευση',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: kInputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white38,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
