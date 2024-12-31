import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'login.dart'; // Pastikan Anda memiliki halaman login
import 'gantipassword.dart'; // Pastikan Anda memiliki halaman ChangePasswordPage

class ForgotPasswordotpPage extends StatefulWidget {
  final String email; // Parameter email yang diterima

  // Constructor untuk menerima email
  const ForgotPasswordotpPage({Key? key, required this.email})
      : super(key: key);

  @override
  _ForgotPasswordotpPageState createState() => _ForgotPasswordotpPageState();
}

class _ForgotPasswordotpPageState extends State<ForgotPasswordotpPage> {
  int _countdown = 120; // Countdown timer
  Timer? _timer;
  final TextEditingController _otpController =
      TextEditingController(); // Controller untuk OTP
  bool _isLoading = false; // State untuk loading

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar(
          context, 'Error', 'Kode OTP tidak boleh kosong', ContentType.failure);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiHost = dotenv.env['API_HOST'];
      final verifyOtpUrl =
          '${apiHost}forgot-password.php?action=verifikasi_token';

      print('Verify OTP URL: $verifyOtpUrl'); // Debug print

      // Membuat payload JSON
      final payload = {
        'email': widget.email,
        'token': _otpController.text,
      };

      // Mengirim permintaan POST
      final response = await http
          .post(
        Uri.parse(verifyOtpUrl),
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
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          // Navigasi ke ChangePasswordPage dengan mengirimkan email dan token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordPage(
                email: widget.email,
                token: _otpController.text,
              ),
            ),
          );
        } else {
          _showSnackBar(
              context,
              'Error',
              responseData['message'] ?? 'Gagal memverifikasi OTP',
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
  void dispose() {
    _timer?.cancel();
    _otpController.dispose(); // Hapus controller saat widget di dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah email ada, jika tidak kembalikan ke halaman login
    if (widget.email.isEmpty) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage()), // Ganti dengan LoginPage
        );
      });
    }

    double screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

    return Scaffold(
      backgroundColor: Color(0xFF202425), // Background color
      body: Stack(
        children: [
          // Positioned image at the top filling the full height
          Positioned(
            top: -150,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight, // Adjust height of the image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/lupa_password.png'), // Replace with your image path
                  fit: BoxFit.contain, // Ensure the image covers the area
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.6), // Space for the image
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align children to the left
                    children: [
                      Text(
                        'Verifikasi Kode OTP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Masukkan kode OTP yang telah kami kirimkan ke email Anda untuk melanjutkan proses pengaturan ulang password.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 40), // Space before inputs
                      // OTP Input
                      Container(
                        width: 374,
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Color(0xFF95608E), width: 3),
                        ),
                        child: TextField(
                          controller: _otpController, // Controller untuk OTP
                          style: TextStyle(
                            color: Colors
                                .white, // Set the input text color to white
                            fontFamily: 'Poppins', // Use the same font family
                            fontSize: 16, // Adjust font size if needed
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Masukkan Kode OTP', // Label for the input
                            labelStyle: TextStyle(
                              backgroundColor: Color(0xFF202425),
                              color: Color.fromARGB(
                                  255, 255, 255, 255), // Color of the label
                              fontFamily: 'Poppins',
                              fontSize: 18, // Adjust font size if needed
                              fontWeight: FontWeight.w600,
                            ),
                            hintText: 'Kode OTP',
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
                      SizedBox(height: 30), // Space before button
                      // Verify OTP Button
                      SizedBox(
                        width: 374,
                        height: 51,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _verifyOtp, // Disable button saat loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFFE8767C), // Button background color
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(50), // Rounded button
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Verifikasi OTP',
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
                SizedBox(height: 100), // Space for the sun and countdown
              ],
            ),
          ),
          // Countdown Timer
          Positioned(
            top: 470, // Sesuaikan posisi sesuai kebutuhan
            right: 10, // Sesuaikan posisi sesuai kebutuhan
            child: Stack(
              alignment: Alignment.center, // Memusatkan isi di tengah
              children: [
                // Sun Image with Shadow
                Container(
                  width: 120, // Sesuaikan ukuran gambar
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFEE9D3E).withOpacity(0.8), // Warna bayangan 0%
                        Color(0xFFECA14A)
                            .withOpacity(0.0), // Warna bayangan 100% transparan
                      ],
                      radius: 1.0,
                      center: Alignment.center,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEE9D3E)
                            .withOpacity(0.5), // Warna bayangan
                        blurRadius: 15, // Seberapa kabur bayangan
                        spreadRadius: 10, // Seberapa jauh bayangan menyebar
                        offset: Offset(0, 5), // Posisi bayangan
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Sun.png', // Ganti dengan path gambar matahari Anda
                      fit: BoxFit.cover, // Pastikan gambar memenuhi area
                    ),
                  ),
                ),
                // Countdown Timer
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors
                        .transparent, // Background color for the countdown
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        color: Color(
                            0xFFC81B1E), // Perbaiki dengan Color() yang benar
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
