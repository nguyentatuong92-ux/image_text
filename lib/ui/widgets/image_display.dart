import 'dart:io';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final File? image;

  const ImageDisplay({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image!, fit: BoxFit.contain),
            )
          : Center(
              child: Text(
                'Vui lòng chọn ảnh !',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
