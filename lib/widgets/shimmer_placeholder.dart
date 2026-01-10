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
      baseColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      period: const Duration(milliseconds: 1500),
      direction: ShimmerDirection.ltr,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
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
      elevation: 3,
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
                horizontal: isWideScreen ? 16.0 : 14.0,
                vertical: isWideScreen ? 12.0 : 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer - múltiples líneas para simular título
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerPlaceholder(
                          width: double.infinity,
                          height: 15,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 8),
                        ShimmerPlaceholder(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 15,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date shimmer con icono
                  Row(
                    children: [
                      ShimmerPlaceholder(
                        width: 14,
                        height: 14,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(width: 4),
                      ShimmerPlaceholder(
                        width: 90,
                        height: 13,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Action buttons shimmer (matches PostActions con divider)
          Container(
            padding: EdgeInsets.fromLTRB(
              isWideScreen ? 16.0 : 12.0,
              8,
              isWideScreen ? 16.0 : 12.0,
              isWideScreen ? 16.0 : 12.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShimmerPlaceholder(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 8),
                ShimmerPlaceholder(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
