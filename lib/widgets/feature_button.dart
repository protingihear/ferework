import 'package:flutter/material.dart';

class FeatureButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double? width; 

  const FeatureButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.width, 
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 100, 
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 80, height: 80),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureButtonRow extends StatelessWidget {
  final List<Map<String, dynamic>> features;

  const FeatureButtonRow({Key? key, required this.features}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.26;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: features.map((feature) {
          return FeatureButton(
            imagePath: feature['imagePath'],
            label: feature['label'],
            onTap: feature['onTap'],
            width: buttonWidth,
          );
        }).toList(),
      ),
    );
  }
}
