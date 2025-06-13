import 'package:flutter/material.dart';

class CardCarousel extends StatefulWidget {
  final List<Widget> cards;
  final double height;
  final double viewportFraction;

  const CardCarousel({
    super.key,
    required this.cards,
    this.height = 220,
    required this.viewportFraction,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.cards.length,
        itemBuilder: (context, index) {
          return _buildTransformedCard(widget.cards[index], index);
        },
      ),
    );
  }

  Widget _buildTransformedCard(Widget card, int index) {
    // Calculer la différence entre la page actuelle et l'index de cette carte
    final double offset = _currentPage - index;
    
    // Calculer le facteur de scale (1.0 pour la carte centrale, plus petit pour les autres)
    final double scaleFactor = (1.0 - (offset.abs() * 0.1)).clamp(0.8, 1.0);
    
    // Calculer l'opacité (1.0 pour la carte centrale, plus transparent pour les autres)
    final double opacity = (1.0 - (offset.abs() * 0.3)).clamp(0.7, 1.0);
    
    return Transform.scale(
      scale: scaleFactor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Opacity(
          opacity: opacity,
          child: card,
        ),
      ),
    );
  }
}