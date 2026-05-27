# PWD Tender Manager

A Flutter app for managing PWD tenders, tracking investor contributions with dynamic equity calculation, and monitoring project expenses.

## Features
- Multi-user roles: Engineer (admin), Investor (read-only portal)
- Dynamic equity: S_i = (I_i / T_invested) × 100%
- Expense tracking with categories and photo receipts
- Financial dashboards with charts
- Firebase backend (free Spark plan)

## Setup
1. `flutter pub get`
2. Create Firebase project at console.firebase.google.com
3. Run `flutterfire configure` to generate firebase_options.dart
4. `flutter run`

## Tech Stack
Flutter 3.16+, Firebase (Firestore, Auth, Storage), Provider, fl_chart
