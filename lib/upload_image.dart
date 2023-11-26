import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadImages extends StatefulWidget {
  const UploadImages({super.key});

  @override
  State<UploadImages> createState() => _UploadImagesState();
}

class _UploadImagesState extends State<UploadImages> {
  File? image;
  final _picker = ImagePicker();
  bool showspinner = false;

  Future getImages() async {
    final pickedfile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedfile != null) {
      image = File(pickedfile.path);
      setState(() {});
    } else {
      print('No Image is Selected');
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showspinner = true;
    });
    var stream = http.ByteStream(image!.openRead());
    stream.cast();

    var length = await image!.length();

    var uri = Uri.parse("https://fakestoreapi.com/products");
    var request = http.MultipartRequest('POST', uri);

    request.fields['title'] = "Static Title";
    var multiport = http.MultipartFile('image', stream, length);

    request.files.add(multiport);

    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        showspinner = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image Uploaded Successfully'),
        backgroundColor: Colors.green,
      ));
    } else {
      setState(() {
        showspinner = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image is not Uploaded'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showspinner,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: getImages,
              child: Center(
                child: Container(
                    child: image == null
                        ? const Center(
                            child: Text('Pick Image'),
                          )
                        : Container(
                            child: Image.file(
                            File(image!.path).absolute,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ))),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: uploadImage, child: const Text('Upload Image'))
          ],
        ),
      ),
    );
  }
}
