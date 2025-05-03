# 🎓 TutorFee

<div align="center">
  

**A modern solution for tutors to manage fees and students to track payments**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

</div>

## ✨ Features

### For Tutors
- 📝 Create and manage fee structures for different courses
- 💰 Track payments from students in real-time
- 📊 View detailed reports of payments received
- 📄 Generate and download professional PDF reports
- 📱 Mobile-friendly interface for on-the-go management

### For Students
- 👀 Browse available courses and fee details
- 💳 Make payments securely within the app
- 📜 Access payment history and receipts
- 🧾 Download payment receipts as PDF
- 📱 Intuitive mobile interface

## 📱 Preview
[See Preview Video](https://drive.google.com/file/d/1pkXtLqZJnfDaf5Hmgwr9CZKCDECLLn9X/view?usp=sharing)


## 🛠️ Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Functions
- **PDF Generation**: flutter_pdf
- **State Management**: Provider/Bloc

## 📋 Project Structure

```
lib/
├── main.dart               # Entry point
├── config/                 # App configuration
├── models/                 # Data models
├── screens/                # UI screens
│   ├── auth/               # Authentication screens
│   ├── tutor/              # Tutor-specific screens
│   └── student/            # Student-specific screens
├── services/               # Firebase and other services
├── utils/                  # Utility functions
└── widgets/                # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (2.5.0 or higher)
- Dart (2.14.0 or higher)
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/fastcode746/UUM-TutorPay-App.git
   cd UUM-TutorPay-App
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files
   - Enable Firebase Authentication and Firestore

4. Run the app:
   ```bash
   flutter run
   ```

## 🔒 Firebase Structure

### Collections

**Fees**
```
fees/
├── feeId/
│   ├── description: String
│   ├── feeAmount: Number
│   ├── tutorId: String
│   ├── tutorName: String
│   ├── tutorEmail: String
│   ├── createdAt: Timestamp
│   ├── updatedAt: Timestamp
│   └── paidStudents: Array
│       └── {
│           studentId: String,
│           studentName: String,
│           studentEmail: String,
│           paidAt: Timestamp
│       }
```

**Users**
```
users/
├── userId/
│   ├── displayName: String
│   ├── email: String
│   ├── role: String (tutor/student)
│   └── createdAt: Timestamp
```

## 📊 Reports Feature

### Tutor Reports
- Comprehensive list of students who paid for each fee
- Total revenue calculation
- Downloadable PDF reports for record-keeping

### Student Receipts
- Detailed payment history
- Official receipts for each payment
- PDF download option for offline access

## 🛣️ Roadmap

- [ ] Implement recurring payment options
- [ ] Add in-app notifications for payment reminders
- [ ] Introduce analytics dashboard for tutors
- [ ] Support for multiple payment methods
- [ ] Calendar integration for scheduling sessions

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact
Email me at czaaaa20@gmail.com


---

<div align="center">
  <sub>Built with ❤️ by Zargham Abbas </sub>
</div>
