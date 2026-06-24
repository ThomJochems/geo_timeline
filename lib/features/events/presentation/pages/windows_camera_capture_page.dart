import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class WindowsCameraCapturePage extends StatefulWidget {
  const WindowsCameraCapturePage({super.key});

  @override
  State<WindowsCameraCapturePage> createState() =>
      _WindowsCameraCapturePageState();
}

class _WindowsCameraCapturePageState extends State<WindowsCameraCapturePage> {
  CameraController? _controller;
  Future<void>? _initializeCameraFuture;
  Object? _error;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _controller = controller;
      await controller.initialize();
    } catch (error) {
      _error = error;
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;

    if (controller == null || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      await _initializeCameraFuture;
      final image = await controller.takePicture();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(image);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _error = error);
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take photo')),
      body: FutureBuilder<void>(
        future: _initializeCameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final error = _error;
          final controller = _controller;

          if (error != null ||
              controller == null ||
              !controller.value.isInitialized) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not open the camera.\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(child: CameraPreview(controller)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Center(
                  child: FloatingActionButton.large(
                    onPressed: _isCapturing ? null : _capturePhoto,
                    child: _isCapturing
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
