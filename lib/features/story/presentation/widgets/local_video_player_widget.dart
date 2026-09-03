import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayerWidget extends StatefulWidget {
  final File file;

  const LocalVideoPlayerWidget({super.key, required this.file});

  @override
  State<LocalVideoPlayerWidget> createState() => _LocalVideoPlayerWidgetState();
}

class _LocalVideoPlayerWidgetState extends State<LocalVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = VideoPlayerController.file(widget.file);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(_isMuted ? 0.0 : 1.0);
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    await _controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.white.withOpacity(0.05),
        child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 40)),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          // Play/Pause Overlay Indicator
          if (!_controller.value.isPlaying)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            ),
          // Mute/Unmute Button Overlay
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
