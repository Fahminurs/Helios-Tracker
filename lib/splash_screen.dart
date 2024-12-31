import 'package:flutter/material.dart';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'login.dart'; // Pastikan Anda memiliki login.dart untuk halaman login  
import 'dashboard.dart'; // Pastikan Anda memiliki dashboard.dart untuk halaman dashboard  

class SplashScreen extends StatefulWidget {  
  @override  
  _SplashScreenState createState() => _SplashScreenState();  
}  

class _SplashScreenState extends State<SplashScreen> {  
  @override  
  void initState() {  
    super.initState();  
    // Menunggu 3 detik sebelum pindah ke halaman yang sesuai  
    Future.delayed(Duration(seconds: 3), () async {  
      SharedPreferences prefs = await SharedPreferences.getInstance();  
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;  
      int idUser = prefs.getInt('idUser') ?? 0;  
      String kodePerangkat = prefs.getString('kode_perangkat') ?? ''; // Berikan nilai default jika null  

      // Navigasi berdasarkan status login  
      if (isLoggedIn) {  
        // Jika sudah login, arahkan ke Dashboard  
        Navigator.of(context).pushReplacement(  
          MaterialPageRoute(builder: (context) => Dashboard(idUser: idUser, kodePerangkat: kodePerangkat)),  
        );  
      } else {  
        // Jika belum login, arahkan ke LoginPage  
        Navigator.of(context).pushReplacement(  
          MaterialPageRoute(builder: (context) => LoginPage()),  
        );  
      }  
    });  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: Color(0xFF1B334D), // Latar belakang berwarna #1B334D  
      body: Center(  
        child: Image.asset(  
          'assets/images/splash_logo.png', // Ganti dengan nama gambar Anda  
          width: 504, // Lebar gambar  
          height: 504, // Tinggi gambar  
        ),  
      ),  
    );  
  }  
}