import 'package:flutter/material.dart';
import 'package:helios_tracker/profile/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UpdateProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final int idUser; // Add idUser for profile update

  // Constructor to receive data with default values
  const UpdateProfilePage({
    Key? key,
    required this.name, // Default value for name
    required this.email, // Default value for email
    required this.phone, // Default value for phone
    required this.idUser, // Default value for idUser
  }) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  String kodePerangkat = '';


  File? _image; // Variable to hold the selected image

  @override
  void initState() {
    super.initState();
    _fetchDeviceCode(); // Ambil kode perangkat dari SharedPreferences  

    // Setup animation for shaking effect
    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController);

    // Set initial values from the passed data
    _namaController.text = widget.name;
    _emailController.text = widget.email;
    _teleponController.text = widget.phone;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _animationController.dispose();
    super.dispose();
  }

   Future<void> _fetchDeviceCode() async {  
    SharedPreferences prefs = await SharedPreferences.getInstance();  
    setState(() {  
      kodePerangkat = prefs.getString('kode_perangkat') ?? ''; // Ambil kode perangkat  
    });  
  } 


  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Get the MIME type from the image file
      final mimeType = image.mimeType;
      print('MIME Type: $mimeType'); // Debugging line to check the MIME type
      setState(() {
        _image = File(image.path); // Save the selected image
      });
    } else {
      _showSnackBar(context, 'Error', 'Tidak ada gambar yang dipilih.',
          ContentType.failure);
    }
  }

  void _showConfirmationDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: 'Konfirmasi',
      desc: 'Apakah Anda yakin ingin menyimpan perubahan?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _saveChanges(); // Call the save function
      },
    ).show();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Prepare data for API
      final apiHost = dotenv.env['API_HOST'];
      final updateUrl = '${apiHost}profile/update_profile.php';

      // Prepare request
      var request = http.MultipartRequest('POST', Uri.parse(updateUrl));
      request.fields['id_user'] = widget.idUser.toString();
      request.fields['nama'] = _namaController.text;
      request.fields['email'] = _emailController.text;
      request.fields['no_hp'] = _teleponController.text;

      // If an image is selected, convert it to Base64 and add it to the request
      if (_image != null) {
        // Convert image to Base64
        List<int> imageBytes = await _image!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        String mimeType =
            _image!.path.split('.').last; // Get the file extension

        // Prepare the Base64 string with the correct format
        String base64String = 'data:image/$mimeType;base64,$base64Image';
        print(
            'Base64 Image: $base64String'); // Debugging line to check the Base64 string

        // Add the Base64 string to the request
        request.fields['foto_profil'] =
            base64String; // Adjust the field name as needed
      }

      try {
        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${responseData.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final jsonResponse = json.decode(responseData.body);

          if (jsonResponse['status'] == 'success') {
            // Show success using Snackbar
            _showSnackBar(context, 'Sukses', 'Perubahan telah disimpan!',
                ContentType.success);
                 // Navigate to ProfilePage after saving changes  
                    Navigator.pushReplacement(  
                      context,  
                      MaterialPageRoute(  
                        builder: (context) => ProfilePage(idUser: widget.idUser, kodePerangkat: kodePerangkat),  
                      ),  
                    );  
          } else {
            // Show error using Snackbar
            _showSnackBar(
                context,
                'Error',
                'Gagal menyimpan perubahan: ${jsonResponse['message']}',
                ContentType.failure);
          }
        } else if (response.statusCode == 400) {
          // Show error using Snackbar
          final jsonResponse = json.decode(responseData.body);
          _showSnackBar(
              context,
              'Error',
              'Gagal menyimpan perubahan: ${jsonResponse['message']}',
              ContentType.failure);
        } else {
          // Show error dialog for non-200 response
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: 'Error',
            desc: 'Terjadi kesalahan saat menghubungi server.',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        // Show error dialog for exceptions
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Terjadi kesalahan: $e',
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      // If validation fails, trigger shaking animation
      _animationController.forward(from: 0);
    }
  }

  void _validateAndSave() {
    _showConfirmationDialog(); // Show confirmation dialog
  }

  void _showSnackBar(BuildContext context, String title, String message,
      ContentType contentType) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent, // Make background transparent
      elevation: 0, // Remove shadow
      behavior: SnackBarBehavior.floating, // Make Snackbar float
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
      duration: Duration(seconds: 3), // Snackbar display duration
    );

    // Show Snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                            'Update Profile',
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
              SizedBox(height: 20), // Space between AppBar and content

              // Profile Update Form
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Form(
                    key: _formKey,
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded edges
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Nama',
                              Icons.person,
                              _namaController,
                              'Nama tidak boleh kosong!',
                            ),
                            SizedBox(height: 10),
                            _buildTextField(
                              'Email',
                              Icons.email,
                              _emailController,
                              'Email tidak boleh kosong!',
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: _pickImage, // Call image picker on tap
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10), // Added left padding
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[200],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.image, color: Colors.purple),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _image != null
                                            ? _image!.path
                                                .split('/')
                                                .last // Display the image file name
                                            : 'Pilih Foto Profile',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // Display the selected image
                            if (_image != null) // Check if an image is selected
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height:
                                    150, // Set height of the image container
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(
                                        _image!), // Load the selected image
                                    fit: BoxFit
                                        .cover, // Cover the entire container
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            _buildTextField(
                              'No Telepon',
                              Icons.phone,
                              _teleponController,
                              'No Telepon tidak boleh kosong!',
                            ),
                            SizedBox(height: 20), // Space before buttons

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to ProfilePage when canceling
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfilePage(idUser: widget.idUser,kodePerangkat: kodePerangkat),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.red, // Red background
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
                                  onPressed: _validateAndSave,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller, String errorMessage) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple),
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
