import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/post/presentation/bloc/post_event.dart';
import 'package:vagabond/features/post/presentation/bloc/post_state.dart';
import 'package:vagabond/features/post/presentation/widgets/add_post_media_picker.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final List<File> _selectedMedia = [];
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final remaining = 10 - _selectedMedia.length;
    if (remaining <= 0) {
      CustomSnackBar.showError(context, AppStrings.postMaxMediaError);
      return;
    }

    final picked = await _imagePicker.pickMultiImage(limit: remaining);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(picked.map((xf) => File(xf.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    if (_selectedMedia.length >= 10) {
      CustomSnackBar.showError(context, AppStrings.postMaxMediaError);
      return;
    }
    final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedMedia.add(File(picked.path));
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PostBloc>(),
      child: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostSuccess) {
            CustomSnackBar.showSuccess(context, state.message);
            context.pop();
          } else if (state is PostFailure) {
            CustomSnackBar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is PostLoading;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: const Text(
                AppStrings.postCreateTitle,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: _selectedMedia.isEmpty
                        ? null
                        : () {
                            context.read<PostBloc>().add(
                              CreatePostRequested(
                                media: _selectedMedia,
                                caption: _captionController.text.trim(),
                                location: _locationController.text.trim(),
                                tags: _tagsController.text.trim(),
                              ),
                            );
                          },
                    child: Text(
                      AppStrings.postButton,
                      style: TextStyle(
                        color: _selectedMedia.isEmpty ? Colors.white30 : const Color(0xFF6366F1),
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
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AddPostMediaPicker(
                        selectedMedia: _selectedMedia,
                        isLoading: isLoading,
                        onPickPhoto: _pickMedia,
                        onPickVideo: _pickVideo,
                        onRemoveMedia: _removeMedia,
                      ),
                      const SizedBox(height: 16),
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
                            child: Column(
                              children: [
                                CustomTextFormField(
                                  controller: _captionController,
                                  labelText: AppStrings.postCaptionLabel,
                                  prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1), size: 18),
                                  maxLines: 4,
                                  minLines: 2,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.multiline,
                                ),
                                const SizedBox(height: 12),
                                CustomTextFormField(
                                  controller: _locationController,
                                  labelText: AppStrings.postLocationLabel,
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFF6366F1),
                                    size: 18,
                                  ),
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),
                                CustomTextFormField(
                                  controller: _tagsController,
                                  labelText: AppStrings.postTagsLabel,
                                  prefixIcon: const Icon(Icons.tag, color: Color(0xFF6366F1), size: 18),
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.done,
                                ),
                              ],
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
}
