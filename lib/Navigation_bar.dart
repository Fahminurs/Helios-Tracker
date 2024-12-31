import 'package:flutter/material.dart';
import 'package:helios_tracker/Navigation_bar//constants/color.dart';
import 'package:helios_tracker/Navigation_bar//constants/text_style.dart';
import 'package:helios_tracker/Navigation_bar//data/model.dart';
import 'package:helios_tracker/Navigation_bar//widgets/custom_paint.dart';
import 'package:helios_tracker/dashboard.dart'; // Impor halaman dashboard
import 'package:helios_tracker/profile/profile.dart'; // Impor halaman profile


class CustomNavigationBar extends StatefulWidget {  
  final int selectedIndex; // Tambahkan parameter ini  
  final int idUser; // Tambahkan parameter ini  
   final String kodePerangkat; 

  const CustomNavigationBar({Key? key, required this.selectedIndex, required this.idUser, required this.kodePerangkat})  
      : super(key: key);  

  @override  
  _CustomNavigationBarState createState() => _CustomNavigationBarState();  
}
class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectBtn = 0;
  @override
  Widget build(BuildContext context) {
    return navigationBar(); // Langsung return method navigationBar()
  }

  @override
  void initState() {
    super.initState();
    selectBtn = widget.selectedIndex; // Set initial selected button
      print('navigation bar ID User: ${widget.idUser}');  
  print('navigation bar Kode Perangkat: ${widget.kodePerangkat}');  

  }

  AnimatedContainer navigationBar() {
    return AnimatedContainer(
      height: 70.0,
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < navBtn.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectBtn = i; // Update selected button
                });
                // Navigasi berdasarkan tombol yang dipilih
                if (i == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(idUser: widget.idUser, kodePerangkat: widget.kodePerangkat)), // Halaman Dashboard
                  );
                } else if (i == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(idUser: widget.idUser, kodePerangkat: widget.kodePerangkat)), // Halaman Profile
                  );
                }
              },
              child: iconBtn(i),
            ),
        ],
      ),
    );
  }

  SizedBox iconBtn(int i) {
    bool isActive = selectBtn == i ? true : false;
    var height = isActive ? 60.0 : 0.0;
    var width = isActive ? 50.0 : 0.0;
    return SizedBox(
      width: 75.0,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              height: height,
              width: width,
              duration: const Duration(milliseconds: 600),
              child: isActive
                  ? CustomPaint(
                      painter: ButtonNotch(),
                    )
                  : const SizedBox(),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Icon(
              navBtn[i].icon,
              color: isActive ? selectColor : black,
              size: 30,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              navBtn[i].name,
              style: isActive ? bntText.copyWith(color: selectColor) : bntText,
            ),
          )
        ],
      ),
    );
  }
}
