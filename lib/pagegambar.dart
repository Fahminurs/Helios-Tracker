// page_gambar.dart  
import 'dart:convert';  
import 'dart:io';  
import 'package:flutter/material.dart';  
import 'package:image_picker/image_picker.dart';  
import 'package:http/http.dart' as http;  

class PageGambar extends StatefulWidget {  
  @override  
  _PageGambarState createState() => _PageGambarState();  
}  

class _PageGambarState extends State<PageGambar> {  
  String? base64Image;  
  final ImagePicker _picker = ImagePicker();  

  Future<void> pickImage() async {  
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);  
    if (image != null) {  
      // Convert image to Base64  
      File imageFile = File(image.path);  
      List<int> imageBytes = await imageFile.readAsBytes();  
      setState(() {  
        base64Image = base64Encode(imageBytes);  
      });  
    }  
  }  

  Future<void> uploadImage() async {  
    if (base64Image == null) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text('Please select an image first')),  
      );  
      return;  
    }  

    // Prepare the request body  
    String requestBody = 'data:image/png;base64,$base64Image';  
    print('Request Body: $requestBody'); // Print the request body  

    final response = await http.post(  
      Uri.parse('http://192.168.0.107/helios-tracker-api/api-gambar.php'), // Change to your server URL  
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},  
      body: {'image': requestBody}, // Adjust MIME type if necessary  
    );  

    // Print the response status code and body  
    print('Response Status Code: ${response.statusCode}');  
    print('Response Body: ${response.body}');  

    if (response.statusCode == 200) {  
      final responseData = json.decode(response.body);  
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text(responseData['message'])),  
      );  
    } else {  
      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(content: Text('Failed to upload image')),  
      );  
    }  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: Text('Upload Image')),  
      body: Center(  
        child: Column(  
          mainAxisAlignment: MainAxisAlignment.center,  
          children: [  
            if (base64Image != null)  
              Image.memory(base64Decode(base64Image!), height: 200),  
            SizedBox(height: 20),  
            ElevatedButton(  
              onPressed: pickImage,  
              child: Text('Pick Image'),  
            ),  
            SizedBox(height: 20),  
            ElevatedButton(  
              onPressed: uploadImage,  
              child: Text('Upload Image'),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}