# Focal

Focal is a Flutter productivity app focused on task planning, timer-based deep work, and progress insights.

The app now runs fully local on device:

- No Firebase
- No account creation
- No sign-in screens
- Tasks, streak, and insights are stored with SharedPreferences on the device

## Features

- Task management: add, edit, complete, and delete tasks
- Daily habit rollover support
- Focus timer with strict focus lock mode
- Progress and weekly insights
- Daily reflection journal
- Local notifications for reminders

## Data Storage

- Local-only persistence via SharedPreferences
- Data stays on the same device unless manually cleared or app data is removed

## Run Locally

1. Install Flutter SDK.
1. Get dependencies:

```bash
flutter pub get
```

1. Run:

```bash
flutter run
```

## Project Notes

- App starts directly into the splash flow and then main navigation.
- No authentication gate is used.
