import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyVideoPlayer(),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key});

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: !loading && _chewieController.videoPlayerController.value.isInitialized
          ? OrientationBuilder(builder: (context, orientation) {
              return Chewie(controller: _chewieController);
            })
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _initializeVideoPlayer() async {
    /// String apiUrl = "api-to-fetch-url";

    /// Fetch HLS URL from the API
    /// String hlsUrl = await fetchHlsUrl(apiUrl);

    String hlsUrl =
        "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8";

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(hlsUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoPlay: true,
      looping: true,
      allowFullScreen: true,
      allowedScreenSleep: false,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );

    setState(() {
      loading = false;
    });
  }

  Future<String> _fetchHlsUrl(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['hlsUrl'];
    } else {
      throw Exception('Failed to fetch HLS URL');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
