import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/large_button.dart';

class SendScreen extends StatelessWidget {
  final String pdfPath;

  const SendScreen({
    super.key,
    required this.pdfPath,
  });

  String get _fileName => pdfPath.split('/').last;

  Future<void> _shareToWhatsApp(BuildContext context) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(pdfPath)],
        text: 'Scanned document',
      );

      // Optional: Handle share result
      if (result.status == ShareResultStatus.dismissed) {
        // User cancelled sharing
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not share to WhatsApp');
      }
    }
  }

  Future<void> _shareViaGmail(BuildContext context) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(pdfPath)],
        subject: 'Scanned Document',
        text: 'Please find attached scanned document',
      );

      if (result.status == ShareResultStatus.dismissed) {
        // User cancelled sharing
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not share via Gmail');
      }
    }
  }

  Future<void> _shareMore(BuildContext context) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(pdfPath)],
        text: 'Scanned document',
      );

      if (result.status == ShareResultStatus.dismissed) {
        // User cancelled sharing
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not share file');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Send Document',
          style: TextStyle(fontSize: 22),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Success Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Document saved successfully!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // PDF Preview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 50,
                      color: Colors.red[400],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Saved in Documents folder',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Share Buttons
              LargeButton(
                text: 'Send to WhatsApp',
                icon: Icons.chat,
                onPressed: () => _shareToWhatsApp(context),
                color: const Color(0xFF25D366),
              ),

              const SizedBox(height: 16),

              LargeButton(
                text: 'Send via Gmail',
                icon: Icons.email,
                onPressed: () => _shareViaGmail(context),
                color: const Color(0xFFEA4335),
              ),

              const SizedBox(height: 16),

              LargeButton(
                text: 'Share More Options',
                icon: Icons.share,
                onPressed: () => _shareMore(context),
                color: const Color(0xFF2196F3),
              ),

              const Spacer(),

              // Done Button
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}