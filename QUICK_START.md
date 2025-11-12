# 🚀 Quick Start Guide - Agentic Ocean Explorer

Get your ocean exploration app running in 3 minutes!

## Step 1: Check Prerequisites ✓

```bash
flutter --version
```

Make sure you have:
- Flutter ≥ 3.35.7
- Dart ≥ 3.9

## Step 2: Install Dependencies

```bash
flutter pub get
```

## Step 3: Configure Firebase (5 minutes)

⚠️ **Important:** Firebase setup is required for the LLM to work!

### Quick Firebase Setup

1. **Go to** [Firebase Console](https://console.firebase.google.com)
2. **Select your project** or create new one
3. **Enable Billing** (Blaze plan - has free tier!)
   - Settings → Usage and billing → Modify → Blaze
4. **Enable AI API** by visiting:
   ```
   https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=YOUR-PROJECT-ID
   ```
   Click "Enable" and wait 5 minutes

5. **Already done for you:** `firebase_options.dart` is configured ✅

For detailed steps, see [FIREBASE_SETUP_CHECKLIST.md](./FIREBASE_SETUP_CHECKLIST.md)

## Step 4: Run the App

```bash
flutter run
```

Or for web:
```bash
flutter run -d chrome
```

## Step 5: Try It Out!

Once the app opens:

1. **Enable Agent Log**: Click the eye icon (👁️) in the top right
2. **Ask a question**: Type in the text field at the bottom
3. **Watch the magic**: See the agent log show each step!

### Example Questions to Try

```
What is the ocean temperature in the North Sea?
```

```
Show me salinity trends in the Atlantic Ocean
```

```
Where were the highest waves measured?
```

```
What are all the ocean conditions in the Mediterranean?
```

## 🎯 What to Expect

### Agent Log Will Show:
- 👁️ **Perceive**: Understanding your question
- 🧠 **Plan**: Deciding visualization strategy  
- ⚡ **Act**: Fetching ocean data (mock data)
- 🤔 **Reflect**: Analyzing the results
- 🎨 **Present**: Creating the UI

### The UI Will Display:
- Cards with ocean measurements
- Current values with units (°C, PSU, meters, etc.)
- Statistics (min/max/avg)
- Location information
- Trend descriptions

## 🐛 Quick Troubleshooting

### "API not enabled" error?
→ Wait 10 minutes after enabling Firebase AI API, then restart app

### Nothing happening when you ask?
→ Check agent log (eye icon) for error messages

### App not building?
```bash
flutter clean
flutter pub get
flutter run
```

### No Firebase project?
→ Follow [FIREBASE_SETUP_CHECKLIST.md](./FIREBASE_SETUP_CHECKLIST.md)

## 📱 Platform Notes

### Web
Works great! Best for development and testing.
```bash
flutter run -d chrome
```

### Android/iOS
Make sure you've configured Firebase for mobile platforms:
```bash
flutterfire configure --project YOUR-PROJECT-ID
```

### Desktop (Windows/Mac/Linux)
Supported! Web/Desktop are the easiest for this hackathon.

## ✨ Pro Tips

1. **Keep Agent Log Open**: It's educational to see how the agent thinks!
2. **Be Specific**: "Temperature in North Sea" is better than "show temperature"
3. **One Topic**: Ask about one measurement at a time
4. **Mock Data**: Currently uses realistic test data - perfect for demos!
5. **Abort Button**: Long requests? Click "Abort" during processing

## 🎉 Success!

If you see the agent log fill up and UI cards appear, you're successful!

The agent is now:
- ✅ Understanding natural language
- ✅ Planning responses intelligently
- ✅ Generating dynamic UIs
- ✅ Showing transparent logging
- ✅ Working offline with mock data

## 📚 Next Steps

- Read [SETUP_GUIDE.md](./SETUP_GUIDE.md) for full documentation
- Check [FIREBASE_SETUP_CHECKLIST.md](./FIREBASE_SETUP_CHECKLIST.md) for Firebase details
- Explore the code in `lib/features/`
- Try customizing the agent prompt in `lib/features/chat/services/genui_service.dart`

## 🏆 Hackathon Ready!

Your Agentic Ocean Explorer demonstrates:
- ✅ LLM Integration (Gemini via Firebase AI)
- ✅ Agent Architecture (Perceive → Plan → Act → Reflect → Present)
- ✅ Dynamic UI Generation (GenUI)
- ✅ Transparent Agent Logging
- ✅ Robust Fallback System (Mock Data)
- ✅ Modern Flutter UI

**Good luck with your hack! 🌊**

---

Need help? Check the agent log first - it usually shows what's wrong!

