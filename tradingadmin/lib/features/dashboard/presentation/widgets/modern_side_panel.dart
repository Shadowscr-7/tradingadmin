import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'side_panel_header.dart';
import 'side_panel_user_profile.dart';
import 'side_panel_menu.dart';
import 'side_panel_footer.dart';

class ModernSidePanel extends StatelessWidget {
  const ModernSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 320,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.background.withOpacity(0.95),
                theme.colorScheme.surface.withOpacity(0.9),
              ],
            ),
          ),
          child: ClipRRect(
            child: GlassmorphicContainer(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: 0,
              borderGradient: LinearGradient(
                colors: [Colors.transparent, Colors.transparent],
              ),
              blur: 25,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con logo y título
                      const SidePanelHeader(),

                      // Perfil de usuario
                      const SidePanelUserProfile(),

                      const SizedBox(height: 24),

                      // Menú principal - Usa Expanded y SingleChildScrollView
                      Expanded(
                        child: SingleChildScrollView(
                          child: const SidePanelMenu(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer con ayuda y logout
                      const SidePanelFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
