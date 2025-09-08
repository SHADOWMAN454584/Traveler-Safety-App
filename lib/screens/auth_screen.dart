import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/constants.dart';
import '../widgets/gradient_background.dart';
import '../services/api_services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.largeRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.largeSpacing),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo and Title
                          FadeInDown(
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.security,
                                  size: 80,
                                  color: const Color.fromARGB(
                                    255,
                                    220,
                                    220,
                                    223,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.mediumSpacing,
                                ),
                                Text(
                                  AppConstants.appName,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.smallSpacing,
                                ),
                                Text(
                                  _isSignIn ? 'Welcome Back' : 'Create Account',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Toggle between Sign In and Sign Up
                          FadeInLeft(
                            delay: const Duration(milliseconds: 400),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.mediumRadius,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isSignIn = true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppConstants.smallSpacing,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isSignIn
                                              ? AppColors.primaryBlue
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.mediumRadius,
                                          ),
                                        ),
                                        child: Text(
                                          'Sign In',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: _isSignIn
                                                    ? AppColors.white
                                                    : AppColors.mediumGray,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _isSignIn = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppConstants.smallSpacing,
                                        ),
                                        decoration: BoxDecoration(
                                          color: !_isSignIn
                                              ? AppColors.primaryBlue
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.mediumRadius,
                                          ),
                                        ),
                                        child: Text(
                                          'Sign Up',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: !_isSignIn
                                                    ? AppColors.white
                                                    : AppColors.mediumGray,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Form Fields
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(_isSignIn),
                              children: [
                                // Name field (only for sign up)
                                if (!_isSignIn) ...[
                                  FadeInRight(
                                    delay: const Duration(milliseconds: 600),
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        prefixIcon: Icon(Icons.person_outline),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.mediumRadius,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppConstants.mediumSpacing,
                                  ),
                                ],

                                // Email field
                                FadeInRight(
                                  delay: Duration(
                                    milliseconds: _isSignIn ? 600 : 800,
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.mediumRadius,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  height: AppConstants.mediumSpacing,
                                ),

                                // Password field
                                FadeInRight(
                                  delay: Duration(
                                    milliseconds: _isSignIn ? 800 : 1000,
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(Icons.lock_outline),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.mediumRadius,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                // Confirm Password field (only for sign up)
                                if (!_isSignIn) ...[
                                  const SizedBox(
                                    height: AppConstants.mediumSpacing,
                                  ),
                                  FadeInRight(
                                    delay: const Duration(milliseconds: 1200),
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm Password',
                                        prefixIcon: Icon(Icons.lock_outline),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.mediumRadius,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.largeSpacing),

                          // Submit Button
                          FadeInUp(
                            delay: Duration(
                              milliseconds: _isSignIn ? 1000 : 1400,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.mediumRadius,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: AppColors.white,
                                      )
                                    : Text(
                                        _isSignIn ? 'Sign In' : 'Sign Up',
                                        style: AppTextStyles.buttonLarge,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.mediumSpacing),

                          // Forgot Password (only for sign in)
                          if (_isSignIn)
                            FadeInUp(
                              delay: const Duration(milliseconds: 1200),
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _handleSubmit() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() => _isLoading = true);

  //     // Simulate API call
  //     await Future.delayed(const Duration(seconds: 2));

  //     setState(() => _isLoading = false);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             _isSignIn
  //                 ? 'Successfully signed in!'
  //                 : 'Account created successfully!',
  //           ),
  //           backgroundColor: AppColors.safeGreen,
  //         ),
  //       );

  //       // Navigate to home screen
  //       Navigator.of(context).pushReplacementNamed('/home');
  //     }
  //   }
  // }
  //   void _handleSubmit() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() => _isLoading = true);

  //     Map<String, dynamic> result;

  //     if (_isSignIn) {
  //       // Call backend Sign In
  //       result = await AuthService.signIn(
  //         _emailController.text.trim(),
  //         _passwordController.text.trim(),
  //       );
  //     } else {
  //       // Call backend Sign Up
  //       result = await AuthService.signUp(
  //         _emailController.text.trim(),
  //         _passwordController.text.trim(),
  //         _nameController.text.trim(),
  //       );
  //     }

  //     setState(() => _isLoading = false);

  //     if (mounted) {
  //       if (result['success']) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               _isSignIn ? '✅ Signed in successfully!' : '✅ Account created!',
  //             ),
  //             backgroundColor: AppColors.safeGreen,
  //           ),
  //         );

  //         // Navigate after login
  //         Navigator.of(context).pushReplacementNamed('/home');
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('❌ ${result['error']}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }
  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Map<String, dynamic> response;

        if (_isSignIn) {
          response = await ApiService.signin(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          response = await ApiService.signup(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }

        setState(() => _isLoading = false);

        if (mounted) {
          if (response["success"] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isSignIn ? '✅ Signed in successfully!' : '✅ Account created successfully!',
                ),
                backgroundColor: AppColors.safeGreen,
              ),
            );

            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${response["error"] ?? "Something went wrong"}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Network Error: Please check your connection"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
          'A password reset link will be sent to your email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent!'),
                  backgroundColor: AppColors.safeGreen,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
