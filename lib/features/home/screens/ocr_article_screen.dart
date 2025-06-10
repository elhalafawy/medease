import 'package:flutter/material.dart';

class OcrArticleScreen extends StatelessWidget {
  const OcrArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OCR Application',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Understanding OCR Application in Healthcare',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8, // Max width 80% of screen
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/ocr_illustration.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Optical Character Recognition (OCR) technology has revolutionized how we handle documents, especially in sectors like healthcare. OCR can automatically convert scanned or image-based medical records, prescriptions, and lab results into machine-readable text. This significantly reduces manual data entry, minimizes errors, and speeds up information retrieval, enhancing overall data management.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.4),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            Text(
              'Key Benefits of OCR in Healthcare:',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme, 
              'Enhanced Data Accuracy',
              'By automating data extraction, OCR significantly reduces the risk of human error during transcription, leading to more accurate patient records and improved reliability of health information.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Improved Operational Efficiency',
              'Healthcare professionals can quickly access patient information, leading to faster diagnoses, more efficient treatment plans, and streamlined administrative workflows.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Significant Cost Reduction',
              'Automating data entry and management processes through OCR can lead to substantial cost savings for healthcare providers by reducing labor, printing, and storage expenses.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Better Patient Care Outcomes',
              'With readily available, accurate, and organized information, doctors can make more informed and timely decisions, ultimately improving the quality of patient care and treatment outcomes.',
            ),
            const SizedBox(height: 20),
            Text(
              'Future Integration of OCR in MedEase:',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Our MedEase application is designed to fully leverage OCR to enable users to seamlessly upload various medical documents, including lab reports and prescriptions. These documents are then intelligently analyzed to extract and categorize relevant information, making health records easily accessible and manageable within the app. This innovative approach aims to enhance user experience and optimize the digitization of health data.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitPoint(ThemeData theme, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.4),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 