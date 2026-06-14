import 'package:flutter/material.dart';

import '../models/home_models.dart';

class FeatureBanner extends StatelessWidget {
  const FeatureBanner({super.key, required this.data, this.onTap});

  final HomeFeatureCardData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 476 / 184,
            child: Image.asset(
              data.imagePath,
              package: data.packageName,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
