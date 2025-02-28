import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reva_bites/utils/constants.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: AppDecorations.searchBar,
      child: TextField(
        onChanged: onSearch,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: 'Search for restaurants, cuisines, dishes...',
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingMedium,
          ),
        ),
      ),
    );
  }
}
