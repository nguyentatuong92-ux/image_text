import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import 'widgets/image_display.dart';
import 'widgets/result_view.dart';
import 'widgets/history_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final hasResult =
            provider.originalText.isNotEmpty || provider.isProcessing;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              hasResult ? 'Kết quả nhận diện' : 'Ảnh sang Văn bản',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            leading: hasResult
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => provider.clear(),
                    tooltip: 'Quay lại',
                  )
                : Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: themeProvider.isDarkMode
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () => themeProvider.toggleTheme(
                          !themeProvider.isDarkMode,
                        ),
                      );
                    },
                  ),
            centerTitle: true,
            actions: [
              if (hasResult && !provider.isProcessing)
                IconButton(
                  onPressed: () => provider.recropAndProcessImage(),
                  icon: const Icon(Icons.crop),
                  color: Colors.blue,
                  tooltip: 'Cắt lại ảnh',
                ),
              IconButton(
                onPressed: () => provider.clear(),
                icon: const Icon(Icons.refresh),
                color: Colors.blue,
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasResult) ...[
                    ImageDisplay(image: provider.image),
                    const SizedBox(height: 30),
                    const HistoryList(),
                  ] else ...[
                    if (provider.showImageInResult &&
                        provider.image != null) ...[
                      ImageDisplay(image: provider.image),
                      const SizedBox(height: 16),
                    ],
                    const ResultView(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
