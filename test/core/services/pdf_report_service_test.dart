import 'dart:io';
import 'package:expendly/core/services/pdf_report_service.dart';
import 'package:expendly/features/analytics/domain/entities/analytics_report.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory tempDir;

  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempDir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfReportService Tests', () {
    late PdfReportService pdfReportService;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('expendly_pdf_test_');
      PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);
      pdfReportService = PdfReportService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('generateAnalyticsReportPdf creates valid PDF file with charts and narratives', () async {
      const report = AnalyticsReport(
        totalIncome: 5000.0,
        totalExpense: 3200.0,
        netSavings: 1800.0,
        savingsRatePercentage: 36.0,
        avgDailySpend: 106.67,
        avgDailySpendChangePct: -4.5,
        budgetHealthPercentage: 85.0,
        budgetHealthStatus: 'Excellent',
        topCategoryName: 'Food & Dining',
        topCategoryPercentage: 38.5,
        topCategoryDesc: 'Largest expenditure area',
        periodName: 'Monthly',
        categoryBreakdowns: [
          CategoryReportItem(
            categoryName: 'Food & Dining',
            iconName: 'restaurant',
            colorHex: '#FF5722',
            amount: 1232.0,
            percentage: 38.5,
          ),
          CategoryReportItem(
            categoryName: 'Housing & Utilities',
            iconName: 'home',
            colorHex: '#2196F3',
            amount: 950.0,
            percentage: 29.7,
          ),
          CategoryReportItem(
            categoryName: 'Transportation',
            iconName: 'directions_bus',
            colorHex: '#4CAF50',
            amount: 450.0,
            percentage: 14.1,
          ),
        ],
        dailyFlows: [
          DailyFlowItem(label: '01', amount: 80.0, heightRatio: 0.4),
          DailyFlowItem(label: '02', amount: 150.0, heightRatio: 0.75),
          DailyFlowItem(label: '03', amount: 200.0, heightRatio: 1.0, isPeak: true),
          DailyFlowItem(label: '04', amount: 45.0, heightRatio: 0.22),
        ],
      );

      final filePath = await pdfReportService.generateAnalyticsReportPdf(
        report: report,
        periodName: 'Monthly',
        currencySymbol: '\$',
        transactions: const [],
      );

      final file = File(filePath);
      expect(await file.exists(), isTrue);
      expect(file.path.endsWith('.pdf'), isTrue);
      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(100)); // Non-empty binary PDF payload
    });
  });
}
