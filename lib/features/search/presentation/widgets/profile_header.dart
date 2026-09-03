import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isFollowing;
  final bool isSelf;
  final VoidCallback onFollowToggle;
  final VoidCallback onMessageTap;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isFollowing,
    required this.isSelf,
    required this.onFollowToggle,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: user.coverPhotoUrl.isNotEmpty
                    ? DecorationImage(image: CachedNetworkImageProvider(user.coverPhotoUrl), fit: BoxFit.cover)
                    : null,
              ),
            ),
            Positioned(
              bottom: -50,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                  backgroundImage: user.profilePictureUrl.isNotEmpty
                      ? CachedNetworkImageProvider(user.profilePictureUrl)
                      : null,
                  child: user.profilePictureUrl.isEmpty
                      ? Text(
                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Color(0xFF6366F1), size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('@${user.username}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                  if (user.isPrivate) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.lock, color: Colors.white.withOpacity(0.4), size: 14),
                  ],
                ],
              ),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(user.bio, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4)),
              ],
              const SizedBox(height: 16),
              if (user.location.isNotEmpty || user.website.isNotEmpty) ...[
                Row(
                  children: [
                    if (user.location.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined, color: Colors.white.withOpacity(0.5), size: 16),
                      const SizedBox(width: 4),
                      Text(user.location, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                      const SizedBox(width: 16),
                    ],
                    if (user.website.isNotEmpty) ...[
                      Icon(Icons.link, color: Colors.white.withOpacity(0.5), size: 16),
                      const SizedBox(width: 4),
                      Text(user.website, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 13)),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 20),
              if (!isSelf) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFollowing
                                  ? Colors.white.withOpacity(0.05)
                                  : const Color(0xFF6366F1).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFollowing ? Colors.white.withOpacity(0.1) : Colors.transparent,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onFollowToggle,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Center(
                                    child: Text(
                                      isFollowing ? AppStrings.searchFollowingButton : AppStrings.searchFollowButton,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onMessageTap,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: const Center(
                                    child: Text(
                                      'Message',
                                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
