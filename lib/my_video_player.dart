import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

enum UiState { loading, error, success }

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key});

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  UiState state = UiState.loading;

  @override
  void initState() {
    loadVideo();

    super.initState();
  }

  void loadVideo() {
    try {
      setState(() {
        state = UiState.loading;
      });
      _initializeVideoPlayer();

      ///loading time out
      Future.delayed(const Duration(seconds: 10)).then((value) {
        if (state == UiState.loading) {
          setState(() {
            state = UiState.error;
          });
        }
      });
    } catch (e) {
      setState(() {
        state = UiState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: const Text('Video Player'),
      ),
      body: _body(context),
    );
  }

  Center _body(BuildContext context) {
    if (state == UiState.success && _chewieController.videoPlayerController.value.isInitialized) {
      return Center(
        child: Container(
            color: Colors.black,
            height: MediaQuery.sizeOf(context).height * 0.25,
            child: Chewie(controller: _chewieController)),
      );
    }
    if (state == UiState.error) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error),
          const SizedBox(height: 24),
          const Text("Something went wrong, Please try again"),
          const SizedBox(height: 24),
          TextButton(onPressed: loadVideo, child: const Text("Try again"))
        ],
      ));
    }

    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 24),
        Text("Please wait, while we loading the video"),
      ],
    ));
  }

  void _initializeVideoPlayer() async {
    /// String apiUrl = "api-to-fetch-url";

    ///fetch HLS URL from the API
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
      state = UiState.success;
    });
  }

  /// this is to fetch the url from the server
  /// as there is no open api have found i've create a function of it
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
