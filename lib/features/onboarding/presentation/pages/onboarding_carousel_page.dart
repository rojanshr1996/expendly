import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_slide_card.dart';

@RoutePage()
class OnboardingCarouselPage extends StatefulWidget {
  const OnboardingCarouselPage({super.key});

  @override
  State<OnboardingCarouselPage> createState() => _OnboardingCarouselPageState();
}

class _OnboardingCarouselPageState extends State<OnboardingCarouselPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  void _onNext() {
    if (_currentPageNotifier.value < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onSkip();
    }
  }

  void _onSkip() {
    context.router.push(const CurrencySetupRoute());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    final slides = [
      OnboardingSlideCard(
        icon: Icons.shield_outlined,
        iconColor: colorScheme.primary,
        title: l10n.welcomeTitle1,
        description: l10n.welcomeDesc1,
        badgeTag: '100% Offline Vault',
      ),
      OnboardingSlideCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: colorScheme.secondary,
        title: l10n.welcomeTitle2,
        description: l10n.welcomeDesc2,
        badgeTag: 'Multi-Account Sync',
      ),
      OnboardingSlideCard(
        icon: Icons.insights_rounded,
        iconColor: colorScheme.tertiary,
        title: l10n.welcomeTitle3,
        description: l10n.welcomeDesc3,
        badgeTag: 'Calculated Fiscal Calm',
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: Column(
              children: [
                // Top Progress Header
                OnboardingHeader(
                  progress: 0.25,
                  stepLabel: l10n.setupStep1,
                  titleLabel: l10n.stepWelcome,
                  onSkip: _onSkip,
                ),
                verticalMarginMedium,

                // Slide Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) =>
                        _currentPageNotifier.value = index,
                    itemBuilder: (context, index) => slides[index],
                  ),
                ),
                verticalMarginMedium,

                // Indicator Dots
                ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (index) {
                        final isSelected = index == currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: isSelected ? 24.w : 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant
                                    .withAlpha((0.3 * 255).round()),
                          ),
                        );
                      }),
                    );
                  },
                ),
                verticalMarginLarge,

                // Continue Button
                AppButton(
                  text: l10n.continueButton,
                  onPressed: _onNext,
                ),
              ],
            ).defaultCanvasPadding(),
          ),
        ),
      ),
    );
  }
}
