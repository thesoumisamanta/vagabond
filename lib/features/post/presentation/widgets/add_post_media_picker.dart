import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vagabond/features/post/presentation/widgets/video_thumbnail.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class AddPostMediaPicker extends StatelessWidget {
  final List<File> selectedMedia;
  final bool isLoading;
  final VoidCallback onPickPhoto;
  final VoidCallback onPickVideo;
  final Function(int index) onRemoveMedia;

  const AddPostMediaPicker({
    super.key,
    required this.selectedMedia,
    required this.isLoading,
    required this.onPickPhoto,
    required this.onPickVideo,
    required this.onRemoveMedia,
  });

  bool _isVideoFile(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppStrings.postMediaPrefix}${selectedMedia.length}${AppStrings.postMediaSuffix}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: [
                      _MediaButton(
                        icon: Icons.image_outlined,
                        label: AppStrings.postPhotoLabel,
                        onTap: isLoading ? null : onPickPhoto,
                      ),
                      const SizedBox(width: 8),
                      _MediaButton(
                        icon: Icons.videocam_outlined,
                        label: AppStrings.postVideoLabel,
                        onTap: isLoading ? null : onPickVideo,
                      ),
                    ],
                  ),
                ],
              ),
              if (selectedMedia.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedMedia.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final file = selectedMedia[index];
                      final isVideo = _isVideoFile(file);
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isVideo
                                ? VideoThumbnail(file: file, width: 100, height: 110)
                                : Image.file(file, width: 100, height: 110, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onRemoveMedia(index),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              if (selectedMedia.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      AppStrings.postAddMediaPlaceholder,
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MediaButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
