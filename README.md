# MyLock Candy Tracker

Flutter companion app for the **e-MyLock Candy** smart luggage system. It surfaces live device location, geofence safety status, and lock/fingerprint management UI in a polished multi-tab experience.

> 📈 **Flowcharts:** See [docs/flowcharts.md](docs/flowcharts.md) for detailed flow diagrams of the data and UI flows.

## Features (Detailed)

### 1) Status Dashboard
- **Lock state ring** with a hold-to-toggle interaction (UI-only in this build).
- **BLE connection badge** and "secure link" messaging (hardware integration placeholder).
- **Power & signal tiles** for device health at a glance.

### 2) Fingerprint Setup
- **Step-based enrollment UI** with progress indicator.
- **Pulsing fingerprint animation** to guide the interaction.
- **Coming-soon badge** that clarifies hardware dependency.

### 3) Live Location Map
- **OpenStreetMap tiles** rendered via `flutter_map`.
- **Animated live indicator** with update status.
- **Accuracy ring** around the device marker.
- **Snackbar updates** when coordinates change.
- **Location details card** (lat/lng/altitude + last fetch time).

### 4) Geofence Management
- **Create/adjust geofence** by tapping the map and sliding the radius.
- **Geofence visualization** overlayed on the live map.
- **Geofence status badge** (SAFE/OUTSIDE) on the main map.
- **Save/Clear geofence** actions persisted to Firebase.

### 5) Breach Alerts
- **Automatic breach detection** when the device exits the safe zone.
- **Haptic alert sequence** and modal dialog summary.
- **Quick navigation** to the Location tab after a breach.

### 6) Settings & Device Info
- Device identity, BLE sensitivity, notifications, firmware update status, and support links.
- Factory reset confirmation modal.

## Architecture Overview

The app is a single Flutter application using **Provider** for state management, and **Firebase Realtime Database** for device telemetry and geofence state.

**State providers**
- `FirebaseLocationService`: Listens to `latest_location` data and exposes derived text like “last seen”.
- `GeofenceService`: Listens to geofence and location values, computes distance, and detects breaches.

**Primary UI entry**
- `main.dart` → `HomeShell` (bottom navigation)

## Firebase Data Model (Realtime DB)

The app reads and writes under the `emylock-candy` root:

```
emylock-candy/
  latest_location/
    latitude: number
    longitude: number
    altitude: number
    accuracy: number
    timestamp: number
    polled_at: ISO-8601 string
  geofence-lat: number
  geofence-long: number
  geofence-radius: number (meters)
```

## Project Structure

```
lib/
  main.dart                # App bootstrap + providers
  screens/
    home_shell.dart         # Tab shell + breach alert dialog
    status_screen.dart       # Lock & BLE dashboard
    fingerprint_screen.dart  # Enrollment UI
    location_screen.dart     # Live map + metrics
    geofence_screen.dart     # Geofence editing
    settings_screen.dart     # Settings + reset
  services/
    firebase_location_service.dart  # Realtime location listener
    geofence_service.dart            # Geofence state + breach detection
  widgets/
    ble_status_chip.dart
    lock_ring.dart
    stat_card.dart
  theme/
    app_theme.dart
```

## Setup & Run

### Prerequisites
- Flutter SDK (3.10+ recommended)
- A Firebase project with Realtime Database enabled

### Configure Firebase
This repo initializes Firebase in `main.dart`. You must provide:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

> The database URL is currently hardcoded in the services. Update it if you need a different Firebase instance.

### Install Dependencies
```
flutter pub get
```

### Run the App
```
flutter run
```

## Testing & Linting

```
flutter analyze
flutter test
```

## Configuration Points

| Location | Purpose |
| --- | --- |
| `firebase_location_service.dart` | Database URL + location listener path |
| `geofence_service.dart` | Database URL + geofence keys |
| `location_screen.dart` | Map provider + display formatting |

## Limitations / Coming Soon

- **BLE integration** is UI-only and not wired to hardware yet.
- **Fingerprint hardware** is UI-only and does not enroll real templates.
- **Map tiles** require internet connectivity (OpenStreetMap).

## Flowcharts

Detailed diagrams are in [docs/flowcharts.md](docs/flowcharts.md).
