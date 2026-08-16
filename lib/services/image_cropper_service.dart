import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperService {
  final ImageCropper _cropper = ImageCropper();

  Future<CroppedFile?> cropImage(String sourcePath) async {
    try {
      return await _cropper.cropImage(
        sourcePath: sourcePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Chỉnh sửa vùng ảnh',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            // Trên Android, khi lockAspectRatio: false và không có tham số khác,
            // thư viện uCrop thường cho phép kéo tự do các góc.
            // Hãy đảm bảo người dùng kéo ở CÁC GÓC để thay đổi kích thước linh hoạt nhất.
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Chỉnh sửa vùng ảnh',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
    } catch (e) {
      rethrow;
    }
  }
}
