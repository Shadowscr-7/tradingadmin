import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/modern_app_bar.dart';
import '../../../dashboard/presentation/widgets/modern_side_panel.dart';
import '../widgets/profile_header_section.dart';
import '../widgets/profile_stats_section.dart';
import '../widgets/profile_settings_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            const Color(0xFF0f0f23),
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        drawer: const ModernSidePanel(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ModernAppBar(
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Header con información del perfil
                  const ProfileHeaderSection(),

                  const SizedBox(height: 24),

                  // Estadísticas del usuario
                  const ProfileStatsSection(),

                  const SizedBox(height: 24),

                  // Configuraciones y opciones
                  const ProfileSettingsSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
