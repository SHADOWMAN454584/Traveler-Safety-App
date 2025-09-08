import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import 'tourist_portal_screen.dart';
import 'dashboard_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const TouristPortalScreen(),
    const DashboardScreen(),
    const AboutScreen(),
  ];

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.mediumGray,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Tourist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outlined),
              activeIcon: Icon(Icons.info),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            GradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.largeSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.largeSpacing),

                      // Welcome Text
                      FadeInDown(
                        child: Text(
                          'Welcome to',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 18,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      // App Title
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          AppConstants.appName,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      // Tagline
                      FadeInDown(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.extraLargeSpacing),

                      // Quick Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: FadeInLeft(
                              delay: const Duration(milliseconds: 600),
                              child: _buildQuickActionButton(
                                context,
                                icon: Icons.badge_outlined,
                                title: 'Get Digital ID',
                                subtitle: 'Secure Identity',
                                onTap: () {
                                  // Navigate to tourist portal for digital ID
                                  final homeState = context
                                      .findAncestorStateOfType<
                                        _HomeScreenState
                                      >();
                                  if (homeState != null) {
                                    homeState._updateIndex(1);
                                  }
                                },
                                isWhiteButton: true,
                              ),
                            ),
                          ),

                          const SizedBox(width: AppConstants.mediumSpacing),

                          Expanded(
                            child: FadeInRight(
                              delay: const Duration(milliseconds: 800),
                              child: _buildQuickActionButton(
                                context,
                                icon: Icons.emergency,
                                title: 'Emergency',
                                subtitle: 'Quick Help',
                                onTap: () {
                                  _showEmergencyDialog(context);
                                },
                                isWhiteButton: false,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.largeSpacing),
                    ],
                  ),
                ),
              ),
            ),

            // Key Features Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Text(
                      'Key Features',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Features Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: AppConstants.mediumSpacing,
                    mainAxisSpacing: AppConstants.mediumSpacing,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.security,
                        title: 'Digital ID',
                        description: 'Secure blockchain-based identification',
                        color: AppColors.primaryBlue,
                        delay: 1200,
                      ),
                      _buildFeatureCard(
                        icon: Icons.notifications_active,
                        title: 'Safety Alerts',
                        description: 'Real-time geofence monitoring',
                        color: AppColors.primaryPurple,
                        delay: 1400,
                      ),
                      _buildFeatureCard(
                        icon: Icons.location_on,
                        title: 'GPS Tracking',
                        description: 'Live location monitoring',
                        color: AppColors.safeGreen,
                        delay: 1600,
                      ),
                      _buildFeatureCard(
                        icon: Icons.dashboard,
                        title: 'Dashboard',
                        description: 'Authority monitoring portal',
                        color: AppColors.warningOrange,
                        delay: 1800,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Statistics Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 2000),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.largeSpacing),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.lightBlue, AppColors.lightPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.largeRadius,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'App Statistics',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.mediumSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('1,234', 'Active Tourists'),
                              _buildStatItem('567', 'Safety Alerts'),
                              _buildStatItem('89%', 'Safety Score'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.largeSpacing),

                  // Logout Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 2200),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.dangerRed,
                            side: const BorderSide(color: AppColors.dangerRed),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.mediumSpacing,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isWhiteButton,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        decoration: BoxDecoration(
          color: isWhiteButton
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          border: isWhiteButton
              ? null
              : Border.all(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isWhiteButton ? AppColors.primaryBlue : AppColors.white,
              size: 32,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isWhiteButton ? AppColors.primaryBlue : AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isWhiteButton
                    ? AppColors.mediumGray
                    : AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.smallSpacing),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              ),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(height: AppConstants.smallSpacing),

            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.smallSpacing / 2),

            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert'),
        content: const Text(
          'Are you sure you want to send an emergency alert? This will notify authorities and your emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency alert sent successfully!'),
                  backgroundColor: AppColors.safeGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to auth screen
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth',
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
