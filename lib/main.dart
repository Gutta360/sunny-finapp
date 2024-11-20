import 'package:flutter/material.dart';
import 'package:finapp/layout/layout.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBXcAQFzWEnQaEACh7bzPXza1P7zQxapsU",
        authDomain: "sunnyfinapp.firebaseapp.com",
        projectId: "sunnyfinapp",
        storageBucket: "sunnyfinapp.firebasestorage.app",
        messagingSenderId: "98115636944",
        appId: "1:98115636944:web:e7c93958d8ff277c49d8d5",
        measurementId: "G-ZJN28WMZ0Z"),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalData(),
      child: const MainWidget(),
    ),
  );
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.outfitTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.outfit(textStyle: textTheme.bodyMedium),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const LayoutWidget());
  }
}

class GlobalData extends ChangeNotifier {
  bool _isUserLoggedIn = false;

  bool get isUserLoggedIn => _isUserLoggedIn;

  void setIsUserLoggedIn(bool isUserLoggedIn) {
    _isUserLoggedIn = isUserLoggedIn;
    notifyListeners();
  }
}
