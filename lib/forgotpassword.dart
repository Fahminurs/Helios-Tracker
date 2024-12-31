import 'package:flutter/material.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'dart:async';  
import 'dart:io';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'forgotpassword_otp.dart'; // Pastikan Anda memiliki ForgotPasswordOtpPage  

class ForgotPasswordPage extends StatefulWidget {  
  @override  
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();  
}  

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {  
  final TextEditingController _emailController = TextEditingController();  
  bool _isLoading = false;  

  Future<void> _sendRecoveryEmail() async {  
    // Validasi input  
    if (_emailController.text.isEmpty) {  
      _showSnackBar(context, 'Error', 'Email tidak boleh kosong', ContentType.failure);  
      return;  
    }  

    setState(() {  
      _isLoading = true;  
    });  

    try {  
      final apiHost = dotenv.env['API_HOST'];  
      final forgotPasswordUrl = '${apiHost}forgot-password.php?action=lupa_password';  

      print('Forgot Password URL: $forgotPasswordUrl'); // Debug print  

      // Membuat payload JSON  
      final payload = {  
        'email': _emailController.text,  
      };  

      // Mengirim permintaan POST  
      final response = await http.post(  
        Uri.parse(forgotPasswordUrl),  
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
        final responseData = json.decode(response.body);  
      if (response.statusCode == 200 || response.statusCode == 201) {  

        if (responseData['status'] == 'success') {  
          // Navigasi ke ForgotPasswordOtpPage dengan mengirimkan email  
          Navigator.pushReplacement(  
            context,  
            MaterialPageRoute(  
              builder: (context) => ForgotPasswordotpPage(email: _emailController.text),  
            ),  
          );  
        } else {  
          _showSnackBar(context, 'Error', responseData['message'] ?? 'Gagal mengirim email', ContentType.failure);  
        }  
      }else if(response.statusCode == 400){
     _showSnackBar(context,'Error', responseData['message'], ContentType.failure);
      } else {  
        _showSnackBar(context, 'Error', 'Terjadi kesalahan. Status Code: ${response.statusCode}', ContentType.failure);  
      }  
    } on TimeoutException catch (_) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(context, 'Error', 'Koneksi timeout. Periksa koneksi internet Anda.', ContentType.failure);  
    } on SocketException catch (_) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(context, 'Error', 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.', ContentType.failure);  
    } catch (e) {  
      setState(() {  
        _isLoading = false;  
      });  
      _showSnackBar(context, 'Error', 'Koneksi error: ${e.toString()}', ContentType.failure);  
    }  
  }  

  // Fungsi untuk menampilkan SnackBar  
  void _showSnackBar(BuildContext context, String title, String message, ContentType contentType) {  
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
    double screenHeight = MediaQuery.of(context).size.height; // Get screen height  

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
                  image: AssetImage('assets/images/lupa_password.png'), // Replace with your image path  
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
                      top: BorderSide(color: Colors.white, width: 3), // Only top border  
                      left: BorderSide.none, // No left border  
                      right: BorderSide.none, // No right border  
                      bottom: BorderSide.none, // No bottom border  
                    ),  
                  ),  
                  padding: EdgeInsets.all(20),  
                  child: Column(  
                    mainAxisSize: MainAxisSize.min,  
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left  
                    children: [  
                      Text(  
                        'Lupa Password?',  
                        style: TextStyle(  
                          fontFamily: 'Poppins',  
                          fontSize: 24,  
                          color: Colors.white,  
                          fontWeight: FontWeight.w700,  
                        ),  
                      ),  
                      SizedBox(height: 10),  
                      Text(  
                        'Tenang Helios Tracker dapat mengirimkan link untuk mengubah password anda',  
                        style: TextStyle(  
                          fontFamily: 'Poppins',  
                          fontSize: 14,  
                          color: Colors.white,  
                        ),  
                        textAlign: TextAlign.left, // Align text to the left  
                      ),  
                      SizedBox(height: 40), // Space before inputs  
                      // Email Input  
                      Container(  
                        width: 374,  
                        height: 51,  
                        decoration: BoxDecoration(  
                          borderRadius: BorderRadius.circular(50),  
                          border: Border.all(color: Color(0xFF95608E), width: 3),  
                        ),  
                        child: TextField(  
                          controller: _emailController, // Tambahkan controller  
                          style: TextStyle(  
                            color: Colors.white, // Set the input text color to white  
                            fontFamily: 'Poppins', // Use the same font family  
                            fontSize: 16, // Adjust font size if needed  
                          ),  
                          decoration: InputDecoration(  
                            labelText: 'Email', // Label for the input  
                            labelStyle: TextStyle(  
                              backgroundColor: Color(0xFF202425),  
                              color: Color.fromARGB(255, 255, 255, 255), // Color of the label  
                              fontFamily: 'Poppins',  
                              fontSize: 18, // Adjust font size if needed  
                              fontWeight: FontWeight.w600,  
                            ),  
                            hintText: 'Email',  
                            hintStyle: TextStyle(  
                              color: Color(0xFF95608E),  
                              fontFamily: 'Poppins',  
                            ),  
                            border: InputBorder.none,  
                            contentPadding: EdgeInsets.fromLTRB(20, -5, 20, 0), // Adjust top padding  
                          ),  
                        ),  
                      ),  
                      SizedBox(height: 30), // Space before button  
                      // Get Recovery Button  
                      SizedBox(  
                        width: 374,  
                        height: 51,  
                        child: ElevatedButton(  
                          onPressed: _isLoading ? null : _sendRecoveryEmail, // Disable button saat loading  
                          style: ElevatedButton.styleFrom(  
                            backgroundColor: Color(0xFFE8767C), // Button background color  
                            shape: RoundedRectangleBorder(  
                              borderRadius: BorderRadius.circular(50), // Rounded button  
                            ),  
                          ),  
                          child: _isLoading  
                              ? CircularProgressIndicator(color: Colors.white)  
                              : Text(  
                                  'Get Recovery',  
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
    _emailController.dispose();  
    super.dispose();  
  }  
}