بِسْــــــــــــــــــمِ اللهِ الرَّحْمَنِ الرَّحِيْمِ

# 📱 Syathiby App

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-blue) ![Dart](https://img.shields.io/badge/Dart-3.2.0-blue) ![Laravel](https://img.shields.io/badge/Laravel-8-red)

Mobile app development of [Ma'had Imam Asy-Syathiby](https://syathiby.id).

## 🔬 Demo Testing

**iOS App**

⏳ _Coming soon_

**Android App**

[![Download apk](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "Download apk")](https://raw.githubusercontent.com/CreatorB/flutter-syathiby/main/demo/universal.apk)

<div align="center" style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
  <br>
  <img src="https://raw.githubusercontent.com/CreatorB/flutter-syathiby/main/demo/app-login.png" alt="App Login" style="max-width: 250px; height: 250px;">
  <img src="https://raw.githubusercontent.com/CreatorB/flutter-syathiby/main/demo/app-dashboard.png" alt="App Dashboard" style="max-width: 250px; height: 250px;">
  <br>
</div>

**Web App**

[Al-Umm System Induk Mahad Syathiby - https://al-umm.syathiby.id](https://al-umm.syathiby.id)

<div align="center" style="display: flex; flex-wrap: wrap; justify-content: center; gap: 10px;">
  <br>
  <img src="https://raw.githubusercontent.com/CreatorB/flutter-syathiby/main/demo/web-login.png" alt="Web Login" style="max-width: 250px; height: 250px;">
  <img src="https://raw.githubusercontent.com/CreatorB/flutter-syathiby/main/demo/web-tapping.png" alt="Web Tapping" style="max-width: 250px; height: 250px;">
  <br>
</div>

## ✨ Key Features

- ✅ **WIP** – _Work in progress_.

## 🏗️ Tech Stack

- **Flutter (Dart)** – Cross-platform app development.
- **BLoC & Cubit** – State management.
- **Laravel (TALL Stack)** – Backend framework.
- **Alpine.js, Livewire** – Interactive UI components.
- **Tailwind CSS** – Modern styling framework.
- **MySQL** – Database management.

## 🚀 Installation & Setup

### 1️⃣ Prerequisites

Ensure you have installed:

- Flutter SDK → [Download Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio / VS Code
- Emulator or physical device

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/CreatorB/flutter-syathiby.git
cd flutter-syathiby
```

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

### 4️⃣ Run the Application

```bash
flutter run
```

To run on a specific platform:

```bash
flutter run -d android
flutter run -d ios
flutter run -d web
```

If you use fvm you can also debug by combine it commands

```
fvm flutter clean ; fvm flutter pub get ; fvm flutter run -d 127.0.0.1:5555 -v
```

You can also build apk by combine it fvm commands

```
flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
```

## 🏗️ Project Structure

Combined Structure | BLoC and Cubit

## 🛠️ Backend Setup (TALL Stack)

[Al-umm](https://github.com/CreatorB/al-umm.git)

## 📦 Build APK / iOS

To generate a **AAB (Android App Bundle)**:

```bash
flutter build appbundle
```

To generate a **APKS (for Android Testing)**:

- FVM (Flutter Version Management) / Split APK by structure

```bash
fvm flutter build apk --release --target-platform=android-arm,android-arm64 --split-per-abi
```

- [Bundletool](https://developer.android.com/studio/command-line/bundletool) (rename .apks to .zip and extract universal.apk from it)

```bash
java -jar D:\IT\HSN\Developments\sdk\bundletool-all-1.18.0.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app-release.apks --mode=universal --ks=D:\IT\HSN\Developments\android\keystrok\creatorbe-bundle.jks --ks-key-alias=xxx --ks-pass=pass:xxx --key-pass=pass:xxx
```

To generate a **release APK**:

```bash
flutter build apk
```

For **iOS (macOS required)**:

```bash
flutter build ios
```

## 📝 License

This project is licensed under the **MIT** license.

---

If you need further customization, let me know! 🚀

[Hasan IT Syathiby](https://wa.me/6289619060672) | [CreatorB](https://github.com/CreatorB)
