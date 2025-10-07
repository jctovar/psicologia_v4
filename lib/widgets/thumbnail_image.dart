import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:suayed/utils/app_constants.dart';

class ThumbnailImage extends StatelessWidget {
  final String imageUrl;

  const ThumbnailImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(Constants.placeholderImg),
      imageUrl: imageUrl,
      alignment: Alignment.center,
      fit: BoxFit.fill,
      errorWidget: (context, url, error) =>
          Image.asset(Constants.placeholderImg),
    );
  }
}
