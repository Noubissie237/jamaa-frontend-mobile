import 'package:flutter/material.dart';

class HorizontalGestureIndicator extends StatefulWidget {
  final String? text;
  final Color? iconColor;
  final Color? textColor;
  
  const HorizontalGestureIndicator({
    super.key,
    this.text,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  _HorizontalGestureIndicatorState createState() => _HorizontalGestureIndicatorState();
}

class _HorizontalGestureIndicatorState extends State<HorizontalGestureIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Conteneur avec les flèches animées
        Container(
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flèche gauche
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      color: widget.iconColor,
                      size: 30,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 20),
              
              // Icône centrale (main ou swipe)
              Icon(
                Icons.swipe,
                color: widget.iconColor,
                size: 24,
              ),
              
              const SizedBox(width: 20),
              
              // Flèche droite
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_animation.value, 0),
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color: widget.iconColor,
                      size: 30,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Texte explicatif
        Text(
          widget.text ?? "Glissez horizontalement",
          style: TextStyle(
            color: widget.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Version alternative avec des points animés
class DotGestureIndicator extends StatefulWidget {
  final String? text;
  final Color? dotColor;
  final Color? textColor;
  
  const DotGestureIndicator({
    super.key,
    this.text,
    this.dotColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  _DotGestureIndicatorState createState() => _DotGestureIndicatorState();
}

class _DotGestureIndicatorState extends State<DotGestureIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Points animés
        Container(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  double delay = index * 0.2;
                  double animationValue = (_animation.value - delay) % 1.0;
                  double scale = animationValue < 0.5 
                      ? 1.0 + (animationValue * 2) * 0.5
                      : 1.5 - ((animationValue - 0.5) * 2) * 0.5;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: Transform.scale(
                      scale: scale.clamp(0.8, 1.5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.dotColor!.withValues(
                            alpha: scale.clamp(0.3, 1.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Texte explicatif
        Text(
          widget.text ?? "Glissez pour voir plus",
          style: TextStyle(
            color: widget.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}