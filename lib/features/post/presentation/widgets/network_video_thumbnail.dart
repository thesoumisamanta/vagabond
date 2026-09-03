import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NetworkVideoThumbnail extends StatefulWidget {
  final String url;

  const NetworkVideoThumbnail({super.key, required this.url});

  @override
  State<NetworkVideoThumbnail> createState() => _NetworkVideoThumbnailState();
}

class _NetworkVideoThumbnailState extends State<NetworkVideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await ctrl.initialize();
      // Seek to first frame so the video surface shows a thumbnail
      await ctrl.seekTo(Duration.zero);
      if (mounted) {
        setState(() {
          _controller = ctrl;
          _initialized = true;
        });
      } else {
        await ctrl.dispose();
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || (!_initialized && !_failed)) {
      // Show a placeholder while loading / on error
      return Container(
        color: Colors.white.withOpacity(0.06),
        child: Center(
          child: _failed
              ? const Icon(Icons.videocam_off_outlined, color: Colors.white38, size: 28)
              : const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
        // Play icon overlay
        Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}
