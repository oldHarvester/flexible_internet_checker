# flexible_internet_checker

A Flutter package for real-time internet connectivity monitoring. Unlike simple network-state checks, it verifies actual internet access by making HTTP requests to multiple endpoints.

## Features

- Monitors internet connectivity via a broadcast `Stream<InternetStatus>`
- Verifies real internet access (not just network presence) using HTTP HEAD requests
- Checks multiple URLs simultaneously and considers connection active if any responds
- Periodic background checks at a configurable interval
- Reacts instantly to network-state changes (Wi-Fi, mobile, etc.)
- Throttle support to prevent status update flooding
- Automatically pauses monitoring when the app goes to background and resumes on foreground
- Fully configurable: custom URLs, timeouts, intervals, HTTP client

## Platform setup

### Android

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### macOS

Add the network entitlement to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.network.server</key>
<true/>
```

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flexible_internet_checker:
    git:
      url: https://github.com/oldHarvester/flexible_internet_checker.git
```

## Usage

### Basic usage

```dart
import 'package:flexible_internet_checker/flexible_internet_checker.dart';

final checker = FlexibleInternetChecker.createInstance();

// Listen to status stream — monitoring starts automatically on first listener
checker.status.listen((InternetStatus status) {
  switch (status) {
    case InternetStatus.connected:
      print('Internet is available');
    case InternetStatus.disconnected:
      print('No internet');
  }
});

// Don't forget to dispose when done
checker.dispose();
```

### With StreamBuilder in a widget

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FlexibleInternetChecker _checker = FlexibleInternetChecker.createInstance();

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<InternetStatus>(
      stream: _checker.status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        return Text(status?.name ?? 'checking...');
      },
    );
  }
}
```

### One-time check

```dart
// Check current network interfaces (Wi-Fi, mobile, etc.)
final connections = await checker.checkConnections();

// Check actual internet access (makes real HTTP requests)
final hasInternet = await checker.checkConnection();
```

## Configuration

All parameters are optional — defaults work out of the box.

```dart
final checker = FlexibleInternetChecker.createInstance(
  // How often to ping URLs in the background
  interval: const Duration(seconds: 5),

  // Default HTTP timeout for each address check
  timeout: const Duration(seconds: 3),

  // Delay between emitting consecutive status updates (debounce-like)
  statusUpdateThrottleDuration: const Duration(milliseconds: 500),

  // If true — ALL addresses must respond; if false — ANY one is enough
  requiredAllRespond: false,

  // Refresh connections and recheck internet when app returns to foreground
  refreshOnForeground: true,

  // Pause the periodic checker when app goes to background, resume on foreground
  pauseOnBackground: true,

  // Custom list of URLs to check
  addresses: [
    AddressCheckOption(uri: Uri.parse('https://one.one.one.one')),
    AddressCheckOption(
      uri: Uri.parse('https://example.com'),
      timeout: const Duration(seconds: 2), // per-address timeout override
    ),
  ],

  // Inject a custom HTTP client (useful for testing)
  client: http.Client(),

  // Inject a custom Connectivity instance (useful for testing)
  connectivity: Connectivity(),
);
```

## API reference

### `FlexibleInternetChecker`

| Member | Type | Description |
|---|---|---|
| `status` | `Stream<InternetStatus>` | Broadcast stream of internet status updates. Monitoring starts on first listener and stops when all listeners cancel. |
| `lastStatus` | `InternetStatus?` | The most recently emitted status, or `null` if no check has completed yet. |
| `connections` | `ConnectionsList` | Last known list of network interfaces. |
| `checkConnections()` | `Future<ConnectionsList>` | Manually query network interfaces. |
| `checkConnection()` | `Future<bool>` | Manually perform an HTTP reachability check. |
| `refreshOnForeground` | `bool` | If `true` (default), re-checks connections and internet when the app returns to foreground. |
| `pauseOnBackground` | `bool` | If `true` (default), stops the periodic checker when the app goes to background and restarts it on resume. |
| `dispose()` | `void` | Cancel all subscriptions and close the stream. Call this when the checker is no longer needed. |

### `InternetStatus`

| Value | Description |
|---|---|
| `connected` | At least one address responded successfully |
| `disconnected` | No address could be reached |

### `AddressCheckOption`

| Parameter | Type | Description |
|---|---|---|
| `uri` | `Uri` | The URL to send a HEAD request to |
| `timeout` | `Duration?` | Per-address timeout. Falls back to the checker's global `timeout` if not set. |

### `InternetStatusX` extension

```dart
status.connected     // true if InternetStatus.connected
status.disconnected  // true if InternetStatus.disconnected
```

## Default check URLs

| URL | Purpose |
|---|---|
| `https://one.one.one.one` | Cloudflare DNS |
| `https://jsonplaceholder.typicode.com/albums/1` | Public test API |
| `https://fakestoreapi.com/products/1` | Public test API |
| `https://icanhazip.com/` | IP lookup service |

## Dependencies

| Package | Purpose |
|---|---|
| `connectivity_plus` | Network interface state detection |
| `http` | HTTP HEAD requests for reachability checks |
| `equatable` | Value equality for `AddressCheckOption` / `AddressCheckResult` |
