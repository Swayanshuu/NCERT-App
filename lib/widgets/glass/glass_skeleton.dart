import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'glass_surface.dart';
import '../../theme/app_theme.dart';

class GlassSkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const GlassSkeletonCard({
    super.key,
    this.height = 180,
    this.width = double.infinity,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      height: height,
      width: width,
      borderRadius: borderRadius,
      child: Shimmer.fromColors(
        baseColor: isDark
            ? AppTheme.darkSurfaceElevated.withValues(alpha: 0.4)
            : AppTheme.lightSurfaceElevated.withValues(alpha: 0.6),
        highlightColor: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: height * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassSkeletonGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const GlassSkeletonGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.76,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const GlassSkeletonCard(),
    );
  }
}
