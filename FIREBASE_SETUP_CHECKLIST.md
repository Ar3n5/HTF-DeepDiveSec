# Firebase & Gemini API Setup Checklist

Before running the app, make sure you complete these steps:

## ☑️ Quick Checklist

- [ ] Firebase project created
- [ ] Billing enabled on Firebase project (required for Gemini)
- [ ] Firebase AI Logic API enabled
- [ ] `firebase_options.dart` configured (already done ✅)
- [ ] App tested with a simple query

## 📋 Detailed Steps

### 1. Firebase Project

If you haven't created a Firebase project yet:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or select existing project
3. Note your **Project ID** (you'll need this)

### 2. Enable Billing (Required for Gemini)

**Why:** Gemini API requires a billing account, but has a generous free tier.

1. In Firebase Console, go to **Settings** (⚙️) → **Usage and billing**
2. Click **Details and settings** under Spark plan
3. Click **Modify**
4. Select **Blaze (Pay as you go)**
5. Add payment method

**Free Tier:** Up to 1500 requests/day with Gemini API at no cost.

### 3. Enable Firebase Vertex AI API

**Method 1: Via Google Cloud Console (Recommended)**

1. Visit this URL (replace `YOUR-PROJECT-ID`):
   ```
   https://console.developers.google.com/apis/api/firebasevertexai.googleapis.com/overview?project=YOUR-PROJECT-ID
   ```
2. Click **"Enable"** button
3. Wait 5-10 minutes for changes to propagate

**Method 2: Via Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Build → AI Logic → Apps**
4. Click **"Get started"** or **"Enable"**
5. Choose **"Gemini Developer API"**
6. Select platforms you're using (Android/iOS/Web)
7. Confirm setup and wait for **"Enabled"** status
8. Wait 5-10 minutes for changes to propagate

### 4. Verify firebase_options.dart

You should already have this file at `lib/firebase_options.dart`.

If not, or if you need to regenerate it:

```bash
# Make sure FlutterFire CLI is installed
dart pub global activate flutterfire_cli

# Make sure it's in your PATH (you already did this)
# Then configure
flutterfire configure --project YOUR-PROJECT-ID
```

Select the platforms you want to support when prompted.

### 5. Test the App

```bash
flutter run
```

Try a simple query:
```
"What is the ocean temperature in the North Sea?"
```

Expected behavior:
- Agent log should show all 5 phases (Perceive, Plan, Act, Reflect, Present)
- You should see UI cards with ocean data
- Mock data should be used (look for "Using mock data" in logs)

### 6. Troubleshooting

#### Error: "API not enabled"

**Solution:**
- Wait 10-15 minutes after enabling the API
- Restart your app
- Verify billing is enabled
- Check [API Status](https://console.cloud.google.com/apis/api/firebasevertexai.googleapis.com)

#### Error: "Quota exceeded"

**Solution:**
- Check your [Firebase quota usage](https://console.firebase.google.com/project/_/usage)
- Free tier: 1500 requests/day
- Wait for quota reset (daily) or upgrade plan

#### App crashes on startup

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### No response from Gemini

**Solution:**
- Check agent log for errors (enable with eye icon)
- Look for network errors
- Verify internet connection
- App should fall back to text responses if UI generation fails

## ✅ You're Done!

Once all checkboxes are marked, your app is ready to use with Gemini AI!

The app will:
- Use Gemini LLM to understand your questions
- Generate appropriate UI visualizations
- Show you the agent's thinking process in real-time
- Fall back to mock data when needed

## 🔗 Helpful Links

- [Firebase Console](https://console.firebase.google.com)
- [Google Cloud Console APIs](https://console.cloud.google.com/apis)
- [Gemini API Documentation](https://ai.google.dev/docs)
- [Firebase Pricing](https://firebase.google.com/pricing)
- [FlutterFire Documentation](https://firebase.flutter.dev)

## 💡 Tips

1. **Start Small**: Begin with simple queries to test everything works
2. **Watch Agent Logs**: Enable the log panel to see what's happening
3. **Mock Data**: The app works offline with realistic test data
4. **Rate Limits**: Be mindful of the 1500 requests/day free tier limit
5. **Billing Alerts**: Set up billing alerts in Google Cloud Console

---

**Need Help?** Check the [SETUP_GUIDE.md](./SETUP_GUIDE.md) for more details.

