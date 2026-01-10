import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/widgets/shimmer_placeholder.dart';

class ThumbnailImage extends StatelessWidget {
  final String imageUrl;
  final double? memCacheWidth;
  final double? memCacheHeight;

  const ThumbnailImage({
    super.key,
    required this.imageUrl,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => const ShimmerPlaceholder(
        width: double.infinity,
        height: double.infinity,
      ),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.cover,
      memCacheWidth: memCacheWidth?.toInt(),
      memCacheHeight: memCacheHeight?.toInt(),
      errorWidget: (context, url, error) =>
          Image.asset(Constants.placeholderImg, fit: BoxFit.cover),
    );
  }
}