import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mrz_scaner_id_card/camera_page.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scaner MRZ ID Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<Map<PermissionGroup, PermissionStatus>>(
        future:
            PermissionHandler().requestPermissions([PermissionGroup.camera]),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data[PermissionGroup.camera] ==
                  PermissionStatus.granted) {
            return CameraPage();
          }
          return Scaffold(
            body: Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  Text('Awaiting for permissions')
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
