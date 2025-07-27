import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';

class BannerWidget extends StatefulWidget {
  final List<String> bannerImages;
  const BannerWidget({Key? key, required this.bannerImages}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll implementation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        autoScroll();
      }
    });
  }

  void autoScroll() {
    if (!mounted) return;

    Future.delayed(Duration(seconds: 3), () {
      if (_currentPage < widget.bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }

      autoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.logoBlueColor.withValues(alpha: 0.3),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.bannerImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.network(
                        widget.bannerImages[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: AppColors.logoBlueColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget.bannerImages.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 20,
                    height: 2,
                    color:
                        i == _currentPage
                            ? AppColors.logoBlueColor
                            : Colors.black12,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
