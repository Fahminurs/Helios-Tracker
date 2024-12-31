import 'package:flutter/material.dart';  
import 'package:helios_tracker/Navigation_bar.dart';  
import 'device_list.dart';  
import 'main_konten.dart';  

class Dashboard extends StatefulWidget {  
  final int idUser; // Tambahkan parameter ini  
  final String kodePerangkat;  

  const Dashboard({Key? key, required this.idUser, required this.kodePerangkat}) : super(key: key);  

  @override  
  _DashboardState createState() => _DashboardState();  
}  

class _DashboardState extends State<Dashboard> {  
  int _selectedIndex = 0;  

  // Daftar halaman yang akan ditampilkan  
  late final List<Widget> _pages;  

  @override  
  void initState() {  
    super.initState();  
    // Inisialisasi _pages di sini  
    // Print idUser dan kodePerangkat  
  print('ID User: ${widget.idUser}');  
  print('Kode Perangkat: ${widget.kodePerangkat}');  
    _pages = [  
      DefaultTabController(  
        length: 2,  
        child: Scaffold(  
          backgroundColor: Color(0xFFF6F8F9),  
          body: SafeArea(  
            child: Column(  
              children: [  
                // Card sebagai pengganti AppBar (kode sebelumnya)  
                Card(  
                  elevation: 2,  
                  margin: EdgeInsets.zero,  
                  shape: RoundedRectangleBorder(  
                    borderRadius: BorderRadius.only(  
                      bottomLeft: Radius.circular(30),  
                      bottomRight: Radius.circular(30),  
                    ),  
                  ),  
                  child: Container(  
                    height: 130,  
                    decoration: BoxDecoration(  
                      color: Colors.white,  
                      borderRadius: BorderRadius.only(  
                        bottomLeft: Radius.circular(30),  
                        bottomRight: Radius.circular(30),  
                      ),  
                    ),  
                    child: Padding(  
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),  
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start,  
                        children: [  
                          SizedBox(height: 16),  
                          Row(  
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                            children: [  
                              Text(  
                                'Helios Tracker',  
                                style: TextStyle(  
                                  color: Colors.black,  
                                  fontWeight: FontWeight.w800,  
                                  fontSize: 24,  
                                  fontFamily: 'Inter',  
                                ),  
                              ),  
                              SizedBox(  
                                width: 48,  
                                height: 48,  
                                child: ClipOval(  
                                  child: Image.asset(  
                                    'assets/icon/logoapp.png',  
                                    fit: BoxFit.cover,  
                                  ),  
                                ),  
                              ),  
                            ],  
                          ),  
                          SizedBox(height: 14),  
                          TabBar(  
                            indicatorColor: Color(0XFF7847EB),  
                            indicatorWeight: 6,  
                            labelColor: Colors.black,  
                            unselectedLabelColor: Color(0xFF413F3F),  
                            labelStyle: TextStyle(  
                              fontSize: 16,  
                              fontWeight: FontWeight.w600,  
                              fontFamily: 'Poppins',  
                            ),  
                            unselectedLabelStyle: TextStyle(  
                              fontSize: 16,  
                              fontWeight: FontWeight.w400,  
                              fontFamily: 'Poppins',  
                            ),  
                            tabs: [  
                              Tab(text: ' Main '),  
                              Tab(text: 'Device List'),  
                            ],  
                          ),  
                        ],  
                      ),  
                    ),  
                  ),  
                ),  
                // Konten TabBarView  
                Expanded(  
                  child: TabBarView(  
                    physics: NeverScrollableScrollPhysics(), // Tetap mencegah scroll horizontal  
                    children: [  
                      MainKonten(kodePerangkat: widget.kodePerangkat, idUser: widget.idUser),  
                      DeviceList(idUser: widget.idUser, kodePerangkat: widget.kodePerangkat), // Kembalikan ke DeviceList tanpa pembungkus  
                    ],  
                  ),  
                ),   
              ],  
            ),  
          ),  
        ),  
      ),  
    ];  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      body: Stack(  
        children: [  
          // Halaman utama  
          _pages[0], // Secara default menampilkan halaman pertama  

          // Navigation Bar di bagian bawah  
          Positioned(  
            left: 0,  
            right: 0,  
            bottom: 0,  
            child: CustomNavigationBar(selectedIndex: _selectedIndex, idUser: widget.idUser, kodePerangkat: widget.kodePerangkat), // Gunakan NavigationBar yang baru dibuat  
          ),  
        ],  
      ),  
    );  
  }  
}