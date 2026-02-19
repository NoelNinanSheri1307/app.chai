import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/spacing.dart';
import '../../models/analysis_result_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../models/history_item_model.dart';
import '../dashboard/main_dashboard.dart';
import '../../services/report_service.dart';

class ResultScreen extends StatefulWidget {
  final String? imagePath;
  final bool saveToHistory;

  const ResultScreen({super.key, this.imagePath, this.saveToHistory = true});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool showHeatmap = false;
  double heatmapOpacity = 0.4;
  final List<Rect> mockTamperRegions = [
    const Rect.fromLTWH(50, 40, 100, 80),
    const Rect.fromLTWH(180, 120, 120, 90),
  ];

  AnalysisResult _mockResult() {
    return AnalysisResult(
      authenticityScore: 62,
      riskLevel: "Medium",
      enforcementAction: "Review",
      aiScore: 0.58,
      manipulationScore: 0.64,
      frequencyScore: 0.61,
      metadataFlag: true,
      explanation:
          "The image shows moderate indicators of AI generation and compression inconsistencies. Further human review is recommended.",
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case "Low":
        return AppColors.riskLow;
      case "High":
        return AppColors.riskHigh;
      default:
        return AppColors.riskMedium;
    }
  }

  @override
  void initState() {
    super.initState();

    if (!widget.saveToHistory) return;

    final result = _mockResult();

    Future.microtask(() {
      final historyProvider = Provider.of<HistoryProvider>(
        context,
        listen: false,
      );

      historyProvider.addHistoryItem(
        HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: widget.imagePath,
          authenticityScore: result.authenticityScore,
          riskLevel: result.riskLevel,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _mockResult();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final riskColor = _getRiskColor(result.riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export Report",
            onPressed: () {
              ReportService.generateReport(result);
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: "Go to Dashboard",
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainDashboard()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PREVIEW + HEATMAP
              if (widget.imagePath != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Image.file(
                              File(widget.imagePath!),
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),

                            if (showHeatmap)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: heatmapOpacity,
                                  child: Container(color: AppColors.riskHigh),
                                ),
                              ),

                            if (showHeatmap)
                              ...mockTamperRegions.map(
                                (rect) => Positioned(
                                  left: rect.left,
                                  top: rect.top,
                                  width: rect.width,
                                  height: rect.height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.riskHigh,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Show Heatmap",
                            style: AppTextStyles.body(primaryText),
                          ),
                          Switch(
                            value: showHeatmap,
                            onChanged: (val) {
                              setState(() {
                                showHeatmap = val;
                              });
                            },
                          ),
                        ],
                      ),

                      if (showHeatmap)
                        Slider(
                          value: heatmapOpacity,
                          min: 0.1,
                          max: 0.8,
                          onChanged: (val) {
                            setState(() {
                              heatmapOpacity = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),

              if (widget.imagePath != null)
                const SizedBox(height: AppSpacing.xl),

              // AUTHENTICITY SCORE
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      "Authenticity Score",
                      style: AppTextStyles.body(secondaryText),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        result.riskLevel,
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: result.authenticityScore),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return CircularPercentIndicator(
                            radius: 90,
                            lineWidth: 10,
                            percent: value / 100,
                            animation: false,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: riskColor,
                            backgroundColor: borderColor,
                            center: Text(
                              "${value.toInt()}%",
                              style: AppTextStyles.scoreLarge(primaryText),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // RISK & ACTION
              Row(
                children: [
                  _Badge(label: result.riskLevel, color: riskColor),
                  const SizedBox(width: AppSpacing.md),
                  _Badge(label: result.enforcementAction, color: riskColor),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // BREAKDOWN CARD
              Container(
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
                      "Detection Breakdown",
                      style: AppTextStyles.headingMedium(primaryText),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _ScoreRow("AI Score", result.aiScore),
                    _ScoreRow("Manipulation Score", result.manipulationScore),
                    _ScoreRow("Frequency Score", result.frequencyScore),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Text(
                          "Metadata Flag:",
                          style: AppTextStyles.body(primaryText),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          result.metadataFlag
                              ? Icons.warning
                              : Icons.check_circle,
                          color: result.metadataFlag
                              ? AppColors.riskHigh
                              : AppColors.riskLow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // EXPLANATION
              Container(
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
                      "Explanation",
                      style: AppTextStyles.headingMedium(primaryText),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;

  const _ScoreRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "${(value * 100).toInt()}%",
            style: AppTextStyles.body(primaryText),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
