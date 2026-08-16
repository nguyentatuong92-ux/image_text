import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      // Tối ưu hóa: Giữ nguyên độ phân giải gốc và chất lượng cao nhất của cảm biến camera
      // ML Kit hoạt động tốt nhất khi có nhiều chi tiết điểm ảnh (pixel)
      return await _picker.pickImage(
        source: source,
        imageQuality: 100, // Giữ chất lượng gốc (không nén)
      );
    } catch (e) {
      rethrow;
    }
  }
}
