import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsSection extends StatefulWidget {
  const ProfileSettingsSection({super.key});

  @override
  State<ProfileSettingsSection> createState() => _ProfileSettingsSectionState();
}

class _ProfileSettingsSectionState extends State<ProfileSettingsSection> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Animate(
      effects: [
        FadeEffect(delay: 300.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 300.ms),
      ],
      child: Column(
        children: [
          // Configuraciones
          Container(
            width: double.infinity,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 420,
              borderRadius: 20,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: 1,
              borderGradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              blur: 20,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuraciones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notificaciones
                    _buildSettingTile(
                      icon: Icons.notifications_rounded,
                      title: 'Notificaciones',
                      subtitle: 'Alertas y recordatorios',
                      color: const Color(0xFFFF9800),
                      hasSwitch: true,
                      switchValue: _notificationsEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Modo Oscuro
                    _buildSettingTile(
                      icon: Icons.dark_mode_rounded,
                      title: 'Modo Oscuro',
                      subtitle: 'Tema de la aplicación',
                      color: const Color(0xFF673AB7),
                      hasSwitch: true,
                      switchValue: _darkModeEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Autenticación Biométrica
                    _buildSettingTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'Autenticación Biométrica',
                      subtitle: 'Usar huella dactilar',
                      color: const Color(0xFF00BCD4),
                      hasSwitch: true,
                      switchValue: _biometricEnabled,
                      onSwitchChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Seguridad
                    _buildSettingTile(
                      icon: Icons.security_rounded,
                      title: 'Seguridad',
                      subtitle: 'Cambiar contraseña',
                      color: const Color(0xFFF44336),
                      hasSwitch: false,
                      onTap: () {
                        // Implementar cambio de contraseña
                      },
                    ),

                    const SizedBox(height: 16),

                    // Ayuda
                    _buildSettingTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Ayuda',
                      subtitle: 'Preguntas frecuentes',
                      color: const Color(0xFF4CAF50),
                      hasSwitch: false,
                      onTap: () {
                        // Implementar ayuda
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Botón de Cerrar Sesión
          Animate(
            effects: [
              FadeEffect(delay: 400.ms),
              SlideEffect(begin: const Offset(0, 0.3), delay: 400.ms),
            ],
            child: Container(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showLogoutDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.2),
                          Colors.red.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cerrar Sesión',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.red.shade300,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool hasSwitch,
    bool switchValue = false,
    VoidCallback? onTap,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasSwitch ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasSwitch)
                Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: color,
                  activeTrackColor: color.withOpacity(0.3),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '¿Cerrar Sesión?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
