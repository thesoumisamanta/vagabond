import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/features/story/presentation/bloc/story_state.dart';
import 'package:vagabond/features/story/presentation/widgets/local_video_player_widget.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  File? _selectedMedia;
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _isVideo(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v'].contains(ext);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedMedia = File(picked.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedMedia = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StoryBloc>(),
      child: BlocConsumer<StoryBloc, StoryState>(
        listener: (context, state) {
          if (state is StoryActionSuccess) {
            CustomSnackBar.showSuccess(context, state.message);
            context.pop(true); // Return true to indicate a story was created
          } else if (state is StoryFailure) {
            CustomSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is StoryLoading;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                'Create Story',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: _selectedMedia == null
                        ? null
                        : () {
                            context.read<StoryBloc>().add(
                              CreateStoryRequested(media: _selectedMedia!, caption: _captionController.text.trim()),
                            );
                          },
                    child: Text(
                      'Share',
                      style: TextStyle(
                        color: _selectedMedia == null ? Colors.white30 : const Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Media Preview / Picker
                      GestureDetector(
                        onTap: isLoading ? null : () => _showPickerOptions(context),
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: _selectedMedia != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _isVideo(_selectedMedia!)
                                          ? LocalVideoPlayerWidget(file: _selectedMedia!)
                                          : Image.file(_selectedMedia!, fit: BoxFit.cover),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black.withOpacity(0.5),
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            onPressed: () {
                                              setState(() {
                                                _selectedMedia = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, color: Colors.white54, size: 48),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap to select photo or video',
                                      style: TextStyle(color: Colors.white54, fontSize: 14),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Caption Input
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: CustomTextFormField(
                              controller: _captionController,
                              labelText: 'Caption (optional)',
                              prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1), size: 18),
                              maxLines: 3,
                              minLines: 1,
                              enabled: !isLoading,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Pick Image', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white),
                title: const Text('Pick Video', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
