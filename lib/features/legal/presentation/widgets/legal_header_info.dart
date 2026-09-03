import 'package:flutter/material.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_glass_container.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class LegalHeaderInfo extends StatelessWidget {
  final String version;
  final String effectiveDate;

  const LegalHeaderInfo({super.key, required this.version, required this.effectiveDate});

  @override
  Widget build(BuildContext context) {
    return LegalGlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${AppStrings.legalVersionPrefix}$version',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
          ),
          Text(
            '${AppStrings.legalEffectivePrefix}$effectiveDate',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
