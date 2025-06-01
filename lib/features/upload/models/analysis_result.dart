import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../../../core/config/api_keys.dart';

class AnalysisResult {
  final String diagnosis;
  final List<String> medications;
  final List<String> requiredTests;
  final List<String> requiredScans;
  final String rawText;
  final List<String> symptoms;

  AnalysisResult({
    required this.diagnosis,
    required this.medications,
    required this.requiredTests,
    required this.requiredScans,
    required this.rawText,
    required this.symptoms,
  });

  static Future<AnalysisResult> fromText(String text) async {
    // Verify API key
    ApiKeys.verifyApiKey();

    if (text.isEmpty) {
      // Fallback to basic analysis for empty text
      print('Text to analyze is empty, performing basic analysis.');
      return _basicAnalysis(text);
    }

    print('Initializing Gemini API...');

    try {
      // Initialize Gemini API
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: ApiKeys.geminiApiKey,
      );

      // Create a prompt for the model
      final prompt = '''
      Analyze the following medical text and extract information in JSON format with the following structure:
      {
        "diagnosis": "main diagnosis or condition",
        "medications": ["list of medication names, without surrounding text"],
        "requiredTests": ["list of required lab test names, without surrounding text"],
        "requiredScans": ["list of required scan or imaging names, without surrounding text"],
        "symptoms": ["list of symptom descriptions, without surrounding text"]
      }

      Text to analyze:
      $text

      Only respond with the JSON structure, no additional text. Do not include any markdown formatting (like ```json). The output must be purely the JSON object.
      ''';

      print('Sending request to Gemini API...');

      // Get response from Gemini
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.trim().isEmpty) {
         print('Empty or whitespace response from Gemini API.');
         // Fallback if API returns empty or whitespace
         return _basicAnalysis(text);
      }

      String responseText = response.text!;

      // Clean up potential markdown if API incorrectly includes it
      if (responseText.startsWith('```json')) {
          responseText = responseText.substring(7);
      }
      if (responseText.endsWith('```')) {
          responseText = responseText.substring(0, responseText.length - 3);
      }
      responseText = responseText.trim();

      print('Received response from Gemini API');
      print('Response text: $responseText');

      // Parse the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(responseText);
      print('Parsed JSON response: $jsonResponse');

      // Validate and cast the lists, providing defaults if null
      final List<String> medications = (jsonResponse['medications'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [];
      final List<String> requiredTests = (jsonResponse['requiredTests'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [];
      final List<String> requiredScans = (jsonResponse['requiredScans'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [];
      final List<String> symptoms = (jsonResponse['symptoms'] as List<dynamic>?)?.map((item) => item.toString()).toList() ?? [];

      return AnalysisResult(
        diagnosis: jsonResponse['diagnosis']?.toString() ?? '',
        medications: medications,
        requiredTests: requiredTests,
        requiredScans: requiredScans,
        symptoms: symptoms,
        rawText: text,
      );
    } on FormatException catch (e) {
      print('JSON parsing error: $e');
      print('Falling back to basic analysis due to JSON error...');
      return _basicAnalysis(text);
    } on Exception catch (e) {
      print('Error in Gemini API call: $e');
      print('Falling back to basic analysis due to API error...');
      return _basicAnalysis(text);
    }
  }

  static AnalysisResult _basicAnalysis(String text) {
    print('Performing basic analysis (fallback)...');

    List<String> meds = [];
    List<String> tests = [];
    List<String> scans = [];
    String diagnosis = '';
    List<String> symptoms = [];

    List<String> lines = text.split('\n');
    print('Basic analysis: Split text into ${lines.length} lines');

    // Simple helper to extract text after a keyword and common separators
    String extractAfterKeyword(String line, List<String> keywords) {
        String lowerLine = line.trim().toLowerCase();
        for (String keyword in keywords) {
            String lowerKeyword = keyword.toLowerCase();
            int index = lowerLine.indexOf(lowerKeyword);
            if (index != -1) {
                // Get the substring after the keyword
                String extracted = line.trim().substring(index + keyword.length);
                // Trim leading spaces and common separators like :, -, etc.
                extracted = extracted.trimLeft();
                while (extracted.isNotEmpty && (extracted[0] == ':' || extracted[0] == '-' || extracted[0] == ' ')) {
                    extracted = extracted.substring(1).trimLeft();
                }
                return extracted.trim(); // Trim trailing spaces as well
            }
        }
        return line.trim(); // Return original trimmed line if no keyword found
    }

    // Keywords (case-insensitive matching will be done inside helper)
    final List<String> diagnosisKeywords = ['diagnosis', 'تشخيص'];
    final List<String> medicationKeywords = ['medication', 'drug', 'دواء', 'علاج'];
    final List<String> testKeywords = ['test', 'lab', 'تحليل', 'فحص', 'blood test', 'urine test'];
    final List<String> scanKeywords = ['scan', 'x-ray', 'اشعة', 'رنين', 'imaging', 'eeg', 'mri', 'ct scan'];
    final List<String> symptomKeywords = ['symptoms', 'اعراض'];

    for (String line in lines) {
      if (line.trim().isEmpty) continue; // Skip empty lines

      String lowerLine = line.trim().toLowerCase();

      // Check for Diagnosis first as it's usually a distinct line
      if (diagnosisKeywords.any((keyword) => lowerLine.contains(keyword))) {
        diagnosis = extractAfterKeyword(line, diagnosisKeywords); // Extract diagnosis
        print('Basic analysis: Found diagnosis: $diagnosis');
        continue; // Move to next line once a category is matched
      }

      // Check other categories
      if (medicationKeywords.any((keyword) => lowerLine.contains(keyword))) {
        meds.add(extractAfterKeyword(line, medicationKeywords)); // Extract medication
        print('Basic analysis: Found medication: ${meds.last}');
      } else if (testKeywords.any((keyword) => lowerLine.contains(keyword))) {
        tests.add(extractAfterKeyword(line, testKeywords)); // Extract test
        print('Basic analysis: Found test: ${tests.last}');
      } else if (scanKeywords.any((keyword) => lowerLine.contains(keyword))) {
        scans.add(extractAfterKeyword(line, scanKeywords)); // Extract scan
        print('Basic analysis: Found scan: ${scans.last}');
      } else if (symptomKeywords.any((keyword) => lowerLine.contains(keyword))) {
         symptoms.add(extractAfterKeyword(line, symptomKeywords)); // Extract symptom
         print('Basic analysis: Found symptom: ${symptoms.last}');
      } else {
          // If a line doesn't match any category, you might want to add it as part of raw text only
          // Or add it to a general 'notes' section if you add one to AnalysisResult
          // For now, we'll just log it.
          print('Basic analysis: Line did not match any category: $line');
      }
    }

    return AnalysisResult(
      diagnosis: diagnosis,
      medications: meds,
      requiredTests: tests,
      requiredScans: scans,
      symptoms: symptoms,
      rawText: text, // Keep raw text for reference
    );
  }
} 