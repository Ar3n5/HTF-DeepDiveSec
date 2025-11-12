/// API Keys configuration
/// 
/// To use the direct Gemini API:
/// 1. Get your API key from: https://aistudio.google.com/app/apikey
/// 2. Replace 'YOUR_GEMINI_API_KEY_HERE' with your actual key
/// 
/// IMPORTANT: Never commit your actual API key to git!
/// Add this file to .gitignore in production.
class ApiKeys {
  // Replace with your Gemini API key from https://aistudio.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Set to true to use direct Gemini API instead of Firebase Vertex AI
  static const bool useDirectGeminiApi = true;
}

