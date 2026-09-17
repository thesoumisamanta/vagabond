import 'package:flutter/material.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_glass_container.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class LegalHeaderInfo extends StatelessWidget {
  final String version;
  final String effectiveDate;
  final String? lastUpdated;

  const LegalHeaderInfo({
    super.key,
    required this.version,
    required this.effectiveDate,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return LegalGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
          if (lastUpdated != null && lastUpdated!.isNotEmpty && lastUpdated != effectiveDate) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Last Updated: $lastUpdated',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
