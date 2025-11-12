# Nautilus AI - Setup & Usage Guide

## 🌊 What You've Built

An intelligent Flutter app that answers questions about ocean conditions using:
- **Gemini LLM** for understanding queries and generating responses
- **Flutter GenUI** for creating dynamic UI visualizations
- **Agent Loop Architecture** (Perceive → Plan → Act → Reflect → Present)
- **Mock Ocean Data** with fallback support for MCP integration
- **Transparent Agent Logging** showing what the agent is thinking

## ✅ Completed Features

### Core Functionality
- ✅ **Question Interface**: Users can ask ocean-related questions
- ✅ **Gemini LLM Integration**: Firebase AI with Gemini configured
- ✅ **GenUI Visualization**: Dynamic UI generation from LLM responses
- ✅ **Agent Logging**: Transparent run-log showing agent workflow
- ✅ **Mock Data Fallback**: Works offline with realistic ocean data

### UI Components
- ✅ **Agent Run Log**: Toggle-able panel showing agent steps
- ✅ **Stop/Abort Button**: Control during processing
- ✅ **Clear Logs**: Reset agent log history
- ✅ **Processing Indicator**: Shows when agent is working
- ✅ **Responsive Chat UI**: Scrollable message history

### Architecture
- ✅ **Ocean Data Models**: Structured data for temperature, salinity, waves, etc.
- ✅ **MCP Service Layer**: Ready for real ocean data integration
- ✅ **Mock Data Service**: Generates realistic test data
- ✅ **Agent Log System**: Tracks Perceive → Plan → Act → Reflect → Present

## 🚀 Getting Started

### Prerequisites

1. **Flutter & Dart**
   - Flutter ≥ 3.35.7
   - Dart ≥ 3.9
   - Check with: `flutter --version`

2. **Firebase Project** (if not already set up)
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Billing (required for Gemini API)

### Setup Steps

#### 1. Check Your Firebase Configuration

Your project already has `firebase_options.dart`. If you need to reconfigure:

```bash
# Install FlutterFire CLI (already done)
dart pub global activate flutterfire_cli

# Configure Firebase (if needed)
flutterfire configure --project <your-firebase-project-id>
```

#### 2. Enable Firebase AI Logic API

**Option A: Via Google Cloud Console**
1. Go to: https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=<your-project-id>
2. Click "Enable"

**Option B: Via Firebase Console**
1. Go to Firebase Console → Build → AI Logic → Apps
2. Click "Get started" / "Enable"
3. Choose "Gemini Developer API"
4. Select platforms (Android/iOS/Web)
5. Confirm status is "Enabled"

Wait a few minutes for changes to propagate.

#### 3. Install Dependencies

```bash
flutter pub get
```

#### 4. Run the App

```bash
# For development
flutter run

# For web
flutter run -d chrome

# For specific device
flutter devices  # List devices
flutter run -d <device-id>
```

## 💬 How to Use

### Basic Queries

Ask natural language questions about the ocean:

**Temperature Queries:**
- "What is the ocean temperature in the North Sea?"
- "Show me temperature trends in the Atlantic over the past month"

**Salinity Queries:**
- "What's the salinity in the Mediterranean Sea?"
- "Show me salinity trends in the Pacific Ocean"

**Wave Data:**
- "Where were the highest waves measured?"
- "What's the wave height in the Southern Ocean?"

**Multiple Measurements:**
- "Show me all ocean conditions in the Caribbean Sea"
- "What are the current measurements in the North Atlantic?"

### Agent Log

- **Toggle Log**: Click the eye icon (👁️) in the app bar
- **Clear Logs**: Click the trash icon (🗑️) in the app bar
- **Log Colors**:
  - 👁️ Cyan = Perceive (understanding query)
  - 🧠 Purple = Plan (determining strategy)
  - ⚡ Yellow = Act (fetching data)
  - 🤔 Orange = Reflect (analyzing results)
  - 🎨 Green = Present (creating UI)
  - ❌ Red = Error
  - ℹ️ Gray = Info

### Stop/Abort

If the agent is taking too long:
- Click the **"Abort"** button that appears during processing
- The agent will stop and you can try a different query

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase configuration
├── features/
│   ├── chat/                          # Chat/conversation feature
│   │   ├── models/
│   │   │   ├── chat_message.dart      # Message model
│   │   │   └── agent_log.dart         # Agent logging model
│   │   ├── services/
│   │   │   └── genui_service.dart     # GenUI & Gemini setup
│   │   ├── view/
│   │   │   └── chat_screen.dart       # Main chat UI
│   │   └── viewmodel/
│   │       └── chat_view_model.dart   # Chat logic & state
│   └── ocean/                         # Ocean data feature
│       ├── models/
│       │   └── ocean_data.dart        # Ocean data structures
│       ├── services/
│       │   ├── mock_ocean_data_service.dart  # Mock data generator
│       │   └── ocean_mcp_service.dart        # MCP integration layer
│       └── widgets/
│           └── ocean_catalog_items.dart      # GenUI catalog
└── l10n/                              # Localization
```

## 🔧 Customization

### Add More Ocean Measurements

Edit `lib/features/ocean/models/ocean_data.dart`:

```dart
enum OceanMeasurementType {
  temperature,
  salinity,
  waveHeight,
  yourNewMeasurement,  // Add here
  // ...
}
```

### Modify Mock Data

Edit `lib/features/ocean/services/mock_ocean_data_service.dart` to adjust:
- Base values for measurements
- Variation ranges
- Number of data points
- Trend patterns

### Customize Agent Prompt

Edit `lib/features/chat/services/genui_service.dart`:
- Modify `_oceanExplorerPrompt` to change agent behavior
- Add new example interactions
- Adjust agent loop instructions

### Add Real MCP Integration

When you have a real ocean data API:

1. Update `lib/features/ocean/services/ocean_mcp_service.dart`
2. Set `mcpEndpoint` to your API URL
3. Implement the API call logic in the fetch methods
4. The service automatically falls back to mock data if MCP fails

## 🎯 Success Criteria (MVP)

✅ **User can ask ocean questions** - Works!
✅ **Gemini LLM is integrated** - Firebase AI configured
✅ **GenUI shows data visually** - Dynamic UI generation
✅ **Run-log shows transparency** - Agent log panel
✅ **App works with mock data** - Fallback system in place

## 🚀 Stretch Goals (Optional Enhancements)

### GenUI Improvements
- [ ] Add custom OceanDataCard component
- [ ] Add OceanLineChart for time series
- [ ] Add OceanLocationPin for map markers
- [ ] Add OceanStatsSummary widget
- [ ] Custom styling and themes

### App Polish
- [ ] Loading animations during data fetch
- [ ] Better error messages
- [ ] Dark/light mode toggle
- [ ] Smooth screen transitions

### User Experience
- [ ] Query history (last 5 questions)
- [ ] Favorites system
- [ ] Share results via screenshot
- [ ] Voice input for queries

### Data Integration
- [ ] Connect to real ocean data API
- [ ] Add caching for offline use
- [ ] Real-time data updates
- [ ] Historical data comparison

## 🐛 Troubleshooting

### Firebase Error: "API not enabled"

**Solution:**
1. Wait 5-10 minutes after enabling the API
2. Restart the app
3. Check billing is enabled on Firebase project

### "Cannot connect to MCP"

**This is expected!** The app uses mock data by default.
- Check logs: Should say "Using mock data"
- No action needed unless you have a real MCP endpoint

### GenUI not showing responses

**Check:**
1. Agent log shows "Present" steps
2. No errors in the log
3. Try simpler query: "What is ocean temperature?"

### Agent log not appearing

- Click the eye icon (👁️) in the app bar to toggle visibility
- Check that queries are being sent

## 📝 Tips for Best Results

1. **Be Specific**: "What is the temperature in the North Sea?" is better than "Tell me about temperature"

2. **One Topic at a Time**: Ask about one measurement or region per query

3. **Watch the Agent Log**: Learn how the agent breaks down your question

4. **Use Natural Language**: The agent understands conversational queries

5. **Check Mock Data Disclaimer**: Remember the app uses simulated data currently

## 📚 Resources

- [Flutter GenUI GitHub](https://github.com/flutter/genui) - Official GenUI docs
- [Gemini API Documentation](https://ai.google.dev/docs) - LLM integration
- [Firebase Documentation](https://firebase.google.com/docs) - Firebase setup
- [Flutter Documentation](https://flutter.dev/docs) - Flutter guides

## 🎉 You're Ready!

Your Agentic Ocean Explorer is ready to use! Try asking it questions about the ocean and watch the agent log to see how it processes your queries.

**Example First Query:**
```
"What is the ocean temperature in the North Sea over the past month?"
```

Watch the agent log to see:
- 👁️ Perceive: Understanding your question
- 🧠 Plan: Deciding how to visualize
- ⚡ Act: Fetching mock data
- 🤔 Reflect: Analyzing results
- 🎨 Present: Creating the UI

Have fun exploring the ocean! 🌊

