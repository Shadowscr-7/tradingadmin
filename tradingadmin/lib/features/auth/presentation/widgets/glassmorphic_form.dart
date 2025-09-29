import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassmorphicForm extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<CustomFormField> fields;
  final String primaryButtonText;
  final VoidCallback onPrimaryAction;
  final bool isLoading;
  final String? errorMessage;
  final String? footerText;
  final String? footerLinkText;
  final VoidCallback? onFooterLinkTap;

  const GlassmorphicForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.primaryButtonText,
    required this.onPrimaryAction,
    this.isLoading = false,
    this.errorMessage,
    this.footerText,
    this.footerLinkText,
    this.onFooterLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: _calculateHeight(),
        borderRadius: 24,
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
        blur: 15,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Título y subtítulo
              _buildHeader(),

              // Campos del formulario
              ...fields.asMap().entries.map((entry) {
                int index = entry.key;
                CustomFormField field = entry.value;
                return Animate(
                  effects: [
                    FadeEffect(delay: (600 + index * 100).ms),
                    SlideEffect(
                      begin: Offset(index.isEven ? -0.3 : 0.3, 0),
                      delay: (600 + index * 100).ms,
                    ),
                  ],
                  child: _buildTextField(field),
                );
              }).toList(),

              // Botón principal
              Animate(
                effects: [
                  FadeEffect(delay: (800 + fields.length * 100).ms),
                  ScaleEffect(
                    begin: const Offset(0.8, 0.8),
                    delay: (800 + fields.length * 100).ms,
                  ),
                ],
                child: _buildPrimaryButton(),
              ),

              // Mensaje de error
              if (errorMessage != null)
                Animate(
                  effects: [FadeEffect(), ShakeEffect()],
                  child: _buildErrorMessage(),
                ),

              // Footer con enlace
              if (footerText != null && footerLinkText != null) _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        SlideEffect(begin: const Offset(0, -0.3), delay: 400.ms),
      ],
      child: Column(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [const Color(0xFF9C27B0), const Color(0xFF00E5FF)],
                ).createShader(bounds),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(CustomFormField field) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: field.controller,
        obscureText: field.obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        decoration: InputDecoration(
          labelText: field.label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF9C27B0), const Color(0xFF00E5FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(field.icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF00E5FF).withOpacity(0.5),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9C27B0),
            const Color(0xFF673AB7),
            const Color(0xFF3F51B5),
            const Color(0xFF00BCD4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPrimaryAction,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Center(
              child:
                  isLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        primaryButtonText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: onFooterLinkTap,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$footerText ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: footerLinkText!,
              style: TextStyle(
                color: const Color(0xFF00E5FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF00E5FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateHeight() {
    double baseHeight = 200; // Header + padding
    double fieldHeight = fields.length * 80; // Each field
    double buttonHeight = 80; // Button + margin
    double errorHeight = errorMessage != null ? 60 : 0;
    double footerHeight =
        (footerText != null && footerLinkText != null) ? 60 : 0;

    return baseHeight + fieldHeight + buttonHeight + errorHeight + footerHeight;
  }
}

class CustomFormField {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  CustomFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });
}
