import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/margin_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/padding_extensions.dart';
import '../../../../core/theme/font_weights.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/liquid_glass_app_bar.dart';
import '../../../../core/widgets/status_components.dart';

class _FaqItem {
  final String id;
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });
}

@RoutePage()
class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _expandedIds = {'faq_split_1', 'faq_track_1'};

  static const List<({String name, IconData icon})> _faqCategories = [
    (name: 'All', icon: Icons.tune_rounded),
    (name: 'Expenses', icon: Icons.receipt_long_rounded),
    (name: 'Split Bills', icon: Icons.people_alt_rounded),
    (name: 'Budgets', icon: Icons.pie_chart_rounded),
    (name: 'Privacy & Security', icon: Icons.lock_outline_rounded),
  ];

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      id: 'faq_track_1',
      category: 'Expenses',
      question: 'How do I add a new expense or income transaction?',
      answer:
          'Tap the "+" button on the bottom navigation bar. Select whether it is an Expense or Income, choose a category, enter the amount, and tap "Save Transaction". You can also add custom notes, select payment modes, and adjust transaction dates.',
    ),
    _FaqItem(
      id: 'faq_track_2',
      category: 'Expenses',
      question: 'How do I search or filter my past transactions?',
      answer:
          'Navigate to the Transactions tab to see all logged records. Use the search bar at the top to filter by title, description, or amount, and tap the category filter chips to view specific spending types.',
    ),
    _FaqItem(
      id: 'faq_split_1',
      category: 'Split Bills',
      question: 'How does Split Bills & Shared Events work?',
      answer:
          'Navigate to "Split Bills" from the dashboard or drawer menu. Create a new event (such as a trip, dinner, or household sharing), add friends as participants, and log shared expenses with either equal or custom percentage splits. Expendly automatically computes net balances across all members with simplified settlement clarity.',
    ),
    _FaqItem(
      id: 'faq_split_2',
      category: 'Split Bills',
      question: 'How do I send payment reminders to participants?',
      answer:
          'Open your shared event, switch to the "Balances" tab, and tap the "Remind" button next to any participant who owes money. If an email was not added initially, simply edit the event to assign an email to that person, and Expendly will draft a reminder email ready to send from your default mail client.',
    ),
    _FaqItem(
      id: 'faq_split_3',
      category: 'Split Bills',
      question: 'How do I settle balances and archive an event?',
      answer:
          'In the event\'s "Balances" tab, tap "Settle Up" next to any balance to record a settlement payment. When all balances are squared, open the top-right options menu and tap "Mark as Settled" to move the event into your Settled archive tab.',
    ),
    _FaqItem(
      id: 'faq_budget_1',
      category: 'Budgets',
      question: 'How do monthly category budgets work?',
      answer:
          'Navigate to the Budgets tab, tap "Set Budget", choose a category, and specify your monthly spending threshold. Expendly tracks your daily progress with live visual indicators and alerts you as your spending approaches or exceeds your limit.',
    ),
    _FaqItem(
      id: 'faq_budget_2',
      category: 'Budgets',
      question: 'Can I change my default currency?',
      answer:
          'Yes! Go to Settings > Preferences > Currency to select your preferred currency code and symbol (e.g. USD, EUR, NPR, INR, GBP). All personal ledgers, group balances, and budget reports will immediately reflect your chosen currency.',
    ),
    _FaqItem(
      id: 'faq_privacy_1',
      category: 'Privacy & Security',
      question: 'Where is my financial data stored? Is it private?',
      answer:
          'Expendly operates 100% offline. All personal transactions, budgets, categories, and group split events are stored strictly on your device using a local SQLite database. We never collect, track, or upload your financial data to external servers.',
    ),
    _FaqItem(
      id: 'faq_privacy_2',
      category: 'Privacy & Security',
      question: 'How do I backup and restore my records?',
      answer:
          'Go to Settings > Data & Backup > "Export Data (CSV)" to export a complete offline backup file. You can restore transactions, categories, and budgets on any device anytime using the "Import / Restore" option.',
    ),
    _FaqItem(
      id: 'faq_privacy_3',
      category: 'Privacy & Security',
      question: 'How do I enable Biometric (Face ID / Fingerprint) lock?',
      answer:
          'Go to Settings > Security. Set a 4-digit Security PIN first, then toggle on "Biometric Lock". When enabled, you can quickly unlock the app using Face ID or Fingerprint authentication for complete privacy.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'All' || faq.category == _selectedCategory;
      final query = _searchQuery.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
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
      if (launched && context.mounted) {
        _questionController.clear();
        StatusComponents.showToast(
          context,
          message: 'Opening email client...',
        );
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

  Widget _buildLiquidGlassTabBar(
      BuildContext context, double headerPaddingTop) {
    final colorScheme = context.colorScheme;

    return Positioned(
      top: headerPaddingTop + 4.h,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final tabs = [
                {'index': 0, 'label': 'Help & Support'},
                {'index': 1, 'label': 'FAQ'},
              ];

              return _HelpLiquidGlassCard(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                borderRadius: BorderRadius.circular(14.r),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: tabs.map((t) {
                    final tabIndex = t['index'] as int;
                    final tabLabel = t['label'] as String;
                    final isSelected = _tabController.index == tabIndex;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(tabIndex);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8.r,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              tabLabel,
                              textAlign: TextAlign.center,
                              style: context.customTypography.labelMediumMono
                                  .copyWith(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context, double headerPaddingTop) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final filteredList = _filteredFaqs;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: headerPaddingTop + 60.h,
        bottom: 40.h,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Box with Liquid Glass Effect
              _HelpLiquidGlassCard(
                borderRadius: BorderRadius.circular(16.r),
                child: AppTextField(
                  controller: _searchController,
                  hintText: 'Search questions and topics...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.outline,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 18.sp,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  fillColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),
              SizedBox(height: 12.h),

              // Category Filter Pills with Liquid Glass Effect
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _faqCategories.map((cat) {
                    final isSelected = _selectedCategory == cat.name;
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _FaqCategoryChip(
                        label: cat.name,
                        icon: cat.icon,
                        isSelected: isSelected,
                        activeColor: colorScheme.primary,
                        onTap: () =>
                            setState(() => _selectedCategory = cat.name),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),

              // FAQ Items List
              if (filteredList.isEmpty) ...[
                GlassContainer(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 28.h,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 36.sp,
                        color: colorScheme.outline,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No matching questions found',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Try searching with different keywords or switch to the Help & Support tab to ask us directly.',
                        style: customTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...filteredList.map((faq) {
                  final isExpanded = _expandedIds.contains(faq.id);
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isExpanded
                            ? colorScheme.primary.withValues(alpha: 0.35)
                            : customColors.glassStroke,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIds.remove(faq.id);
                            } else {
                              _expandedIds.add(faq.id);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            faq.category.toUpperCase(),
                                            style: customTypography
                                                .labelMediumMono
                                                .copyWith(
                                              fontSize: 9.sp,
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(
                                          faq.question,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: isExpanded
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isExpanded
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                      size: 22.sp,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: EdgeInsets.only(top: 10.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        color: customColors.glassStroke,
                                        height: 1,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        faq.answer,
                                        style: customTypography.bodyMedium
                                            .copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                crossFadeState: isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ).defaultCanvasPadding(),
        ),
      ),
    );
  }

  Widget _buildContactSupportTab(
      BuildContext context, double headerPaddingTop) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: headerPaddingTop + 60.h,
        bottom: 40.h,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Support Agent Header Glass Card
              // Support Agent Header Glass Card
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
                            Icons.support_agent_rounded,
                            color: colorScheme.primary,
                            size: 24.sp,
                          ),
                        ),
                        horizontalMarginSmall,
                        Expanded(
                          child: Text(
                            'Direct Support & Assistance',
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
                      'Have an issue, feature suggestion, or question? Send a message to our support team and we will get back to you promptly.',
                      style: customTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              verticalMarginMedium,

              // Question Input Card
              GlassContainer(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your Message / Question',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 10.h),
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
                        fillColor: colorScheme.surfaceContainerHigh
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: customColors.glassStroke,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: customColors.glassStroke,
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
                    SizedBox(height: 16.h),

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
              verticalMarginMedium,

              // Additional info footer
              Center(
                child: Text(
                  '${context.l10n.appName} ${AppConfig.formattedVersion} • Offline Personal Finance',
                  style: customTypography.labelMediumMono.copyWith(
                    color: colorScheme.outline,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ).defaultCanvasPadding(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;
    final headerPaddingTop =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: LiquidGlassAppBar(
        titleText: l10n.helpAndSupport,
        onLeadingPressed: () => context.router.maybePop(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildContactSupportTab(context, headerPaddingTop),
              _buildFaqTab(context, headerPaddingTop),
            ],
          ),
          _buildLiquidGlassTabBar(context, headerPaddingTop),
        ],
      ),
    );
  }
}

class _HelpLiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const _HelpLiquidGlassCard({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final br = borderRadius ?? BorderRadius.circular(16.r);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [
                  colorScheme.surfaceContainerLowest.withValues(alpha: 0.35),
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.20),
                ]
              : [
                  colorScheme.surfaceContainerHigh.withValues(alpha: 0.25),
                  colorScheme.surfaceContainerLow.withValues(alpha: 0.15),
                ],
        ),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.50)
              : customColors.glassStroke.withValues(alpha: 0.40),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: isLight ? 0.5 : 0.0),
            blurRadius: 6.r,
            spreadRadius: -1.r,
            offset: const Offset(0, -1),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.06 : 0.18),
            blurRadius: 12.r,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Helper widget for animated FAQ category filter chip pills with liquid glass effect.
class _FaqCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _FaqCategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final onActiveTextColor = (activeColor == colorScheme.primary && !isLight)
        ? colorScheme.onPrimary
        : Colors.white;

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                  : (isLight
                      ? colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.6)
                      : colorScheme.surfaceContainerLow),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : (isLight
                        ? colorScheme.outlineVariant.withValues(alpha: 0.6)
                        : context.customColors.glassStroke),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            activeColor.withValues(alpha: isLight ? 0.35 : 0.4),
                        blurRadius: 8.r,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15.sp,
                  color: isSelected
                      ? onActiveTextColor
                      : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: customTypography.labelMediumMono.copyWith(
                    color:
                        isSelected ? onActiveTextColor : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
