import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class SettingsMenuCard extends StatelessWidget {
  final List<SettingsMenuItem> menuItems;

  const SettingsMenuCard({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: 600.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 600.ms),
      ],
      child: GlassmorphicContainer(
        width: double.infinity,
        height: menuItems.length * 64.0 + 32,
        borderRadius: 20,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: 1,
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        blur: 15,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children:
                menuItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  SettingsMenuItem item = entry.value;

                  return Animate(
                    effects: [
                      FadeEffect(delay: (800 + index * 100).ms),
                      SlideEffect(
                        begin: const Offset(-0.3, 0),
                        delay: (800 + index * 100).ms,
                      ),
                    ],
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [item.color, item.color.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle:
                            item.subtitle != null
                                ? Text(
                                  item.subtitle!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                )
                                : null,
                        trailing:
                            item.hasSwitch
                                ? Switch(
                                  value: item.switchValue ?? false,
                                  onChanged: item.onSwitchChanged,
                                  activeColor: const Color(0xFF00E5FF),
                                )
                                : Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 16,
                                ),
                        onTap: item.onTap,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class SettingsMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  SettingsMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
  });
}
