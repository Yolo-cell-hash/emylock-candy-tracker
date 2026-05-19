# Flowcharts

This document provides visual explanations of the core application flows.

## 1) App Bootstrap & Navigation

```mermaid
flowchart TD
  A[App start] --> B[WidgetsFlutterBinding.ensureInitialized]
  B --> C[Firebase.initializeApp]
  C --> D[runApp(MyApp)]
  D --> E[MultiProvider\nLocation + Geofence services]
  E --> F[HomeShell]
  F --> G[Bottom navigation]
  G --> H1[Status]
  G --> H2[Fingerprint]
  G --> H3[Location]
  G --> H4[Settings]
```

## 2) Live Location Update Flow

```mermaid
flowchart LR
  A[Realtime DB: latest_location] --> B[FirebaseLocationService listener]
  B --> C[Parse latitude/longitude\naltitude/accuracy/timestamp]
  C --> D[Update state + lastSeenText]
  D --> E[notifyListeners()]
  E --> F[LocationScreen Consumer]
  F --> G[Map marker + accuracy ring]
  F --> H[Location card + last fetch]
  F --> I[Snackbar when coordinates change]
```

## 3) Geofence Setup & Persistence

```mermaid
flowchart TD
  A[Tap shield button] --> B[GeofenceScreen]
  B --> C[Tap map to set center]
  C --> D[Adjust radius slider]
  D --> E[Activate Geofence]
  E --> F[GeofenceService.setGeofence]
  F --> G[Write geofence-lat/long/radius]
  G --> H[GeofenceService listener updates state]
  H --> I[LocationScreen draws geofence overlay]
```

## 4) Breach Detection & Alerting

```mermaid
flowchart TD
  A[GeofenceService receives updates] --> B[Compute distance (Haversine)]
  B --> C{Inside radius?}
  C -- Yes --> D[isInsideGeofence = true]
  C -- No --> E[hasBreached = true]
  E --> F[HomeShell listener]
  F --> G[Haptic alert + modal dialog]
  G --> H[Dismiss or View Location]
  H --> I[clearBreach()]
```

## 5) Fingerprint Enrollment (UI)

```mermaid
flowchart TD
  A[Fingerprint tab] --> B[Show step + progress]
  B --> C[Tap fingerprint card]
  C --> D{More steps?}
  D -- Yes --> E[Increment step]
  D -- No --> F[Reset to step 1]
  B --> G[Cancel setup]
  G --> F
```

## 6) Status Lock Toggle (UI)

```mermaid
flowchart TD
  A[Status tab] --> B[Hold-to-toggle action]
  B --> C[Toggle local lock state]
  C --> D[Update LockRing + button text]
```
