import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../services/location_service.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final MapController _mapController = MapController();
  List<Hospital> _hospitals = [];
  bool _isLoading = true;
  String? _error;
  Hospital? _selectedHospital;
  AppMapType _mapType = AppMapType.standard;
  bool _locationFetched = false;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final position = await LocationService.instance.getCurrentPosition();
      
      LatLng currentLatLng;
      if (position != null) {
        currentLatLng = LatLng(position.latitude, position.longitude);
        _currentLocation = currentLatLng;
        _locationFetched = true;
      } else {
        currentLatLng = const LatLng(37.7749, -122.4194);
      }
      
      final hospitals = await LocationService.instance.getNearbyHospitals(
        latitude: currentLatLng.latitude,
        longitude: currentLatLng.longitude,
      );
      
      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });

      _mapController.move(currentLatLng, 13.0);
    } catch (e) {
      setState(() { 
        _error = e.toString(); 
        _isLoading = false; 
      });
    }
  }

  String _getTileUrl() {
    switch (_mapType) {
      case AppMapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case AppMapType.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case AppMapType.standard:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  void _goToCurrentLocation() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ]))
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation ?? const LatLng(37.7749, -122.4194),
                        initialZoom: 13.0,
                        onTap: (_, __) => setState(() => _selectedHospital = null),
                      ),
                      children: [
                        TileLayer(urlTemplate: _getTileUrl(), userAgentPackageName: 'com.example.vaxguard'),
                        MarkerLayer(
                          markers: [
                            if (_locationFetched && _currentLocation != null)
                              Marker(
                                point: _currentLocation!,
                                width: 50, height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary, shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: AppTheme.shadowMd,
                                  ),
                                  child: const Icon(Icons.my_location, color: Colors.white, size: 24),
                                ),
                              ),
                            ..._hospitals.map((hospital) => Marker(
                                  point: LatLng(hospital.latitude, hospital.longitude),
                                  width: 50, height: 50,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedHospital = hospital),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: hospital.isEmergency ? AppTheme.danger : AppTheme.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedHospital?.id == hospital.id ? Colors.amber : Colors.white,
                                          width: _selectedHospital?.id == hospital.id ? 3 : 2,
                                        ),
                                        boxShadow: AppTheme.shadowMd,
                                      ),
                                      child: Icon(
                                        Icons.local_hospital, color: Colors.white,
                                        size: _selectedHospital?.id == hospital.id ? 26 : 22,
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 10,
                      left: 16, right: 16,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                'Find Hospital',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            PopupMenuButton<AppMapType>(
                              icon: const Icon(Icons.layers_rounded),
                              onSelected: (type) => setState(() => _mapType = type),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: AppMapType.standard, child: Text('Standard')),
                                const PopupMenuItem(value: AppMapType.satellite, child: Text('Satellite')),
                                const PopupMenuItem(value: AppMapType.terrain, child: Text('Terrain')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16, bottom: _selectedHospital != null ? 180 : 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'location',
                            onPressed: _goToCurrentLocation,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.my_location, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton(
                            heroTag: 'refresh',
                            onPressed: _loadData,
                            backgroundColor: AppTheme.primary,
                            child: const Icon(Icons.refresh, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedHospital != null) _buildHospitalSheet(),
                  ],
                ),
    );
  }

  Widget _buildHospitalSheet() {
    final hospital = _selectedHospital!;
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: hospital.isEmergency ? AppTheme.dangerLight : AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: hospital.isEmergency ? AppTheme.danger : AppTheme.secondary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 2),
                      const SizedBox(height: 4),
                      Text(hospital.type, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (hospital.distanceKm != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  LocationService.instance.formatDistance(hospital.distanceKm),
                  style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callHospital(hospital.phone),
                    icon: const Icon(Icons.phone_rounded),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _getDirections(hospital),
                    icon: const Icon(Icons.directions_car_rounded),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _getDirections(Hospital hospital) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}&travelmode=driving');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

enum AppMapType { standard, satellite, terrain }