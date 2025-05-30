# translator_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🚀 Translation Service Setup

This app uses [LibreTranslate](https://libretranslate.com/). To enable translation:

### Option 1: Use public API (requires free API key)
1. Get your key from [https://libretranslate.com](https://libretranslate.com)
2. Insert it in `translation_service.dart`:

```dart
static const String _apiKey = 'YOUR_API_KEY';
