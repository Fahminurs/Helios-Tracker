import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:async';
import 'dart:io';
import 'registrasi.dart';
import 'forgotpassword.dart';
import 'dashboard.dart'; // Pastikan Anda sudah membuat file dashboard.dart
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible =
      false; // State variable to manage password visibility
  bool _isLoading = false;

  // Controllers untuk TextField
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    // Validasi input
    if (_identifierController.text.isEmpty) {
      _showSnackBar(context, 'Error', 'Email atau No HP tidak boleh kosong',
          ContentType.failure);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar(
          context, 'Error', 'Password tidak boleh kosong', ContentType.failure);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan timeout untuk menangani koneksi lambat
      final apiHost = dotenv.env['API_HOST'];
      final loginUrl = '${apiHost}login.php';

      print('Login URL: $loginUrl'); // Debug print

      // Membuat payload JSON
      final payload = {
        'identifier': _identifierController.text,
        'password': _passwordController.text,
      };

      // Mengirim permintaan POST
      final response = await http
          .post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json', // Set header Content-Type
        },
        body: jsonEncode(payload), // Mengubah payload menjadi JSON
      )
          .timeout(
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
          // Login berhasil
          _showSnackBar(
            context,
            'Sukses',
            'Login Berhasil',
            ContentType.success,
          );
          int idUser = responseData['data']['id_user'];
          String kode_perangkat = responseData['data']['kode_perangkat'];

  // Simpan status login dan kode perangkat ke SharedPreferences  
  SharedPreferences prefs = await SharedPreferences.getInstance();  
  await prefs.setBool('isLoggedIn', true); // Menyimpan status login  
  await prefs.setInt('idUser', idUser); // Menyimpan idUser  
  await prefs.setString('kode_perangkat', kode_perangkat); // Menyimpan kode perangkat 

          // Navigasi ke dashboard
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Dashboard(idUser: idUser,kodePerangkat:kode_perangkat )),
            );
          });
        } else {
          // Login gagal
          _showSnackBar(
            context,
            'Error',
            responseData['message'] ?? 'Login Gagal',
            ContentType.failure,
          );
        }
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        // Menangani status 401
        final responseData = json.decode(response.body);
        _showSnackBar(
          context,
          'Error',
          responseData['message'] ?? 'Akses ditolak',
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

  // Fungsi untuk menampilkan SnackBar
void _showSnackBar(BuildContext context, String title, String message,  
    ContentType contentType) {  
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(  
    /// need to set following properties for best effect of awesome_snackbar_content  
    elevation: 0,  
    behavior: SnackBarBehavior.floating,  
    backgroundColor: Colors.transparent,  
    duration: Duration(seconds: 1), // Mengatur lama munculnya snackbar  
    content: AwesomeSnackbarContent(  
      title: title,  
      message: message,  
      contentType: contentType,  
    ),  
  ));  
}  

  @override
  Widget build(BuildContext context) {
    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: Color(0xFF202425), // Background color
      body: Stack(
        children: [
          // Positioned image at the top
          Positioned(
            top: 0, // Ensure the image is above
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.6, // Adjust height of the image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/login.png'), // Replace with your image path
                  fit: BoxFit.cover, // Ensure the image covers the area
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.517), // Space for the image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    color: Color(0xFF202425), // Background color for the form
                    border: Border(
                      top: BorderSide(
                          color: Colors.white, width: 3), // Only top border
                      left: BorderSide.none, // No left border
                      right: BorderSide.none, // No right border
                      bottom: BorderSide.none, // No bottom border
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        'Silahkan Login untuk Melanjutkan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40), // Space before inputs
                      // Email or Phone Input
                      Container(
                        width: 374,
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Color(0xFF95608E), width: 3),
                        ),
                        child: TextField(
                          controller:
                              _identifierController, // Tambahkan controller
                          style: TextStyle(
                            color: Colors
                                .white, // Set the input text color to white
                            fontFamily: 'Poppins', // Use the same font family
                            fontSize: 16, // Adjust font size if needed
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Email atau No HP', // Label for the input
                            labelStyle: TextStyle(
                              backgroundColor: Color(0xFF202425),
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Color of the label
                              fontFamily: 'Poppins',
                              fontSize: 18, // Adjust font size if needed
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Email atau No HP',
                            hintStyle: TextStyle(
                              color: Color(0xFF95608E),
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(
                                20, -5, 20, 0), // Adjust top padding
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Space between inputs
                      // Password Input
                      Container(
                        width: 374,
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Color(0xFF95608E), width: 3),
                        ),
                        child: TextField(
                          controller:
                              _passwordController, // Tambahkan controller
                          obscureText:
                              !_isPasswordVisible, // Toggle password visibility
                          style: TextStyle(
                            color: Colors
                                .white, // Set the input text color to white
                            fontFamily: 'Poppins', // Use the same font family
                            fontSize: 16, // Adjust font size if needed
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password', // Label for the input
                            labelStyle: TextStyle(
                              backgroundColor: Color(0xFF202425),
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Color of the label
                              fontFamily: 'Poppins',
                              fontSize: 18, // Adjust font size if needed
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Color(0xFF95608E),
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(
                                20, -5, 20, 0), // Adjust top padding
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white, // Icon color
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30), // Space before button
                      // Login Button
                      SizedBox(
                        width: 374,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _loginUser, // Disable button saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFFE8767C), // Button background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
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
                      SizedBox(height: 20), // Space below button
                      // Additional text
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()),
                          );
                        },
                        child: Text(
                          'Belum Mempunyai akun? disini',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Hapus controller saat widget di dispose
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
