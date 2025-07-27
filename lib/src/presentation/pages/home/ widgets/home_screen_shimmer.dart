import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenShimmer extends StatelessWidget {
  const HomeScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Search Bar shimmer
          shimmerContainer(height: 40, margin: EdgeInsets.symmetric(horizontal: 16)),

          const SizedBox(height: 10),
          // Banner shimmer
          shimmerContainer(height: 150, margin: EdgeInsets.symmetric(horizontal: 16)),

          const SizedBox(height: 20),
          // Category shimmer
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    shimmerCircle(size: 50),
                    const SizedBox(height: 5),
                    shimmerContainer(height: 10, width: 40),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          // Featured Products Grid shimmer
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerContainer(height: 100),
                const SizedBox(height: 5),
                shimmerContainer(height: 10, width: 60),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Recently Viewed shimmer title
          shimmerContainer(height: 20, width: 150, margin: EdgeInsets.symmetric(horizontal: 8)),

          const SizedBox(height: 10),
          // Recently Viewed Grid shimmer
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => shimmerProductCard(),
          ),
        ],
      ),
    );
  }

  // shimmer container for lines or rectangles
  Widget shimmerContainer({double height = 20, double width = double.infinity, EdgeInsets? margin}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // shimmer for circular icons
  Widget shimmerCircle({double size = 50}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // shimmer for product card
  Widget shimmerProductCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmerContainer(height: 120),
          const SizedBox(height: 8),
          shimmerContainer(height: 10, width: 100, margin: EdgeInsets.symmetric(horizontal: 8)),
          const SizedBox(height: 4),
          shimmerContainer(height: 14, width: 60, margin: EdgeInsets.symmetric(horizontal: 8)),
          const SizedBox(height: 2),
          shimmerContainer(height: 10, width: 80, margin: EdgeInsets.symmetric(horizontal: 8)),
        ],
      ),
    );
  }
}
