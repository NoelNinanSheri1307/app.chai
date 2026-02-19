import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/spacing.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/analysis_screen.dart';
import '../../models/analysis_result_model.dart';
import '../result/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() async {
    try {
      final AnalysisResult result =
          await AnalysisService.analyzeImage(File(widget.imagePath));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: result,
            imagePath: widget.imagePath,
          ),
        ),
      );
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Analysis failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Processing"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Analyzing Image",
              style: AppTextStyles.headingLarge(primaryText),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Please wait while the system evaluates authenticity",
              style: AppTextStyles.body(secondaryText),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
