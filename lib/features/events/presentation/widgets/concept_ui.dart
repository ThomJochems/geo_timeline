import 'package:flutter/material.dart';

import '../../domain/models/event.dart';

abstract final class ConceptAssets {
  static const volcano = 'assets/images/volcano_eruption.jpeg';
  static const gasPlume = 'assets/images/gas_plume.jpeg';
  static const seismicWave = 'assets/images/seismic_wave.jpeg';
  static const map = 'assets/images/map_reference.png';
}

abstract final class ConceptColors {
  static const orange = Color(0xFFF26D2A);
  static const blue = Color(0xFF176D88);
  static const green = Color(0xFF48A927);
  static const lightBlue = Color(0xFF8DCCF0);
  static const black = Color(0xFF050505);
}

Color conceptEventColor(EventCategory category) {
  return switch (category) {
    EventCategory.volcano => ConceptColors.orange,
    EventCategory.earthquake => ConceptColors.blue,
    EventCategory.gasEmission => ConceptColors.green,
    EventCategory.tsunami => ConceptColors.blue,
  };
}

Color conceptEventTextColor(EventCategory category) {
  return switch (category) {
    EventCategory.volcano => Colors.black,
    EventCategory.earthquake => Colors.white,
    EventCategory.gasEmission => Colors.white,
    EventCategory.tsunami => Colors.white,
  };
}

String conceptEventAsset(EventCategory category) {
  return switch (category) {
    EventCategory.volcano => ConceptAssets.volcano,
    EventCategory.earthquake => ConceptAssets.seismicWave,
    EventCategory.gasEmission => ConceptAssets.gasPlume,
    EventCategory.tsunami => ConceptAssets.seismicWave,
  };
}

class ConceptButton extends StatelessWidget {
  const ConceptButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ConceptColors.black,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ConceptColors.black.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.12,
        ),
      ),
      child: icon == null
          ? Text(label, textAlign: TextAlign.center)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
    );
  }
}

class ConceptBackButton extends StatelessWidget {
  const ConceptBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => Navigator.of(context).maybePop(),
      iconSize: 72,
      color: ConceptColors.blue,
      icon: const Icon(Icons.arrow_back),
    );
  }
}

class ConceptGlobeButton extends StatelessWidget {
  const ConceptGlobeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open map',
      onPressed: onPressed,
      iconSize: 58,
      color: Colors.black,
      icon: const Icon(Icons.public),
    );
  }
}
