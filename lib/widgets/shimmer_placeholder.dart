import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder widget for loading states
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Shimmer placeholder specifically for card images
class CardImageShimmer extends StatelessWidget {
  final double height;

  const CardImageShimmer({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return ShimmerPlaceholder(
      width: double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(10),
    );
  }
}

/// Shimmer placeholder for an entire post card
/// Matches the structure of PostCard for consistent GridView layout
class PostCardShimmer extends StatelessWidget {
  final bool isWideScreen;

  const PostCardShimmer({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image shimmer - flex 3 (matches PostCard)
          Expanded(
            flex: 3,
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Content area - flex 2 (matches PostCard)
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 16.0 : 12.0,
                vertical: isWideScreen ? 10.0 : 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder(
                          width: double.infinity,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        ShimmerPlaceholder(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date shimmer
                  ShimmerPlaceholder(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          // Action buttons shimmer (matches PostActions)
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, isWideScreen ? 16.0 : 14.0, isWideScreen ? 16.0 : 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShimmerPlaceholder(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(18),
                ),
                SizedBox(width: isWideScreen ? 8.0 : 4.0),
                ShimmerPlaceholder(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
