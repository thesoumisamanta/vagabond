import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class InboxEmptyState extends StatelessWidget {
  const InboxEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Center(
            child: Text(AppStrings.chatNoConversations, style: TextStyle(color: Colors.white54, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
