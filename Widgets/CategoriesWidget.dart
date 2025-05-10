import 'package:flutter/material.dart';

class CategoriesWidget extends StatefulWidget {
  @override
  _CategoriesWidgetState createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<CategoriesWidget> {
  final List<String> bannerImages = [
    "assets/images/banner.jpg",
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/buncha.jpg",
  ];

  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _autoSlide();
  }

  void _autoSlide() {
    Future.delayed(Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % bannerImages.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _autoSlide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Chiều cao của banner
      child: PageView.builder(
        controller: _pageController,
        itemCount: bannerImages.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset("assets/images/default.png", fit: BoxFit.cover);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
