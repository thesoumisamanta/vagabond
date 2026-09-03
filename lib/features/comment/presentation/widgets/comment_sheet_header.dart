import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_state.dart';

class CommentSheetHeader extends StatelessWidget {
  const CommentSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              int count = 0;
              if (state is CommentsLoaded) {
                count = state.totalComments;
              }
              return Text(
                '${AppStrings.commentsTitle} ($count)',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
