# Architecture Overview - Agentic Ocean Explorer

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           ChatScreen (Flutter Widget)                 │   │
│  │  • Message Display                                    │   │
│  │  • Agent Log Panel (Toggle-able)                      │   │
│  │  • Input Field & Send Button                          │   │
│  │  • Stop/Abort Control                                 │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                     View Model Layer                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           ChatViewModel (State Management)            │   │
│  │  • Message List                                       │   │
│  │  • Agent Log Entries                                  │   │
│  │  • Processing State                                   │   │
│  │  • Log Toggle State                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Service Layer                             │
│  ┌──────────────────┐         ┌──────────────────────────┐  │
│  │  GenUiService    │         │  OceanMcpService         │  │
│  │  • Catalog       │────────▶│  • MCP Integration       │  │
│  │  • Generator     │         │  • Mock Data Fallback    │  │
│  │  • System Prompt │         │  • API Client            │  │
│  └──────────────────┘         └──────────────────────────┘  │
└──────────────────────┬──────────────────┬──────────────────┘
                       │                  │
                       ▼                  ▼
┌────────────────────────────┐  ┌─────────────────────────────┐
│   Firebase AI / Gemini     │  │   MockOceanDataService      │
│   • LLM Processing         │  │   • Time Series Data        │
│   • Agent Loop Execution   │  │   • Location Data           │
│   • JSON Generation        │  │   • Regional Summaries      │
└────────────────────────────┘  └─────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   GenUI Framework                            │
│  • GenUiManager (Widget Registry)                           │
│  • GenUiConversation (LLM ↔ UI Bridge)                      │
│  • Core Catalog (Text, Card, Column, Row, etc.)             │
│  • Surface Management (Dynamic UI Rendering)                │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Module Breakdown

### 1. Chat Feature (`lib/features/chat/`)

#### Models
- **`chat_message.dart`**: Message data structure
  - Supports text and GenUI surface messages
  - Handles user/AI/error message types

- **`agent_log.dart`**: Agent logging system
  - 5 log types: Perceive, Plan, Act, Reflect, Present
  - Timestamp tracking
  - Pretty-print formatting

#### Services
- **`genui_service.dart`**: GenUI & Gemini configuration
  - Creates catalog with ocean-focused widgets
  - Configures Gemini LLM with system prompt
  - Defines agent loop instructions

#### ViewModels
- **`chat_view_model.dart`**: Chat state management
  - Message history
  - Agent log management
  - Processing state
  - GenUI conversation lifecycle

#### Views
- **`chat_screen.dart`**: Main UI
  - Chat message list
  - Agent log panel (collapsible)
  - Input controls
  - Stop/Abort button

### 2. Ocean Feature (`lib/features/ocean/`)

#### Models
- **`ocean_data.dart`**: Ocean data structures
  - `OceanDataPoint`: Single measurement
  - `OceanTimeSeries`: Time-series data
  - `OceanLocation`: Geographic data
  - `OceanMeasurementType`: Enum of measurements

#### Services
- **`ocean_mcp_service.dart`**: MCP integration layer
  - Connects to real ocean data APIs
  - Automatic fallback to mock data
  - Health check and retry logic
  - Error handling

- **`mock_ocean_data_service.dart`**: Mock data generator
  - Realistic ocean measurement values
  - Time-series generation
  - Location-based data
  - Regional summaries

#### Widgets
- **`ocean_catalog_items.dart`**: GenUI catalog
  - Currently uses CoreCatalogItems
  - Placeholder for custom ocean widgets
  - Future: OceanDataCard, OceanLineChart, etc.

## 🔄 Agent Loop Flow

```
User Query: "What is the temperature in the North Sea?"
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  1. PERCEIVE (👁️)                                           │
│  • Extract: measurement = "temperature"                      │
│  • Extract: region = "North Sea"                             │
│  • Extract: time = "current"                                 │
│  • Log: "User query: What is the temperature..."            │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  2. PLAN (🧠)                                                │
│  • Determine: Need current + historical temperature          │
│  • Decide: Show current value + statistics                   │
│  • Select: Cards with Text widgets                           │
│  • Log: "Planning response strategy..."                      │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  3. ACT (⚡)                                                 │
│  • Check: MCP available? → No                                │
│  • Action: Fetch mock data for North Sea temperature         │
│  • Generate: 30 days of temperature data                     │
│  • Log: "Using mock data for temperature in North Sea"       │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  4. REFLECT (🤔)                                             │
│  • Analyze: Current temp 15.2°C                              │
│  • Insight: Trend shows +1.5°C increase                      │
│  • Decision: Show current + trend + stats                    │
│  • Log: "Analyzing results..."                               │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│  5. PRESENT (🎨)                                             │
│  • Generate: JSON schema for GenUI                           │
│  • Create: Column with:                                      │
│    - Card("Current Temperature: 15.2°C")                     │
│    - Card("Min: 13.5°C | Max: 16.8°C | Avg: 15.1°C")        │
│    - Card("Trend: +1.5°C over 30 days")                      │
│  • Render: GenUI creates Flutter widgets                     │
│  • Log: "Created UI surface"                                 │
└─────────────────────────────────────────────────────────────┘
                       ▼
                  Display to User
```

## 🎯 Data Flow

### Query Processing Flow

```
ChatScreen → ChatViewModel → GenUiConversation → Gemini LLM
                    │                                  │
                    │ (Agent Log Events)               │
                    │                                  │
                    ▼                                  ▼
              Agent Log List              (Agent processes query)
                                                      │
                                                      ▼
                                          (Generates JSON Schema)
                                                      │
                                                      ▼
                                          GenUiManager interprets
                                                      │
                                                      ▼
                                          GenUiSurface renders
                                                      │
                                                      ▼
                                          ChatScreen displays
```

### Ocean Data Flow

```
User Query → Gemini → (Future: MCP Tool Call)
                              │
                              ▼
                      OceanMcpService
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
              Check MCP Health      Mock Data
                    │                   Service
                    │                      │
              (Available?)                 │
                    │                      │
         ┌──────────┴──────────┐          │
         ▼                     ▼          ▼
    Real API Call         Mock Data Generation
         │                          │
         └──────────┬───────────────┘
                    ▼
            Ocean Data Result
                    │
                    ▼
               Return to LLM
                    │
                    ▼
            Present in UI
```

## 🗂️ File Structure

```
lib/
├── main.dart                               # App entry & Firebase init
├── firebase_options.dart                   # Firebase config (auto-generated)
│
├── features/
│   ├── chat/                               # Chat/Conversation feature
│   │   ├── models/
│   │   │   ├── chat_message.dart           # Message data model
│   │   │   └── agent_log.dart              # Agent log entry model
│   │   │
│   │   ├── services/
│   │   │   └── genui_service.dart          # GenUI & Gemini setup
│   │   │
│   │   ├── view/
│   │   │   └── chat_screen.dart            # Main chat UI
│   │   │
│   │   └── viewmodel/
│   │       └── chat_view_model.dart        # Chat state & logic
│   │
│   └── ocean/                              # Ocean data feature
│       ├── models/
│       │   └── ocean_data.dart             # Ocean data structures
│       │
│       ├── services/
│       │   ├── ocean_mcp_service.dart      # MCP client
│       │   └── mock_ocean_data_service.dart # Mock data generator
│       │
│       └── widgets/
│           └── ocean_catalog_items.dart     # GenUI catalog
│
└── l10n/                                   # Localization
    ├── app_localizations.dart              # Base class
    ├── app_localizations_en.dart           # English
    ├── app_localizations_nl.dart           # Dutch
    ├── app_en.arb                          # English strings
    └── app_nl.arb                          # Dutch strings
```

## 🔌 Key Integrations

### Firebase AI / Gemini
- **Purpose**: LLM for understanding queries and generating UI
- **Configuration**: `lib/features/chat/services/genui_service.dart`
- **Model**: Gemini (via Firebase Vertex AI)
- **System Prompt**: Defines agent behavior and ocean domain knowledge

### Flutter GenUI
- **Purpose**: Dynamic UI generation from JSON schemas
- **Components**: Text, Card, Column, Row, TextField, Button
- **Catalog**: `CoreCatalogItems.asCatalog()`
- **Future**: Custom ocean visualization widgets

### MCP (Model Context Protocol)
- **Purpose**: Connect to real ocean data APIs
- **Current**: Mock data fallback
- **Future**: Real-time sensor data, historical databases
- **Service**: `OceanMcpService` with automatic fallback

## 🧩 Design Patterns

### MVVM (Model-View-ViewModel)
- **Models**: Data structures (chat messages, ocean data)
- **Views**: Flutter widgets (chat screen)
- **ViewModels**: State management & business logic

### Repository Pattern
- **Interface**: `OceanMcpService`
- **Implementations**: Real API + Mock fallback
- **Benefit**: Easy to swap data sources

### Observer Pattern
- **ChangeNotifier**: `ChatViewModel`
- **Listeners**: `AnimatedBuilder` in UI
- **Updates**: Automatic UI refresh on state change

### Strategy Pattern
- **Context**: Data fetching
- **Strategies**: Real MCP vs Mock Data
- **Selection**: Based on MCP availability

## 🔒 Error Handling

### Graceful Degradation
1. **MCP Unavailable** → Mock Data
2. **Gemini Error** → Text Response
3. **UI Generation Fails** → Plain Text
4. **Network Issues** → Offline Mode (Mock)

### Error Logging
- All errors logged to Agent Log
- User-friendly error messages
- Technical details in logs for debugging

## 📈 Scalability Considerations

### Current Architecture Supports:
- ✅ Multiple data sources (MCP + Mock)
- ✅ Custom widget catalog extension
- ✅ Localization (EN/NL)
- ✅ Platform independence (Web/Mobile/Desktop)

### Future Extensions:
- [ ] Real-time data streaming
- [ ] User authentication
- [ ] Saved queries/favorites
- [ ] Custom visualization library
- [ ] Multi-agent collaboration
- [ ] Voice input/output

## 🎓 Learning Resources

- **Flutter GenUI**: [github.com/flutter/genui](https://github.com/flutter/genui)
- **Firebase AI**: [firebase.google.com/docs/ai](https://firebase.google.com/docs/ai)
- **Gemini API**: [ai.google.dev](https://ai.google.dev)
- **Agent Architecture**: See `_oceanExplorerPrompt` in `genui_service.dart`

---

This architecture balances:
- 🎯 **Simplicity**: Easy to understand and modify
- 🔄 **Flexibility**: Swap components easily
- 🚀 **Scalability**: Ready for real data sources
- 🛡️ **Robustness**: Graceful fallbacks everywhere

