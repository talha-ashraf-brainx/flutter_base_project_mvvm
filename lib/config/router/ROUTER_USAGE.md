# App Router - Named Routes Usage Guide

This document explains how to use the new named routes system implemented in the Flutter app.

## Route Names

The following route names are available in the `AppRoutes` enum:

- `AppRoutes.splash` - Splash screen (`/`)
- `AppRoutes.home` - Main home screen with bottom navigation (`/home`)
- `AppRoutes.homepage` - Homepage view (`/homepage`)
- `AppRoutes.search` - Search screen (`/search`)
- `AppRoutes.settings` - Settings screen (`/settings`)
- `AppRoutes.camera` - Camera screen (`/camera`)

### Usage

```dart
// Access the route path
String routePath = AppRoutes.home.path; // '/home'

// Or use toString() method
String routePath = AppRoutes.home.toString(); // '/home'
```

## Navigation Methods

### Basic Navigation

```dart
// Navigate to a route
AppRouter.pushNamed(context, AppRoutes.home.path);

// Navigate with arguments
AppRouter.pushNamed(context, AppRoutes.camera.path, arguments: {
  'onImageCaptured': (XFile image) => print('Image captured: ${image.path}')
});
```

### Replacement Navigation

```dart
// Replace current route
AppRouter.pushReplacementNamed(context, AppRoutes.home.path);

// Replace current route with result
AppRouter.pushReplacementNamed(context, AppRoutes.home.path, result: 'some_result');
```

### Navigation with Route Removal

```dart
// Navigate and remove all previous routes
AppRouter.pushNamedAndRemoveUntil(context, AppRoutes.home.path);

// Navigate and remove routes based on condition
AppRouter.pushNamedAndRemoveUntil(
  context, 
  AppRoutes.home.path,
  predicate: (route) => route.settings.name != AppRoutes.splash.path
);
```



## Example Usage

### From Splash to Home

```dart
// In splash screen
AppRouter.pushReplacementNamed(context, AppRoutes.home.path);
```

### From Homepage to Camera

```dart
// In homepage
AppRouter.pushNamed(context, AppRoutes.camera.path, arguments: {
  'onImageCaptured': (XFile selectedImage) async {
    // Handle the captured image
    setState(() {
      // Update UI with captured image
    });
  }
});
```

### Deep Linking

The router supports deep linking through the `onGenerateRoute` callback:

```dart
// This is already configured in main.dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
  // ...
)
```



## Adding New Routes

To add a new route:

1. Add the route to the `AppRoutes` enum in `app_routes.dart`:
   ```dart
   enum AppRoutes {
     // ... existing routes
     newRoute('/new-route');
   }
   ```

2. Add the route generation logic in `generateRoute`:
   ```dart
   } else if (routeName == AppRoutes.newRoute.path) {
     return MaterialPageRoute(
       builder: (_) => const NewRouteWidget(),
       settings: settings,
     );
   ```

3. Add the route to the routes map in `main.dart`:
   ```dart
   routes: {
     AppRoutes.newRoute.path: (context) => const NewRouteWidget(),
     // ... other routes
   },
   ```


