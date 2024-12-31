import 'package:flutter/material.dart';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'splash_screen.dart'; // Import splash_screen.dart  

Future<void> main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  try {  
    await dotenv.load(fileName: ".env");  
    print("File .env loaded successfully");  
  } catch (e) {  
    print("Error loading .env: $e");  
  }  
  runApp(MyApp());  
}

class MyApp extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      debugShowCheckedModeBanner: false,  
      title: 'Splash Screen Example',  
      home: SplashScreen(), // Set SplashScreen sebagai halaman awal  
    );  
  }  
}