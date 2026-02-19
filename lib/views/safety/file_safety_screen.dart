import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/spacing.dart';
import '../../models/analysis_result_model.dart';
import '../safety/file_safety_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/report_service.dart';
import 'package:share_plus/share_plus.dart';

class FileSafetyScreen extends StatefulWidget {
  const FileSafetyScreen({super.key});

  @override
  State<FileSafetyScreen> createState() => _FileSafetyScreenState();
}

class _FileSafetyScreenState extends State<FileSafetyScreen> {
  File? selectedImage;
  AnalysisResult? result;
  bool isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  bool _showResultAnimation = false;
  bool _isBlockedPulse = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text("File Safety Check")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadSection(cardColor, borderColor, primaryText),
            const SizedBox(height: AppSpacing.xl),

            if (isAnalyzing) const Center(child: CircularProgressIndicator()),

            if (result != null)
              AnimatedScale(
                scale: _isBlockedPulse && _showResultAnimation ? 1.02 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _showResultAnimation ? 1 : 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 400),
                    offset: _showResultAnimation
                        ? Offset.zero
                        : const Offset(0, 0.05),
                    child: _buildEnforcementSection(
                      result!,
                      cardColor,
                      borderColor,
                      primaryText,
                      secondaryText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(
    Color cardColor,
    Color borderColor,
    Color primaryText,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            "Upload Image For Safety Check",
            style: AppTextStyles.headingMedium(primaryText),
          ),
          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: () async {
              final XFile? picked = await _picker.pickImage(
                source: ImageSource.gallery,
              );

              if (picked != null) {
                setState(() {
                  selectedImage = File(picked.path);
                  result = null;
                });
              }
            },
            child: const Text("Select Image"),
          ),

          if (selectedImage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Image.file(selectedImage!, height: 200, fit: BoxFit.cover),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _runMockAnalysis,
              child: const Text("Analyze Safety"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnforcementSection(
    AnalysisResult result,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    Color bannerColor;
    IconData icon;
    String title;

    switch (result.enforcementAction) {
      case "Allow":
        bannerColor = AppColors.riskLow;
        icon = Icons.check_circle;
        title = "Upload Approved";
        break;
      case "Review":
        bannerColor = AppColors.riskMedium;
        icon = Icons.warning;
        title = "Under Review Required";
        break;
      default:
        bannerColor = AppColors.riskHigh;
        icon = Icons.block;
        title = "Upload Blocked";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: bannerColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: bannerColor,
              width: result.enforcementAction == "Block" && _showResultAnimation
                  ? 3
                  : 2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: bannerColor, size: 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headingMedium(primaryText),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      result.explanation,
                      style: AppTextStyles.body(secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        _buildForensicBreakdown(result, cardColor, borderColor, primaryText),

        const SizedBox(height: AppSpacing.xl),

        _buildActionButtons(result),
      ],
    );
  }

  Widget _buildForensicBreakdown(
    AnalysisResult result,
    Color cardColor,
    Color borderColor,
    Color primaryText,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Technical Forensic Report",
            style: AppTextStyles.headingMedium(primaryText),
          ),
          const SizedBox(height: AppSpacing.md),
          Text("Authenticity Score: ${result.authenticityScore}%"),
          Text("AI Score: ${(result.aiScore * 100).toInt()}%"),
          Text(
            "Manipulation Score: ${(result.manipulationScore * 100).toInt()}%",
          ),
          Text("Frequency Score: ${(result.frequencyScore * 100).toInt()}%"),
          Text("Metadata Flag: ${result.metadataFlag}"),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                ReportService.generateReport(result);
              },
              child: const Text("Export PDF"),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                Share.share(
                  "Authenticity Score: ${result.authenticityScore}%\n"
                  "Risk Level: ${result.riskLevel}\n"
                  "Action: ${result.enforcementAction}",
                );
              },
              child: const Text("Share"),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        if (result.enforcementAction == "Allow")
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskLow),
            child: const Text("Proceed With Upload"),
          )
        else if (result.enforcementAction == "Review")
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskMedium,
            ),
            child: const Text("Send For Manual Review"),
          )
        else
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.riskHigh,
            ),
            child: const Text("Upload Blocked"),
          ),
      ],
    );
  }

  void _runMockAnalysis() async {
    setState(() {
      isAnalyzing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final random = DateTime.now().millisecondsSinceEpoch % 3;

    AnalysisResult mock;

    if (random == 0) {
      mock = AnalysisResult(
        authenticityScore: 90,
        riskLevel: "Low",
        enforcementAction: "Allow",
        aiScore: 0.1,
        manipulationScore: 0.1,
        frequencyScore: 0.2,
        metadataFlag: false,
        explanation: "Image appears authentic.",
      );
    } else if (random == 1) {
      mock = AnalysisResult(
        authenticityScore: 55,
        riskLevel: "Medium",
        enforcementAction: "Review",
        aiScore: 0.6,
        manipulationScore: 0.5,
        frequencyScore: 0.6,
        metadataFlag: true,
        explanation: "Potential AI modifications detected.",
      );
    } else {
      mock = AnalysisResult(
        authenticityScore: 20,
        riskLevel: "High",
        enforcementAction: "Block",
        aiScore: 0.9,
        manipulationScore: 0.8,
        frequencyScore: 0.9,
        metadataFlag: true,
        explanation: "Strong indicators of AI-generated content.",
      );
    }

    setState(() {
      result = mock;
      isAnalyzing = false;
      _showResultAnimation = false;
      _isBlockedPulse = mock.enforcementAction == "Block";
    });

    await Future.delayed(const Duration(milliseconds: 50));

    setState(() {
      _showResultAnimation = true;
    });
  }
}
