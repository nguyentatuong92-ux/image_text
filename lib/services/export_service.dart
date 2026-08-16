import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:docs_gee/docs_gee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ExportService {
  Future<void> exportToPdf(String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Text(text),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/ket_qua.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  Future<void> exportToDocx(String text) async {
    try {
      // Sử dụng docs_gee để tạo file Word
      final doc = Document(title: 'Kết quả nhận diện');

      // Thêm nội dung văn bản vào document
      final lines = text.split('\n');
      for (var line in lines) {
        doc.addParagraph(Paragraph.text(line));
      }

      // Tạo bytes của file Word bằng DocxGenerator
      final bytes = DocxGenerator().generate(doc);

      final output = await getTemporaryDirectory();
      final filePath = "${output.path}/ket_qua.docx";
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      await OpenFilex.open(filePath);
    } catch (e) {
      print("Lỗi xuất Word (docs_gee): $e");
      rethrow;
    }
  }
}
