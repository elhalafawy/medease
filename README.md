# MedEase - Your Personal Healthcare Companion

## Project Overview

MedEase is a sophisticated mobile application designed to empower individuals in proactively managing their health and medical information. Built with Flutter for a seamless cross-platform experience, MedEase provides a comprehensive suite of tools for medical record management, medication tracking, and intelligent document processing. Leveraging robust backend services from Supabase, Firebase Authentication, and the advanced capabilities of Google's Gemini API, MedEase streamlines the process of digitizing and understanding medical documents, ultimately aiming to improve patient engagement and health outcomes.

## Core Features

MedEase offers a range of features tailored to provide a powerful and intuitive healthcare management experience:

*   **Intelligent Medical Document Analysis:** Utilize cutting-edge Optical Character Recognition (OCR) powered by Google ML Kit to extract text from prescriptions, lab reports, and other medical documents. Further processed by Google's Gemini API, the extracted text is semantically analyzed and categorized into key medical information such as Diagnosis, Medications, Required Tests, Required Scans, and Symptoms.
*   **Streamlined Medication Reminders:** Effortlessly add medications to your personal list and set customizable reminders to ensure adherence to your treatment plan. Medication names can be automatically populated from the intelligent document analysis results, reducing manual data entry.
*   **Organized Medical Records:** Maintain a digital repository of your medical history. Easily view past records, including diagnoses, tests, scans, and medications. (Note: This feature is currently showcasing sample data; future development will focus on integrating dynamically saved analysis results from Supabase).
*   **Appointment Management:** (Existing/Planned Feature) Schedule and manage appointments with healthcare providers directly through the app.
*   **Healthcare Provider Interaction:** (Existing/Planned Feature) Features to view doctor profiles, potentially receive digital prescriptions, and facilitate communication.

## Technical Architecture

MedEase is built upon a modern and scalable technical foundation:

### Frontend

*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Navigation:** Go Router
*   **OCR:** Google ML Kit Text Recognition
*   **AI Analysis:** Google Generative AI (Gemini API)
*   **UI/UX:** Material Design principles for a clean and intuitive user interface.

### Backend

*   **Database (Primary):** Supabase - Provides the main database for storing patient data, medical records, medications, etc.
*   **Authentication:** Firebase Authentication - Handled separately for user authentication.
*   **Storage:** Firebase Storage - Used for file storage (e.g., uploaded document images).
*   **Cloud Functions:** Firebase Cloud Functions (Existing/Planned for backend logic).

## Getting Started

To set up and run MedEase locally, follow these steps:

### Prerequisites

*   Flutter SDK ([Installation Guide](https://flutter.dev/docs/get-started/install))
*   Dart SDK
*   A Google account for Firebase and Google Cloud/AI Studio
*   A Supabase account
*   An IDE such as Android Studio or VS Code with Flutter and Dart plugins.

### Installation and Configuration

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/elhalafawy/medease.git
    cd medease
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Supabase:**
    *   Create a new Supabase project or use an existing one.
    *   Obtain your Supabase Project URL and `anon` Public Key from your project settings.
    *   Update the `Supabase.initialize` call in `lib/main.dart` with your specific URL and Anon Key.
    *   Set up your database schema in Supabase (e.g., tables for `users`, `patients`, `medications`, `medical_records`). Refer to the application's code and data models for required structures.

4.  **Configure Firebase:**
    *   Create a new Firebase project or use an existing one.
    *   Add your Android and iOS apps to the Firebase project.
    *   Download the configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) and place them in the correct project directories.
    *   Enable Firebase Authentication and Firebase Storage in your Firebase console.

5.  **Configure Google Gemini API:**
    *   Navigate to Google AI Studio (https://makersuite.google.com/app/apikey) or the Google Cloud console to obtain a Gemini API key.
    *   Open the file `lib/core/config/api_keys.dart` and replace the placeholder with your actual Gemini API key.
    *   **Crucially, ensure `lib/core/config/api_keys.dart` is added to your `.gitignore` file** to prevent your API key from being committed to version control.

6.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

```
medease/
├── lib/
│   ├── core/
│   │   ├── config/         # API Keys and other configuration constants
│   │   ├── firebase/       # Firebase service implementations (Authentication, Storage)
│   │   ├── providers/      # State management providers (Auth, Analysis Result, etc.)
│   │   ├── routes/         # Application routing setup
│   │   └── supabase/       # Supabase service implementations (Database interactions)
│   ├── features/
│   │   ├── auth/           # Authentication related screens and logic
│   │   ├── doctor/         # Doctor specific features (existing/planned)
│   │   ├── home/           # Home screen and related features (Medical Records, Medications)
│   │   │   └── screens/
│   │   ├── appointment/    # Appointment scheduling features
│   │   ├── profile/        # User profile management
│   │   └── upload/         # OCR and Document Analysis feature
│   │       ├── models/     # Data models for analysis results, etc.
│   │       └── screens/    # UI screens for the upload and analysis flow
│   └── main.dart           # Application entry point and initial setup
├── test/
├── ... (other project files)
└── README.md
```

## Contributing

We welcome contributions to MedEase! If you're interested in contributing, please fork the repository and submit a pull request. Ensure your code adheres to the project's coding standards and includes relevant tests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For any questions, suggestions, or inquiries, please open an issue on the GitHub repository or contact us at [ahmed.elhlafawy@gmail.com].