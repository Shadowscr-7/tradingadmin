import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/loading_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: 'demo@trading.com');
  final _passwordController = TextEditingController(text: 'demo1234');
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);
    final user = ref.read(authProvider);
    if (user != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoadingScreen(),
      );
      // Simula carga y cierra el dialog
      await Future.delayed(const Duration(milliseconds: 1200));
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      setState(() => _loading = false);
      context.go('/dashboard');
    } else {
      setState(() {
        _loading = false;
        _error = 'Credenciales incorrectas';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.surface,
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo FluxTrader mejorado
                  _buildFluxTraderLogo(theme),
                  const SizedBox(height: 60),

                  // Título Trading Admin mejorado
                  _buildTitle(theme),
                  const SizedBox(height: 50),

                  // Formulario glassmorphic
                  _buildLoginForm(theme),

                  // Información de usuario demo
                  const SizedBox(height: 30),
                  _buildDemoInfo(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFluxTraderLogo(ThemeData theme) {
    return Animate(
      effects: [
        FadeEffect(delay: 200.ms),
        ScaleEffect(delay: 200.ms, begin: const Offset(0.8, 0.8)),
      ],
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 60,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              blurRadius: 80,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Ícono de onda con gradiente
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, const Color(0xFF00E5FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            // Texto FluxTrader
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Flux',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 42,
                      letterSpacing: 1,
                    ),
                  ),
                  TextSpan(
                    text: 'Trader',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.w800,
                      fontSize: 42,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Animate(
      effects: [
        FadeEffect(delay: 400.ms),
        SlideEffect(begin: const Offset(0, -0.3), delay: 400.ms),
      ],
      child: Text(
        'Trading Admin',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 28,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 440,
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
              // Campo Email
              Animate(
                effects: [
                  FadeEffect(delay: 600.ms),
                  SlideEffect(begin: const Offset(-0.3, 0), delay: 600.ms),
                ],
                child: _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_rounded,
                  theme: theme,
                ),
              ),

              // Campo Password
              Animate(
                effects: [
                  FadeEffect(delay: 700.ms),
                  SlideEffect(begin: const Offset(0.3, 0), delay: 700.ms),
                ],
                child: _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  theme: theme,
                  obscureText: true,
                ),
              ),

              // Botón Login
              Animate(
                effects: [
                  FadeEffect(delay: 800.ms),
                  ScaleEffect(begin: const Offset(0.8, 0.8), delay: 800.ms),
                ],
                child: _buildLoginButton(theme),
              ),

              // Error message
              if (_error != null)
                Animate(
                  effects: [FadeEffect(), ShakeEffect()],
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              // Link de registro
              TextButton(
                onPressed: () => context.push('/register'),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: 'Regístrate',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.8),
                      const Color(0xFF00E5FF).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              labelStyle: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              floatingLabelStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.6),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme) {
    if (_loading) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.7),
              const Color(0xFF00E5FF).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, const Color(0xFF00E5FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _login,
          child: const Center(
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoInfo(ThemeData theme) {
    return Animate(
      effects: [
        FadeEffect(delay: 1000.ms),
        SlideEffect(begin: const Offset(0, 0.3), delay: 1000.ms),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Usuario demo:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'demo@trading.com / demo1234',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
