import 'package:flutter/material.dart';

class FeatureButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const FeatureButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FeatureButtonRow extends StatelessWidget {
  final List<Map<String, dynamic>> features;

  const FeatureButtonRow({Key? key, required this.features}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Add more space
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0), // Add horizontal gap
            child: FeatureButton(
              imagePath: feature['imagePath'],
              label: feature['label'],
              onTap: feature['onTap'],
            ),
          );
        }).toList(),
      ),
    );
  }
}