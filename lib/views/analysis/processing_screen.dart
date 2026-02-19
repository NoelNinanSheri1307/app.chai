import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/spacing.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../result/result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStep = 0;

  final List<String> _steps = [
    "Running AI Detection",
    "Performing Forensic Analysis",
    "Calculating Risk Fusion",
    "Generating Report",
  ];

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _currentStep = i;
      });
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(imagePath: widget.imagePath),
      ),
    );
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

            Expanded(
              child: ListView.builder(
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final isActive = index <= _currentStep;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          isActive
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isActive
                              ? AppColors.accentBlue
                              : secondaryText,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          _steps[index],
                          style: AppTextStyles.body(
                            isActive ? primaryText : secondaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
