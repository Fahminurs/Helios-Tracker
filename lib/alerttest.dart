import 'package:flutter/material.dart';  
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';  

class AlertDemo extends StatelessWidget {  
  const AlertDemo({Key? key}) : super(key: key);  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      body: Center(  
        child: Column(  
          mainAxisSize: MainAxisSize.min,  
          children: [  
            ElevatedButton(  
              child: const Text('Show Success SnackBar'),  
              onPressed: () {  
                final snackBar = SnackBar(  
                  elevation: 0,  
                  behavior: SnackBarBehavior.floating,  
                  backgroundColor: Colors.transparent,  
                  content: AwesomeSnackbarContent(  
                    title: 'Success!',  
                    message: 'Your action was successful.',  
                    contentType: ContentType.success,  
                  ),  
                );  

                ScaffoldMessenger.of(context)  
                  ..hideCurrentSnackBar()  
                  ..showSnackBar(snackBar);  
              },  
            ),  
            const SizedBox(height: 10),  
            ElevatedButton(  
              child: const Text('Show Failure SnackBar'),  
              onPressed: () {  
                final snackBar = SnackBar(  
                  elevation: 0,  
                  behavior: SnackBarBehavior.floating,  
                  backgroundColor: Colors.transparent,  
                  content: AwesomeSnackbarContent(  
                    title: 'Failure!',  
                    message: 'Your action failed. Please try again.',  
                    contentType: ContentType.failure,  
                  ),  
                );  

                ScaffoldMessenger.of(context)  
                  ..hideCurrentSnackBar()  
                  ..showSnackBar(snackBar);  
              },  
            ),  
            const SizedBox(height: 10),  
            ElevatedButton(  
              child: const Text('Show Confirmation Dialog'),  
              onPressed: () {  
                _showConfirmationDialog(context);  
              },  
            ),  
            const SizedBox(height: 10),  
            ElevatedButton(  
              child: const Text('Show Awesome Material Banner'),  
              onPressed: () {  
                final materialBanner = MaterialBanner(  
                  elevation: 0,  
                  backgroundColor: Colors.transparent,  
                  forceActionsBelow: true,  
                  content: AwesomeSnackbarContent(  
                    title: 'Oh Hey!!',  
                    message: 'This is an example error message that will be shown in the body of materialBanner!',  
                    contentType: ContentType.success,  
                    inMaterialBanner: true,  
                  ),  
                  actions: const [SizedBox.shrink()],  
                );  

                ScaffoldMessenger.of(context)  
                  ..hideCurrentMaterialBanner()  
                  ..showMaterialBanner(materialBanner);  
              },  
            ),  
          ],  
        ),  
      ),  
    );  
  }  

  void _showConfirmationDialog(BuildContext context) {  
    showDialog(  
      context: context,  
      builder: (BuildContext context) {  
        return AlertDialog(  
          title: Text('Confirmation'),  
          content: Text('Are you sure you want to proceed?'),  
          actions: [  
            TextButton(  
              onPressed: () {  
                Navigator.of(context).pop(); // Close the dialog  
                final snackBar = SnackBar(  
                  elevation: 0,  
                  behavior: SnackBarBehavior.floating,  
                  backgroundColor: Colors.transparent,  
                  content: AwesomeSnackbarContent(  
                    title: 'Confirmed!',  
                    message: 'You have confirmed the action.',  
                    contentType: ContentType.success,  
                  ),  
                );  

                ScaffoldMessenger.of(context)  
                  ..hideCurrentSnackBar()  
                  ..showSnackBar(snackBar);  
              },  
              child: Text('Yes'),  
            ),  
            TextButton(  
              onPressed: () {  
                Navigator.of(context).pop(); // Close the dialog  
                final snackBar = SnackBar(  
                  elevation: 0,  
                  behavior: SnackBarBehavior.floating,  
                  backgroundColor: Colors.transparent,  
                  content: AwesomeSnackbarContent(  
                    title: 'Cancelled!',  
                    message: 'You have cancelled the action.',  
                    contentType: ContentType.failure,  
                  ),  
                );  

                ScaffoldMessenger.of(context)  
                  ..hideCurrentSnackBar()  
                  ..showSnackBar(snackBar);  
              },  
              child: Text('No'),  
            ),  
          ],  
        );  
      },  
    );  
  }  
}  

