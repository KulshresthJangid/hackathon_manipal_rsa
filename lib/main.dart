import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'dart:developer' as developer;
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info Sender',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Send Device Info'),
        ),
        body: DeviceInfoSender(),
      ),
    );
  }
}

class _DeviceInfoSenderState extends State<DeviceInfoSender> {
  String deviceId = '';
  String publicKey = '''
  LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJB
UUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF2UDFOdmYzODJHbm54MS83TWxkLwpxOWg5
Zy9CMUo4dVU2MG1jT3I2MjM0U3dLSmxKQW4xTCtpaVc3RDN2ckdQSDRBa2x6M2NX
OVlVdzN0SzhIREZUCjBLeTQvZzdQS1NXeDg0MTBnUm5CZWF0VkR6UlZab0xmVzZX
VnowZXhwbDhaY2N1aWhkckxPOHlsZUVQdUhDaVMKWlRwWWRNTkY3c0NtMnY0ZXJ2
VG9ic0lOcWRnYzQ3NktkejFSVWF0QnhTMGg3SEp3OXJPZ2tVbEFxQUhFZVNaZQpZ
NHBmdTlMZGJvdFNJSDAvekxqNjVUY2JvSmllN2FaNWZsZ1QrekhiRlU2b3NMajVK
dE40RW9IUEZvR29mNk43CnRjRGFZbW4zUzZ0Ti84MVJQMC8wbllqdEhaZUZHa2ZV
ejhqM1RpY3QxZy9WSFlXYXZySzc4NXdGeWRLdmJPR2wKT3dJREFRQUIKLS0tLS1F
TkQgUFVCTElDIEtFWS0tLS0tCg==
  '''; // Replace with actual public key logic if needed
  String rsaEncrypt = '';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  // Get Android device info like device ID
  Future<void> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    var message = "some_message";
    var rsaEnc = await encryptData(message, publicKey);

    setState(() {
      deviceId = androidInfo.id; // Device ID on Android
      rsaEncrypt = rsaEnc.toString(); // RSA Encryption
    });
  }

  Future<String> encryptData(String message, String publicKey) async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final encryptedData = await RSA.encryptOAEP(message, androidInfo.id, Hash.SHA256, publicKey); // SETTING THE RSA HERE WITH DEVICE ID IN IT
      return encryptedData;
    } catch (e) {
      print("Encryption error: $e");
      return '';
    }
  }

  // Send the device info and public key to the server
  Future<void> sendDeviceInfo() async {
    String url = 'https://your-server.com/api/sendDeviceInfo'; // Replace with your API URL
    Map<String, dynamic> requestData = {
      'device_id': deviceId,
      'public_key': publicKey,
    };

    try {
      // Sending POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // Success
        print('Device info sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device info sent successfully!')),
        );
      } else {
        // Failure
        print('Failed to send device info');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send device info!')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending device info!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Device ID: $deviceId'),
          Text('RSA Encryption: $rsaEncrypt'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: sendDeviceInfo,
            child: Text('Send Device Info'),
          ),
        ],
      ),
    );
  }
}

class DeviceInfoSender extends StatefulWidget {
  @override
  _DeviceInfoSenderState createState() => _DeviceInfoSenderState();
}
