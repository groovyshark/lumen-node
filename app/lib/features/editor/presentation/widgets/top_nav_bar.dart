import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text("Lumen Node Editor", 
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900, 
              fontSize: 20,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            )
          ),
          const SizedBox(width: 40),
          _navLink("File"),
          _navLink("Edit"),
          _navLink("View", active: true),
          const Spacer(),
          _ghostButton("Export GLSL"),
          const SizedBox(width: 12),
          _gradientButton("Deploy Shader"),
        ],
      ),
    );
  }

  Widget _navLink(String text, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: active ? const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primary, width: 2))
        ) : null,
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(text, style: GoogleFonts.inter(
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        )),
      ),
    );
  }

  Widget _ghostButton(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: AppColors.surfaceContainerHigh,
        foregroundColor: AppColors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _gradientButton(String text) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDim]),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(text, style: GoogleFonts.inter(
          color: const Color(0xFF004A5D), 
          fontSize: 12, 
          fontWeight: FontWeight.bold
        )),
      ),
    );
  }
}