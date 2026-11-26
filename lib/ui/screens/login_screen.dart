import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  void _showError(String errorMsg) {
    if (errorMsg.contains('] ')) {
      errorMsg = errorMsg.split('] ').last;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMsg,
          style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _submitGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/icon1.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'ZENFLOW',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'M I N I M A L I S T   F I N A N C E',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),
              FadeSlideIn(
                delay: const Duration(milliseconds: 450),
                child: Center(
                  child: Text(
                    'SELAMAT DATANG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48),
              FadeSlideIn(
                delay: const Duration(milliseconds: 600),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : AnimatedPressable(
                        onTap: _submitGoogle,
                        child: Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, size: 36, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'LANJUTKAN DENGAN GOOGLE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
