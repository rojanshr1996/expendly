import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/status_components.dart';

@RoutePage()
class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail(BuildContext context) async {
    final questionText = _questionController.text.trim();
    final l10n = context.l10n;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (questionText.isEmpty) {
      StatusComponents.showToast(
        context,
        message: l10n.emptyQuestionError,
        isError: true,
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'thoughtsphere0@gmail.com',
      queryParameters: {
        'subject': 'Expendly Support & Feedback',
        'body': questionText,
      },
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched && mounted) {
        _questionController.clear();
      }
    } catch (_) {
      try {
        await launchUrl(emailUri);
        if (mounted) {
          _questionController.clear();
        }
      } catch (_) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Could not launch email app. Please ensure an email client is installed.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          l10n.helpAndSupport,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeights.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalMarginMedium,

                // Support Header Glass Card
                GlassContainer(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.mark_email_read_rounded,
                              color: colorScheme.primary,
                              size: 24.sp,
                            ),
                          ),
                          horizontalMarginSmall,
                          Expanded(
                            child: Text(
                              l10n.askQuestionTitle,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalMarginMedium,
                      Text(
                        l10n.askQuestionDesc,
                        style: customTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                verticalMarginMedium,

                // Question Input Text Field Card
                GlassContainer(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _questionController,
                        maxLines: 5,
                        style: customTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.questionHint,
                          hintStyle: customTypography.bodyMedium.copyWith(
                            color: colorScheme.outline,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppColors.glassStroke,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppColors.glassStroke,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      verticalMarginMedium,

                      // Submit Email Button
                      SizedBox(
                        height: 48.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _sendEmail(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(Icons.send_rounded, size: 18.sp),
                          label: Text(
                            l10n.sendQuestion,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeights.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalMarginLarge,
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}
