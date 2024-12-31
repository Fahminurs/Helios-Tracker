import 'package:flutter/material.dart';  

class WelcomePage extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    // Mendapatkan tinggi layar  
    final screenHeight = MediaQuery.of(context).size.height;  

    return Scaffold(  
      backgroundColor: Color(0xFF202425), // Latar belakang #202425  
      body: Stack(  
        children: [  
          // Latar belakang  
          Container(  
            color: Color(0xFF202425), // Warna latar belakang  
          ),  
          // Konten di bawah gambar  
          Center(  
            child: Container(  
              margin: EdgeInsets.only(bottom: 50), // Menambahkan margin bawah  
              child: Column(  
                mainAxisAlignment: MainAxisAlignment.end, // Mengatur konten di bawah  
                children: [  
                  SizedBox(height: 20),  
                  // Tombol Login  
                  SizedBox(  
                    width: 331, // Lebar tombol 331 piksel  
                    height: 51, // Tinggi tombol 51 piksel  
                    child: ElevatedButton(  
                      onPressed: () {  
                        // Aksi untuk tombol Login  
                      },  
                      style: ElevatedButton.styleFrom(  
                        backgroundColor: Color(0xFFE8767C), // Warna tombol #E8767C  
                        shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(30),  
                        ),  
                      ),  
                      child: Text(  
                        'Login',  
                        style: TextStyle(  
                          fontFamily: 'Poppins',  
                          fontSize: 24,  
                          fontWeight: FontWeight.w600,  
                          color: Colors.white,  
                        ),  
                      ),  
                    ),  
                  ),  
                  SizedBox(height: 20),  
                  // Tombol Register  
                  SizedBox(  
                    width: 331, // Lebar tombol 331 piksel  
                    height: 51, // Tinggi tombol 51 piksel  
                    child: ElevatedButton(  
                      onPressed: () {  
                        // Aksi untuk tombol Register  
                      },  
                      style: ElevatedButton.styleFrom(  
                        backgroundColor: Color(0xFFE8767C), // Warna tombol #E8767C  
                        shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(30),  
                        ),  
                      ),  
                      child: Text(  
                        'Register',  
                        style: TextStyle(  
                          fontFamily: 'Poppins',  
                          fontSize: 24,  
                          fontWeight: FontWeight.w600,  
                          color: Colors.white,  
                        ),  
                      ),  
                    ),  
                  ),  
                  SizedBox(height: 20),  
                  // Kalimat  
                  Text(  
                    'Track the Sun, Power Your Future!',  
                    style: TextStyle(  
                      fontFamily: 'Poppins',  
                      fontSize: 14,  
                      color: Colors.white,  
                      fontWeight: FontWeight.w600,  
                    ),  
                  ),  
                  SizedBox(height: 20), // Tambahkan jarak di bawah kalimat  
                ],  
              ),  
            ),  
          ),  
          // Gambar  
          Positioned(  
            top: -10, // Memastikan gambar berada di atas  
            left: 0,  
            right: -2,  
            child: Container(  
              height: screenHeight * 0.690, // Sesuaikan tinggi gambar  
              decoration: BoxDecoration(  
                image: DecorationImage(  
                  image: AssetImage('assets/images/welcome.png'), // Ganti dengan nama gambar Anda  
                  fit: BoxFit.contain, // Pastikan gambar tidak terpotong  
                ),  
              ),  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
}