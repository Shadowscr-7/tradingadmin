import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ModernAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;

  const ModernAppBar({super.key, required this.onMenuPressed});

  @override
  State<ModernAppBar> createState() => _ModernAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(85);
}

class _ModernAppBarState extends State<ModernAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 75,
        borderRadius: 0,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: 0,
        borderGradient: LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
        blur: 25,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Menú hamburguesa al lado izquierdo
                _buildMenuButton(theme),
                const SizedBox(width: 16),
                // Logo FluxTrader sin animación
                Expanded(child: _buildStaticLogo(theme)),
                // Iconos de la derecha
                _buildNotificationButton(theme),
                const SizedBox(width: 8),
                _buildUserAvatar(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticLogo(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícono de onda
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFF00E5FF)],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.show_chart_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        // Texto FluxTrader sin animaciones
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Flux',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'Trader',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton(ThemeData theme) {
    return Animate(
      effects: [
        ScaleEffect(duration: Duration(milliseconds: 800)),
        ShimmerEffect(duration: Duration(milliseconds: 1500)),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                // Acción de notificaciones
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00E5FF),
                      theme.colorScheme.primary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ThemeData theme) {
    return Animate(
      effects: [
        ScaleEffect(duration: Duration(milliseconds: 600)),
        ShimmerEffect(duration: Duration(milliseconds: 2000)),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, const Color(0xFF00E5FF)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.transparent,
          child: Text(
            'FT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(ThemeData theme) {
    return Animate(
      effects: [RotateEffect(duration: Duration(milliseconds: 1000))],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
          onPressed: widget.onMenuPressed,
        ),
      ),
    );
  }
}
