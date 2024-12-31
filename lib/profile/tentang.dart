import 'package:flutter/material.dart';  

class TentangPage extends StatelessWidget {  
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
                            'Tentang',  
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

              // Card Content  
              Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 16.0),  
                child: Card(  
                  color: Colors.white,  
                  elevation: 5,  
                  shape: RoundedRectangleBorder(  
                    borderRadius: BorderRadius.circular(20), // Rounded edges  
                  ),  
                  child: Padding(  
                    padding: const EdgeInsets.all(16.0),  
                    child: Column(  
                      crossAxisAlignment: CrossAxisAlignment.center,  
                      children: [  
                        // Circular Image with size 156x156  
                        Container(  
                          width: 256,  
                          height: 256,  
                          decoration: BoxDecoration(  
                            shape: BoxShape.circle,  
                            boxShadow: [  
                              
                              BoxShadow(  
                                color: Colors.black.withOpacity(0.2), // Shadow color  
                                blurRadius: 10, // Shadow blur  
                                spreadRadius: 0, // Shadow spread  
                              ),  
                            ],  
                         
                            image: DecorationImage(  
                              image: AssetImage(  
                                'assets/icon/Tentang.png', // Update with your image path  
                              ),  
                              fit: BoxFit.cover, // Change to cover to fill the circle  
                            ),  
                          ),  
                        ),  
                        SizedBox(height: 20), // Space between image and text  

                        // Description  
                        Text(  
                          'Helios Tracker adalah aplikasi inovatif yang dirancang khusus untuk memantau sistem solar tracker dual axis. Dengan teknologi Internet of Things (IoT), aplikasi ini memungkinkan pengguna untuk mengawasi kinerja panel surya secara real-time, memastikan efisiensi maksimum dalam penangkapan sinar matahari. Helios Tracker memberikan data yang akurat dan mendetail mengenai posisi panel, sehingga pengguna dapat mengoptimalkan pengaturan dan meningkatkan produksi energi.',  
                          style: TextStyle(  
                            fontFamily: 'Poppins',  
                            fontSize: 14,  
                            color: Colors.black87,  
                            height: 1.6,  
                                 fontWeight: FontWeight.w500, // Extra Bold
                          ),  
                          textAlign: TextAlign.justify,  
                        ),  
                        SizedBox(height: 15),  
                        Text(  
                          'Selain itu, Helios Tracker juga dilengkapi dengan fitur analisis yang membantu pengguna memahami pola penggunaan energi dan mengidentifikasi potensi perbaikan. Dengan antarmuka yang ramah pengguna, aplikasi ini memudahkan pemantauan dan pengelolaan sistem solar tracker dari mana saja dan kapan saja. Dengan Helios Tracker, pengguna dapat memaksimalkan investasi mereka dalam energi terbarukan dan berkontribusi pada keberlanjutan lingkungan.',  
                          style: TextStyle(  
                            fontFamily: 'Poppins',  
                            fontSize: 14,  
                            color: Colors.black87,  
                            height: 1.6,  
                              fontWeight: FontWeight.w500, // Extra Bold
                          ),  
                          textAlign: TextAlign.justify,  
                        ),  
                      ],  
                    ),  
                  ),  
                ),  
              ),  
              SizedBox(height: 20), // Space at the bottom  
            ],  
          ),  
        ),  
      ),  
    );  
  }  
}