# OpenShock Mobile App

The OpenShock mobile app is built using **Flutter**, a cross-platform UI toolkit that enables a seamless experience on both iOS and Android devices. OpenShock allows users to manage and control their OpenShock-enabled devices efficiently, providing a responsive and high-performance interface.

## Tech Stack

- **Flutter**: Cross-platform UI framework to build a native mobile app for iOS and Android from a single codebase.
- **Dart**: Programming language used for the app, offering a strong typing system and reactive model for UI development.
- **Dio**: Used for making HTTP requests and managing API calls with headers like `OpenShockToken` for backend integration.
- **Shared Preferences**: Lightweight key-value storage used for saving user settings and device information locally.

## How to Build the Project

To build the OpenShock mobile app, follow the steps below:

### Prerequisites

Make sure you have the following installed on your development environment:
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- A code editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Steps to Build

1. **Clone the Repository**  
   ```
   git clone https://github.com/yourusername/OpenShock.git
   cd OpenShock
   ```

2. **Install Dependencies**  
   After navigating to the project directory, run:
   ```
   flutter pub get
   ```

3. **Run the App**  
   Connect an iOS or Android device or start an emulator, then run the following command to launch the app:
   ```
   flutter run
   ```

4. **Build for Production**  
   To build the app for production, use:
   ```
   flutter build apk   # Android
   flutter build ios   # iOS
   ```

## How to Contribute

1. **Fork the Repository**: Start by forking the OpenShock mobile app repo to your own GitHub account.
2. **Set Up Your Environment**:
   - Ensure you have the latest version of Flutter installed.
   - Clone the repo and run `flutter pub get` to install dependencies.
3. **Branch & Develop**:
   - Create a new branch for your feature or bug fix.
   - Follow the existing code style and structure, keeping your code clean and modular.
4. **Submit a Pull Request**: Once you've completed your changes, submit a pull request for review.

Feel free to report issues or request new features using the [Issues](https://github.com/yourusername/OpenShock/issues) tab in GitHub.

---

Happy Coding!
