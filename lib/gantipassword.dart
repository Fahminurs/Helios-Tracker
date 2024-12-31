import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:async';
import 'dart:io';
import 'login.dart'; // Pastikan Anda sudah membuat file login.dart

class ChangePasswordPage extends StatefulWidget {
  final String email; // Parameter email
  final String token; // Parameter token

  // Constructor untuk menerima email dan token
  const ChangePasswordPage({Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isNewPasswordVisible = false; // State untuk menampilkan password baru
  bool _isConfirmPasswordVisible =
      false; // State untuk menampilkan konfirmasi password
  bool _isLoading = false; // State untuk menampilkan loading

  // Controllers untuk TextField
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cek apakah email dan token ada, jika tidak kembalikan ke halaman login
    if (widget.email.isEmpty || widget.token.isEmpty) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage()), // Ganti dengan LoginPage
        );
      });
    }
  }

  Future<void> _changePassword() async {
    // Validasi input
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar(context, 'Error', 'Password baru tidak boleh kosong',
          ContentType.failure);
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showSnackBar(context, 'Error', 'Konfirmasi password tidak boleh kosong',
          ContentType.failure);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar(context, 'Error',
          'Password baru dan konfirmasi tidak cocok', ContentType.failure);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan timeout untuk menangani koneksi lambat
      final apiHost = dotenv.env['API_HOST'];
      final changePasswordUrl =
          '${apiHost}forgot-password.php?action=reset_password'; // Ganti dengan URL endpoint yang sesuai

      // Membuat payload JSON
      final payload = {
        'email': widget.email,
        'token': widget.token,
        'password': _newPasswordController.text,
        'konfirmasi_password': _confirmPasswordController.text,
      };

      // Mengirim permintaan POST
      final response = await http
          .post(
        Uri.parse(changePasswordUrl),
        headers: {
          'Content-Type': 'application/json', // Set header Content-Type
        },
        body: jsonEncode(payload), // Mengubah payload menjadi JSON
      )
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Koneksi timeout');
      });

      setState(() {
        _isLoading = false;
      });

      // Cek response dari server
        final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {

        if (responseData['status'] == 'success') {
          // Ganti password berhasil
          _showSnackBar(context, 'Sukses', 'Password berhasil diubah',
              ContentType.success);
          // Navigasi kembali ke halaman login
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else {
          // Ganti password gagal
          _showSnackBar(
              context,
              'Error',
              responseData['message'] ?? 'Ganti password gagal',
              ContentType.failure);
        }
      } else if (response.statusCode == 400) {
        _showSnackBar(
            context, 'Error', responseData['message'], ContentType.failure);
      } else {
        _showSnackBar(
            context,
            'Error',
            'Terjadi kesalahan. Status Code: ${response.statusCode}',
            ContentType.failure);
      }
    } on TimeoutException catch (_) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
          context,
          'Error',
          'Koneksi timeout. Periksa koneksi internet Anda.',
          ContentType.failure);
    } on SocketException catch (_) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(
          context,
          'Error',
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          ContentType.failure);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(context, 'Error', 'Koneksi error: ${e.toString()}',
          ContentType.failure);
    }
  }

  // Fungsi untuk menampilkan SnackBar
  void _showSnackBar(BuildContext context, String title, String message,
      ContentType contentType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.6, // Adjust height of the image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/lupa_password.png'), // Ganti dengan path gambar Anda
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.560), // Space for the image
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
                      left: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide.none,
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Atur Ulang Password Baru',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Silakan masukkan password baru Anda dan konfirmasi untuk melanjutkan.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40), // Space before inputs
                      // New Password Input
                      Container(
                        width: 374,
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Color(0xFF95608E), width: 3),
                        ),
                        child: TextField(
                          controller: _newPasswordController,
                          obscureText:
                              !_isNewPasswordVisible, // Toggle password visibility
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password Baru',
                            labelStyle: TextStyle(
                              backgroundColor: Color(0xFF202425),
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Masukkan password baru',
                            hintStyle: TextStyle(
                              color: Color(0xFF95608E),
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(20, -5, 20, 0),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isNewPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // Space between inputs
                      // Confirm Password Input
                      Container(
                        width: 374,
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Color(0xFF95608E), width: 3),
                        ),
                        child: TextField(
                          controller: _confirmPasswordController,
                          obscureText:
                              !_isConfirmPasswordVisible, // Toggle password visibility
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            labelStyle: TextStyle(
                              backgroundColor: Color(0xFF202425),
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Masukkan kembali password baru',
                            hintStyle: TextStyle(
                              color: Color(0xFF95608E),
                              fontFamily: 'Poppins',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(20, -5, 20, 0),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30), // Space before button
                      // Change Password Button
                      SizedBox(
                        width: 374,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _changePassword, // Disable button saat loading
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
                                  'Ganti Password',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
