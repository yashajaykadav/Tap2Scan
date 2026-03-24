import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../widgets/large_button.dart';
import '../widgets/loading_overlay.dart';
import 'send_screen.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isProcessing = false;

  Future<void> _saveAndContinue() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfPath = await PdfService.createPdfFromImage(widget.imagePath);

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        final shouldReturn = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendScreen(pdfPath: pdfPath),
          ),
        );

        if (mounted) {
          Navigator.pop(context, shouldReturn ?? true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save document',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _retake() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Preview',
          style: TextStyle(fontSize: 22),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Image Preview
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Buttons
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      LargeButton(
                        text: 'SAVE & SEND',
                        icon: Icons.check_circle,
                        onPressed: _saveAndContinue,
                      ),
                      const SizedBox(height: 12),
                      LargeButton(
                        text: 'RETAKE',
                        icon: Icons.camera_alt,
                        onPressed: _retake,
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_isProcessing)
            const LoadingOverlay(
              message: 'Creating PDF...\nThis may take a moment',
            ),
        ],
      ),
    );
  }
}