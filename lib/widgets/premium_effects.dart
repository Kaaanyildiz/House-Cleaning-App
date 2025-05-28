import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const GlassmorphismContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.color,
    this.blur = 15,
    this.padding,
    this.height,
    this.width,
  }) : super(key: key);
  
  // Karanlık modu kontrol eden yardımcı metod
  bool _isDarkMode(BuildContext context) {
    // Temadan kontrol etmek daha güvenli
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode(context);
    
    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        // Karanlık modda daha koyu bir camlaşma efekti ve kontrast
        color: color ?? (isDark 
            ? Colors.grey[900]!.withOpacity(0.5)  
            : Colors.white.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          // Karanlık modda daha belirgin bir kenar rengi
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
            blurRadius: isDark ? 10 : 20,
            offset: const Offset(0, 5),
            spreadRadius: isDark ? -2 : -4,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeumorphismContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const NeumorphismContainer({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.backgroundColor,
    this.padding,
    this.onTap,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<NeumorphismContainer> createState() => _NeumorphismContainerState();
}

class _NeumorphismContainerState extends State<NeumorphismContainer>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Karanlık modu kontrol eden yardımcı metod
  bool _isDarkMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              width: widget.width,
              padding: widget.padding,              decoration: BoxDecoration(
                // Karanlık modda daha uyumlu bir arkaplan rengi
                color: widget.backgroundColor ?? (_isDarkMode(context) 
                  ? const Color(0xFF2D3748) // Karanlık mod için koyu gri
                  : const Color(0xFFE2E8F0)), // Açık mod için açık gri
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isDarkMode(context)
                  ? [
                      // Karanlık mod için daha az belirgin gölgeler
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        offset: Offset(_isPressed ? 2 : -3, _isPressed ? 2 : -3),
                        blurRadius: _isPressed ? 3 : 6,
                        spreadRadius: _isPressed ? -1 : -1,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        offset: Offset(_isPressed ? -2 : 3, _isPressed ? -2 : 3),
                        blurRadius: _isPressed ? 3 : 6,
                        spreadRadius: _isPressed ? -1 : -2,
                      ),
                    ]
                  : [
                      // Açık mod için normal gölgeler
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(_isPressed ? 2 : -6, _isPressed ? 2 : -6),
                        blurRadius: _isPressed ? 4 : 12,
                        spreadRadius: _isPressed ? -2 : 0,
                      ),
                      BoxShadow(
                        color: const Color(0xFFBECBE8).withOpacity(0.4),
                        offset: Offset(_isPressed ? -2 : 6, _isPressed ? -2 : 6),                        blurRadius: _isPressed ? 4 : 12,
                        spreadRadius: _isPressed ? -2 : 0,
                      ),
                    ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AnimatedGradientContainer({
    Key? key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Karanlık mod kontrolü
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors.map((color) => 
                isDark ? color.withOpacity(color.opacity * 0.7) : color
              ).toList(),
              transform: GradientRotation(_animation.value * 2 * math.pi),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerEffect({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Karanlık mod kontrolü
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Karanlık modda farklı renkler kullan
    final baseCol = widget.baseColor ?? 
        (isDark ? const Color(0xFF303030) : const Color(0xFFE0E0E0));
    final highlightCol = widget.highlightColor ?? 
        (isDark ? const Color(0xFF505050) : const Color(0xFFF5F5F5));
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                baseCol,
                highlightCol,
                baseCol,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class FloatingActionButtonWithAnimation extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final String? tooltip;

  const FloatingActionButtonWithAnimation({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.tooltip,
  }) : super(key: key);

  @override
  State<FloatingActionButtonWithAnimation> createState() =>
      _FloatingActionButtonWithAnimationState();
}

class _FloatingActionButtonWithAnimationState
    extends State<FloatingActionButtonWithAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: FloatingActionButton.extended(
              onPressed: () {
                _scaleController.forward().then((_) {
                  _scaleController.reverse();
                });
                _rotationController.forward().then((_) {
                  _rotationController.reverse();
                });
                widget.onPressed();
              },
              backgroundColor: widget.backgroundColor,
              tooltip: widget.tooltip,
              icon: widget.child,
              label: const Text('Yeni Görev'),
              elevation: 12,
              highlightElevation: 16,
            ),
          ),
        );
      },
    );
  }
}
