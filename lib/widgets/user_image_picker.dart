import 'dart:io';

import 'package:all_in_one_socials/controllers/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

ColorPalette cp = Get.find();

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _pickImage() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImage = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: cp.bg,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(
            Icons.image,
            color: cp.container,
          ),
          label: Text(
            'Add Images',
            style: const TextStyle().copyWith(color: cp.container),
          ),
        )
      ],
    );
  }
}
