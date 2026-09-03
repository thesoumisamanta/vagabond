import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/story/domain/entities/story.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';
import 'package:vagabond/features/dashboard/presentation/home/widgets/story_viewer.dart';
import 'package:vagabond/features/post/presentation/widgets/network_video_thumbnail.dart';

class StoryHighlightsSection extends StatefulWidget {
  final String userId;

  const StoryHighlightsSection({super.key, required this.userId});

  @override
  State<StoryHighlightsSection> createState() => _StoryHighlightsSectionState();
}

class _StoryHighlightsSectionState extends State<StoryHighlightsSection> {
  late StoryBloc _storyBloc;

  @override
  void initState() {
    super.initState();
    _storyBloc = sl<StoryBloc>();
    _storyBloc.add(GetUserHighlightsRequested(userId: widget.userId));
  }

  @override
  void dispose() {
    _storyBloc.close();
    super.dispose();
  }

  void _showCreateHighlightDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return BlocProvider.value(value: _storyBloc, child: const CreateHighlightSheet());
      },
    ).then((value) {
      if (value == true) {
        _storyBloc.add(GetUserHighlightsRequested(userId: widget.userId));
      }
    });
  }

  void _viewHighlight(StoryHighlight highlight) {
    // Convert StoryHighlight to UserStories so we can view it with StoryViewer
    final userStories = UserStories(
      user: StoryUser(
        id: highlight.userId,
        username: '',
        fullName: highlight.title,
        profilePictureUrl: highlight.coverImageUrl,
        accountType: 'personal',
        isVerified: false,
      ),
      stories: highlight.stories,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Highlight Viewer',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) {
        return BlocProvider.value(
          value: _storyBloc,
          child: StoryViewer(userStories: userStories),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthBloc>().currentUser;
    final isSelf = widget.userId == currentUser?.id;

    return BlocProvider.value(
      value: _storyBloc,
      child: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          List<StoryHighlight> highlights = [];
          if (state is StoryHighlightsLoaded) {
            highlights = state.highlights;
          }

          if (highlights.isEmpty && !isSelf) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Highlights',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: highlights.length + (isSelf ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isSelf && index == 0) {
                      // Add Highlight button
                      return GestureDetector(
                        onTap: _showCreateHighlightDialog,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                              const SizedBox(height: 4),
                              const Text('New', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    }

                    final highlightIndex = isSelf ? index - 1 : index;
                    final highlight = highlights[highlightIndex];

                    return GestureDetector(
                      onTap: () => _viewHighlight(highlight),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
                                image: highlight.coverImageUrl.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(highlight.coverImageUrl), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: highlight.coverImageUrl.isEmpty
                                  ? const Icon(Icons.folder_open, color: Colors.white70, size: 24)
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 64,
                              child: Text(
                                highlight.title,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreateHighlightSheet extends StatefulWidget {
  const CreateHighlightSheet({super.key});

  @override
  State<CreateHighlightSheet> createState() => _CreateHighlightSheetState();
}

class _CreateHighlightSheetState extends State<CreateHighlightSheet> {
  final _titleController = TextEditingController();
  final List<String> _selectedStoryIds = [];
  File? _coverImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<StoryBloc>().add(const GetArchivedStoriesRequested(page: 1, limit: 50));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _coverImage = File(picked.path);
      });
    }
  }

  void _toggleStorySelection(String id) {
    setState(() {
      if (_selectedStoryIds.contains(id)) {
        _selectedStoryIds.remove(id);
      } else {
        _selectedStoryIds.add(id);
      }
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      CustomSnackBar.showError(context, 'Please enter a title');
      return;
    }
    if (_selectedStoryIds.isEmpty) {
      CustomSnackBar.showError(context, 'Please select at least one story');
      return;
    }

    context.read<StoryBloc>().add(
      CreateHighlightRequested(title: title, storyIds: _selectedStoryIds, coverImage: _coverImage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoryHighlightActionSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is StoryFailure) {
          CustomSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is StoryLoading;

        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 16, left: 16, right: 16),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Highlight',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _submit,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Cover Image and Title input
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickCoverImage,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white24, width: 1),
                        image: _coverImage != null
                            ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _coverImage == null
                          ? const Icon(Icons.add_a_photo_outlined, color: Colors.white54, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextFormField(
                      controller: _titleController,
                      labelText: 'Highlight Title',
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Stories',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // Stories Grid from Archive
              Expanded(
                child: BlocBuilder<StoryBloc, StoryState>(
                  buildWhen: (previous, current) => current is ArchivedStoriesLoaded || current is StoryLoading,
                  builder: (context, state) {
                    if (state is StoryLoading && _selectedStoryIds.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                      );
                    }

                    List<Story> archivedStories = [];
                    if (state is ArchivedStoriesLoaded) {
                      archivedStories = state.response.stories;
                    }

                    if (archivedStories.isEmpty) {
                      return const Center(
                        child: Text('No archived stories found', style: TextStyle(color: Colors.white54)),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: archivedStories.length,
                      itemBuilder: (context, index) {
                        final story = archivedStories[index];
                        final isSelected = _selectedStoryIds.contains(story.id);

                        return GestureDetector(
                          onTap: () => _toggleStorySelection(story.id),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: story.media.type == 'video'
                                    ? NetworkVideoThumbnail(url: story.media.url)
                                    : Image.network(story.media.url, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? const Color(0xFF6366F1) : Colors.black45,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                  child: Icon(isSelected ? Icons.check : null, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
