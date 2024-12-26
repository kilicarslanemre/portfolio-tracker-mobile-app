import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:portfolio_tracker/app/app.dart';
import 'package:portfolio_tracker/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PortfolioApp());
}
