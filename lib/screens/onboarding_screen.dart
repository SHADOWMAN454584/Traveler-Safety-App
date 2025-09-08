import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Digital ID',
      description:
          'Secure digital identification for tourists with blockchain technology and real-time verification.',
      icon: Icons.badge_outlined,
      color: AppColors.primaryBlue,
    ),
    OnboardingPage(
      title: 'Safety Alerts',
      description:
          'Real-time safety notifications and geofence alerts to keep you informed about your surroundings.',
      icon: Icons.notifications_active_outlined,
      color: AppColors.primaryPurple,
    ),
    OnboardingPage(
      title: 'Panic Button',
      description:
          'Instant emergency assistance with GPS location sharing to authorities and emergency contacts.',
      icon: Icons.emergency_outlined,
      color: AppColors.dangerRed,
    ),
    OnboardingPage(
      title: 'Dashboard Access',
      description:
          'Police and tourism authorities can monitor tourist safety and respond to incidents quickly.',
      icon: Icons.dashboard_outlined,
      color: AppColors.safeGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToHome,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),

              // Page Indicators
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: AnimatedContainer(
                            duration: AppConstants.shortAnimation,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.white
                                  : AppColors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.largeSpacing),

                    // Navigation Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.mediumSpacing,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          if (_currentPage > 0)
                            FadeInLeft(
                              child: GradientButton(
                                onPressed: _previousPage,
                                colors: [
                                  AppColors.white.withOpacity(0.2),
                                  AppColors.white.withOpacity(0.1),
                                ],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.mediumSpacing,
                                  vertical: AppConstants.smallSpacing,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back_ios,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Previous',
                                      style: AppTextStyles.buttonMedium,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 80),

                          // Next/Get Started Button
                          FadeInRight(
                            child: GradientButton(
                              onPressed: _nextPage,
                              colors: [
                                AppColors.white,
                                AppColors.white.withOpacity(0.9),
                              ],
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.largeSpacing,
                                vertical: AppConstants.smallSpacing,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentPage == _pages.length - 1
                                        ? 'Get Started'
                                        : 'Next',
                                    style: AppTextStyles.buttonMedium.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _currentPage == _pages.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward_ios,
                                    color: AppColors.primaryBlue,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largeSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          FadeInDown(
            delay: Duration(milliseconds: 200 * index),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(page.icon, size: 60, color: AppColors.white),
            ),
          ),

          const SizedBox(height: AppConstants.extraLargeSpacing),

          // Title
          FadeInUp(
            delay: Duration(milliseconds: 400 + (200 * index)),
            child: Text(
              page.title,
              style: AppTextStyles.heading1.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Description
          FadeInUp(
            delay: Duration(milliseconds: 600 + (200 * index)),
            child: Text(
              page.description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
