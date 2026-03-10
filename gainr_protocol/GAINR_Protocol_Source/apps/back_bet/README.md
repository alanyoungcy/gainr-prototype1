# GAINR Frontend (Flutter Mobile App)

Cross-platform mobile application for the **GAINR Protocol** decentralized sports betting platform.

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── main.dart           # App entry point
│   ├── screens/            # Screen widgets (Dashboard, Markets, etc.)
│   ├── theme/              # Design system (colors, typography)
│   └── widgets/            # Reusable UI components
├── windows/                # Windows platform files
├── pubspec.yaml            # Flutter dependencies
└── README.md               # This file
```

## 🛠️ Prerequisites

1.  **Flutter SDK** (3.0+)
    -   [Install Flutter](https://docs.flutter.dev/get-started/install)
    -   Verify: `flutter doctor`

2.  **IDE** (Recommended)
    -   VS Code with Flutter extension
    -   Android Studio with Flutter plugin

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Run the App

**For Web:**
```bash
flutter run -d chrome
```

**For Windows:**
```bash
flutter run -d windows
```

**For Android (emulator or device):**
```bash
flutter run -d android
```

**For iOS (macOS only):**
```bash
flutter run -d ios
```

## 🏗️ Build for Production

**Web:**
```bash
flutter build web
```

**Android APK:**
```bash
flutter build apk --release
```

**Windows:**
```bash
flutter build windows
```

## 🔗 Connecting to Backend

The app connects to the Solana blockchain via RPC. Configuration:

| Environment | RPC Endpoint                            |
| ----------- | --------------------------------------- |
| Localnet    | `http://localhost:8899`                 |
| Devnet      | `https://api.devnet.solana.com`         |
| Mainnet     | `https://api.mainnet-beta.solana.com`   |

See [CONNECTION_GUIDE.md](../CONNECTION_GUIDE.md) for full integration details.

## 🧪 Testing

```bash
flutter test
```

## 📦 Key Dependencies

| Package        | Purpose                     |
| -------------- | --------------------------- |
| `google_fonts` | Custom typography           |
| `lucide_icons` | Modern icon set             |
