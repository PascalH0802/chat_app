import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPage extends StatelessWidget {
  final String mediaUrl;
  final bool isVideo;

  MediaPage({required this.mediaUrl, required this.isVideo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: isVideo
            ? ChewieVideoPlayer(videoUrl: mediaUrl)
            : Image.network(mediaUrl),
      ),
    );
  }
}

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;

  ChewieVideoPlayer({required this.videoUrl});

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 9/16,
    );
    videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }
}


