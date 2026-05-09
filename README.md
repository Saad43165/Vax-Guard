# VaxGuard 🛡️

**VaxGuard** is a high-fidelity, AI-powered Clinical Decision Support System (CDSS) designed to streamline infectious disease triage and vaccination management. Built with a focus on clinical accuracy and premium user experience, VaxGuard empowers both healthcare professionals and non-technical users with real-time diagnostic guidance and evidence-based action plans.

---

## ✨ Key Features

### 🩺 Professional Diagnostic Triage
- **Animal Bite Assessor**: A sophisticated triage system based on **WHO Rabies Protocols**. It maps anatomical bite locations and exposure severity to clinical categories (I, II, III).
- **Automated PEP Scheduling**: Generates personalized Rabies Post-Exposure Prophylaxis (PEP) vaccination schedules (Days 0, 3, 7, 14, 28).
- **Risk Assessment Hub**: Multi-dimensional diagnostic flows for various infectious diseases with severity-based clinical reporting.

### 📡 Real-Time Monitoring
- **Live Outbreak Radar**: Geospatial tracking of active disease outbreaks in proximity to the user's location.
- **Health Library**: A comprehensive clinical repository of vaccine-preventable diseases, symptoms, and prevention strategies.

### 👤 Patient-Centric Design
- **Health History**: Secure local storage of diagnostic assessments and vaccination records.
- **Plain Language Reporting**: Diagnostic results translated into clear, actionable health alerts (e.g., "EMERGENCY ACTION REQUIRED") for non-technical users.
- **Premium UX/UI**: A clinical health-tech aesthetic featuring glassmorphism, professional gradients, and interactive anatomical mapping.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform)
- **Language**: Dart
- **State Management**: Notifiers & Provider pattern
- **Database**: Local Persistence for assessment history
- **Localization**: Multi-language support (English/Urdu) via `L10n`
- **Clinical Logic**: Integrated WHO Rabies Post-Exposure Prophylaxis (PEP) guidelines

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Dart SDK

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Saad43165/Vax-Guard.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📋 Clinical Standards
VaxGuard is developed following international clinical standards for Post-Exposure Prophylaxis. The **Animal Bite Module** specifically implements the WHO 2018 Rabies PEP guidelines to ensure patient safety and diagnostic reliability.

---

## 📸 Visual Identity
VaxGuard features a high-fidelity clinical seal that represents protection and reliability.

![VaxGuard Logo](assets/images/splash_icon.png)

---

## 📄 License
This project is for clinical diagnostic support. Please consult professional medical authorities for definitive healthcare decisions.

© 2026 VaxGuard Clinical Production. All Rights Reserved.
