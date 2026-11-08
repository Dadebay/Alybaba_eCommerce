# Alybaba

Alybaba is a Flutter marketplace app for browsing products, managing a cart, placing orders, and tracking deliveries. The Android app is available on [Google Play](https://play.google.com/store/apps/details?id=com.gurbanow.alybaba).

## Development

Use Flutter 3.47.8, Dart 3.13, and JDK 17. Android uses application ID `com.gurbanow.alybaba`; the existing iOS Runner uses `com.bilermennesil.alybaba`. Confirm the iOS identifier with the App Store record before an iOS release.

```sh
flutter pub get
flutter run
flutter analyze --no-fatal-infos
flutter test
flutter build apk --debug
flutter build ios --simulator --no-codesign
```

The app starts from `lib/main.dart`. API clients are under `lib/app/data/services`, screens under `lib/app/modules`, and bundled assets under `assets`. Firebase configuration files for the Android and iOS app IDs are already included. Keep signing files and server credentials out of Git.

## Release prerequisites

The backend address in `lib/app/constants/constants.dart` currently uses plain HTTP. The HTTPS certificate for `alybaba.com.tm` expired on **22 September 2026**. Renew the certificate and move all API calls and media URLs to HTTPS before publishing another app version. Authentication, customer details, and orders must not travel over HTTP. The app no longer disables certificate verification globally, but its current HTTP API remains a release blocker.

Android release builds require `android/key.properties` and the matching upload keystore. The release build no longer falls back to the debug signing key. Verify the upload certificate against the existing Google Play app, then test login, checkout, payments, notifications, and order history on a real device before publishing. The OTP endpoints currently return a code that the app displays; confirm the intended production SMS flow before release.

CI checks analysis, the auth storage regression test, and unsigned debug or simulator builds. A passing CI run does not replace backend, payment, or device testing.

Iconly font assets come from [flutter_iconly](https://github.com/m-noer/flutter_iconly); see [third party notices](THIRD_PARTY_NOTICES.md).
