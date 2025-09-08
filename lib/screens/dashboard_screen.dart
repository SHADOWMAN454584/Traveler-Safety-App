import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggedIn = false;
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoggedIn ? _buildDashboard() : _buildLoginScreen(),
    );
  }

  Widget _buildLoginScreen() {
    return GradientBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                FadeInDown(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 50,
                      color: AppColors.white,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Dashboard Login',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32),
                  ),
                ),

                const SizedBox(height: AppConstants.smallSpacing),

                FadeInDown(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Police & Tourism Authority Access',
                    style: AppTextStyles.tagline,
                  ),
                ),

                const SizedBox(height: AppConstants.extraLargeSpacing),

                // Login Form
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.largeSpacing),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.largeRadius,
                      ),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) => _username = value,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.mediumRadius,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.mediumRadius,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.mediumSpacing),

                        TextField(
                          onChanged: (value) => _password = value,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: AppColors.white.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.mediumRadius,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.white.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.mediumRadius,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.largeSpacing),

                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: _login,
                            colors: [
                              AppColors.white,
                              AppColors.white.withOpacity(0.9),
                            ],
                            child: Text(
                              'Login',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.mediumSpacing),

                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    'Secure login with JWT + Blockchain verification',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              setState(() {
                _isLoggedIn = false;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            FadeInUp(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.mediumSpacing,
                mainAxisSpacing: AppConstants.mediumSpacing,
                children: [
                  _buildStatCard(
                    'Active Tourists',
                    '1,247',
                    Icons.people,
                    AppColors.primaryBlue,
                  ),
                  _buildStatCard(
                    'Emergency Alerts',
                    '3',
                    Icons.emergency,
                    AppColors.dangerRed,
                  ),
                  _buildStatCard(
                    'Safe Zones',
                    '156',
                    Icons.shield,
                    AppColors.safeGreen,
                  ),
                  _buildStatCard(
                    'High Risk Areas',
                    '12',
                    Icons.warning,
                    AppColors.warningOrange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.largeSpacing),

            // Tourist Heatmap
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map, color: AppColors.primaryBlue),
                          const SizedBox(width: AppConstants.smallSpacing),
                          Text(
                            'Tourist Heatmap',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),

                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(
                            AppConstants.smallRadius,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 48,
                                color: AppColors.mediumGray,
                              ),
                              SizedBox(height: AppConstants.smallSpacing),
                              Text(
                                'Interactive Heatmap',
                                style: TextStyle(
                                  color: AppColors.mediumGray,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Google Maps with tourist clusters',
                                style: TextStyle(
                                  color: AppColors.mediumGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.mediumSpacing),

            // Active Alerts Table
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notification_important,
                            color: AppColors.dangerRed,
                          ),
                          const SizedBox(width: AppConstants.smallSpacing),
                          Text('Active Alerts', style: AppTextStyles.heading3),
                        ],
                      ),
                      const SizedBox(height: AppConstants.mediumSpacing),

                      _buildAlertItem(
                        'PANIC',
                        'Tourist ID: T12345',
                        'Location: Red Fort Area',
                        '2 min ago',
                        AppColors.dangerRed,
                        true,
                      ),

                      _buildAlertItem(
                        'GEOFENCE',
                        'Tourist ID: T67890',
                        'Location: Restricted Zone',
                        '5 min ago',
                        AppColors.warningOrange,
                        false,
                      ),

                      _buildAlertItem(
                        'ANOMALY',
                        'Tourist ID: T11111',
                        'Location: Unknown',
                        '10 min ago',
                        AppColors.primaryPurple,
                        false,
                      ),

                      const SizedBox(height: AppConstants.mediumSpacing),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // View all alerts
                          },
                          icon: const Icon(Icons.list),
                          label: const Text('View All Alerts'),
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
              delay: const Duration(milliseconds: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: AppTextStyles.heading3),
                      const SizedBox(height: AppConstants.mediumSpacing),

                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              onPressed: () {
                                // Generate E-FIR
                              },
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryPurple,
                              ],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.description,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Generate E-FIR',
                                    style: AppTextStyles.buttonMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: AppConstants.smallSpacing),

                          Expanded(
                            child: GradientButton(
                              onPressed: () {
                                // Digital ID Lookup
                              },
                              colors: [
                                AppColors.safeGreen,
                                AppColors.safeGreen.withOpacity(0.8),
                              ],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID Lookup',
                                    style: AppTextStyles.buttonMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: AppConstants.smallSpacing),

                          Expanded(
                            child: GradientButton(
                              onPressed: () {
                                // Send Broadcast Alert
                              },
                              colors: [
                                AppColors.warningOrange,
                                AppColors.warningOrange.withOpacity(0.8),
                              ],
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.campaign,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Broadcast',
                                    style: AppTextStyles.buttonMedium,
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(height: AppConstants.smallSpacing),

          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    String type,
    String touristId,
    String location,
    String time,
    Color color,
    bool isUrgent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      padding: const EdgeInsets.all(AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: AppConstants.smallSpacing),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallRadius,
                        ),
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(
                      time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  touristId,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),

                Text(
                  location,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              // View alert details
            },
            icon: Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ),
        ],
      ),
    );
  }

  void _login() {
    // Simple demo login - in real app, this would connect to backend
    if (_username.isNotEmpty && _password.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter username and password'),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }
}
