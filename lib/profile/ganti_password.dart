import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:helios_tracker/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


class gantipwprofile extends StatefulWidget {
  final int idUser;
  final String kodePerangkat; 
  const gantipwprofile({Key? key, required this.idUser, required this.kodePerangkat}) : super(key: key);

  @override
  _gantipwprofileState createState() => _gantipwprofileState();
}

class _gantipwprofileState extends State<gantipwprofile> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {  
    super.initState();  
  }




  void _showConfirmationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'Konfirmasi',
      desc: 'Apakah Anda yakin ingin menyimpan perubahan?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _saveChanges(); // Call the save function
      },
    ).show();
  }

  void _showSnackBar(BuildContext context, String title, String message,
      ContentType contentType) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    ));
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Prepare the payload for the API request
      final apiHost = dotenv.env['API_HOST'];
      final updatePasswordUrl = '${apiHost}profile/update_password.php';
      print('Update Password URL: $updatePasswordUrl'); // Debug print
      final payload = {
        'id_user': widget.idUser,
        'password_sekarang': _currentPasswordController.text,
        'password_baru': _newPasswordController.text,
        'konfirmasi_password': _confirmPasswordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(updatePasswordUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          // If the server returns a 200 or 201 response, show success snackbar
          _showSnackBar(
            context,
            'Berhasil!',
            'Password telah diubah!',
            ContentType.success,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(idUser: widget.idUser, kodePerangkat: widget.kodePerangkat),
            ),
          );
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          // Handle bad request
          final responseData = json.decode(response.body);
          String errorMessage;

          if (responseData.containsKey('errors') &&
              responseData['errors'].isNotEmpty) {
            errorMessage = responseData['errors']
                .join(', '); // Get the error messages from the array
          } else {
            errorMessage =
                responseData['message']; // Fallback to the general message
          }

          _showSnackBar(
            context,
            'Gagal!',
            errorMessage,
            ContentType.failure,
          );
        } else {
          // Handle other status codes
          _showSnackBar(
            context,
            'Kesalahan!',
            'Terjadi kesalahan yang tidak terduga.',
            ContentType.warning,
          );
        }
      } catch (e) {
        // Handle exceptions
        _showSnackBar(
          context,
          'Error!',
          'Tidak dapat menghubungi server. Periksa koneksi internet.',
          ContentType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F9), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Card as AppBar
              Card(
                elevation: 2,
                margin: EdgeInsets.zero, // Full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30), // Bottom left corner
                    bottomRight: Radius.circular(30), // Bottom right corner
                  ),
                ),
                child: Container(
                  height: 122, // Height of the Card
                  decoration: BoxDecoration(
                    color: Colors.white, // Card background color
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50, right: 16),
                          child: Text(
                            'Ganti Password',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800, // Bold
                              fontSize: 32, // Font size 32
                              fontFamily: 'Poppins', // Using Poppins font
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100), // Space between AppBar and form

              // Change Password Form
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Add padding to the sides
                child: Form(
                  key: _formKey,
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Rounded edges
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            'Password Saat Ini',
                            _currentPasswordController,
                            _isCurrentPasswordVisible,
                            () {
                              setState(() {
                                _isCurrentPasswordVisible =
                                    !_isCurrentPasswordVisible;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          // Divider with text in the middle
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Password Baru',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: 10),
                          _buildPasswordField(
                            'Password Baru',
                            _newPasswordController,
                            _isNewPasswordVisible,
                            () {
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          _buildPasswordField(
                            'Konfirmasi Password Baru',
                            _confirmPasswordController,
                            _isConfirmPasswordVisible,
                            () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          SizedBox(height: 20), // Space before buttons

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(idUser: widget.idUser,kodePerangkat: widget.kodePerangkat),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Red background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                icon: Icon(Icons.cancel, color: Colors.white),
                                label: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showConfirmationDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFF6A5ACD), // Purple background
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                icon: Icon(Icons.save, color: Colors.white),
                                label: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong!';
        }
        return null;
      },
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock, color: Colors.purple),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.purple,
          ),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple), // Purple border
        ),
        filled: true,
        fillColor: Colors.grey[200], // Light grey background for text field
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }
}
