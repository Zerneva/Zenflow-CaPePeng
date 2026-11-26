import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeOutController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _fadeOutController.forward().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (_, a, b) => widget.nextScreen,
                transitionDuration: AppTheme.medium,
                transitionsBuilder: (c, animation, d, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                    child: child,
                  );
                },
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _fadeOutController]),
        builder: (context, _) {
          return Opacity(
            opacity: _fadeOut.value,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusXl,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icon/icon1.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Animated title
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Text(
                        'ZENFLOW',
                        style: AppTheme.displayMedium(
                          context,
                        ).copyWith(color: Colors.white, letterSpacing: 8),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Animated subtitle
                  Opacity(
                    opacity: _subtitleOpacity.value,
                    child: Text(
                      'M I N I M A L I S T   F I N A N C E',
                      style: AppTheme.labelSmall(
                        context,
                      ).copyWith(color: Colors.white38, letterSpacing: 3),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
