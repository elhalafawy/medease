import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../../../core/config/api_keys.dart';

// New class for structured medication data
class Medication {
  final String name;
  final String dosage;
  final String frequency;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
  });

  // Factory constructor to create a Medication object from JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
    );
  }
}

// Updated AnalysisResult class
class AnalysisResult {
  final String? patientName;
  final List<String> symptoms;
  final List<String> diagnosis;
  final List<Medication> medications;
  final List<String> labTests;
  final List<String> radiologyScans;
  final String rawText;

  AnalysisResult({
    this.patientName,
    required this.symptoms,
    required this.diagnosis,
    required this.medications,
    required this.labTests,
    required this.radiologyScans,
    required this.rawText,
  });

  static Future<AnalysisResult> fromText(String text) async {
    // Verify API key and text presence
    ApiKeys.verifyApiKey();
    if (text.trim().isEmpty) {
      print('Text to analyze is empty, performing basic analysis.');
      return _basicAnalysis(text);
    }
    // IMPORTANT: Replace 'YOUR_PLACEHOLDER_API_KEY' in lib/core/config/api_keys.dart with your actual Gemini API key.
    if (ApiKeys.geminiApiKey == 'YOUR_PLACEHOLDER_API_KEY') {
      print('Warning: Using placeholder Gemini API key.');
      return _basicAnalysis(text);
    }

    print('Initializing Gemini API...');

    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: ApiKeys.geminiApiKey,
      );

      // ===================================================================
      // IMPROVEMENT 1: A MORE DETAILED AND ACCURATE PROMPT
      // ===================================================================
      final prompt = '''
      You are an expert AI assistant for analyzing medical prescription texts from OCR scans. Your task is to extract information into a structured JSON format ONLY.

      **CRITICAL RULES:**
      1.  Your entire response MUST be a single, valid JSON object. Do not include any explanatory text, markdown like ```json, or any character outside the JSON object.
      2.  The text can be messy, in English or Arabic. Understand abbreviations.
      3.  If a field is not found, use `null` for text fields (like patient_name) or an empty array `[]` for lists.
      4.  **Crucially, differentiate between lab tests and scans:**
          - `lab_tests`: Include blood tests (CBC, ESR), urine tests, etc.
          - `radiology_scans`: Include imaging like MRI, CT Scan, X-Ray, Ultrasound, EEG.
      5.  Ignore non-medical items like doctor specialities (e.g., "NEUROLOGIST").

      **Required JSON Structure:**
      {
        "patient_name": "string or null",
        "symptoms": ["string"],
        "diagnosis": ["string"],
        "medications": [
          {
            "name": "string",
            "dosage": "string",
            "frequency": "string"
          }
        ],
        "lab_tests": ["string"],
        "radiology_scans": ["string"]
      }

      **Example:**
      Input Text: "TESTS: Blood tests, MRI brain"
      Correct JSON Output Snippet:
      "lab_tests": ["Blood tests"],
      "radiology_scans": ["MRI brain"]

      **Prescription Text to Analyze:**
      """
      $text
      """
      ''';

      print('Sending request to Gemini API...');
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (response.text == null || response.text!.trim().isEmpty) {
        print('Empty response from Gemini API. Falling back to basic analysis.');
        return _basicAnalysis(text);
      }

      String responseText = response.text!.trim().replaceAll('''```json''', '').replaceAll('''```''', '').trim();
      print('Cleaned Gemini Response:\n$responseText');
      
      final Map<String, dynamic> jsonResponse = json.decode(responseText);

      final List<dynamic> medList = jsonResponse['medications'] ?? [];
      final List<Medication> medications = medList
          .map((item) => Medication.fromJson(item as Map<String, dynamic>))
          .toList();

      final List<String> symptoms = List<String>.from(jsonResponse['symptoms'] ?? []);
      final List<String> diagnosis = List<String>.from(jsonResponse['diagnosis'] ?? []);
      final List<String> labTests = List<String>.from(jsonResponse['lab_tests'] ?? []);
      final List<String> radiologyScans = List<String>.from(jsonResponse['radiology_scans'] ?? []);

      return AnalysisResult(
        patientName: jsonResponse['patient_name']?.toString(),
        symptoms: symptoms,
        diagnosis: diagnosis,
        medications: medications,
        labTests: labTests,
        radiologyScans: radiologyScans,
        rawText: text,
      );

    } on Exception catch (e) {
      print('An error occurred during Gemini API call or parsing: $e');
      print('Falling back to basic analysis...');
      return _basicAnalysis(text);
    }
  }

  // ===================================================================
  // IMPROVEMENT 2: A SMARTER FALLBACK FUNCTION
  // ===================================================================
  static AnalysisResult _basicAnalysis(String text) {
    print('Performing smarter basic analysis (fallback)...');
    
    List<Medication> meds = [];
    List<String> tests = [];
    List<String> scans = [];
    List<String> diagnosis = [];
    List<String> symptoms = [];

    // Keywords to help differentiate tests from scans
    final scanKeywords = ['mri', 'ct', 'scan', 'x-ray', 'xray', 'radiology', 'imaging', 'ultrasound', 'eeg', 'رنين', 'اشعة', 'أشعة'];
    final nonMedicationKeywords = ['neurologist', 'doctor', 'physician'];

    final lines = text.split('\n');
    String currentCategory = '';

    for(var line in lines) {
      var lowerLine = line.toLowerCase().trim();
      if (lowerLine.isEmpty) continue;

      // Check for category headers first
      if (lowerLine.startsWith('diagnosis') || lowerLine.startsWith('تشخيص')) {
        currentCategory = 'diagnosis';
        continue;
      }
      if (lowerLine.startsWith('symptoms') || lowerLine.startsWith('اعراض')) {
        currentCategory = 'symptoms';
        continue;
      }
      if (lowerLine.startsWith('medication') || lowerLine.startsWith('علاج')) {
        currentCategory = 'meds';
        continue;
      }
      if (lowerLine.startsWith('test') || lowerLine.startsWith('تحاليل')) {
        currentCategory = 'tests_scans'; // Use a combined category
        continue;
      }

      // If it's not a category header, process the content line
      if (nonMedicationKeywords.any((kw) => lowerLine.contains(kw))) {
         continue; // Skip lines with professions
      }
      
      switch(currentCategory) {
        case 'diagnosis':
          diagnosis.add(line.trim());
          break;
        case 'symptoms':
          symptoms.add(line.trim());
          break;
        case 'meds':
          meds.add(Medication(name: line.trim(), dosage: '', frequency: ''));
          break;
        case 'tests_scans':
          // Here's the smarter logic: check if the line contains a scan keyword
          if (scanKeywords.any((kw) => lowerLine.contains(kw))) {
            scans.add(line.trim());
          } else {
            tests.add(line.trim());
          }
          break;
      }
    }
    
    return AnalysisResult(
      patientName: null, // Basic analysis can't reliably get this
      symptoms: symptoms,
      diagnosis: diagnosis,
      medications: meds,
      labTests: tests,
      radiologyScans: scans,
      rawText: text,
    );
  }
} 