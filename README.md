# BFCAI ChatApp

BFCAI ChatApp is a real-time messaging application developed for the Faculty of Computers and Artificial Intelligence (Beni Suef University).  
The project is designed with a clean architecture, scalable structure, and focuses on delivering a smooth user experience using Flutter and Firebase.

---

## Overview

The application enables real-time communication through Firebase Firestore and provides user authentication, chat messaging, and modular components.  
It is built to support future enhancements such as media sharing, notifications, and group chats.

---

## Features

### Core Features
- Real-time messaging using Firebase Firestore.
- Secure authentication using Firebase Authentication.
- Modern, clean, and responsive UI.
- Light and dark theme support.
- Modular and maintainable code structure.

### Planned Enhancements
- Media sharing (images, files, voice notes).
- Push notifications using Firebase Cloud Messaging.
- Group chat functionality.
- Online/offline status indicators.
- Message delivery status (sent, delivered, seen).

---

## Technologies Used

| Category | Technology |
|----------|------------|
| Frontend | Flutter (Dart) |
| Backend | Firebase |
| Authentication | Firebase Authentication |
| Database | Firebase Firestore |
| File Storage | Firebase Storage |
| State Management | Cubit / Bloc |
| Architecture | Modular / Clean Structure |

---

## Project Structure

```

lib/
├── core/
│   ├── theme/
│   ├── utils/
├── features/
│   ├── auth/
│   ├── chat/
│   ├── home/
├── models/
├── widgets/
└── main.dart

````

---

## Installation and Setup

### 1. Clone the Repository
```bash
git clone https://github.com/AbdoElwahdh/bfcai-chatapp.git
cd bfcai-chatapp
````

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. Create a Firebase project.
2. Add Android and/or iOS apps.
3. Download `google-services.json` and place it in:

   ```
   android/app/
   ```
4. Download `GoogleService-Info.plist` and place it in:

   ```
   ios/Runner/
   ```

### 4. Run the Application

```bash
flutter run
```

---

## Screenshots

(Replace these with actual project images)

```
screenshots/login.png
screenshots/register.png
screenshots/chat.png
```

---

## Contribution Workflow

1. Create a new feature branch:

```bash
git checkout -b feature/your-feature
```

2. Commit your work:

```bash
git commit -m "Add your feature"
```

3. Push the branch:

```bash
git push origin feature/your-feature
```

4. Open a Pull Request on GitHub for review.

## License

This project is created for educational purposes within the Faculty of Computers and Artificial Intelligence, Beni Suef University.
قولي وأنا أعملها لك فوراً
