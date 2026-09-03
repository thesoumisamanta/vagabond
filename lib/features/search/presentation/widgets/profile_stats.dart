import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vagabond/features/auth/domain/entities/user.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class ProfileStats extends StatelessWidget {
  final User user;
  final bool isPrivateAndNotFollowing;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfileStats({
    super.key,
    required this.user,
    required this.isPrivateAndNotFollowing,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  Widget _buildStatItem(String label, String count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.25),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(AppStrings.searchPostsStat, user.postsCount.toString()),
              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.1)),
              _buildStatItem(
                AppStrings.searchFollowersStat,
                user.followersCount.toString(),
                onTap: isPrivateAndNotFollowing ? null : onFollowersTap,
              ),
              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.1)),
              _buildStatItem(
                AppStrings.searchFollowingStat,
                user.followingCount.toString(),
                onTap: isPrivateAndNotFollowing ? null : onFollowingTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
