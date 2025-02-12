import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonVerticalCard extends StatelessWidget {
  const SkeletonVerticalCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant, // M3 surface variant color
      highlightColor: colorScheme.onSurfaceVariant.withOpacity(0.08), // Lighter shade for shimmer
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Match ListView padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container( // Image Skeleton
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8), // Rounded image skeleton
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container( // Title Skeleton
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container( // Subtitle Skeleton
                        width: 150,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row( // Availability Skeletons
              children: [
                for (int i = 0; i < 3; i++) // Example: 3 availability indicators
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12), // Pill-shaped skeleton
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Container( // Price/Rating Skeleton
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}