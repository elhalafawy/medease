import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../models/analysis_result.dart';
import 'analysis_result_screen.dart';

class OcrResultScreen extends StatelessWidget {
  final String extractedText;
  const OcrResultScreen({super.key, required this.extractedText});

  Future<void> _analyzeText(BuildContext context) async {
    if (extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to analyze'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('Starting text analysis...');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Analyzing text...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      print('Text to analyze: $extractedText');
      
      // Perform analysis
      final result = await AnalysisResult.fromText(extractedText);
      print('Analysis completed: ${result.diagnosis}');

      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show results
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(result: result),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error during analysis: $e');
      print('Stack trace: $stackTrace');
      
      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing text: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Result'),
        backgroundColor: AppTheme.appBarBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  extractedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _analyzeText(context),
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze Text'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: extractedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Text copied to clipboard')),
                );
              }
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(extractedText)
            ),
          ],
        ),
      ),
    );
  }
}
