import 'package:flutter/material.dart';  
import 'package:helios_tracker/login.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'dart:async';
import 'dart:io';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences 

class RegistrationPage extends StatefulWidget {  
  @override  
  _RegistrationPageState createState() => _RegistrationPageState();  
}  

class _RegistrationPageState extends State<RegistrationPage> {  
  // Controller untuk setiap input field  
  final TextEditingController _namaController = TextEditingController();  
  final TextEditingController _emailController = TextEditingController();  
  final TextEditingController _noHpController = TextEditingController();  
  final TextEditingController _passwordController = TextEditingController();  
  final TextEditingController _konfirmasiPasswordController = TextEditingController();  

  bool _isPasswordVisible = false;  
  bool _isConfirmPasswordVisible = false;  
  bool _isLoading = false;  

  // Metode untuk menampilkan SnackBar  
  void _showSnackBar(BuildContext context, String title, String message, ContentType contentType) {  
    ScaffoldMessenger.of(context).showSnackBar(  
      SnackBar(  
        elevation: 0,  
        behavior: SnackBarBehavior.floating,  
        backgroundColor: Colors.transparent,
        duration: Duration(seconds: 1), // Mengatur lama munculnya snackbar  
        content: AwesomeSnackbarContent(  
          title: title,  
          message: message,  
          contentType: contentType,  
        ),  
      ),  
    );  
  }  

  // Metode untuk melakukan registrasi  
  Future<void> _registerUser() async {  
    // Validasi input  
    if (_namaController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Nama tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    if (_emailController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Email tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    if (_noHpController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Nomor HP tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    if (_passwordController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Password tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    if (_konfirmasiPasswordController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Konfirmasi Password tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    if (_passwordController.text != _konfirmasiPasswordController.text) {  
      _showSnackBar(context, 'Error', 'Password dan Konfirmasi Password tidak cocok', ContentType.failure);  
      return;  
    }  

    setState(() {  
      _isLoading = true;  
    });  

    try {  
      final apiHost = dotenv.env['API_HOST'];  
      final registerUrl = '${apiHost}register.php';  

      print('Register URL: $registerUrl'); // Debug print  

      // Membuat payload JSON  
      final payload = {  
        'nama': _namaController.text,  
        'email': _emailController.text,  
        'no_hp': _noHpController.text,  
        'password': _passwordController.text,  
        'konfirmasi_password': _konfirmasiPasswordController.text,  
      };  

      // Mengirim permintaan POST  
      final response = await http.post(  
        Uri.parse(registerUrl),  
        headers: {  
          'Content-Type': 'application/json', // Set header Content-Type  
        },  
        body: jsonEncode(payload), // Mengubah payload menjadi JSON  
      ).timeout(  
        Duration(seconds: 10), // Tambahkan timeout 10 detik  
        onTimeout: () {  
          throw TimeoutException('Koneksi timeout');  
        },  
      );  

      print('Response Status Code: ${response.statusCode}');  
      print('Response Body: ${response.body}');  

      setState(() {  
        _isLoading = false;  
      });  

// Cek response dari server  
if (response.statusCode == 200 || response.statusCode == 201) {  
  final responseData = json.decode(response.body);  

  if (responseData['status'] == 'success') {  
    // Registrasi berhasil  
    _showSnackBar(  
      context,  
      'Sukses',  
      'Registrasi Berhasil',  
      ContentType.success,  
    );  
   // Set kode perangkat menjadi "null" di SharedPreferences  
        SharedPreferences prefs = await SharedPreferences.getInstance();  
        await prefs.setString('kode_perangkat', "null"); // Set kode perangkat menjadi "null"  
    // Navigasi ke halaman login  
    Future.delayed(Duration(seconds: 2), () {  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(builder: (context) => LoginPage()),  
      );  
    });  
  } else {  
    // Registrasi gagal, tampilkan pesan kesalahan dari server  
    String errorMessage = responseData['message'] ?? 'Registrasi Gagal';  
    if (responseData['errors'] != null && responseData['errors'] is List) {  
      errorMessage += '\n' + (responseData['errors'] as List).join('\n');  
    }  
    // Batasi panjang pesan untuk SnackBar  
    if (errorMessage.length > 100) {  
      errorMessage = errorMessage.substring(0, 100) + '...'; // Batasi panjang pesan  
    }  
    _showSnackBar(  
      context,  
      'Error',  
      errorMessage,  
      ContentType.failure,  
    );  
  }  
} else if (response.statusCode == 400) {  
  // Menangani status 400  
  final responseData = json.decode(response.body);  
  String errorMessage = responseData['message'] ;  
  if (responseData['errors'] != null && responseData['errors'] is List) {  
    errorMessage += '\n' + (responseData['errors'] as List).join('\n');  
  }  
  // Batasi panjang pesan untuk SnackBar  
  if (errorMessage.length > 100) {  
    errorMessage = errorMessage.substring(0, 500) + '...'; // Batasi panjang pesan  
  }  
  _showSnackBar(  
    context,  
    'Error',  
    errorMessage,  
    ContentType.failure,  
  );  
} else {  
  _showSnackBar(  
    context,  
    'Error',  
    'Terjadi kesalahan. Status Code: ${response.statusCode}',  
    ContentType.failure,  
  );  
} 
    } on TimeoutException catch (_) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(  
        context,  
        'Error',  
        'Koneksi timeout. Periksa koneksi internet Anda.',  
        ContentType.failure,  
      );  
    } on SocketException catch (_) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(  
        context,  
        'Error',  
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',  
        ContentType.failure,  
      );  
    } catch (e) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(  
        context,  
        'Error',  
        'Koneksi error: ${e.toString()}',  
        ContentType.failure,  
      );  
    }  
  }  

  @override  
  Widget build(BuildContext context) {  
    double screenHeight = MediaQuery.of(context).size.height;  

    return Scaffold(  
      backgroundColor: Colors.transparent,  
      body: Stack(  
        children: [  
          // Positioned image at the top filling the full height  
          Positioned(  
            top: 30,  
            left: 0,  
            right: 0,  
            child: Container(  
              height: screenHeight,  
              decoration: BoxDecoration(  
                image: DecorationImage(  
                  image: AssetImage('assets/images/registrasi.png'),  
                  fit: BoxFit.cover,  
                ),  
              ),  
            ),  
          ),  
          // Positioned image at the bottom  
          Align(  
            alignment: Alignment.bottomCenter,  
            child: Container(  
              height: screenHeight * 0.6,  
              decoration: BoxDecoration(  
                image: DecorationImage(  
                  image: AssetImage('assets/images/registrasi.png'),  
                  fit: BoxFit.cover,  
                ),  
              ),  
            ),  
          ),  
          // Overlay with transparency  
          Container(  
            color: Color(0xFF202425).withOpacity(0.88),  
          ),  
          // Main content centered both horizontally and vertically  
          Center(  
            child: SingleChildScrollView(  
              child: Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 20.0),  
                child: Column(  
                  mainAxisSize: MainAxisSize.min,  
                  children: [  
                    SizedBox(height: screenHeight * 0.1),  
                    Text(  
                      'Selamat Datang kembali !',  
                      style: TextStyle(  
                        fontFamily: 'Poppins',  
                        fontSize: 24,  
                        color: Colors.white,  
                        fontWeight: FontWeight.w700,  
                      ),  
                    ),  
                    SizedBox(height: 10),  
                    Text(  
                      'Silahkan Registrasi untuk Melanjutkan',  
                      style: TextStyle(  
                        fontFamily: 'Poppins',  
                        fontSize: 14,  
                        color: Colors.white,  
                      ),  
                    ),  
                    SizedBox(height: 40),  
                    // Name Input  
                    _buildTextField('Nama', false, _namaController),  
                    SizedBox(height: 20),  
                    // Email Input  
                    _buildTextField('Email', false, _emailController),  
                    SizedBox(height: 20),  
                    // Phone Number Input  
                    _buildTextField('No HP', false, _noHpController),  
                    SizedBox(height: 20),  
                    // Password Input  
                    _buildTextField('Password', true, _passwordController),  
                    SizedBox(height: 20),  
                    // Confirm Password Input  
                    _buildTextField('Konfirmasi Password', true, _konfirmasiPasswordController, isConfirm: true),  
                    SizedBox(height: 30),  
                    // Registration Button  
                    SizedBox(  
                      width: 374,  
                      height: 51,  
                      child: ElevatedButton(  
                        onPressed: _isLoading ? null : _registerUser,  
                        style: ElevatedButton.styleFrom(  
                          backgroundColor: Color(0xFFE8767C),  
                          shape: RoundedRectangleBorder(  
                            borderRadius: BorderRadius.circular(50),  
                          ),  
                        ),  
                        child: _isLoading   
                          ? CircularProgressIndicator(color: Colors.white)  
                          : Text(  
                              'Registrasi',  
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
                    // Additional text  
                    GestureDetector(  
                      onTap: () {  
                        Navigator.push(  
                          context,  
                          MaterialPageRoute(builder: (context) => LoginPage()),  
                        );  
                      },  
                      child: Text(  
                        'Sudah Mempunyai akun? Masuk disini',  
                        style: TextStyle(  
                          fontFamily: 'Poppins',  
                          fontSize: 14,  
                          color: Colors.white,  
                          fontWeight: FontWeight.w600,  
                        ),  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
            ),  
          ),  
        ],  
      ),  
    );  
  }  

  // Method to build text fields  
  Widget _buildTextField(String label, bool isPassword, TextEditingController controller, {bool isConfirm = false}) {  
    return Container(  
      height: 51,  
      decoration: BoxDecoration(  
        borderRadius: BorderRadius.circular(50),  
        border: Border.all(color: Color(0xFF95608E), width: 3),  
      ),  
      child: TextField(  
        controller: controller,  
        obscureText: isPassword && (isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible),  
        style: TextStyle(  
          color: Colors.white,  
          fontFamily: 'Poppins',  
          fontSize: 16,  
          fontWeight: FontWeight.bold,  
        ),  
        decoration: InputDecoration(  
          labelText: label,  
          labelStyle: TextStyle(  
            backgroundColor: Color.fromARGB(255, 51, 54, 54).withOpacity(0.7),  
            color: Color.fromARGB(255, 255, 255, 255),  
            fontFamily: 'Poppins',  
            fontSize: 18,  
            fontWeight: FontWeight.w600,  
          ),  
          hintText: label,  
          hintStyle: TextStyle(  
            color: Color(0xFF95608E),  
            fontFamily: 'Poppins',  
          ),  
          border: InputBorder.none,  
          contentPadding: EdgeInsets.fromLTRB(20, -5, 20, 0),  
          suffixIcon: isPassword  
              ? IconButton(  
                  icon: Icon(  
                    isConfirm  
                        ? _isConfirmPasswordVisible  
                            ? Icons.visibility  
                            : Icons.visibility_off  
                        : _isPasswordVisible  
                            ? Icons.visibility  
                            : Icons.visibility_off,  
                    color: Colors.white,  
                  ),  
                  onPressed: () {  
                    setState(() {  
                      if (isConfirm) {  
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;  
                      } else {  
                        _isPasswordVisible = !_isPasswordVisible;  
                      }  
                    });  
                  },  
                )  
              : null,  
        ),  
      ),  
    );  
  }  
}