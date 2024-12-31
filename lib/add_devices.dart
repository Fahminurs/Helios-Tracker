import 'package:flutter/material.dart';  
import 'package:geolocator/geolocator.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'package:awesome_dialog/awesome_dialog.dart';  

class AddDevices extends StatefulWidget {  
  final int idUser;  
  const AddDevices({Key? key, required this.idUser}) : super(key: key);  

  @override  
  _AddDevicesState createState() => _AddDevicesState();  
}  

class _AddDevicesState extends State<AddDevices> {  
  final TextEditingController _deviceCodeController = TextEditingController();  
  final TextEditingController _latitudeController = TextEditingController();  
  final TextEditingController _longitudeController = TextEditingController();  
  bool _isLoading = false;  

  String _formatValue(String value) {  
    return value.length > 10 ? '${value.substring(0, 7)}...' : value;  
  }  

  Future<bool> _handleLocationPermission() async {  
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();  
    if (!serviceEnabled) {  
      await _showAlertDialog('Layanan Lokasi', 'Layanan lokasi dinonaktifkan. Silakan aktifkan layanan.');  
      return false;  
    }  

    LocationPermission permission = await Geolocator.checkPermission();  
    if (permission == LocationPermission.denied) {  
      permission = await Geolocator.requestPermission();  
      if (permission == LocationPermission.denied) {  
        await _showAlertDialog('Izin Lokasi', 'Izin lokasi ditolak. Anda perlu memberikan izin untuk menggunakan fitur ini.');  
        return false;  
      }  
    }  

    if (permission == LocationPermission.deniedForever) {  
      await _showAlertDialog('Izin Lokasi', 'Izin lokasi ditolak secara permanen. Anda perlu mengubah izin di pengaturan aplikasi.');  
      return false;  
    }  

    return true;  
  }  

  Future<void> _showAlertDialog(String title, String content) async {  
    await AwesomeDialog(  
      context: context,  
      dialogType: DialogType.info,  
      animType: AnimType.topSlide,  
      title: title,  
      desc: content,  
      btnOkOnPress: () {},  
    ).show();  
  }  

 Future<void> _getCurrentLocation() async {  
  final hasPermission = await _handleLocationPermission();  
  if (!hasPermission) return;  

  setState(() {  
    _isLoading = true;  
  });  

  try {  
    // Try to get the last known position first  
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();  
    if (lastKnownPosition != null) {  
      setState(() {  
        _latitudeController.text = lastKnownPosition.latitude.toString();  
        _longitudeController.text = lastKnownPosition.longitude.toString();  
        _isLoading = false;  
      });  
      await _showAlertDialog('Lokasi Ditemukan', 'Lokasi terakhir diketahui!\nLatitude: ${lastKnownPosition.latitude}, Longitude: ${lastKnownPosition.longitude}');  
      return;  
    }  

    // If no last known position, try to get the current position  
    Position position = await Geolocator.getCurrentPosition(  
      desiredAccuracy: LocationAccuracy.high,  
      timeLimit: Duration(seconds: 15),  
    );  

    setState(() {  
      _latitudeController.text = position.latitude.toString();  
      _longitudeController.text = position.longitude.toString();  
      _isLoading = false;  
    });  

    await _showAlertDialog('Lokasi Berhasil Didapatkan', 'Lokasi berhasil didapatkan!\nAkurasi: ${position.accuracy.toStringAsFixed(2)} meter');  
  } catch (e) {  
    setState(() {  
      _isLoading = false;  
    });  
    print("Error getting location: $e");  
    await _showAlertDialog('Gagal Mendapatkan Lokasi', 'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi diberikan.');  
  }  
}

  void _addDevice() {  
    if (_deviceCodeController.text.isEmpty) {  
      _showAlertDialog('Peringatan', 'Harap masukkan kode perangkat');  
      return;  
    }  

    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {  
      _showAlertDialog('Peringatan', 'Harap dapatkan lokasi terlebih dahulu');  
      return;  
    }  

    // Show confirmation dialog  
    AwesomeDialog(  
      context: context,  
      dialogType: DialogType.question,  
      animType: AnimType.topSlide,  
      title: 'Konfirmasi Tambah Perangkat',  
      desc: 'Apakah Anda yakin ingin menambahkan perangkat dengan detail berikut?\n'  
          'Kode Perangkat: ${_deviceCodeController.text}\n'  
          'Latitude: ${_latitudeController.text}\n'  
          'Longitude: ${_longitudeController.text}',  
      btnCancelOnPress: () {},  
      btnOkOnPress: () {  
        _saveDevice(); // Call the save device function  
      },  
    ).show();  
  }  

  Future<void> _saveDevice() async {  
    final apiHost = dotenv.env['API_HOST'];  
    final addUrl = '${apiHost}/informasi perangkat/add_informasi perangkat.php';  

    try {  
      double latitude = double.tryParse(_latitudeController.text) ?? 0.0;  
      double longitude = double.tryParse(_longitudeController.text) ?? 0.0;  

      final response = await http.post(  
        Uri.parse(addUrl),  
        headers: {'Content-Type': 'application/json'},  
        body: jsonEncode({  
          'kode_perangkat': _deviceCodeController.text,  
          'id_user': widget.idUser,  
          'lokasi_perangkat': jsonEncode({  
            'Latitude': latitude,  
            'Longitude': longitude,  
          }),  
        }),  
      );  

      print('Response Add Device: ${response.statusCode} ${response.body}');  

      if (response.statusCode == 200 || response.statusCode == 201) {  
        await _showAlertDialog('Berhasil', 'Perangkat berhasil ditambahkan');  
        Navigator.of(context).pop();
        _resetForm();  
      } else {  
        final responseData = json.decode(response.body);  
        await _showAlertDialog('Gagal', responseData['message']);  
      }  
    } catch (e) {  
      await _showAlertDialog('Gagal', 'Terjadi kesalahan. Silakan coba lagi.');  
      print("Gagal Add $e");  
    }  
  }  

  void _resetForm() {  
    _deviceCodeController.clear();  
    _latitudeController.clear();  
    _longitudeController.clear();  
    setState(() {});  
  }  

  void _showSnackBar(String title, String message, ContentType contentType) {  
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(  
      elevation: 0,  
      behavior: SnackBarBehavior.floating,  
      backgroundColor: Colors.transparent,  
      duration: Duration(seconds: 3),  
      content: AwesomeSnackbarContent(  
        title: title,  
        message: message,  
        contentType: contentType,  
      ),  
    ));  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Container(  
      width: 400,  
      child: Column(  
        mainAxisSize: MainAxisSize.min,  
        crossAxisAlignment: CrossAxisAlignment.start,  
        children: [  
          Text(  
            'Tambahkan Perangkat Baru dan Nikmati Fitur Menarik!',  
            style: TextStyle(  
              fontFamily: 'Poppins',  
              fontSize: 12,  
              fontWeight: FontWeight.bold,  
              color: Color(0xFF424242),  
            ),  
          ),  
          SizedBox(height: 30),  
          // Container untuk instruksi 1  
          Container(  
            padding: EdgeInsets.all(10.0),  
            decoration: BoxDecoration(  
              color: Color(0xFF7847EB),  
              borderRadius: BorderRadius.circular(8.0),  
            ),  
            child: Row(  
              children: [  
                Container(  
                  width: 40,  
                  height: 40,  
                  decoration: BoxDecoration(  
                    color: Color(0xFFD9D9D9),  
                    shape: BoxShape.circle,  
                  ),  
                  child: Center(  
                    child: Text(  
                      '1',  
                      style: TextStyle(  
                        fontFamily: 'Poppins',  
                        color: Colors.black,  
                        fontWeight: FontWeight.bold,  
                        fontSize: 17,  
                      ),  
                    ),  
                  ),  
                ),  
                SizedBox(width: 10),  
                Expanded(  
                  child: Text(  
                    'Input Kode Perangkat',  
                    style: TextStyle(  
                      fontFamily: 'Poppins',  
                      fontSize: 12,  
                      color: Colors.white,  
                      fontWeight: FontWeight.bold,  
                    ),  
                  ),  
                ),  
              ],  
            ),  
          ),  
          SizedBox(height: 30),  
          // Input untuk Kode Perangkat  
          Row(  
            children: [  
              Icon(Icons.qr_code, color: Colors.black, size: 40),  
              SizedBox(width: 10),  
              Expanded(  
                child: TextField(  
                  controller: _deviceCodeController,  
                  decoration: InputDecoration(  
                    labelText: 'Kode Perangkat',  
                    labelStyle: TextStyle(  
                      fontFamily: 'Poppins',  
                      color: const Color.fromARGB(255, 71, 71, 71),  
                      fontSize: 14,  
                      fontWeight: FontWeight.w800,  
                    ),  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                    enabledBorder: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                    focusedBorder: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                  ),  
                ),  
              ),  
            ],  
          ),  
          SizedBox(height: 30),  
          // Container untuk instruksi 2  
          Container(  
            padding: EdgeInsets.all(16.0),  
            decoration: BoxDecoration(  
              color: Color(0xFF7847EB),  
              borderRadius: BorderRadius.circular(8.0),  
            ),  
            child: Row(  
              children: [  
                Container(  
                  width: 40,  
                  height: 40,  
                  decoration: BoxDecoration(  
                    color: Color(0xFFD9D9D9),  
                    shape: BoxShape.circle,  
                  ),  
                  child: Center(  
                    child: Text(  
                      '2',  
                      style: TextStyle(  
                        fontFamily: 'Poppins',  
                        color: Colors.black,  
                        fontWeight: FontWeight.bold,  
                        fontSize: 17,  
                      ),  
                    ),  
                  ),  
                ),  
                SizedBox(width: 10),  
                Expanded(  
                  child: Text(  
                    'Dekatkan smartphone kamu dengan perangkat, lalu klik untuk mendapatkan lokasi! Yuk, coba! 📍😊',  
                    style: TextStyle(  
                      fontSize: 12,  
                      fontFamily: 'Poppins',  
                      color: Colors.white,  
                      fontWeight: FontWeight.bold,  
                    ),  
                  ),  
                ),  
              ],  
            ),  
          ),  
          SizedBox(height: 30),  
          // Input untuk Latitude dan Longitude  
          Row(  
            children: [  
              Icon(Icons.location_on, color: Colors.black, size: 40),  
              SizedBox(width: 10),  
              Expanded(  
                child: TextField(  
                  controller: _latitudeController,  
                  enabled: false,  
                  decoration: InputDecoration(  
                    labelText: 'Latitude',  
                    labelStyle: TextStyle(  
                      fontSize: 20,  
                      color: Colors.black,  
                      fontWeight: FontWeight.bold,  
                    ),  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                    disabledBorder: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                  ),  
                ),  
              ),  
              SizedBox(width: 5),  
              Expanded(  
                child: TextField(  
                  controller: _longitudeController,  
                  enabled: false,  
                  decoration: InputDecoration(  
                    labelText: 'Longitude',  
                    labelStyle: TextStyle(  
                      fontSize: 20,  
                      color: Colors.black,  
                      fontWeight: FontWeight.bold,  
                    ),  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                    disabledBorder: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(50),  
                      borderSide: BorderSide(color: Color(0xFF95608E), width: 4),  
                    ),  
                  ),  
                ),  
              ),  
            ],  
          ),  
          SizedBox(height: 10),  
          Row(  
            mainAxisAlignment: MainAxisAlignment.center,  
            crossAxisAlignment: CrossAxisAlignment.center,  
            children: [  
              Expanded(  
                child: ElevatedButton(  
                  onPressed: _isLoading ? null : _getCurrentLocation,  
                  style: ElevatedButton.styleFrom(  
                    backgroundColor: Color(0xFF7847EB),  
                    foregroundColor: Colors.white,  
                    padding: EdgeInsets.symmetric(vertical: 5),  
                  ),  
                  child: _isLoading  
                      ? CircularProgressIndicator(color: Colors.white)  
                      : Row(  
                          mainAxisSize: MainAxisSize.min,  
                          children: [  
                            Icon(Icons.gps_fixed, size: 20, color: Colors.white),  
                            SizedBox(width: 8),  
                            Text(  
                              'Dapatkan Lokasi',  
                              style: TextStyle(  
                                fontFamily: 'Poppins',  
                                fontSize: 12,  
                                fontWeight: FontWeight.bold,  
                              ),  
                            ),  
                          ],  
                        ),  
                ),  
              ),  
              SizedBox(width: 10),  
              Expanded(  
                child: ElevatedButton(  
                  onPressed: _addDevice,  
                  style: ElevatedButton.styleFrom(  
                    backgroundColor: Color.fromARGB(255, 235, 71, 71),  
                    foregroundColor: Colors.white,  
                    padding: EdgeInsets.symmetric(vertical: 5),  
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(30),  
                    ),  
                  ),  
                  child: Text(  
                    'Tambah Perangkat',  
                    style: TextStyle(  
                      fontFamily: 'Poppins',  
                      fontSize: 12,  
                      fontWeight: FontWeight.bold,  
                    ),  
                  ),  
                ),  
              ),  
            ],  
          ),  
        ],  
      ),  
    );  
  }  
}