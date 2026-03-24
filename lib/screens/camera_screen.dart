import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../services/permission_service.dart';
import 'preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndScan();
  }

  Future<void> _checkPermissionAndScan() async {
    final hasPermission = await PermissionService.checkCameraPermission();

    if (!hasPermission) {
      final granted = await PermissionService.requestCameraPermission();
      if (!granted) {
        if (!mounted) return;
        _showPermissionDialog();
        return;
      }
    }

    await _startScanning();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera permission is required to scan documents. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScanning() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      final options = DocumentScannerOptions(
        mode: ScannerMode.full,
        pageLimit: 1,
        isGalleryImport: false,
      );

      final scanner = DocumentScanner(options: options);

      final result = await scanner.scanDocument();

      // SAFE NULL CHECKS
      if (result.images != null &&
          result.images!.isNotEmpty) {

        final imagePath = result.images!.first;

        if (!mounted) return;

        final shouldReturn = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewScreen(imagePath: imagePath),
          ),
        );

        if (!mounted) return;

        Navigator.pop(context, shouldReturn ?? false);
      } else {
        if (!mounted) return;
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanning cancelled'),
        ),
      );

      Navigator.pop(context, false);
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 5,
            ),
            const SizedBox(height: 24),
            const Text(
              'Opening Camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}