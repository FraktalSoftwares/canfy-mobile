import 'package:flutter/material.dart';

class SafeImageAsset extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? placeholderColor;
  final IconData? placeholderIcon;

  const SafeImageAsset({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.placeholderColor,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: placeholderColor ?? const Color(0xFFC3A6F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            placeholderIcon ?? Icons.image_not_supported,
            color: Colors.white70,
            size: (width != null && height != null)
                ? (width! < height! ? width! * 0.5 : height! * 0.5)
                : 48,
          ),
        );
      },
    );
  }
}
