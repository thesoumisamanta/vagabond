import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class SearchInitialPlaceholder extends StatelessWidget {
  const SearchInitialPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, color: Colors.white38, size: 48),
          SizedBox(height: 12),
          Text(AppStrings.searchInitialPlaceholder, style: TextStyle(color: Colors.white38, fontSize: 15)),
        ],
      ),
    );
  }
}
