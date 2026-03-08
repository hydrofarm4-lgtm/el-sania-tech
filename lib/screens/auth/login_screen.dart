import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum AuthMode { login, register }

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  late AnimationController _hoverAnimController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  final String _bgImageUrl =
      'assets/images/568712db29335598b400ef4651bc962f.jpg';

  @override
  void initState() {
    super.initState();
    _hoverAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _hoverAnimController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  void _handleSubmit() async {
    final localizations = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = localizations.localeName == 'ar'
            ? 'يرجى إدخال البريد الإلكتروني وكلمة المرور'
            : 'Please enter email and password';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = localizations.invalidEmail;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final authService = context.read<AuthService>();

    // Attempt Login
    bool success = await authService.login(email, password);

    // If login fails, try registering the user
    if (!success) {
      success = await authService.register(email, password);

      if (!success && mounted) {
        // If both fail, show an error (e.g. wrong password for existing user)
        setState(() {
          _errorMessage = localizations.invalidCredentials;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;
    final localizations = AppLocalizations.of(context)!;
    final interStyle = GoogleFonts.inter(color: Colors.white);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: localizations.language,
            onSelected: (Locale locale) {
              context.read<AppLanguageProvider>().changeLanguage(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Text(localizations.english, style: GoogleFonts.inter()),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('ar'),
                child: Text(localizations.arabic, style: GoogleFonts.inter()),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('fr'),
                child: Text(localizations.french, style: GoogleFonts.inter()),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_bgImageUrl, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: GlassCard(
                  blur: 15.0,
                  opacity: 0.15,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 40.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.agriculture,
                        color: AppTheme.primaryGreen,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.appTitle,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.localeName == 'ar'
                            ? 'أدخل بياناتك للمتابعة أو إنشاء حساب جديد'
                            : 'Enter your credentials to continue or register',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        style: interStyle,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          localizations.email,
                          Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: interStyle,
                        decoration: _inputDecoration(
                          localizations.password,
                          Icons.lock_outline,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildSubmitButton(isLoading, localizations),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppTheme.primaryGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildSubmitButton(bool isLoading, AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoading ? null : _handleSubmit,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  localizations.localeName == 'ar' ? 'دخـول' : 'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
