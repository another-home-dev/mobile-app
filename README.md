# Another Home — Student Mobile App

The Android app students use to live in the hostel: view their room, pay invoices, report maintenance issues, request visitor passes, and read notices and alerts.

Part of [Another Home](https://github.com/another-home-dev). Hostel staff use the [web dashboard](https://github.com/another-home-dev/another-home-fronntend) instead.

## Features

| Tab or screen | What students can do |
| --- | --- |
| Home | See their room, next payment and unread alerts; open the other modules |
| Room | Room number, floor, designation, air conditioning, rent, roommates |
| Payments | See invoices (Pending, Overdue, Paid) and pay one with a reference number |
| Alerts | Read alerts such as payment received and payment reminders; unread count on the tab |
| Profile | View and edit personal details, log out |
| Maintenance | Report an issue with a category, description and optional photo; follow its status |
| Visitors | Request a visitor pass and see whether it was approved |
| Notices | Read announcements from the warden |

Students sign in with Asgardeo. If a warden registered them first, the first sign-in links to that record by email; otherwise the first sign-in creates one.

## Install

Download the release APK and open it on an Android phone. Allow installing from that source if asked. The app talks to the live system at `https://34.54.94.62.nip.io/api/v1` by default.

## Build from source

You need Flutter (Dart 3) and the Android SDK.

```bash
flutter pub get
flutter run                      # on a connected phone or emulator
flutter build apk --release      # → build/app/outputs/flutter-apk/app-release.apk
```

To use a local backend instead of the live one, pass the gateway URL at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001/api/v1   # Android emulator → your machine
```

Push notifications also need a Firebase project: put its `google-services.json` in `android/app/` and apply the `com.google.gms.google-services` plugin in `android/app/build.gradle.kts`. Without it, the app works normally and alerts appear only inside the app.

## Tests

```bash
flutter test
```

## Tech stack

- Flutter, with `flutter_bloc` for state
- `flutter_appauth` for Asgardeo sign-in (OpenID Connect with PKCE)
- `flutter_secure_storage` for tokens
- `http` for API calls, `image_picker` for complaint photos
- `firebase_messaging` for push notifications

## Project structure

The app follows clean architecture: screens call use cases, use cases call repository interfaces, and only the data layer knows about HTTP.

```
lib/
├── main.dart
├── core/
│   ├── di/            service locator
│   ├── network/       API client, DTOs, one API service per backend service
│   ├── services/      secure storage and sign-in, push notifications
│   ├── theme/
│   └── errors/
└── features/
    ├── auth/          sign-in
    ├── dashboard/     home screen and every module screen
    ├── accommodation/ student record and room
    ├── finance/       invoices and payments
    ├── operations/    maintenance and visitors
    └── notifications/ alerts
        (each with domain/ and data/ layers; screens live under dashboard/presentation)
```
