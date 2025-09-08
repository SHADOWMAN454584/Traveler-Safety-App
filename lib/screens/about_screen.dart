import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            GradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.largeSpacing),
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.largeSpacing),

                      // App Logo
                      FadeInDown(
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
                          child: const Icon(
                            Icons.security,
                            size: 60,
                            color: AppColors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.largeSpacing),

                      // App Name and Version
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          AppConstants.appName,
                          style: AppTextStyles.heading1.copyWith(fontSize: 32),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      FadeInDown(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'Version 1.0.0',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.smallSpacing),

                      FadeInDown(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.tagline,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: AppConstants.largeSpacing),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Information
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: AppColors.primaryBlue,
                                ),
                                const SizedBox(
                                  width: AppConstants.smallSpacing,
                                ),
                                Text(
                                  'About the Project',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            Text(
                              'The Smart Tourist Safety Monitoring & Incident Response System is a comprehensive solution designed to enhance tourist safety through advanced technology integration.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            Text(
                              'Key Features:',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: AppConstants.smallSpacing),

                            _buildFeatureBullet(
                              'Digital ID with blockchain security',
                            ),
                            _buildFeatureBullet(
                              'Real-time GPS tracking and geofencing',
                            ),
                            _buildFeatureBullet(
                              'Emergency panic button with instant alerts',
                            ),
                            _buildFeatureBullet('AI-powered anomaly detection'),
                            _buildFeatureBullet(
                              'Multi-language support (10+ Indian languages)',
                            ),
                            _buildFeatureBullet(
                              'Police dashboard for monitoring and response',
                            ),
                            _buildFeatureBullet('Automated E-FIR generation'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.mediumSpacing),

                  // Government Partnership
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance,
                                  color: AppColors.safeGreen,
                                ),
                                const SizedBox(
                                  width: AppConstants.smallSpacing,
                                ),
                                Text(
                                  'Government Partnership',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildPartnershipCard(
                                    'Ministry of Tourism',
                                    'Government of India',
                                    Icons.flight_takeoff,
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.smallSpacing,
                                ),
                                Expanded(
                                  child: _buildPartnershipCard(
                                    'Ministry of Home Affairs',
                                    'Government of India',
                                    Icons.security,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.mediumSpacing),

                  // Emergency Contacts
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.emergency,
                                  color: AppColors.dangerRed,
                                ),
                                const SizedBox(
                                  width: AppConstants.smallSpacing,
                                ),
                                Text(
                                  'Emergency Helplines',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            _buildEmergencyContact(
                              'Police Emergency',
                              AppConstants.policeNumber,
                              Icons.local_police,
                              AppColors.primaryBlue,
                            ),

                            _buildEmergencyContact(
                              'Medical Emergency',
                              AppConstants.ambulanceNumber,
                              Icons.local_hospital,
                              AppColors.dangerRed,
                            ),

                            _buildEmergencyContact(
                              'Tourist Helpline',
                              AppConstants.touristHelpline,
                              Icons.help,
                              AppColors.safeGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.mediumSpacing),

                  // Contact Form
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.contact_mail,
                                  color: AppColors.primaryPurple,
                                ),
                                const SizedBox(
                                  width: AppConstants.smallSpacing,
                                ),
                                Text(
                                  'Contact Us',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Your Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                prefixIcon: Icon(Icons.subject),
                              ),
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Message',
                                prefixIcon: Icon(Icons.message),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 4,
                            ),

                            const SizedBox(height: AppConstants.largeSpacing),

                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onPressed: () {
                                  _submitContactForm(context);
                                },
                                child: Text(
                                  'Send Message',
                                  style: AppTextStyles.buttonLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.mediumSpacing),

                  // App Information
                  FadeInUp(
                    delay: const Duration(milliseconds: 1600),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConstants.mediumSpacing,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Technical Specifications',
                              style: AppTextStyles.heading3,
                            ),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            _buildTechSpec('Frontend', 'Flutter (Dart)'),
                            _buildTechSpec('Backend', 'Node.js + Express.js'),
                            _buildTechSpec('Database', 'MongoDB Atlas'),
                            _buildTechSpec('Security', 'Blockchain + JWT'),
                            _buildTechSpec('Maps', 'Google Maps API'),
                            _buildTechSpec(
                              'AI',
                              'Machine Learning Integration',
                            ),
                            _buildTechSpec('Notifications', 'Firebase FCM'),

                            const SizedBox(height: AppConstants.mediumSpacing),

                            Text(
                              '© 2025 Tourist Safety App. All rights reserved.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.mediumGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.smallSpacing),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildPartnershipCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallSpacing),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 32),
          const SizedBox(height: AppConstants.smallSpacing),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(
    String title,
    String number,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: AppConstants.mediumSpacing),

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
                Text(
                  number,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => _makePhoneCall(number),
            icon: Icon(Icons.phone, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTechSpec(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _submitContactForm(BuildContext context) {
    // Implement contact form submission
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Sent'),
        content: const Text(
          'Thank you for your message. We will get back to you soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
