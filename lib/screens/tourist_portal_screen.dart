import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../services/api_services.dart';

class TouristPortalScreen extends StatefulWidget {
  const TouristPortalScreen({super.key});

  @override
  State<TouristPortalScreen> createState() => _TouristPortalScreenState();
}

class _TouristPortalScreenState extends State<TouristPortalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _safetyScore = 0;
  String _selectedLanguage = 'English';
  bool _isLoading = false;
  List<dynamic> _recentAlerts = [];

  // Form controllers
  final _nameController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _passportController = TextEditingController();
  final _phoneController = TextEditingController();
  final _destinationController = TextEditingController();
  final _hotelController = TextEditingController();
  final _emergencyContact1NameController = TextEditingController();
  final _emergencyContact1PhoneController = TextEditingController();
  final _emergencyContact2NameController = TextEditingController();
  final _emergencyContact2PhoneController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
    _loadSafetyScore();
    _loadRecentAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _aadhaarController.dispose();
    _passportController.dispose();
    _phoneController.dispose();
    _destinationController.dispose();
    _hotelController.dispose();
    _emergencyContact1NameController.dispose();
    _emergencyContact1PhoneController.dispose();
    _emergencyContact2NameController.dispose();
    _emergencyContact2PhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final response = await ApiService.getTouristProfile();
    if (response['success'] && response['data'] != null) {
      final data = response['data'];
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _aadhaarController.text = data['aadhaar'] ?? '';
        _passportController.text = data['passport'] ?? '';
        _destinationController.text = data['destination'] ?? '';
        _hotelController.text = data['hotel'] ?? '';

        if (data['checkIn'] != null) {
          _checkInDate = DateTime.parse(data['checkIn']);
        }
        if (data['checkOut'] != null) {
          _checkOutDate = DateTime.parse(data['checkOut']);
        }

        if (data['emergencyContacts'] != null &&
            data['emergencyContacts'].length > 0) {
          _emergencyContact1NameController.text =
              data['emergencyContacts'][0]['name'] ?? '';
          _emergencyContact1PhoneController.text =
              data['emergencyContacts'][0]['phone'] ?? '';

          if (data['emergencyContacts'].length > 1) {
            _emergencyContact2NameController.text =
                data['emergencyContacts'][1]['name'] ?? '';
            _emergencyContact2PhoneController.text =
                data['emergencyContacts'][1]['phone'] ?? '';
          }
        }
      });
    }
  }

  Future<void> _loadSafetyScore() async {
    final response = await ApiService.getSafetyScore();
    if (response['success'] && response['data'] != null) {
      setState(() {
        _safetyScore = response['data']['score'] ?? 85;
      });
    } else {
      setState(() {
        _safetyScore = 85; // Default score
      });
    }
  }

  Future<void> _loadRecentAlerts() async {
    final response = await ApiService.getSafetyAlerts();
    if (response['success'] && response['data'] != null) {
      setState(() {
        _recentAlerts = response['data']['alerts'] ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: GradientBackground(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInDown(
                            child: Text(
                              'Tourist Portal',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallSpacing),
                          FadeInDown(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Your safety companion',
                              style: AppTextStyles.tagline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.white,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
                tabs: const [
                  Tab(text: 'Profile', icon: Icon(Icons.person, size: 16)),
                  Tab(text: 'Safety', icon: Icon(Icons.security, size: 16)),
                  Tab(text: 'Map', icon: Icon(Icons.map, size: 16)),
                  Tab(text: 'Settings', icon: Icon(Icons.settings, size: 16)),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildSafetyTab(),
            _buildMapTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
      floatingActionButton: _buildPanicButton(),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            child: Text(
              'Digital ID Registration',
              style: AppTextStyles.heading2,
            ),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),

          // Personal Information Form
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Information', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Aadhaar Number',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Passport Number (Optional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Trip Information
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trip Itinerary', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Check-in Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () {
                              // Show date picker
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.mediumSpacing),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Check-out Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () {
                              // Show date picker
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Hotel/Accommodation',
                        prefixIcon: Icon(Icons.hotel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Emergency Contacts
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emergency Contacts', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Primary Contact Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Primary Contact Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Secondary Contact Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Secondary Contact Phone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.largeSpacing),

          // Register Button
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: () {
                  // Handle registration
                },
                child: Text(
                  'Register Digital ID',
                  style: AppTextStyles.buttonLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          // Safety Score Card
          FadeInUp(
            child: Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.mediumRadius,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Safety Score',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    CircularProgressIndicator(
                      value: _safetyScore / 100,
                      strokeWidth: 8,
                      backgroundColor: AppColors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    Text('$_safetyScore', style: AppTextStyles.safetyScore),

                    Text(
                      'You\'re in a Safe Zone',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Quick Actions
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: () {
                      // Call police
                    },
                    colors: [
                      AppColors.safeGreen,
                      AppColors.safeGreen.withOpacity(0.8),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_police, color: AppColors.white),
                        const SizedBox(height: 4),
                        Text('Police', style: AppTextStyles.buttonMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                Expanded(
                  child: GradientButton(
                    onPressed: () {
                      // Call ambulance
                    },
                    colors: [
                      AppColors.warningOrange,
                      AppColors.warningOrange.withOpacity(0.8),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 4),
                        Text('Ambulance', style: AppTextStyles.buttonMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallSpacing),
                Expanded(
                  child: GradientButton(
                    onPressed: () {
                      // Call tourist helpline
                    },
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.help, color: AppColors.white),
                        const SizedBox(height: 4),
                        Text('Helpline', style: AppTextStyles.buttonMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Recent Alerts
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Alerts', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    _buildAlertItem(
                      'Weather Alert',
                      'Heavy rain expected in your area',
                      Icons.cloud,
                      AppColors.warningOrange,
                    ),

                    _buildAlertItem(
                      'Traffic Update',
                      'Road closure on main highway',
                      Icons.traffic,
                      AppColors.dangerRed,
                    ),

                    _buildAlertItem(
                      'Safety Tip',
                      'Avoid isolated areas after 10 PM',
                      Icons.lightbulb,
                      AppColors.safeGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 64, color: AppColors.mediumGray),
          const SizedBox(height: AppConstants.mediumSpacing),
          Text('Interactive Map', style: AppTextStyles.heading3),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            'Google Maps integration will be displayed here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largeSpacing),
          ElevatedButton.icon(
            onPressed: () {
              // Open map functionality
            },
            icon: const Icon(Icons.location_on),
            label: const Text('View Current Location'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(child: Text('Settings', style: AppTextStyles.heading2)),
          const SizedBox(height: AppConstants.mediumSpacing),

          // Language Selector
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Language', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Select Language',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: AppConstants.supportedLanguages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang['name'],
                          child: Text(
                            '${lang['nativeName']} (${lang['name']})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Notification Settings
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: AppTextStyles.heading3),
                    const SizedBox(height: AppConstants.mediumSpacing),

                    SwitchListTile(
                      title: const Text('Emergency Alerts'),
                      subtitle: const Text('Receive critical safety alerts'),
                      value: true,
                      onChanged: (value) {},
                    ),

                    SwitchListTile(
                      title: const Text('Location Updates'),
                      subtitle: const Text(
                        'Share location with emergency contacts',
                      ),
                      value: true,
                      onChanged: (value) {},
                    ),

                    SwitchListTile(
                      title: const Text('Weather Alerts'),
                      subtitle: const Text(
                        'Get weather-related safety updates',
                      ),
                      value: false,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      padding: const EdgeInsets.all(AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanicButton() {
    return GestureDetector(
      onTap: () {
        _showPanicDialog();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: AppColors.panicGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.panicRed.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.emergency, color: AppColors.white, size: 36),
      ),
    );
  }

  void _showPanicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text(
          'Are you sure you want to send an emergency alert? This will notify authorities and your emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Send panic alert
              Navigator.pop(context);
              _sendPanicAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.panicRed,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _sendPanicAlert() {
    // Implement panic alert functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert sent successfully!'),
        backgroundColor: AppColors.safeGreen,
      ),
    );
  }
}
