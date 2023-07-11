import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum PickImageSource {
  camera,
  gallery,
}

class ImageInput extends StatefulWidget {
  final void Function(File image) onPickImage;
  const ImageInput({super.key, required this.onPickImage});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  XFile? pickedImage;

  void _takePicture(PickImageSource source) async {
    final imagePicker = ImagePicker();

    if (source == PickImageSource.camera) {
      pickedImage = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      );
    } else if (source == PickImageSource.gallery) {
      pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
    }

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage!.path);
    });
    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: () {
        _takePicture(PickImageSource.camera);
      },
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
    );
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: () {
          _takePicture(PickImageSource.camera);
        },
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          height: 250,
          width: double.infinity,
          child: content,
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            _takePicture(PickImageSource.gallery);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8.0),
              Text('Upload Image'),
            ],
          ),
        ),
      ],
    );
  }
}
