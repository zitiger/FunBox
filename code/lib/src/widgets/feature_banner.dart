import 'package:flutter/material.dart';

import '../models/home_models.dart';

class FeatureBanner extends StatelessWidget {
  const FeatureBanner({super.key, required this.data});

  final HomeFeatureCardData data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 476 / 184,
        child: Image.asset(
          data.imagePath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
