import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';

/// Result class to hold both coordinates and address
class LocationResult {
  final LatLng coordinates;
  final String address;

  LocationResult({required this.coordinates, required this.address});
}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  const MapLocationPicker({super.key, this.initialLocation});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isLoadingAddress = false;

  static const LatLng _defaultLocation = LatLng(37.9838, 23.7275); // Athens

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
    if (widget.initialLocation != null) {
      _reverseGeocode(widget.initialLocation!);
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _selectedAddress = '';
    });
    _reverseGeocode(latLng);
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _isLoadingAddress = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a readable address
        // Priority: Street, SubLocality, Locality, AdministrativeArea
        final parts = <String>[];

        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        if (place.locality != null &&
            place.locality!.isNotEmpty &&
            !parts.contains(place.locality)) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty &&
            parts.isEmpty) {
          parts.add(place.administrativeArea!);
        }

        setState(() {
          _selectedAddress = parts.join(', ');
        });
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _attemptPop() {
    if (_selectedLocation != null) {
      Navigator.pop(
        context,
        LocationResult(
          coordinates: _selectedLocation!,
          address: _selectedAddress.isNotEmpty
              ? _selectedAddress
              : 'Άγνωστη τοποθεσία',
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Παρακαλώ επιλέξτε τοποθεσία στο χάρτη'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Επιλογή Τοποθεσίας'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _attemptPop),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: 14.0,
            ),
            // onMapCreated: (controller) => _mapController = controller,
            onTap: _onMapTap,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          // Address display at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom:
                24, // Moved lower as requested style often prefers this or with bottom sheet style
            child: SafeArea(
              // Ensure it's not behind nav bar
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: kBlue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _isLoadingAddress
                          ? const Text(
                              'Αναζήτηση τοποθεσίας...',
                              style: TextStyle(color: Colors.white54),
                            )
                          : Text(
                              _selectedAddress.isNotEmpty
                                  ? _selectedAddress
                                  : 'Πατήστε στον χάρτη για επιλογή',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlue,
        onPressed: _attemptPop,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
