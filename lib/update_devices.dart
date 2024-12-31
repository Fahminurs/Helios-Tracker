import 'package:flutter/material.dart';  
import 'package:geolocator/geolocator.dart';  
import 'package:awesome_dialog/awesome_dialog.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'dart:async';  
import 'dart:convert';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:http/http.dart' as http;  

class UpdateDeviceDialog extends StatefulWidget {  
  final int idAlat;  

  const UpdateDeviceDialog({Key? key, required this.idAlat}) : super(key: key);  

  static void showUpdateDialog(BuildContext context, int idAlat) {  
    showModalBottomSheet(  
      context: context,  
      isScrollControlled: true,  
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),  
      builder: (BuildContext context) {  
        return UpdateDeviceDialog(idAlat: idAlat);  
      },  
    );  
  }  

  @override  
  _UpdateDeviceDialogState createState() => _UpdateDeviceDialogState();  
}  

class _UpdateDeviceDialogState extends State<UpdateDeviceDialog> {  
  final TextEditingController _deviceCodeController = TextEditingController();  
  final TextEditingController _latitudeController = TextEditingController();  
  final TextEditingController _longitudeController = TextEditingController();  
  bool _isLoadingLocation = false;  
  bool _isLoadingUpdate = false;  

  Future<bool> _handleLocationPermission() async {  
    bool serviceEnabled;  
    LocationPermission permission;  

    serviceEnabled = await Geolocator.isLocationServiceEnabled();  
    if (!serviceEnabled) {  
      await AwesomeDialog(  
        context: context,  
        dialogType: DialogType.warning,  
        animType: AnimType.topSlide,  
        title: 'Layanan Lokasi',  
        desc: 'Layanan lokasi dinonaktifkan. Silakan aktifkan layanan.',  
        btnOkOnPress: () {},  
      ).show();  
      return false;  
    }  

    permission = await Geolocator.checkPermission();  
    if (permission == LocationPermission.denied) {  
      permission = await Geolocator.requestPermission();  
      if (permission == LocationPermission.denied) {  
        await AwesomeDialog(  
          context: context,  
          dialogType: DialogType.warning,  
          animType: AnimType.topSlide,  
          title: 'Izin Lokasi',  
          desc: 'Izin lokasi ditolak.',  
          btnOkOnPress: () {},  
        ).show();  
        return false;  
      }  
    }  

    if (permission == LocationPermission.deniedForever) {  
      await AwesomeDialog(  
        context: context,  
        dialogType: DialogType.warning,  
        animType: AnimType.topSlide,  
        title: 'Izin Lokasi',  
        desc: 'Izin lokasi ditolak secara permanen.',  
        btnOkOnPress: () {},  
      ).show();  
      return false;  
    }  

    return true;  
  }  

void _updateDeviceLocation() async {  
  final hasPermission = await _handleLocationPermission();  
  if (!hasPermission) return;  

  setState(() {  
    _isLoadingLocation = true;  
  });  

  try {  
    // Try to get the last known position first  
    Position? lastKnownPosition = await Geolocator.getLastKnownPosition();  
    if (lastKnownPosition != null) {  
      setState(() {  
        _latitudeController.text = lastKnownPosition.latitude.toString();  
        _longitudeController.text = lastKnownPosition.longitude.toString();  
        _isLoadingLocation = false;  
      });  
      await AwesomeDialog(  
        context: context,  
        dialogType: DialogType.success,  
        animType: AnimType.topSlide,  
        title: 'Lokasi Ditemukan',  
        desc: 'Lokasi terakhir diketahui!\nAkurasi: ${lastKnownPosition.accuracy.toStringAsFixed(2)} meter',  
        btnOkOnPress: () {},  
      ).show();  
      return; // Exit if last known position is used  
    }  

    // If no last known position, try to get the current position  
    Position position = await Geolocator.getCurrentPosition(  
      desiredAccuracy: LocationAccuracy.high, // Use high accuracy  
      timeLimit: Duration(seconds: 15), // Increased time limit  
    );  

    setState(() {  
      _latitudeController.text = position.latitude.toString();  
      _longitudeController.text = position.longitude.toString();  
      _isLoadingLocation = false;  
    });  

    await AwesomeDialog(  
      context: context,  
      dialogType: DialogType.success,  
      animType: AnimType.topSlide,  
      title: 'Lokasi Berhasil Diperbarui',  
      desc: 'Lokasi berhasil diperbarui!\nAkurasi: ${position.accuracy.toStringAsFixed(2)} meter',  
      btnOkOnPress: () {},  
    ).show();  
  } catch (e) {  
    setState(() {  
      _isLoadingLocation = false;  
    });  

    // Log the error for debugging  
    print("Error updating location: $e");  

    await AwesomeDialog(  
      context: context,  
      dialogType: DialogType.error,  
      animType: AnimType.topSlide,  
      title: 'Gagal Memperbarui Lokasi',  
      desc: 'Gagal memperbarui lokasi. Pastikan GPS aktif dan izin lokasi diberikan.',  
      btnOkOnPress: () {},  
    ).show();  
  }  
} 

  void _saveDeviceInfo() async {  
            Navigator.of(context).pop(); // Tutup modal bottom sheet  

    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {  
          _showSnackBar('Harap Update lokasi terlebih dahulu', ContentType.failure);  
 
      return;  
    }  

    setState(() {  
      _isLoadingUpdate = true;  
    });  

    final payload = {  
      'id_alat': widget.idAlat,  
      'lokasi_perangkat': jsonEncode({  
        'Latitude': double.parse(_latitudeController.text),  
        'Longitude': double.parse(_longitudeController.text),  
      }),  
    };  

    try {  
      final apiHost = dotenv.env['API_HOST'];  
      final updateUrl = '${apiHost}informasi%20perangkat/update_informasi%20perangkat.php';  

      final response = await http.post(  
        Uri.parse(updateUrl),  
        headers: {  
          'Content-Type': 'application/json',  
        },  
        body: jsonEncode(payload),  
      );  

      print('Response Status Code: ${response.statusCode}');  
      print('Response Body: ${response.body}');  

      final responseData = json.decode(response.body);  
      if (response.statusCode == 200) {  
        if (responseData['status'] == 'success') {  
          print("id_alat: ${widget.idAlat}");  
          print("update berhasil: $responseData");  
          _showSnackBar('Informasi perangkat berhasil diperbarui', ContentType.success);  

     
        } else {  
          _showSnackBar(responseData['message'] ?? 'Gagal memperbarui informasi perangkat', ContentType.failure);  
        }  
      } else {  
        _showSnackBar('Terjadi kesalahan. Status Code: ${response.statusCode}', ContentType.failure);  
        print("update kesalahan: $responseData");  
        print("id_alat: ${widget.idAlat}");  
      }  
    } catch (e) {  
      _showSnackBar('Gagal memperbarui informasi perangkat: ${e.toString()}', ContentType.failure);  
    } finally {  
      setState(() {  
        _isLoadingUpdate = false;  
      });  
    }  
  }  

  void _showSuccessDialog() {  
    AwesomeDialog(  
      context: context,  
      dialogType: DialogType.success,  
      animType: AnimType.topSlide,  
      title: 'Berhasil',  
      desc: 'Informasi perangkat berhasil disimpan',  
      btnOkOnPress: () {  
        Navigator.of(context).pop(); // Tutup dialog  
      },  
    ).show();  
  }  

void _showSnackBar(String message,  
    ContentType contentType) {  
  final snackBar = SnackBar(  
    content: AwesomeSnackbarContent(  
      title: 'Info',  
      message: message,  
      contentType: contentType, 

    ),  
    duration: Duration(seconds: 3),  
    behavior: SnackBarBehavior.floating, // Mengatur snackbar menjadi float  
    backgroundColor: Colors.transparent, // Mengatur latar belakang menjadi transparan  
    elevation: 0, // Menghilangkan bayangan  
  );  

  ScaffoldMessenger.of(context).showSnackBar(snackBar);  
}  

  @override  
  Widget build(BuildContext context) {  
    return Container(  
      decoration: BoxDecoration(  
        color: Colors.white,  
        borderRadius: BorderRadius.circular(10),  
      ),  
      child: Column(  
        mainAxisSize: MainAxisSize.min,  
        crossAxisAlignment: CrossAxisAlignment.stretch,  
        children: [  
          Center(  
            child: Container(  
              width: 50,  
              height: 5,  
              margin: EdgeInsets.symmetric(vertical: 10),  
              decoration: BoxDecoration(  
                color: Color(0xFF7847EB),  
                borderRadius: BorderRadius.circular(10),  
              ),  
            ),  
          ),  
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 16.0),  
            child: Column(  
              crossAxisAlignment: CrossAxisAlignment.start,  
              children: [  
                Text(  
                  'Update Informasi Perangkat',  
                  style: TextStyle(  
                    fontSize: 18,  
                    fontWeight: FontWeight.bold,  
                  ),  
                ),  
                SizedBox(height: 20),  
                Row(  
                  children: [  
                    Icon(Icons.location_on, color: Colors.black, size: 40),  
                    SizedBox(width: 10),  
                    Expanded(  
                      child: Text(  
                        'Lokasi Perangkat',  
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  
                      ),  
                    ),  
                  ],  
                ),  
                SizedBox(height: 20),  
                Row(  
                  children: [  
                    Expanded(  
                      child: TextField(  
                        enabled: false,  
                        controller: TextEditingController(  
                          text: _latitudeController.text.isEmpty  
                              ? '-'  
                              : _latitudeController.text,  
                        ),  
                        decoration: _buildDisabledInputDecoration('Latitude'),  
                      ),  
                    ),  
                    SizedBox(width: 10),  
                    Expanded(  
                      child: TextField(  
                        enabled: false,  
                        controller: TextEditingController(  
                          text: _longitudeController.text.isEmpty  
                              ? '-'  
                              : _longitudeController.text,  
                        ),  
                        decoration: _buildDisabledInputDecoration('Longitude'),  
                      ),  
                    ),  
                  ],  
                ),  
                SizedBox(height: 20),  
                Row(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [  
                    ElevatedButton(  
                      onPressed: _isLoadingLocation ? null : _updateDeviceLocation,  
                      child: _isLoadingLocation  
                          ? SizedBox(  
                              width: 20,  
                              height: 20,  
                              child: CircularProgressIndicator(  
                                color: Colors.white,  
                                strokeWidth: 2,  
                              ),  
                            )  
                          : Row(  
                              mainAxisSize: MainAxisSize.min,  
                              children: [  
                                Icon(Icons.gps_fixed, size: 20, color: Colors.white),  
                                SizedBox(width: 8),  
                                Text('Update Lokasi'),  
                              ],  
                            ),  
                      style: ElevatedButton.styleFrom(  
                        backgroundColor: Color(0xFF7847EB),  
                        foregroundColor: Colors.white,  
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),  
                        shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(20),  
                        ),  
                      ),  
                    ),  
                    SizedBox(width: 10),  
                    ElevatedButton(  
                      onPressed: _isLoadingUpdate ? null : _saveDeviceInfo,  
                      child: _isLoadingUpdate  
                          ? SizedBox(  
                              width: 20,  
                              height: 20,  
                              child: CircularProgressIndicator(  
                                color: Colors.white,  
                                strokeWidth: 2,  
                              ),  
                            )  
                          : Row(  
                              mainAxisSize: MainAxisSize.min,  
                              children: [  
                                Icon(Icons.save, size: 20, color: Colors.white),  
                                SizedBox(width: 8),  
                                Text('Simpan'),  
                              ],  
                            ),  
                      style: ElevatedButton.styleFrom(  
                        backgroundColor: Colors.green,  
                        foregroundColor: Colors.white,  
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),  
                        shape: RoundedRectangleBorder(  
                          borderRadius: BorderRadius.circular(20),  
                        ),  
                      ),  
                    ),  
                  ],  
                ),  
                SizedBox(height: 20),  
              ],  
            ),  
          ),  
        ],  
      ),  
    );  
  }  

  InputDecoration _buildDisabledInputDecoration(String labelText) {  
    return InputDecoration(  
      labelText: labelText,  
      labelStyle: TextStyle(  
        fontSize: 20,  
        color: Colors.black,  
        fontWeight: FontWeight.bold,  
      ),  
      border: OutlineInputBorder(  
        borderSide: BorderSide(  
          color: Color(0xFF7847EB),  
          width: 4,  
        ),  
        borderRadius: BorderRadius.circular(20),  
      ),  
      focusedBorder: OutlineInputBorder(  
        borderSide: BorderSide(  
          color: Color(0xFF7847EB),  
          width: 4,  
        ),  
        borderRadius: BorderRadius.circular(20),  
      ),  
      enabledBorder: OutlineInputBorder(  
        borderSide: BorderSide(  
          color: Color(0xFF7847EB),  
          width: 4,  
        ),  
        borderRadius: BorderRadius.circular(20),  
      ),  
      disabledBorder: OutlineInputBorder(  
        borderSide: BorderSide(  
          color: Color(0xFF7847EB),  
          width: 4,  
        ),  
        borderRadius: BorderRadius.circular(20),  
      ),  
    );  
  }  

  @override  
  void dispose() {  
    _deviceCodeController.dispose();  
    _latitudeController.dispose();  
    _longitudeController.dispose();  
    super.dispose();  
  }  
}