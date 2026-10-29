import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  File? _newProfilePicture;
  File? _newCoverPhoto;

  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _businessEmailController;
  late bool _isPrivate;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _websiteController = TextEditingController(text: user?.website ?? '');
    _businessEmailController = TextEditingController(text: user?.businessEmail ?? '');
    _isPrivate = user?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _businessEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _newProfilePicture = File(picked.path);
      });
    }
  }

  Future<void> _pickCoverPhoto() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _newCoverPhoto = File(picked.path);
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            UpdateProfileRequested(
              profilePicture: _newProfilePicture,
              coverPhoto: _newCoverPhoto,
              fullName: _fullNameController.text.trim(),
              bio: _bioController.text.trim(),
              location: _locationController.text.trim(),
              website: _websiteController.text.trim(),
              businessEmail: _businessEmailController.text.trim(),
              isPrivate: _isPrivate,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().currentUser;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUpdateProfileSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.pop(true);
        } else if (state is AuthFailure) {
          CustomSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: _onSave,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Cover Banner & Profile Avatar Picker Section
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Cover Photo Banner
                          GestureDetector(
                            onTap: isLoading ? null : _pickCoverPhoto,
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                image: _newCoverPhoto != null
                                    ? DecorationImage(
                                        image: FileImage(_newCoverPhoto!),
                                        fit: BoxFit.cover,
                                      )
                                    : (user?.coverPhotoUrl.isNotEmpty ?? false)
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(user!.coverPhotoUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 28),
                                      SizedBox(height: 4),
                                      Text(
                                        'Change Cover Banner',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Profile Picture Avatar
                          Positioned(
                            bottom: -45,
                            child: GestureDetector(
                              onTap: isLoading ? null : _pickProfilePicture,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF6366F1), width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 42,
                                      backgroundColor: const Color(0xFF1E1B4B),
                                      backgroundImage: _newProfilePicture != null
                                          ? FileImage(_newProfilePicture!)
                                          : (user?.profilePictureUrl.isNotEmpty ?? false)
                                              ? CachedNetworkImageProvider(user!.profilePictureUrl) as ImageProvider
                                              : null,
                                      child: (_newProfilePicture == null && (user?.profilePictureUrl.isEmpty ?? true))
                                          ? Text(
                                              (user?.fullName.isNotEmpty ?? false)
                                                  ? user!.fullName[0].toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 55),

                      // Profile Details Form Fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: ClipRRect(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextFormField(
                                    controller: _fullNameController,
                                    labelText: 'Full Name',
                                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6366F1), size: 20),
                                    enabled: !isLoading,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Full name cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  CustomTextFormField(
                                    controller: _bioController,
                                    labelText: 'Bio (About You)',
                                    prefixIcon: const Icon(Icons.edit_note_outlined, color: Color(0xFF6366F1), size: 20),
                                    maxLines: 4,
                                    minLines: 2,
                                    enabled: !isLoading,
                                    validator: (val) {
                                      if (val != null && val.length > 500) {
                                        return 'Bio cannot exceed 500 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  CustomTextFormField(
                                    controller: _locationController,
                                    labelText: 'Location',
                                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF6366F1), size: 20),
                                    enabled: !isLoading,
                                  ),
                                  const SizedBox(height: 14),
                                  CustomTextFormField(
                                    controller: _websiteController,
                                    labelText: 'Website',
                                    prefixIcon: const Icon(Icons.language_outlined, color: Color(0xFF6366F1), size: 20),
                                    enabled: !isLoading,
                                    keyboardType: TextInputType.url,
                                  ),
                                  const SizedBox(height: 14),
                                  CustomTextFormField(
                                    controller: _businessEmailController,
                                    labelText: 'Business Email',
                                    prefixIcon: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF6366F1), size: 20),
                                    enabled: !isLoading,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) {
                                      if (val != null && val.isNotEmpty) {
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(val.trim())) {
                                          return 'Please enter a valid email address';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(color: Colors.white.withOpacity(0.08)),
                                  const SizedBox(height: 8),
                                  // Private Account Switch
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: const Row(
                                          children: [
                                            Icon(Icons.lock_outline, color: Color(0xFF6366F1), size: 20),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Private Account',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Only approved followers can see your profile details',
                                                    style: TextStyle(color: Colors.white38, fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Switch(
                                        value: _isPrivate,
                                        activeColor: const Color(0xFF6366F1),
                                        onChanged: isLoading
                                            ? null
                                            : (val) {
                                                setState(() {
                                                  _isPrivate = val;
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

