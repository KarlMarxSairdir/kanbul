# Authentication Architecture

This document outlines the architecture of the authentication system in the KanBul application. The system is designed following the Single Responsibility Principle, with clear separation between state management and actions.

## Overview

The authentication system is divided into two main components:

1. **State Management**: Responsible for tracking the current authentication state.
2. **Action Notifiers**: Responsible for performing specific authentication-related operations.

## State Management

### AuthStateNotifier

`AuthStateNotifier` is a global state provider that solely focuses on:

- Listening to Firebase Auth state changes
- Loading user data when auth state changes
- Providing the current authentication state to the UI

```dart
@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  // Tracks authentication state
  @override
  AuthState build() {
    // Subscribe to auth state changes
    // ...
  }
}
```

## Action Notifiers

Each authentication action is isolated into its own notifier:

### SignInNotifier

Responsible for handling user sign-in operations:

```dart
@riverpod
class SignInNotifier extends _$SignInNotifier {
  Future<UserModel> run({
    required String email,
    required String password,
  }) async {
    // Sign in with email and password
    // ...
  }

  Future<UserModel> signInWithGoogle() async {
    // Sign in with Google
    // ...
  }
}
```

### RegisterNotifier

Handles user registration:

```dart
@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  Future<UserModel> run({
    required String email,
    required String password,
    // Other user data...
  }) async {
    // Register new user
    // ...
  }
}
```

### PasswordResetNotifier

Handles password reset requests:

```dart
@riverpod
class PasswordResetNotifier extends _$PasswordResetNotifier {
  Future<void> run(String email) async {
    // Send password reset email
    // ...
  }
}
```

### SignOutNotifier

Handles user sign-out operations:

```dart
@riverpod
class SignOutNotifier extends _$SignOutNotifier {
  Future<void> run() async {
    // Sign out user
    // ...
  }
}
```

### EmailVerificationNotifier

Handles email verification operations:

```dart
@riverpod
class EmailVerificationNotifier extends _$EmailVerificationNotifier {
  Future<void> sendEmailVerification() async {
    // Send verification email
    // ...
  }

  Future<void> checkEmailVerification() async {
    // Check if email is verified
    // ...
  }
}
```

## Usage Examples

### Checking Authentication State

```dart
final authState = ref.watch(authStateNotifierProvider);

if (authState.isLoading) {
  return LoadingIndicator();
} else if (authState.user != null) {
  return HomeScreen();
} else {
  return LoginScreen();
}
```

### Performing Sign-in

```dart
final signInNotifier = ref.read(signInNotifierProvider.notifier);

try {
  await signInNotifier.run(
    email: 'user@example.com',
    password: 'password',
  );
  // Success - navigation handled by auth state listener
} catch (e) {
  // Handle error, though typically done via provider.listen
}
```

### Handling Loading and Errors

```dart
// Watch for loading state
final signInState = ref.watch(signInNotifierProvider);
final isLoading = signInState.isLoading;

// Listen for errors
ref.listen(signInNotifierProvider, (previous, current) {
  if (current.hasError) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(current.error.toString())),
    );
  }
});
```

## Benefits

1. **Separation of Concerns**: Each component has a single responsibility
2. **Testability**: Each notifier can be tested independently
3. **Maintainability**: Code is organized into smaller, focused files
4. **Reduced Merge Conflicts**: Changes to different features don't affect the same files
5. **Better State Management**: Loading and error states are handled consistently
