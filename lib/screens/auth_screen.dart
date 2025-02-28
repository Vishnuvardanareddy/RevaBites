import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva_bites/utils/constants.dart';
import 'package:reva_bites/widgets/auth_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.matteBlack.withOpacity(0.1),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                'Welcome to\nReva Bites',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                'Your favorite food, delivered fast',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              const AuthForm(),
            ],
          ),
        ),
      ),
    );
  }
}
