import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatefulWidget {
  const Avatar({Key? key, required this.picturePath, required this.sizeAvatar}) : super(key: key);
  final String picturePath;
  final double sizeAvatar;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {

  @override
  void initState() {
    super.initState();
  }

  _loadImage(String picturePath) {
    String url = 'https://galadriel.ired.unam.mx/sup/assets/uploads/pictures/$picturePath';

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.sizeAvatar,
        width: widget.sizeAvatar,
        child: _picture(context, widget.picturePath)
    );
  }

  CircleAvatar _picture(context, picturePath) {
    return CircleAvatar(
      backgroundColor: const Color(0xffFDCF09),
      radius: widget.sizeAvatar,
      child: CachedNetworkImage(
        imageUrl: _loadImage(picturePath),
        imageBuilder: (context, imageProvider) =>
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
        errorWidget: (context, url, error) =>
        const Icon(Icons.person, color: Colors.blue, size: 42.0),
      ),
    );
  }
}