import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'photo_viewer.dart';

class PhotoThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;
  const PhotoThumbnail({super.key, required this.imageUrl, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoViewer(imageUrl: imageUrl))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(width: size, height: size, color: Colors.grey.shade200),
          errorWidget: (_, __, ___) => Container(width: size, height: size, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 20)),
        ),
      ),
    );
  }
}
