import 'package:flutter/material.dart';  
import 'package:http/http.dart' as http;  
import 'dart:convert';  
import 'package:flutter_dotenv/flutter_dotenv.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  
import 'dart:async';  
import 'package:shared_preferences/shared_preferences.dart';  
import 'add_devices.dart'; // Import the AddDevices modal  
import 'dashboard.dart'; // Pastikan Anda sudah membuat file dashboard.dart  
import 'package:awesome_dialog/awesome_dialog.dart';

class DeviceList extends StatefulWidget {  
  final int idUser; // Tambahkan parameter ini  
  final String kodePerangkat;  

  const DeviceList({Key? key, required this.idUser, required this.kodePerangkat})  
      : super(key: key);  

  @override  
  _DeviceListState createState() => _DeviceListState();  
}  

class _DeviceListState extends State<DeviceList> {  
  List<Map<String, dynamic>> devices = []; // Menyimpan daftar perangkat  
  late List<bool> _isTapped;  
  late List<bool> _isDeleting;  
  Timer? _timer;  
  bool _isLoading = true; // Tambahkan variabel loading  

  @override  
  void initState() {  
    super.initState();  
    _isTapped = [];  
    _isDeleting = [];  
    fetchDevices(); // Memanggil fungsi untuk mengambil perangkat  
  }  

  Future<void> fetchDevices() async {  
    final apiHost = dotenv.env['API_HOST'];  
    final url = '${apiHost}devices/read_devices.php';  

    final response = await http.post(  
      Uri.parse(url),  
      headers: {'Content-Type': 'application/json'},  
      body: jsonEncode({'id_user': widget.idUser}),  
    );  

      final data = json.decode(response.body);  
    if (response.statusCode == 200) {  
      if (data['status'] == 'success') {  
        setState(() {  
          devices = List<Map<String, dynamic>>.from(data['data']);  
          _isTapped = List.generate(devices.length, (index) => false);  
          _isDeleting = List.generate(devices.length, (index) => false);  
          _isLoading = false; // Set loading to false setelah data diambil  
        });  
      } else {  
        _showSnackBar(context, 'Error', data['message'], ContentType.failure);  
        setState(() {  
          _isLoading = false; // Set loading to false jika terjadi error  
        });  
      }  
    }else if(data['message'] == 'Tidak ada perangkat ditemukan') {  
       setState(() {  
        _isLoading = false; // Set loading to false jika terjadi error  
      });  
      
      // Tampilkan dialog menggunakan Awesome Dialog  
      AwesomeDialog(  
        context: context,  
        dialogType: DialogType.error,  
        animType: AnimType.scale,  
        title: 'Oops! 😢',  
        desc: 'Anda Belum Memiliki Perangkat, tambahkan perangkat untuk memulai! 🛠️',  
        btnOkOnPress: () {},  
      ).show();  
      
      return; // Keluar dari fungsi jika tidak ada perangkat  
    
    }else {  
      _showSnackBar(context, 'Error', 'Gagal mengambil data perangkat', ContentType.failure);  
        print("Response body devicelist: ${response.body}");
      setState(() {  
        _isLoading = false; // Set loading to false jika terjadi error  
      });  
    }  
  }  

  void _showSnackBar(BuildContext context, String title, String message,  
      ContentType contentType) {  
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(  
      elevation: 0,  
      behavior: SnackBarBehavior.floating,  
      backgroundColor: Colors.transparent,  
      duration: Duration(seconds: 2),  
      content: AwesomeSnackbarContent(  
        title: title,  
        message: message,  
        contentType: contentType,  
      ),  
    ));  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Stack(  
      children: [  
        SingleChildScrollView(  
          child: Padding(  
            padding: const EdgeInsets.only(top: 10.0),  
            child: Column(  
              crossAxisAlignment: CrossAxisAlignment.start,  
              children: [  
                Container(  
                  margin: const EdgeInsets.only(top: 8.0),  
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
                  padding: const EdgeInsets.all(16.0),  
                  child: Column(  
                    crossAxisAlignment: CrossAxisAlignment.start,  
                    children: [  
                      Text(  
                        'Berikut adalah daftar perangkat yang telah berhasil dipasang, mencakup semua perangkat yang terhubung dan siap digunakan. Informasi ini penting untuk memastikan konektivitas yang optimal dan memudahkan pengelolaan perangkat dalam sistem Anda.',  
                        style: TextStyle(  
                          fontSize: 12,  
                          color: Color(0xFF464646),  
                          fontWeight: FontWeight.w600,  
                        ),  
                        textAlign: TextAlign.justify,  
                      ),  
                      SizedBox(height: 20),  
                      // Cek apakah sedang loading  
                      if (_isLoading)   
                        Center(  
                          child: CircularProgressIndicator(  
                            strokeWidth: 5, // Ukuran garis  
                          ),  
                        )  
                      else   
                        ListView.builder(  
                          shrinkWrap: true,  
                          physics: NeverScrollableScrollPhysics(),  
                          itemCount: devices.length,  
                          itemBuilder: (context, index) {  
                            bool isCurrentDevice = devices[index]['kode_perangkat'] == widget.kodePerangkat;  

                            return GestureDetector(  
                              onTap: () async {  
                                // Menyimpan kode perangkat yang dipilih  
                                SharedPreferences prefs = await SharedPreferences.getInstance();  
                                await prefs.setString('kode_perangkat', devices[index]['kode_perangkat']);  

                                // Navigasi ke Dashboard  
                                Navigator.pushReplacement(  
                                  context,  
                                  MaterialPageRoute(  
                                    builder: (context) => Dashboard(  
                                      idUser: widget.idUser,  
                                      kodePerangkat: devices[index]['kode_perangkat'],  
                                    ),  
                                  ),  
                                );  

                                _showSnackBar(context, 'Info', '${devices[index]['Devices']} terpilih.', ContentType.success);  
                              },  
                              onLongPress: () {  
                                setState(() {  
                                  _isTapped[index] = true;  
                                });  
                              },  
                              onLongPressEnd: (details) {  
                                _timer = Timer(Duration(seconds: 2), () {  
                                  setState(() {  
                                    _isTapped[index] = false;  
                                  });  
                                });  
                              },  
                              child: Container(  
                                width: double.infinity,  
                                child: Card(  
                                  color: _isTapped[index] ? Colors.red : (isCurrentDevice ? Color(0xFFFB7B4A) : Color(0xFFFB7B4A)),  
                                  margin: EdgeInsets.symmetric(vertical: 8.0),  
                                  elevation: 2,  
                                  child: Padding(  
                                    padding: const EdgeInsets.all(16.0),  
                                    child: Row(  
                                      crossAxisAlignment: CrossAxisAlignment.center,  
                                      children: [  
                                        SizedBox(width: 20),  
                                        Container(  
                                          width: 80,  
                                          height: 84,  
                                          decoration: BoxDecoration(  
                                            borderRadius: BorderRadius.circular(5),  
                                            boxShadow: [  
                                              BoxShadow(  
                                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),  
                                                spreadRadius: 1,  
                                                blurRadius: 25,  
                                                offset: Offset(0, 1),  
                                              ),  
                                            ],  
                                          ),  
                                          child: ClipRRect(  
                                            borderRadius: BorderRadius.circular(12),  
                                            child: Image.asset(  
                                              'assets/card_device/solar.png',  
                                              fit: BoxFit.cover,  
                                            ),  
                                          ),  
                                        ),  
                                        SizedBox(width: 20),  
                                        Expanded(  
                                          child: Column(  
                                            crossAxisAlignment: CrossAxisAlignment.start,  
                                            mainAxisAlignment: MainAxisAlignment.center,  
                                            children: [  
                                              if (!isCurrentDevice) // Hanya menampilkan nama perangkat jika bukan perangkat saat ini  
                                                Text(  
                                                  devices[index]['Devices'], // Menampilkan nama perangkat  
                                                  style: TextStyle(  
                                                    fontSize: 18, // Ukuran font untuk perangkat yang bukan saat ini  
                                                    fontFamily: 'PressStart2P', // Gunakan PressStart2P untuk perangkat yang bukan saat ini  
                                                    fontWeight: FontWeight.bold,  
                                                    color: Color(0xFF414141), // Warna default  
                                                  ),  
                                                ),  
                                              if (isCurrentDevice) // Menampilkan teks tambahan jika perangkat saat ini  
                                                Text(  
                                                  'Perangkat saat ini',  
                                                  style: TextStyle(  
                                                    fontSize: 16, // Ukuran font untuk status  
                                                    fontFamily: 'Poppins', // Gunakan Poppins untuk status  
                                                    fontWeight: FontWeight.w800, // Normal weight untuk status  
                                                    color: Color.fromARGB(255, 255, 255, 255), // Warna putih untuk status  
                                                  ),  
                                                ),  
                                              SizedBox(height: 2),  
                                              Text(  
                                                'Kode Perangkat: ${devices[index]['kode_perangkat']}',  
                                                style: TextStyle(  
                                                  fontSize: 14,  
                                                  color: Color(0xFF414141),  
                                                  fontWeight: FontWeight.w600,  
                                                ),  
                                              ),  
                                            ],  
                                          ),  
                                        ),  
                                        if (_isTapped[index])  
                                          IconButton(  
                                            icon: Icon(Icons.delete, color: Colors.white),  
                                            onPressed: () {  
                                              _showConfirmationDialog(context, index);  
                                            },  
                                          ),  
                                      ],  
                                    ),  
                                  ),  
                                ),  
                              ),  
                            );  
                          },  
                        ),  
                    ],  
                  ),  
                ),  
                SizedBox(height: 10),  
                SizedBox(height: 60),  
              ],  
            ),  
          ),  
        ),  
        Positioned(  
          bottom: 100,  
          right: 5,  
          child: FloatingActionButton(  
            onPressed: () {  
              showDialog(  
                context: context,  
                builder: (BuildContext context) {  
                  return Dialog(  
                    backgroundColor: Colors.white,  
                    child: Container(  
                      width: 400,  
                      padding: EdgeInsets.all(16.0),  
                      child: Column(  
                        mainAxisSize: MainAxisSize.min,  
                        crossAxisAlignment: CrossAxisAlignment.start,  
                        children: [  
                          Text(  
                            'Tambah Perangkat',  
                            style: TextStyle(  
                                fontFamily: 'Poppins',  
                                fontSize: 25,  
                                fontWeight: FontWeight.bold,  
                                color: Color.fromARGB(255, 0, 0, 0)),  
                            textAlign: TextAlign.start,  
                          ),  
                          SizedBox(height: 20),  
                          AddDevices(idUser: widget.idUser),  
                          SizedBox(height: 20),  
                        ],  
                      ),  
                    ),  
                  );  
                },  
              ).then((value) {  
                // Setelah dialog ditutup, panggil fetchDevices untuk memperbarui daftar perangkat  
                fetchDevices();  
              });  
            },  
            backgroundColor: Color(0XFF7847EB),  
            shape: RoundedRectangleBorder(  
              borderRadius: BorderRadius.circular(30),  
            ),  
            child: Icon(  
              Icons.add,  
              color: Color(0xFFFFFFFF),  
              size: 36,  
            ),  
          ),  
        ),  
      ],  
    );  
  }  

  void _showConfirmationDialog(BuildContext context, int index) {  
    showDialog(  
      context: context,  
      builder: (BuildContext context) {  
        return AlertDialog(  
          title: Text('Konfirmasi Hapus'),  
          content: Text('Apakah Anda yakin ingin menghapus ${devices[index]['Devices']}?'),  
          actions: [  
            TextButton(  
              onPressed: () {  
                Navigator.of(context).pop();  
              },  
              child: Text('Batal'),  
            ),  
            TextButton(  
              onPressed: () {  
                _deleteDevice(devices[index]['id_alat'], widget.idUser, "null");  
                Navigator.of(context).pop();  
              },  
              child: Text('Hapus'),  
            ),  
          ],  
        );  
      },  
    );  
  }  

  Future<void> _deleteDevice(int idAlat, int idUser, String kodePerangkat) async {  
    final apiHost = dotenv.env['API_HOST'];  
    final url = '${apiHost}devices/delete_devices.php';  

    final response = await http.post(  
      Uri.parse(url),  
      headers: {'Content-Type': 'application/json'},  
      body: jsonEncode({'id_alat': idAlat, 'id_user': idUser}),  
    );  

    if (response.statusCode == 200) {  
      final data = json.decode(response.body);  
      if (data['status'] == 'success') {  
        setState(() {  
          devices.removeWhere((device) => device['id_alat'] == idAlat);  
        });  

        // Hapus kode_perangkat dari SharedPreferences  
        SharedPreferences prefs = await SharedPreferences.getInstance();  
        await prefs.remove('kode_perangkat');  

        // Navigasi ke Dashboard dengan idUser dan kodePerangkat yang dihapus  
        Navigator.pushReplacement(  
          context,  
          MaterialPageRoute(  
            builder: (context) => Dashboard(  
              idUser: idUser,  
              kodePerangkat: kodePerangkat, // Kode perangkat yang dihapus  
            ),  
          ),  
        );  

        _showSnackBar(context, 'Sukses', 'Perangkat berhasil dihapus', ContentType.success);  
      } else {  
        _showSnackBar(context, 'Error', data['message'], ContentType.failure);  
      }  
    } else {  
      _showSnackBar(context, 'Error', 'Gagal menghapus perangkat', ContentType.failure);  
    }  
  }  

  @override  
  void dispose() {  
    _timer?.cancel();  
    super.dispose();  
  }  
}