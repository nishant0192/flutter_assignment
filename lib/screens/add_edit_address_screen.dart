import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/address_model.dart';
import '../models/user_profile.dart';
import 'package:uuid/uuid.dart';
import 'location_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? existingAddress;
  final bool autoFetchLocation;

  const AddEditAddressScreen({
    super.key,
    this.existingAddress,
    this.autoFetchLocation = false,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressDetailsController;
  late TextEditingController _receiverNameController;
  late TextEditingController _phoneController;
  final MapController _mapController = MapController();
  Timer? _debounce;

  LatLng _currentLocation = const LatLng(19.0596, 72.8464);
  bool _isLoadingLocation = false;
  String _fetchedAddress = '';

  String _selectedType = 'Other';
  double _sheetPosition = 0.45;

  @override
  void initState() {
    super.initState();
    _addressDetailsController = TextEditingController(
      text: widget.existingAddress?.subtitle ?? '',
    );

    final defaultName = currentUserNotifier.value.name;
    final defaultMobile = currentUserNotifier.value.mobile;

    _receiverNameController = TextEditingController(
      text: (widget.existingAddress?.receiverName?.isNotEmpty ?? false)
          ? widget.existingAddress!.receiverName
          : defaultName,
    );
    _phoneController = TextEditingController(
      text: (widget.existingAddress?.phone?.isNotEmpty ?? false)
          ? widget.existingAddress!.phone
          : defaultMobile,
    );
    _selectedType = widget.existingAddress?.type ?? 'Home';

    if (widget.existingAddress != null &&
        widget.existingAddress!.lat != 0.0 &&
        widget.existingAddress!.lon != 0.0) {
      _currentLocation = LatLng(
        widget.existingAddress!.lat,
        widget.existingAddress!.lon,
      );
      _fetchAddressFromLatLng(_currentLocation);
    } else if (widget.autoFetchLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCurrentLocation();
      });
    } else {
      _fetchAddressFromLatLng(_currentLocation);
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);
      _mapController.move(latLng, 16);
      setState(() {
        _currentLocation = latLng;
      });

      _fetchAddressFromLatLng(latLng);
    } catch (e) {
      debugPrint("Error fetching location: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _fetchAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressText = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
        ].where((e) => e != null).join(', ');

        setState(() {
          _fetchedAddress = addressText;
        });
      }
    } catch (e) {
      debugPrint("Error reverse geocoding: $e");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressDetailsController.dispose();
    _receiverNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final title = _selectedType;

      String combinedAddress = _addressDetailsController.text.trim();
      if (_fetchedAddress.isNotEmpty &&
          !combinedAddress.contains(_fetchedAddress)) {
        if (combinedAddress.isNotEmpty) {
          combinedAddress += ", ";
        }
        combinedAddress += _fetchedAddress;
      }

      final subtitle = combinedAddress;
      final receiverName = _receiverNameController.text.trim();
      final phone = _phoneController.text.trim();

      final updatedAddress = AddressModel(
        id: widget.existingAddress?.id ?? const Uuid().v4(),
        title: title,
        subtitle: subtitle,
        lat: _currentLocation.latitude,
        lon: _currentLocation.longitude,
        type: _selectedType,
        receiverName: receiverName.isEmpty ? null : receiverName,
        phone: phone.isEmpty ? null : phone,
      );

      final addresses = List<AddressModel>.from(savedAddressesNotifier.value);
      if (widget.existingAddress != null) {
        final index = addresses.indexWhere(
          (a) => a.id == widget.existingAddress!.id,
        );
        if (index != -1) {
          addresses[index] = updatedAddress;
        }
      } else {
        addresses.add(updatedAddress);
      }

      savedAddressesNotifier.value = addresses;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () async {
            final AddressModel? selected = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LocationScreen()),
            );
            if (selected != null && selected.lat != 0.0) {
              final latLng = LatLng(selected.lat, selected.lon);
              setState(() {
                _currentLocation = latLng;
              });
              _mapController.move(latLng, 16);
              _fetchAddressFromLatLng(latLng);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search for area, street name...',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map Background
          Positioned(
            top: MediaQuery.of(context).size.height * -0.2,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFFE5E3DF),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 15.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          setState(() {
                            _currentLocation = position.center;
                          });

                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 800),
                            () {
                              if (mounted) {
                                _fetchAddressFromLatLng(position.center);
                              }
                            },
                          );
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.flutter_application_1',
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet Content
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _sheetPosition = notification.extent;
              });
              return true;
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.45,
              maxChildSize: 0.8,
              snap: true,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            'Delivery details',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.existingAddress?.subtitle ??
                                        (_fetchedAddress.isNotEmpty
                                            ? _fetchedAddress
                                            : 'Fetching address...'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressDetailsController,
                            decoration: InputDecoration(
                              hintText: 'Address details*',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'E.g. Floor, Flat no., Tower',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 24),
                          Text(
                            'Receiver details for this address',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_outlined,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          controller: _receiverNameController,
                                          decoration: const InputDecoration(
                                            hintText: 'Name',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ', ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            hintText: 'Phone Number',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          Text(
                            'Save address as',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: ['Home', 'Work', 'Other'].map((type) {
                              final isSelected = _selectedType == type;
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selectedType = type),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green.shade50
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          type == 'Home'
                                              ? Icons.home_outlined
                                              : type == 'Work'
                                              ? Icons.work_outline
                                              : Icons.location_on_outlined,
                                          size: 16,
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.black87,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          type,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.black87,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                          Text(
                            'Door/building image (optional)',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.none,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add an image',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This helps our delivery partners find\nyour exact location faster',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 100,
                          ), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // "Use current location" button that floats directly above the bottom sheet
          Positioned(
            bottom: MediaQuery.of(context).size.height * _sheetPosition + 16,
            right: 16,
            child: GestureDetector(
              onTap: _fetchCurrentLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.green,
                        ),
                      )
                    else
                      const Icon(
                        Icons.my_location,
                        color: Colors.green,
                        size: 18,
                      ),
                    const SizedBox(width: 8),
                    const Text(
                      'Use current location',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
