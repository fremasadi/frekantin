import 'dart:async';
import 'package:flutter/material.dart';

class AutoSlidePageView extends StatefulWidget {
  final List<dynamic> images;
  final String imageUrl;

  const AutoSlidePageView({
    super.key,
    required this.images,
    required this.imageUrl,
  });

  @override
  State<AutoSlidePageView> createState() => _AutoSlidePageViewState();
}

class _AutoSlidePageViewState extends State<AutoSlidePageView> {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        final image = widget.images[index];
        return Image.network(
          '${widget.imageUrl}/storage/${image['image']}',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill,
        );
      },
    );
  }
}
