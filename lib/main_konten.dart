import 'package:flutter/material.dart';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:dio/dio.dart'; // Import Dio  
import 'dart:async';  
import 'update_devices.dart';
import 'dart:convert'; // Import this at the top of your file  

import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences  

class MainKonten extends StatefulWidget {  
  final String kodePerangkat; // Tambahkan parameter ini  
  final int idUser; // Tambahkan parameter ini  

  const MainKonten({Key? key, required this.kodePerangkat, required this.idUser})  
      : super(key: key);  

  @override  
  _MainKontenState createState() => _MainKontenState();  
}  

class _MainKontenState extends State<MainKonten> {  
  // Variabel untuk menyimpan data  
  String statusServo = 'Tidak Diketahui';  
  String statusEsp32 = 'Tidak Diketahui';  
  String cuaca = 'Tidak Diketahui';  
  String suhu = '';  
  String deviceName = 'Tidak Diketahui';  
  double latitude = 0.0;  
  double longitude = 0.0;  
  String ampere = "0";  
  String volt = "0";  
  String posisiX = "0";  
  String posisiY = "0";  
  String kodeperangkatfetch = "Tidak Diketahui";  
  String battery = "0";  
  int id_alat = 0;  

  final Dio dio = Dio(); // Inisialisasi Dio  

Timer? _timer;  

@override  
void initState() {  
  super.initState();  
  fetchData();  
  _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchData());  
}  

@override  
void dispose() {  
  _timer?.cancel(); // Membatalkan timer saat widget dihapus  
  super.dispose();  
}  
  Future<void> fetchData() async {  
    try {  
      await fetchInformasiPerangkat();  
      await updateCuaca();  
      await fetchMonitoringEnergi();  
      await fetchMonitoringSolar();  
      await fetchDevice();  
    } catch (e) {  
      print('Error fetching data: $e');  
    }  
  }  

  Future<void> updateCuaca() async {  
    try {  
      final response = await dio.post(  
        '${dotenv.env['API_HOST']}/informasi%20perangkat/cuaca/update_cuaca.php',  
        data: {"kode_perangkat": widget.kodePerangkat},  
      );  

      if (response.statusCode == 200) {  
        var data = response.data;  
        if (data['status'] == 'success') {  
          setState(() {  
            print("Berhasil Update Cuaca");  
          });  
        }  
      }  
    } catch (e) {  
      print('Error updating weather: $e');  
    }  
  }  

  Future<void> fetchInformasiPerangkat() async {  
    try {  
      final response = await dio.post(  
        '${dotenv.env['API_HOST']}/informasi%20perangkat/select_informasi%20perangkat.php',  
        data: {"kode_perangkat": widget.kodePerangkat},  
      );  

      if (response.statusCode == 200) {  
        var data = response.data;  
        if (data['status'] == 'success') {  
          setState(() {  
            statusServo = data['data']['status_servo'] ?? 'Tidak Diketahui';  
            statusEsp32 = data['data']['status_esp32'] ?? 'Tidak Diketahui';  
            cuaca = data['data']['cuaca'] ?? 'Tidak Diketahui';  
            suhu = data['data']['suhu'] ?? 'Tidak Diketahui';  
            latitude = data['data']['lokasi_perangkat']['Latitude'] ?? 0.0;  
            longitude = data['data']['lokasi_perangkat']['Longitude'] ?? 0.0;  
            kodeperangkatfetch = data['data']['kode_perangkat'] ?? "Tidak Diketahui";  
          });  
        }  
      }  
    } catch (e) {  
      print('Error fetching device information: $e');  
    }  
  }  

  Future<void> fetchMonitoringEnergi() async {  
    try {  
      final response = await dio.post(  
        '${dotenv.env['API_HOST']}/monitoring%20energi/select_monitoring%20energi.php',  
        data: {"kode_perangkat": widget.kodePerangkat},  
      );  

      if (response.statusCode == 200) {  
        var data = response.data;  
        if (data['status'] == 'success') {  
          setState(() {  
            ampere = data['data']['ampere'].toString();  
            volt = data['data']['volt'].toString();  
            battery = data['data']['battery'];  
            print('Ampere: $ampere');  
            print('Volt: $volt');  
            print('Battery: $battery%');  
          });  
        } else {  
          print('Error: ${data['message'] ?? 'Unknown error'}');  
        }  
      }  
    } catch (e) {  
      print('Error fetching energy monitoring: $e');  
    }  
  }  

Future<void> fetchDevice() async {  
  try {  
    print("Memanggil fetchDevice dengan id_user: ${widget.idUser}");  
    
    final response = await dio.post(  
      '${dotenv.env['API_HOST']}/devices/read_devices.php',  
      data: {"id_user": widget.idUser},  
    );  

    // Check if the response is successful  
    if (response.statusCode == 200 || response.statusCode == 201) {  
      // Parse the response data  
      var data = jsonDecode(response.data); // Decode the JSON string  

      // Log the parsed data  
      print("Parsed Response Data: $data");  

      // Check if the response indicates success and if data is a list  
      if (data['status'] == 'success' && data['data'] is List) {  
        print("Berhasil mendapatkan perangkat");  
        
        // Iterate through the list of devices  
        for (var device in data['data']) {  
          // Ensure device is a Map  
          if (device is Map<String, dynamic>) {  
            print("Memeriksa perangkat: ${device['kode_perangkat']}");  
            if (device['kode_perangkat'] == widget.kodePerangkat) {  
              if (mounted) {  
                setState(() {  
                  deviceName = device['Devices'] ?? 'Tidak Diketahui';  
                  print("Nama perangkat: $deviceName");  
                });  
              }  
              break; // Exit loop after finding the matching device  
            }  
          } else {  
            print("Item dalam data['data'] bukan Map: $device");  
          }  
        }  
      } else {  
        print("Status tidak sukses atau data tidak dalam format list: ${data['message']}");  
      }  
    } else {  
      print("Tidak ada data, status code: ${response.statusCode}");  
    }  
  } catch (e) {  
    print("Error fetching devices: $e");  
  }  
}  
  Future<void> fetchMonitoringSolar() async {  
    try {  
      final response = await dio.post(  
        '${dotenv.env['API_HOST']}/solar%20panel/select_solar%20panel.php',  
        data: {"kode_perangkat": widget.kodePerangkat},  
      );  

      if (response.statusCode == 200) {  
        var data = response.data;  
        if (data['status'] == 'success') {  
          setState(() {  
            posisiX = data['data']['posisi_x'].toString();  
            posisiY = data['data']['posisi_y'].toString();  
            id_alat = data['data']['id_alat'];  
            print('Posisi Y: $posisiY');  
            print('Posisi X: $posisiX');  
          });  
        } else {  
          print('Error: ${data['message'] ?? 'Unknown error'}');  
        }  
      }  
    } catch (e) {  
      print('Error fetching solar monitoring: $e');  
    }  
  }  

  Widget build(BuildContext context) {  
  return Scaffold(  
    body: SingleChildScrollView(  
      child: Padding(  
        padding: const EdgeInsets.only(top: 16.0), // Padding atas  
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center, // Menempatkan konten di tengah secara vertikal  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            // Cek apakah kode perangkat null  

        
            if (widget.kodePerangkat == "null" || widget.kodePerangkat.isEmpty || widget.kodePerangkat == "Belum ada alat" ) ...[  
              Center( // Tambahkan Center di sini  
                child: _buildWelcomeCard(), // Tampilkan kartu sambutan  
              )  
            ] else ...[  
              // Card untuk Informasi Perangkat  
              Container(  
                decoration: BoxDecoration(  
                  color: Colors.white,  
                  borderRadius: BorderRadius.circular(30),  
                  boxShadow: [  
                    BoxShadow(  
                      color: Colors.grey.withOpacity(0.2),  
                      spreadRadius: 2,  
                      blurRadius: 5,  
                      offset: Offset(0, 3),  
                    ),  
                  ],  
                ),  
                child: card_informasiPerangkat(context),  
              ),  
              SizedBox(height: 10), // Space between cards  

              // Card untuk Monitoring Solar Panel  
              Container(  
                decoration: BoxDecoration(  
                  color: Colors.white,  
                  borderRadius: BorderRadius.circular(30),  
                  boxShadow: [  
                    BoxShadow(  
                      color: Colors.grey.withOpacity(0.2),  
                      spreadRadius: 2,  
                      blurRadius: 5,  
                      offset: Offset(0, 3),  
                    ),  
                  ],  
                ),  
                child: card_solar(),  
              ),  
              SizedBox(height: 10), // Space between cards  

              // Card untuk Monitoring Energi  
              Container(  
                decoration: BoxDecoration(  
                  color: Colors.white,  
                  borderRadius: BorderRadius.circular(30),  
                  boxShadow: [  
                    BoxShadow(  
                      color: Colors.grey.withOpacity(0.2),  
                      spreadRadius: 2,  
                      blurRadius: 5,  
                      offset: Offset(0, 3),  
                    ),  
                  ],  
                ),  
                child: card_monitoring(),  
              ),  
              SizedBox(height: 60),  
            ],  
          ],  
        ),  
      ),  
    ),  
  );  
}

  // Fungsi untuk memformat nilai
  String _formatValue(String value) {
    if (value.length > 10) {
      return '${value.substring(0, 10)}...'; // Memotong dan menambahkan '...'
    }
    return value; // Mengembalikan nilai asli jika tidak lebih dari 5 digit
  }

  // Modifikasi PopupMenuButton di card_informasiPerangkat
  Widget card_informasiPerangkat(BuildContext context) {
    // Tambahkan parameter context
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Informasi Perangkat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (String value) {
                    // Tambahkan logika untuk setiap pilihan
                    if (value == 'update_info') {
                      UpdateDeviceDialog.showUpdateDialog(context, id_alat);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'update_info',
                      child: Row(
                        children: [
                          Icon(Icons.update, color: Colors.black),
                          SizedBox(width: 10),
                          Text('Update Informasi Perangkat'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Card Kode Perangkat
            _buildDeviceInfoCard(Icons.device_hub_sharp, deviceName),
            SizedBox(height: 10), // Space between cards
            _buildDeviceInfoCard(
                Icons.qr_code, 'Kode Perangkat: ${widget.kodePerangkat}'),
            SizedBox(height: 10), // Space between cards

            // Card Status Servo
            _buildDeviceInfoCard(
                Icons.settings_remote, 'Status Servo: $statusServo'),
            SizedBox(height: 10), // Space between cards

            // Card Status ESP32
            _buildDeviceInfoCard(
                Icons.developer_board, 'Status ESP32: $statusEsp32'),
            SizedBox(height: 10), // Space between cards

            // Row untuk Card Cuaca dan Lokasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildWeatherCard(cuaca, suhu)), // Card Cuaca
                SizedBox(width: 10), // Space between cards
                Expanded(child: _buildLocationCard()), // Card Lokasi
              ],
            ),
            SizedBox(height: 10), // Space after the ro
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Color(0xFF1B334D), // Ganti dengan warna pastel yang diinginkan
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.energy_savings_leaf_sharp, // Ganti dengan ikon yang sesuai
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 30),
          Text(
            '🌟 Selamat datang di Helios Tracker! 🌟',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          Text(
            'Silakan pilih perangkat jika sudah ada, atau tambahkan perangkat baru untuk memulai perjalanan Anda! 🚀',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void _updateDeviceInfo() {
    // Implementasi logika update informasi perangkat
    print('Memperbarui informasi perangkat...');
  }

  Widget _buildDeviceInfoCard(IconData icon, String title) {
    return Card(
      margin: EdgeInsets.zero, // Hapus margin default card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0xFF7847EB),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(String cuaca, String suhu) {
    String getWeatherImage(String cuaca) {
      switch (cuaca) {
        case 'Cerah':
          return 'assets/weather/cerah.png';
        case 'Sebagian Berawan':
          return 'assets/weather/sebagianberawan.png';
        case 'Hujan':
          return 'assets/weather/hujan.png';
        case 'Hujan Petir':
          return 'assets/weather/hujanpetir.png';
        case 'Salju':
          return 'assets/weather/salju.png'; // Pastikan Anda memiliki gambar ini
        default:
          return 'assets/weather/tidakdiketahui.png'; // Gambar default jika cuaca tidak dikenali
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0xFF7847EB),
      child: Container(
        height: 140, // Tinggi tetap 140
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 0,
            top: 10.0,
            bottom: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuaca lokasi perangkat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: suhu == ''
                        ? MainAxisAlignment
                            .center // Jika suhu kosong, tampilkan suhu kosong
                        : MainAxisAlignment
                            .spaceEvenly, // Jika tidak, tampilkan dengan space evenly
                    children: [
                      Image.asset(
                        getWeatherImage(
                            cuaca), // Ambil gambar berdasarkan cuaca
                        width: cuaca == "Tidak Diketahui"
                            ? 60
                            : 95, // Jika cuaca "Tidak Diketahui", ukuran 60, jika tidak, ukuran 95
                        height: cuaca == "Tidak Diketahui"
                            ? 60
                            : 95, // Sama untuk tinggi
                        fit: BoxFit.contain,
                      ),
                      Text(
                        suhu == ''
                            ? '$suhu' // Jika suhu kosong, tampilkan suhu kosong
                            : '$suhu °C', // Jika tidak, tampilkan suhu dengan satuan °C
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  cuaca, // Tampilkan status cuaca
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Color(0xFF7847EB),
      child: Container(
        height: 140, // Tinggi tetap 140
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 10.0,
            bottom: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lokasi Perangkat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text(
                  'Latitude',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Container(
                  width: 100,
                  child: Text(
                    latitude.toString(), // Menampilkan nilai latitude
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Container(
                  width: double.infinity,
                  height: 2.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text(
                  'Longitude',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Container(
                  width: 100,
                  child: Text(
                    longitude.toString(), // Menampilkan nilai longitude
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget card_monitoring() {
    // Menghitung lebar baterai berdasarkan persentase
    double batteryWidth =
        (double.parse(battery) / 100) * 350; // 400 adalah lebar maksimum

    return Card(
      margin: EdgeInsets.zero, // Hapus margin default card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Card putih dengan radius 30
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Energi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 10), // Space before the next section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amperes Card
                Expanded(
                  child: Card(
                    color: Colors.orange[300],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Ampere (A)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$ampere',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: ' A',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Space between cards
                // Volts Card
                Expanded(
                  child: Card(
                    color: Colors.orange[300],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Volt (V)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$volt',
                                  style: TextStyle(
                                    fontSize: 50,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: ' V',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Space after the row of cards

            // Battery Monitoring Card
            Card(
              color: Colors.orange[300],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Battery (B)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width:
                                batteryWidth, // Menggunakan lebar yang dihitung
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Center(
                            child: Text(
                              '$battery%', // Menampilkan persentase baterai
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ), // Space after the battery card
          ],
        ),
      ),
    );
  }

  Widget card_solar() {
    return Card(
      margin: EdgeInsets.zero, // Hapus margin default card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Card putih dengan radius 30
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Solar Panel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 10), // Space before the next section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Posisi X Card
                Expanded(
                  child: Card(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Mengatur teks ke kiri
                        children: [
                          Text(
                            'Horizontal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            // Menempatkan angka di tengah
                            child: Text(
                              '${posisiX}°',
                              style: TextStyle(
                                fontSize: 65,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10), // Space between cards
                // Posisi Y Card
                Expanded(
                  child: Card(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Mengatur teks ke kiri
                        children: [
                          Text(
                            'Vertikal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            // Menempatkan angka di tengah
                            child: Text(
                              '${posisiY}°',
                              style: TextStyle(
                                fontSize: 65,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
  
}
