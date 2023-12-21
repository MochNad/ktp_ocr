import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan debug
      theme: ThemeData.dark(), // Mengaktifkan dark mode
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  File? _image;
  String _result = "";

  Future<void> _uploadImage() async {
    if (_image == null) {
      return;
    }

    String apiUrl = "http://192.168.68.104:5000/result";
    var uri = Uri.parse(apiUrl);

    // Create multipart request
    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Successfully uploaded, parse the JSON response
        var responseBody = await response.stream.bytesToString();
        var result = json.decode(responseBody);

        // Update the state with the result
        setState(() {
          _result = jsonEncode(result);
        });

        // Show result in a dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Hasil OCR"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildField("NIK", result['nik']),
                    buildField("Nama", result['nama']),
                    buildField("Tempat/Tgl Lahir", result['tempatTglLahir']),
                    buildField("Jenis Kelamin", result['jenisKelamin']),
                    buildField("Gol. Darah", result['golDarah']),
                    buildField("Alamat", result['alamat']),
                    buildField("RT/RW", result['rtRw']),
                    buildField("Kel/Desa", result['kelDesa']),
                    buildField("Kecamatan", result['kecamatan']),
                    buildField("Agama", result['agama']),
                    buildField("Status Perkawinan", result['statusPerkawinan']),
                    buildField("Pekerjaan", result['pekerjaan']),
                    buildField("Kewarganegaraan", result['kewarganegaraan']),
                    buildField("Berlaku Hingga", result['berlakuHingga']),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        print("Error: ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Widget buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16.0, color: Colors.white),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KTP OCR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text("Pilih gambar KTP terlebih dahulu")
                : Image.file(_image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text("Pilih Gambar KTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text("Unggah dan Proses OCR"),
            ),
          ],
        ),
      ),
    );
  }
}
