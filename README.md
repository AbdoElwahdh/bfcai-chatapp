# Flutter + Firebase Chat Application

A simple, robust, and real-time mobile chat application built to demonstrate clean architecture and the integration between **Flutter** (Frontend) and **Firebase** (Backend).

---

## Project Overview

This project was built to simulate a real-world mobile development scenario. It focuses on **clarity, correctness, and simplicity** rather than complexity. It is designed to be an educational resource for students and beginner developers to understand how modern chat applications handle data, authentication, and state.

**Key Goals:**

* Demonstrate User Authentication.
* Implement Real-time Data Syncing (Firestore Streams).
* Showcase "Soft Delete" logic (Clear vs. Delete Chat).
* Maintain a clean codebase that is easy to explain in a Viva/Discussion.

---

## 📱 Features

| Feature | Description |
| --- | --- |
| **🔐 Authentication** | Secure Login and Sign Up using Email & Password via Firebase Auth. |
| **⚡ Real-Time Chat** | Messages are delivered instantly without refreshing the screen using Firestore Streams. |
| **📩 Email Initiation** | Start private conversations by entering another user's email address. |
| **🧹 Clear Chat** | Clear message history for yourself without deleting the chat for the other user. |
| **🗑️ Delete Chat** | Remove the conversation from your main list completely (Local delete). |
| **🎨 Clean UI** | A minimal, professional interface designed for readability and focus. |

---

## Architecture & Design

The project follows a simplified **Layered Architecture** to ensure separation of concerns. This makes the code modular, testable, and easy to read.

### Folder Structure

```bash
lib/
├── models/       # Data models (Chat, Message, User)
├── screens/      # UI Screens (Login, ChatList, ChatScreen)
├── services/     # Firebase interaction logic (AuthService, ChatService)
├── widgets/      # Reusable UI components (TextFields, Buttons)
└── utils/        # Helper functions (Date formatting, ID generation)
└── main.dart     # Entry point

```

### Lib Folder Structure (Details)
```js
lib/
├── main.dart                # Entry point (Initializes Firebase & App)
│
├── models/                  # Data classes (Blueprints for data)
│   ├── user_model.dart      # User data structure (uid, email, name)
│   ├── chat_model.dart      # Chat metadata (participants, lastMessage)
│   └── message_model.dart   # Individual message structure
│
├── screens/                 # All the pages the user sees
│   ├── splash_screen.dart   # Checks if user is logged in
│   │
│   ├── auth/                # Login & Sign Up Screens
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   │
│   └── chat/                # Chat functionality screens
│       ├── chat_list_screen.dart  # Home screen (list of all chats)
│       └── chat_screen.dart       # The actual conversation screen
│
├── services/                # Logic & Firebase Code (No UI here!)
│   ├── auth_service.dart    # Login, SignUp, Logout logic
│   └── chat_service.dart    # Send message, Get chats, Delete logic
│
├── widgets/                 # Reusable UI Components
│   ├── custom_button.dart   # Standard app button
│   ├── custom_textfield.dart# Styled text input
│   ├── message_bubble.dart  # The blue/grey bubble for messages
│   └── chat_tile.dart       # Single row in the chat list
│
└── utils/                   # Helper functions & Constants
    ├── constants.dart       # App colors, styles, fixed strings
    └── helpers.dart         # Functions like 'generateChatId' or date formatting
```

### Data Flow

1. **Screens (UI):** Detect user input.
2. **Services:** Handle the logic and communicate with Firebase.
3. **Firebase:** Stores data and pushes updates back to the UI via Streams.

---

##  Database Model (Firestore)

We use **Cloud Firestore** as a NoSQL database. The data is structured to optimize for read speeds and real-time listeners.

### Collections

1. **`users`**: Stores user profiles.
* `uid`, `email`, `username`, `createdAt`


2. **`chats`**: Stores conversation metadata.
* `participants` (Array of UIDs), `lastMessage`, `lastMessageTime`, `deletedBy` (Array)


3. **`messages`** (Subcollection of `chats`): Stores actual texts.
* `senderId`, `text`, `timestamp`, `deletedBy` (Array)



---

## Getting Started

Follow these instructions to run the project on your local machine.

### Prerequisites

* **Flutter SDK:** Installed and set up ([Guide](https://docs.flutter.dev/get-started/install)).
* **VS Code** or **Android Studio**.
* A **Google Account** for Firebase.

### 1. Clone the Repository

```bash
git clone https://github.com/AbdoElwahdh/bfcai-chatapp.git
cd flutter-chat-app

```

### 2. Install Dependencies

```bash
flutter pub get

```

### 3. Firebase Setup (Crucial Step)

Since Firebase keys are private, you must connect your own Firebase project:

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. **Enable Authentication:** Go to Build > Authentication > Sign-in method > Enable **Email/Password**.
4. **Create Database:** Go to Build > Firestore Database > Create Database > Start in **Test Mode**.
5. **Add App:**
* Click the **Android** icon. Register the app (use the package name from `android/app/build.gradle`).
* Download `google-services.json` and place it in `android/app/`.
* (Optional) Repeat for iOS if you are on Mac (`GoogleService-Info.plist` in `ios/Runner/`).



### 4. Run the App

Connect your emulator or physical device and run:

```bash
flutter run

```

---

## User Flow

1. **Splash Screen:** Checks login state.
2. **Auth:** Login or Register.
3. **Home:** View list of active chats.
4. **New Chat:** Input email -> Check DB -> Open Chat.
5. **Chat Room:** Send/Receive messages.

---


## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
