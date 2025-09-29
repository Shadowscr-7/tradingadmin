import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/glassmorphic_background.dart';
import '../widgets/glassmorphic_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Validaciones
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'El nombre es requerido';
        _loading = false;
      });
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _error = 'El email es requerido';
        _loading = false;
      });
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() {
        _error = 'Email no válido';
        _loading = false;
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _error = 'La contraseña debe tener al menos 6 caracteres';
        _loading = false;
      });
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _error = 'Las contraseñas no coinciden';
        _loading = false;
      });
      return;
    }

    // Simular registro
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _loading = false);

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Cuenta creada exitosamente!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Volver al login
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBackground(
      child: Column(
        children: [
          // Botón de regreso
          Align(
            alignment: Alignment.topLeft,
            child: Animate(
              effects: [
                FadeEffect(delay: 100.ms),
                SlideEffect(begin: const Offset(-0.5, 0), delay: 100.ms),
              ],
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                  onPressed: () => context.go('/login'),
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Formulario principal
          GlassmorphicForm(
            title: 'Crear Cuenta',
            subtitle: 'Únete a FluxTrader y comienza tu experiencia de trading',
            fields: [
              CustomFormField(
                controller: _nameController,
                label: 'Nombre Completo',
                icon: Icons.person_rounded,
              ),
              CustomFormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_rounded,
              ),
              CustomFormField(
                controller: _passwordController,
                label: 'Contraseña',
                icon: Icons.lock_rounded,
                obscureText: true,
              ),
              CustomFormField(
                controller: _confirmController,
                label: 'Confirmar Contraseña',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
              ),
            ],
            primaryButtonText: 'CREAR CUENTA',
            onPrimaryAction: _register,
            isLoading: _loading,
            errorMessage: _error,
            footerText: '¿Ya tienes cuenta?',
            footerLinkText: 'Inicia Sesión',
            onFooterLinkTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
