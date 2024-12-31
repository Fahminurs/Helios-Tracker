import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:helios_tracker/Navigation_bar.dart';
import 'package:helios_tracker/login.dart';
import 'package:helios_tracker/profile/update_profile.dart';
import 'package:helios_tracker/profile/tentang.dart';
import 'package:helios_tracker/profile/ganti_password.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int idUser; // Tambahkan parameter ini
  final String kodePerangkat;

  // Constructor untuk menerima idUser
  const ProfilePage(
      {Key? key, required this.idUser, required this.kodePerangkat})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // Variable to hold the selected image
  Map<String, dynamic>? _userData; // Variable to hold user data
  bool _isLoading = true; // Loading state
  bool _hasError = false; // Error state

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    print('profile ID User: ${widget.idUser}');
    print('profile Kode Perangkat: ${widget.kodePerangkat}');
  }

  // Function to fetch user profile from API
  Future<void> _fetchUserProfile() async {
    final apiHost = dotenv.env['API_HOST'];
    final profileUrl = '${apiHost}profile/read_profile.php';

    // Membuat payload JSON
    final payload = {
      'id_user': widget.idUser,
    };

    try {
      final response = await http
          .post(
            Uri.parse(profileUrl),
            headers: {
              'Content-Type': 'application/json', // Set header Content-Type
            },
            body: jsonEncode(payload), // Mengubah payload menjadi JSON
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            _userData = responseData['data']; // Simpan data pengguna
            _isLoading = false; // Set loading to false
            _hasError = false; // Reset error state
            print("Data Profile : $_userData");
          });
        } else {
          setState(() {
            _isLoading = false; // Set loading to false
            _hasError = true; // Set error state
          });
        }
      } else {
        setState(() {
          _isLoading = false; // Set loading to false
          _hasError = true; // Set error state
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false
        _hasError = true; // Set error state
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path); // Update the state with the selected image
      });
    }
  }

  @override
/*************  ✨ Codeium Command ⭐  *************/
  /// Builds the Profile page widget.
  ///
  /// This function returns a Scaffold with a light grey background. The body
  /// of the Scaffold contains a SingleChildScrollView with a Column as its
  /// child. The Column contains a Card with a custom shape as its first child.
  /// The Card is used as an AppBar with a title and a back button. The Card
  /// also contains a child Column with a Text widget as its child. The Text
  /// widget displays the title of the page.
  ///
  /// Below the Card, the Column contains a SizedBox with a height of 20.

  /// If the _isLoading state is true, a Center widget with a CircularProgressIndicator
  /// is displayed. If the _hasError state is true, an error widget is displayed.
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F9), // Light grey background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Profile',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Loading and Error Handling
              if (_isLoading) ...[
                Center(
                    child:
                        CircularProgressIndicator()), // Show loading indicator
              ] else if (_hasError) ...[
                _buildErrorWidget(), // Show error widget
              ] else ...[
                // Profile Information
                _buildProfileInfo(),
                SizedBox(height: 20),

                // Contact Information
                _buildContactInfo(),
                SizedBox(height: 20),

                // Settings Section
                _buildSettingsSection(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
          selectedIndex: 1,
          idUser: widget.idUser,
          kodePerangkat: widget.kodePerangkat), // Set selected index to 1
    );
  }

  // Widget to build profile information
  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage, // Call the image picker on tap
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF87CBD6),
                    width: 4,
                  ),
                  image: _image != null
                      ? DecorationImage(
                          image:
                              FileImage(_image!), // Display the selected image
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: NetworkImage(_userData?['foto_profil'] ??
                              'assets/images/foto_profile.png'), // Use network image if available
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalize(_userData?['nama'] ??
                      'Nama Tidak Ditemukan'), // Display user name
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData?['email'] ??
                      'Email Tidak Ditemukan', // Display user email
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String text) {
    if (text.isEmpty)
      return text; // Jika string kosong, kembalikan string kosong
    return text[0].toUpperCase() +
        text.substring(1); // Ubah huruf pertama menjadi kapital
  }

  // Widget to build contact information
  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF87CBD6)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userData?['no_hp'] ?? 'Nomor Tidak Ditemukan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.devices, color: Color(0xFF87CBD6)),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_userData?['jumlah_device'] ?? 0} Buah', // Display number of devices
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build settings section
  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: [
              _buildSettingItem(
                  Icons.person, 'Update Akun', 'Buat perubahan pada akun Anda',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfilePage(
                      idUser:
                          _userData?['id_user'] ?? '', // Kirim nama pengguna
                      name: _userData?['nama'] ?? '', // Kirim nama pengguna
                      email: _userData?['email'] ?? '', // Kirim email pengguna
                      phone: _userData?['no_hp'] ??
                          '', // Kirim nomor telepon pengguna
                    ),
                  ), // Navigasi ke UpdateProfilePage
                );
              }),
              _buildSettingItem(Icons.lock, 'Ganti Password',
                  'Amankan akun Anda demi keamanan', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => gantipwprofile(
                          idUser: _userData?['id_user'] ?? '',
                          kodePerangkat: widget
                              .kodePerangkat)), // Navigasi ke ChangePasswordPage
                );
              }),
              _buildSettingItem(Icons.info, 'Tentang Aplikasi',
                  'Detail informasi aplikasi ini dibuat', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TentangPage()), // Navigasi ke TentangPage
                );
              }),
              _buildSettingItem(
                  Icons.logout, 'Keluar', 'Amankan akun Anda demi keamanan',
                  () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.scale,
                  title: 'Konfirmasi Keluar',
                  desc: 'Apakah Anda yakin ingin keluar dari aplikasi?',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    // Logika untuk logout
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.remove('isLoggedIn'); // Hapus status login
                    await prefs
                        .remove('idUser'); // Hapus idUser jika diperlukan
                    await prefs.setString('kode_perangkat',
                        "null"); // Set kode perangkat menjadi "null"

                    // Navigasi ke LoginPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ).show();
              }),
            ],
          ),
        ],
      ),
    );
  }

  // Widget to build error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_off, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Tidak dapat terhubung ke internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _fetchUserProfile, // Refresh the profile
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Widget to build setting item
  Widget _buildSettingItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF87CBD6)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF87CBD6)),
          ],
        ),
      ),
    );
  }
}
