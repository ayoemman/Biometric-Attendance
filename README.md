# BioAttendance – Project Tutorial and Setup Guide

This document is a complete, end‑to‑end guide to the BioAttendance iOS app. It covers:
- What each part of the codebase does
- How views and flows are wired together
- How to set up Firebase (Auth + Firestore)
- Required Info.plist keys and permissions (Face ID / Touch ID + Location)
- How to run on a device and test Check‑In/Check‑Out
- Common troubleshooting tips

If you’re new to the codebase or want to reuse parts of it, start here.


## 1) High‑Level Overview

BioAttendance lets a user:
- Sign up (name + email + password)
- Sign in
- Register biometrics (Face ID / Touch ID) within the app
- Check in / Check out when physically at the office (validated by GPS)
- Persist attendance to Firestore under the user’s document

The app uses:
- Firebase Auth for authentication
- Firebase Firestore for attendance data
- LocalAuthentication + Keychain for biometric registration/verification
- Core Location for geofencing the office area
- Network.framework to detect internet connectivity


## 2) Project Structure (Key Files)

- App lifecycle
  - ```swift:AppDelegate.swift```
    - Configures Firebase on launch with `FirebaseApp.configure()`
    - Starts the network monitor `NetworkMonitor.shared.start()`
  - ```swift:SceneDelegate.swift```
    - Standard scene lifecycle wiring for storyboard apps

- UI Screens (Storyboard‑backed)
  - ```swift:SignInViewController.swift```
    - Handles email/password sign‑in
    - Validates inputs and performs segue `SignInToHome` on success
  - ```swift:SignupViewController.swift```
    - Collects name + email, validates, and segues to password screen (`SignupToPassword`)
  - ```swift:PasswordViewController.swift```
    - Creates a Firebase Auth user with the pending email + entered password
    - Creates a Firestore user document and segues to Home (`PasswordToHome`)
  - ```swift:HomeViewController.swift```
    - Main screen for Check In / Check Out
    - Verifies internet, biometric registration, performs biometric verification, requests location, and writes attendance to Firestore
    - Displays user‑facing status via a multi‑line, dynamically sized `statusLabel`

- Services / Managers
  - ```swift:AttendanceService.swift```
    - Core attendance logic
    - Expects you to set the office coordinates and radius
    - Writes/updates daily attendance in Firestore under `users/{uid}/attendance/{YYYY-MM-DD}`
  - ```swift:BiometricManager.swift```
    - Registers biometrics by writing a Keychain item protected by `biometryCurrentSet`
    - Verifies biometrics by attempting to read the Keychain item (prompts Face ID / Touch ID)
  - ```swift:LocationManager.swift```
    - Requests When‑In‑Use permission and fetches one location
    - Handles authorization changes, success/failure callbacks, and timeouts
  - ```swift:NetworkMonitor.swift```
    - Uses `NWPathMonitor` to set `isConnected`
  - ```swift:Validators.swift```
    - Simple email validator utility

- UI Utilities
  - ```swift:UIButton+Adaptive.swift```
    - Adds adaptive primary/secondary button styles (iOS 15+ configurations or a fallback)
    - Preserves storyboard titles/images and enforces a minimum tap height (≥ 48pt)
    - Includes a `UIView` helper to style all buttons recursively

- Storyboard
  - `Base.lproj/Main.storyboard`
    - Contains the scenes for Sign In, Signup, Password, and Home
    - Ensure outlets and actions are connected as described below


## 3) Firebase Setup (Auth + Firestore)

Follow these steps to connect the app to your Firebase project:

1. Create a Firebase project
   - Go to https://console.firebase.google.com
   - Create a new project (or use an existing one)

2. Add an iOS app to the project
   - Use your app’s Bundle Identifier (Xcode target > General > Identity)
   - Download the generated `GoogleServices-Info.plist`
   - Drag the plist into your Xcode project (select “Copy items if needed” and ensure your app target is checked)

3. Add Firebase SDKs (Swift Package Manager recommended)
   - In Xcode: File > Add Packages…
   - Add the Firebase iOS SDK: `https://github.com/firebase/firebase-ios-sdk`
   - Choose the packages:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseCore
   - Alternatively, you can use CocoaPods, but SPM is recommended for simplicity.

4. Initialize Firebase in code
   - `AppDelegate.swift` includes the necessary call:

```swift:AppDelegate.swift
import Firebase

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    NetworkMonitor.shared.start()
    return true
}
