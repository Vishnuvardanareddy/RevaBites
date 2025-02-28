import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva_bites/utils/constants.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              'No orders yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
