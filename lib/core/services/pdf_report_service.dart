import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/app_logger.dart';
import '../../features/analytics/domain/entities/analytics_report.dart';

/// PDF Color helper with RGB components in range 0.0 - 1.0.
class PdfColor {
  final double r;
  final double g;
  final double b;

  const PdfColor(this.r, this.g, this.b);

  static const white = PdfColor(1.0, 1.0, 1.0);
  static const black = PdfColor(0.0, 0.0, 0.0);
  static const darkText = PdfColor(0.09, 0.13, 0.24); // #17213D
  static const mutedText = PdfColor(0.38, 0.44, 0.54); // #61708A
  static const primary = PdfColor(0.02, 0.45, 0.90); // #0573E6
  static const primaryLight = PdfColor(0.90, 0.95, 1.0); // #E6F2FF
  static const success = PdfColor(0.06, 0.72, 0.51); // #10B981
  static const successLight = PdfColor(0.92, 0.98, 0.95);
  static const danger = PdfColor(0.94, 0.27, 0.38); // #F04561
  static const dangerLight = PdfColor(0.99, 0.93, 0.94);
  static const warning = PdfColor(0.96, 0.62, 0.12); // #F59E0B
  static const cardBg = PdfColor(0.96, 0.97, 0.99); // #F5F7FC
  static const cardBorder = PdfColor(0.87, 0.90, 0.94); // #DEE5F0
  static const gridLine = PdfColor(0.91, 0.93, 0.96);

  factory PdfColor.fromHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        final rVal = int.parse(clean.substring(0, 2), radix: 16) / 255.0;
        final gVal = int.parse(clean.substring(2, 4), radix: 16) / 255.0;
        final bVal = int.parse(clean.substring(4, 6), radix: 16) / 255.0;
        return PdfColor(rVal, gVal, bVal);
      }
    } catch (_) {}
    return primary;
  }
}

/// Represents a single page in the PDF document with vector drawing primitives.
class PdfPageContext {
  final double width;
  final double height;
  final StringBuffer _commands = StringBuffer();

  PdfPageContext({this.width = 595.28, this.height = 841.89}); // A4 standard

  void drawRect(
    double x,
    double y,
    double w,
    double h, {
    PdfColor? fillColor,
    PdfColor? strokeColor,
    double strokeWidth = 1.0,
  }) {
    _commands.writeln('q');
    if (strokeColor != null) {
      _commands.writeln(
          '${strokeColor.r.toStringAsFixed(3)} ${strokeColor.g.toStringAsFixed(3)} ${strokeColor.b.toStringAsFixed(3)} RG');
      _commands.writeln('${strokeWidth.toStringAsFixed(2)} w');
    }
    if (fillColor != null) {
      _commands.writeln(
          '${fillColor.r.toStringAsFixed(3)} ${fillColor.g.toStringAsFixed(3)} ${fillColor.b.toStringAsFixed(3)} rg');
    }
    _commands.writeln(
        '${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${w.toStringAsFixed(2)} ${h.toStringAsFixed(2)} re');
    if (fillColor != null && strokeColor != null) {
      _commands.writeln('B');
    } else if (fillColor != null) {
      _commands.writeln('f');
    } else if (strokeColor != null) {
      _commands.writeln('S');
    }
    _commands.writeln('Q');
  }

  void drawRoundedRect(
    double x,
    double y,
    double w,
    double h,
    double r, {
    PdfColor? fillColor,
    PdfColor? strokeColor,
    double strokeWidth = 1.0,
  }) {
    // PDF rounded rectangle approximation
    final k = 0.5522847498 * r;
    _commands.writeln('q');
    if (strokeColor != null) {
      _commands.writeln(
          '${strokeColor.r.toStringAsFixed(3)} ${strokeColor.g.toStringAsFixed(3)} ${strokeColor.b.toStringAsFixed(3)} RG');
      _commands.writeln('${strokeWidth.toStringAsFixed(2)} w');
    }
    if (fillColor != null) {
      _commands.writeln(
          '${fillColor.r.toStringAsFixed(3)} ${fillColor.g.toStringAsFixed(3)} ${fillColor.b.toStringAsFixed(3)} rg');
    }
    _commands
        .writeln('${(x + r).toStringAsFixed(2)} ${y.toStringAsFixed(2)} m');
    _commands
        .writeln('${(x + w - r).toStringAsFixed(2)} ${y.toStringAsFixed(2)} l');
    _commands.writeln(
        '${(x + w - r + k).toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${(x + w).toStringAsFixed(2)} ${(y + r - k).toStringAsFixed(2)} ${(x + w).toStringAsFixed(2)} ${(y + r).toStringAsFixed(2)} c');
    _commands.writeln(
        '${(x + w).toStringAsFixed(2)} ${(y + h - r).toStringAsFixed(2)} l');
    _commands.writeln(
        '${(x + w).toStringAsFixed(2)} ${(y + h - r + k).toStringAsFixed(2)} ${(x + w - r + k).toStringAsFixed(2)} ${(y + h).toStringAsFixed(2)} ${(x + w - r).toStringAsFixed(2)} ${(y + h).toStringAsFixed(2)} c');
    _commands.writeln(
        '${(x + r).toStringAsFixed(2)} ${(y + h).toStringAsFixed(2)} l');
    _commands.writeln(
        '${(x + r - k).toStringAsFixed(2)} ${(y + h).toStringAsFixed(2)} ${x.toStringAsFixed(2)} ${(y + h - r + k).toStringAsFixed(2)} ${x.toStringAsFixed(2)} ${(y + h - r).toStringAsFixed(2)} c');
    _commands
        .writeln('${x.toStringAsFixed(2)} ${(y + r).toStringAsFixed(2)} l');
    _commands.writeln(
        '${x.toStringAsFixed(2)} ${(y + r - k).toStringAsFixed(2)} ${(x + r - k).toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${(x + r).toStringAsFixed(2)} ${y.toStringAsFixed(2)} c');
    if (fillColor != null && strokeColor != null) {
      _commands.writeln('B');
    } else if (fillColor != null) {
      _commands.writeln('f');
    } else if (strokeColor != null) {
      _commands.writeln('S');
    }
    _commands.writeln('Q');
  }

  void drawLine(
    double x1,
    double y1,
    double x2,
    double y2,
    PdfColor color, {
    double strokeWidth = 1.0,
  }) {
    _commands.writeln('q');
    _commands.writeln(
        '${color.r.toStringAsFixed(3)} ${color.g.toStringAsFixed(3)} ${color.b.toStringAsFixed(3)} RG');
    _commands.writeln('${strokeWidth.toStringAsFixed(2)} w');
    _commands.writeln('${x1.toStringAsFixed(2)} ${y1.toStringAsFixed(2)} m');
    _commands.writeln('${x2.toStringAsFixed(2)} ${y2.toStringAsFixed(2)} l');
    _commands.writeln('S');
    _commands.writeln('Q');
  }

  void drawText(
    String text,
    double x,
    double y, {
    double fontSize = 10.0,
    bool bold = false,
    bool italic = false,
    PdfColor color = PdfColor.darkText,
  }) {
    final fontId = bold ? '/F2' : (italic ? '/F3' : '/F1');
    final escaped = _escapePdfString(text);

    _commands.writeln('BT');
    _commands.writeln(
        '${color.r.toStringAsFixed(3)} ${color.g.toStringAsFixed(3)} ${color.b.toStringAsFixed(3)} rg');
    _commands.writeln('$fontId ${fontSize.toStringAsFixed(1)} Tf');
    _commands.writeln('${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} Td');
    _commands.writeln('($escaped) Tj');
    _commands.writeln('ET');
  }

  void drawProgressBar(
    double x,
    double y,
    double w,
    double h,
    double ratio, {
    required PdfColor fillColor,
    PdfColor bgColor = const PdfColor(0.90, 0.92, 0.95),
  }) {
    drawRoundedRect(x, y, w, h, h / 2, fillColor: bgColor);
    final clampedRatio = ratio.clamp(0.0, 1.0);
    if (clampedRatio > 0.01) {
      final fillW = (w * clampedRatio).clamp(h, w);
      drawRoundedRect(x, y, fillW, h, h / 2, fillColor: fillColor);
    }
  }

  String _escapePdfString(String input) {
    var result = input
        .replaceAll('₹', 'Rs.')
        .replaceAll('€', 'EUR ')
        .replaceAll('£', 'GBP ')
        .replaceAll('¥', 'JPY ')
        .replaceAll('•', '-')
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('“', '"')
        .replaceAll('”', '"');

    final buffer = StringBuffer();
    for (int i = 0; i < result.length; i++) {
      final code = result.codeUnitAt(i);
      if (code >= 32 && code <= 126) {
        if (code == 40 || code == 41 || code == 92) {
          buffer.write('\\');
        }
        buffer.writeCharCode(code);
      } else if (code == 10 || code == 13) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String getStreamContent() => _commands.toString();
}

/// Pure Dart ISO 32000-1 PDF document builder.
class PdfDocumentBuilder {
  final List<PdfPageContext> _pages = [];

  PdfPageContext addPage() {
    final page = PdfPageContext();
    _pages.add(page);
    return page;
  }

  Uint8List build() {
    final buffer = BytesBuilder();
    final offsets = <int>[];

    void writeString(String s) {
      buffer.add(utf8.encode(s));
    }

    // 1. Header
    writeString('%PDF-1.4\n');
    writeString('%\xE2\xE3\xCF\xD3\n'); // Binary marker

    // Object 1: Catalog
    offsets.add(buffer.length);
    writeString('1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n');

    // Object 2: Pages Parent
    offsets.add(buffer.length);
    final kidsStr = StringBuffer();
    for (int i = 0; i < _pages.length; i++) {
      kidsStr.write('${3 + i * 2} 0 R ');
    }
    writeString(
        '2 0 obj\n<< /Type /Pages /Kids [$kidsStr] /Count ${_pages.length} >>\nendobj\n');

    // Standard Font Objects (Objects allocated at end)
    final font1ObjNum = 3 + _pages.length * 2;
    final font2ObjNum = font1ObjNum + 1;
    final font3ObjNum = font1ObjNum + 2;

    // Page Objects and Content Streams
    for (int i = 0; i < _pages.length; i++) {
      final page = _pages[i];
      final pageObjNum = 3 + i * 2;
      final contentObjNum = pageObjNum + 1;

      // Page Object
      offsets.add(buffer.length);
      writeString(
          '$pageObjNum 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${page.width} ${page.height}] /Resources << /Font << /F1 $font1ObjNum 0 R /F2 $font2ObjNum 0 R /F3 $font3ObjNum 0 R >> >> /Contents $contentObjNum 0 R >>\nendobj\n');

      // Content Stream Object
      final streamData = utf8.encode(page.getStreamContent());
      offsets.add(buffer.length);
      writeString(
          '$contentObjNum 0 obj\n<< /Length ${streamData.length} >>\nstream\n');
      buffer.add(streamData);
      writeString('\nendstream\nendobj\n');
    }

    // Font 1: Helvetica
    offsets.add(buffer.length);
    writeString(
        '$font1ObjNum 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>\nendobj\n');

    // Font 2: Helvetica-Bold
    offsets.add(buffer.length);
    writeString(
        '$font2ObjNum 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>\nendobj\n');

    // Font 3: Helvetica-Oblique
    offsets.add(buffer.length);
    writeString(
        '$font3ObjNum 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Oblique /Encoding /WinAnsiEncoding >>\nendobj\n');

    // XRef Table
    final startXRef = buffer.length;
    final totalObjects = font3ObjNum + 1;
    writeString('xref\n0 $totalObjects\n0000000000 65535 f \n');
    for (final offset in offsets) {
      final offStr = offset.toString().padLeft(10, '0');
      writeString('$offStr 00000 n \n');
    }

    // Trailer
    writeString('trailer\n<< /Size $totalObjects /Root 1 0 R >>\n');
    writeString('startxref\n$startXRef\n%%EOF\n');

    return buffer.toBytes();
  }
}

/// Service dedicated to generating comprehensive visual Financial PDF Reports.
@lazySingleton
class PdfReportService {
  /// Generates a complete, multi-page financial analytics PDF report file.
  Future<String> generateAnalyticsReportPdf({
    required AnalyticsReport report,
    required String currencySymbol,
    required List<Map<String, dynamic>> transactions,
    String periodName = 'Monthly',
  }) async {
    final doc = PdfDocumentBuilder();

    // ─────────────────────────────────────────────────────────────────────────
    // PAGE 1: EXECUTIVE SUMMARY & VISUAL CHARTS WITH EXPLANATIONS
    // ─────────────────────────────────────────────────────────────────────────
    final p1 = doc.addPage();
    final pageWidth = p1.width;

    // Header Top Banner
    p1.drawRoundedRect(36, 755, pageWidth - 72, 54, 8,
        fillColor: PdfColor.cardBg, strokeColor: PdfColor.cardBorder);
    p1.drawRoundedRect(36, 755, 6, 54, 3, fillColor: PdfColor.primary);

    p1.drawText('EXPENDLY FINANCIAL ANALYTICS & INSIGHTS REPORT', 52, 788,
        fontSize: 14, bold: true, color: PdfColor.darkText);
    final nowFormatted = DateTime.now().toString().substring(0, 10);
    p1.drawText(
        'Period: $periodName  |  Generated: $nowFormatted  |  Currency: $currencySymbol',
        52,
        768,
        fontSize: 9,
        color: PdfColor.mutedText);

    // ── Key Metrics Cards (4 Columns) ────────────────────────────────────────
    final cardW = (pageWidth - 72 - 18) / 4;
    const cardY = 685.0;
    const cardH = 58.0;

    // Income Card
    p1.drawRoundedRect(36, cardY, cardW, cardH, 6,
        fillColor: PdfColor.successLight,
        strokeColor: PdfColor.success,
        strokeWidth: 0.8);
    p1.drawText('TOTAL INCOME', 44, cardY + 42,
        fontSize: 7.5, bold: true, color: PdfColor.mutedText);
    p1.drawText('$currencySymbol${report.totalIncome.toStringAsFixed(2)}', 44,
        cardY + 18,
        fontSize: 11.5, bold: true, color: PdfColor.success);

    // Expense Card
    p1.drawRoundedRect(36 + cardW + 6, cardY, cardW, cardH, 6,
        fillColor: PdfColor.dangerLight,
        strokeColor: PdfColor.danger,
        strokeWidth: 0.8);
    p1.drawText('TOTAL EXPENSE', 36 + cardW + 14, cardY + 42,
        fontSize: 7.5, bold: true, color: PdfColor.mutedText);
    p1.drawText('$currencySymbol${report.totalExpense.toStringAsFixed(2)}',
        36 + cardW + 14, cardY + 18,
        fontSize: 11.5, bold: true, color: PdfColor.danger);

    // Net Savings Card
    final isNetPositive = report.netSavings >= 0;
    p1.drawRoundedRect(36 + (cardW + 6) * 2, cardY, cardW, cardH, 6,
        fillColor: isNetPositive ? PdfColor.primaryLight : PdfColor.dangerLight,
        strokeColor: isNetPositive ? PdfColor.primary : PdfColor.danger,
        strokeWidth: 0.8);
    p1.drawText('NET SAVINGS', 36 + (cardW + 6) * 2 + 8, cardY + 42,
        fontSize: 7.5, bold: true, color: PdfColor.mutedText);
    final sign = isNetPositive ? '+' : '';
    p1.drawText('$sign$currencySymbol${report.netSavings.toStringAsFixed(2)}',
        36 + (cardW + 6) * 2 + 8, cardY + 18,
        fontSize: 11.5,
        bold: true,
        color: isNetPositive ? PdfColor.primary : PdfColor.danger);

    // Savings Rate & Budget Health Card
    p1.drawRoundedRect(36 + (cardW + 6) * 3, cardY, cardW, cardH, 6,
        fillColor: PdfColor.cardBg,
        strokeColor: PdfColor.cardBorder,
        strokeWidth: 0.8);
    p1.drawText('SAVINGS RATE / HEALTH', 36 + (cardW + 6) * 3 + 8, cardY + 42,
        fontSize: 7.5, bold: true, color: PdfColor.mutedText);
    p1.drawText(
        '${report.savingsRatePercentage.toStringAsFixed(1)}% (${report.budgetHealthStatus})',
        36 + (cardW + 6) * 3 + 8,
        cardY + 18,
        fontSize: 10.5,
        bold: true,
        color: PdfColor.darkText);

    // ── Section 1: Cash Flow Trends (Vector Bar Chart) ──────────────────────
    const chart1Y = 490.0;
    p1.drawText('1. CASH FLOW & DAILY SPENDING TREND CHART', 36, 665,
        fontSize: 10, bold: true, color: PdfColor.darkText);

    // Chart Box
    p1.drawRoundedRect(36, chart1Y, pageWidth - 72, 165, 8,
        fillColor: PdfColor.white,
        strokeColor: PdfColor.cardBorder,
        strokeWidth: 1.0);

    // Grid baseline
    p1.drawLine(
        56, chart1Y + 45, pageWidth - 56, chart1Y + 45, PdfColor.gridLine,
        strokeWidth: 1.0);
    p1.drawLine(
        56, chart1Y + 85, pageWidth - 56, chart1Y + 85, PdfColor.gridLine,
        strokeWidth: 0.5);
    p1.drawLine(
        56, chart1Y + 125, pageWidth - 56, chart1Y + 125, PdfColor.gridLine,
        strokeWidth: 0.5);

    // Render Daily Flow Bars
    final flows = report.dailyFlows;
    if (flows.isNotEmpty) {
      final availableWidth = (pageWidth - 112);
      final barStep = availableWidth / flows.length;
      const maxBarH = 80.0;

      for (int i = 0; i < flows.length; i++) {
        final item = flows[i];
        final barX = 56 + i * barStep + (barStep * 0.2);
        final barW = (barStep * 0.6).clamp(6.0, 24.0);
        final barH = (item.heightRatio * maxBarH).clamp(4.0, maxBarH);

        final barColor =
            item.isPeak ? PdfColor.primary : const PdfColor(0.35, 0.65, 0.95);
        p1.drawRoundedRect(barX, chart1Y + 45, barW, barH, 2,
            fillColor: barColor);

        // Day label below baseline
        p1.drawText(item.label, barX - 1, chart1Y + 32,
            fontSize: 7, color: PdfColor.mutedText);

        // Amount on top of peak bar
        if (item.isPeak || flows.length <= 7) {
          final amtStr = item.amount >= 1000
              ? '${(item.amount / 1000).toStringAsFixed(1)}k'
              : item.amount.toStringAsFixed(0);
          p1.drawText(amtStr, barX - 2, chart1Y + 47 + barH,
              fontSize: 6.5, bold: item.isPeak, color: PdfColor.darkText);
        }
      }
    }

    // Chart 1 Explanation Box
    p1.drawRoundedRect(36, chart1Y - 45, pageWidth - 72, 40, 6,
        fillColor: PdfColor.cardBg, strokeColor: PdfColor.cardBorder);
    p1.drawText('CHART INSIGHT & ANALYSIS:', 44, chart1Y - 18,
        fontSize: 7.5, bold: true, color: PdfColor.primary);
    final peakDay = flows.where((f) => f.isPeak).firstOrNull;
    final peakDesc = peakDay != null
        ? 'Peak spending occurred on ${peakDay.label} ($currencySymbol${peakDay.amount.toStringAsFixed(2)}).'
        : 'Daily expenditures remained evenly balanced throughout the period.';
    p1.drawText(
        '$peakDesc Average daily spend is $currencySymbol${report.avgDailySpend.toStringAsFixed(2)}.',
        44,
        chart1Y - 32,
        fontSize: 8,
        color: PdfColor.darkText);

    // ── Section 2: Category Breakdown (Visual Distribution Bars) ────────────
    const chart2Y = 240.0;
    p1.drawText('2. CATEGORY EXPENSE BREAKDOWN & DISTRIBUTION', 36, 430,
        fontSize: 10, bold: true, color: PdfColor.darkText);

    p1.drawRoundedRect(36, chart2Y, pageWidth - 72, 180, 8,
        fillColor: PdfColor.white,
        strokeColor: PdfColor.cardBorder,
        strokeWidth: 1.0);

    final categories = report.categoryBreakdowns.take(5).toList();
    var catRowY = chart2Y + 145.0;

    if (categories.isEmpty) {
      p1.drawText(
          'No category expenses recorded for this period.', 56, chart2Y + 80,
          fontSize: 9, italic: true, color: PdfColor.mutedText);
    } else {
      for (final cat in categories) {
        final catColor = PdfColor.fromHex(cat.colorHex);
        p1.drawRoundedRect(56, catRowY + 2, 8, 8, 2, fillColor: catColor);
        p1.drawText(cat.categoryName, 70, catRowY + 2,
            fontSize: 8.5, bold: true, color: PdfColor.darkText);

        // Progress bar
        final barWidth = pageWidth - 72 - 180;
        p1.drawProgressBar(
            180, catRowY + 3, barWidth, 6, cat.percentage / 100.0,
            fillColor: catColor);

        // Percentage & Amount
        final pctStr = '${cat.percentage.toStringAsFixed(1)}%';
        final amtStr = '$currencySymbol${cat.amount.toStringAsFixed(2)}';
        p1.drawText(pctStr, 180 + barWidth + 10, catRowY + 2,
            fontSize: 8, color: PdfColor.mutedText);
        p1.drawText(amtStr, pageWidth - 100, catRowY + 2,
            fontSize: 8.5, bold: true, color: PdfColor.darkText);

        catRowY -= 28.0;
      }
    }

    // Chart 2 Explanation Box
    p1.drawRoundedRect(36, chart2Y - 45, pageWidth - 72, 40, 6,
        fillColor: PdfColor.cardBg, strokeColor: PdfColor.cardBorder);
    p1.drawText('CATEGORY INSIGHT & BUDGET ADVICE:', 44, chart2Y - 18,
        fontSize: 7.5, bold: true, color: PdfColor.primary);
    final topCat = report.topCategoryName ?? 'General';
    final topPct = report.topCategoryPercentage?.toStringAsFixed(1) ?? '0.0';
    p1.drawText(
        'Top spending category is "$topCat" making up $topPct% of outlays. Maintain essential expenses under 50% of income.',
        44,
        chart2Y - 32,
        fontSize: 8,
        color: PdfColor.darkText);

    // ── Section 3: Budget Health & Financial Stability Scorecard ────────────
    const chart3Y = 80.0;
    p1.drawText('3. BUDGET HEALTH & SAVINGS EFFICIENCY SCORECARD', 36, 180,
        fontSize: 10, bold: true, color: PdfColor.darkText);

    p1.drawRoundedRect(36, chart3Y, pageWidth - 72, 85, 8,
        fillColor: PdfColor.white,
        strokeColor: PdfColor.cardBorder,
        strokeWidth: 1.0);

    // Health score bar
    p1.drawText(
        'Overall Financial Health Score: ${report.budgetHealthPercentage.toStringAsFixed(0)}%  (${report.budgetHealthStatus})',
        56,
        chart3Y + 60,
        fontSize: 9,
        bold: true,
        color: PdfColor.darkText);
    final healthRatio = (report.budgetHealthPercentage / 100.0).clamp(0.0, 1.0);
    p1.drawProgressBar(56, chart3Y + 45, pageWidth - 112, 8, healthRatio,
        fillColor: healthRatio > 0.7
            ? PdfColor.success
            : (healthRatio > 0.4 ? PdfColor.warning : PdfColor.danger));

    p1.drawText(
        'Explanation: Score is calculated from savings rate adherence, expenditure distribution, and cash flow consistency.',
        56,
        chart3Y + 26,
        fontSize: 7.5,
        color: PdfColor.mutedText);
    p1.drawText(
        'Recommendation: Continue automated saving allocations to build an emergency fund of 3-6 months of expenses.',
        56,
        chart3Y + 12,
        fontSize: 7.5,
        color: PdfColor.mutedText);

    // Page 1 Footer
    p1.drawLine(36, 45, pageWidth - 36, 45, PdfColor.cardBorder,
        strokeWidth: 0.5);
    p1.drawText('Expendly Financial Platform  |  Confidential Report', 36, 32,
        fontSize: 7.5, color: PdfColor.mutedText);
    p1.drawText('Page 1 of 2', pageWidth - 80, 32,
        fontSize: 7.5, color: PdfColor.mutedText);

    // ─────────────────────────────────────────────────────────────────────────
    // PAGE 2: ITEMIZED TRANSACTION AUDIT LEDGER
    // ─────────────────────────────────────────────────────────────────────────
    final p2 = doc.addPage();
    final p2Width = p2.width;

    // Page 2 Header
    p2.drawRoundedRect(36, 765, p2Width - 72, 44, 6,
        fillColor: PdfColor.cardBg, strokeColor: PdfColor.cardBorder);
    p2.drawText('ITEMIZED TRANSACTION AUDIT LEDGER', 52, 788,
        fontSize: 12, bold: true, color: PdfColor.darkText);
    p2.drawText(
        'Detailed breakdown of transactions recorded during the $periodName period',
        52,
        773,
        fontSize: 8,
        color: PdfColor.mutedText);

    // Table Column Header
    const thY = 740.0;
    p2.drawRect(36, thY, p2Width - 72, 20, fillColor: PdfColor.primary);
    p2.drawText('DATE & TIME', 44, thY + 6,
        fontSize: 8, bold: true, color: PdfColor.white);
    p2.drawText('TYPE', 150, thY + 6,
        fontSize: 8, bold: true, color: PdfColor.white);
    p2.drawText('CATEGORY', 210, thY + 6,
        fontSize: 8, bold: true, color: PdfColor.white);
    p2.drawText('DESCRIPTION / NOTE', 310, thY + 6,
        fontSize: 8, bold: true, color: PdfColor.white);
    p2.drawText('AMOUNT', p2Width - 90, thY + 6,
        fontSize: 8, bold: true, color: PdfColor.white);

    // Table Rows
    var rowY = thY - 18.0;
    const rowH = 17.0;
    const maxRows = 38;
    final displayTx = transactions.take(maxRows).toList();

    for (int i = 0; i < displayTx.length; i++) {
      final tx = displayTx[i];
      final isEven = i % 2 == 0;
      if (isEven) {
        p2.drawRect(36, rowY - 3, p2Width - 72, rowH,
            fillColor: const PdfColor(0.97, 0.98, 0.99));
      }

      final dateStr = (tx['date'] as String? ?? '').length >= 10
          ? (tx['date'] as String).substring(0, 10)
          : '';
      final typeStr = (tx['type'] as String? ?? 'EXPENSE').toUpperCase();
      final catStr = tx['category'] as String? ?? 'General';
      final noteStr = tx['note'] as String? ?? '';
      final amountVal = (tx['amount'] as num? ?? 0.0).toDouble();
      final isIncome = typeStr == 'INCOME';

      p2.drawText(dateStr, 44, rowY + 2,
          fontSize: 7.5, color: PdfColor.darkText);
      p2.drawText(typeStr, 150, rowY + 2,
          fontSize: 7,
          bold: true,
          color: isIncome ? PdfColor.success : PdfColor.danger);
      p2.drawText(catStr, 210, rowY + 2,
          fontSize: 7.5, color: PdfColor.darkText);
      p2.drawText(
          noteStr.length > 25 ? '${noteStr.substring(0, 25)}...' : noteStr,
          310,
          rowY + 2,
          fontSize: 7.5,
          color: PdfColor.mutedText);

      final amtFormatted =
          '${isIncome ? '+' : '-'}$currencySymbol${amountVal.toStringAsFixed(2)}';
      p2.drawText(amtFormatted, p2Width - 95, rowY + 2,
          fontSize: 7.5,
          bold: true,
          color: isIncome ? PdfColor.success : PdfColor.danger);

      rowY -= rowH;
    }

    if (transactions.isEmpty) {
      p2.drawText('No transactions recorded for this period.', 56, rowY - 10,
          fontSize: 9, italic: true, color: PdfColor.mutedText);
    }

    // Page 2 Footer
    p2.drawLine(36, 45, p2Width - 36, 45, PdfColor.cardBorder,
        strokeWidth: 0.5);
    p2.drawText('Expendly Financial Platform  |  Confidential Report', 36, 32,
        fontSize: 7.5, color: PdfColor.mutedText);
    p2.drawText('Page 2 of 2', p2Width - 80, 32,
        fontSize: 7.5, color: PdfColor.mutedText);

    // ── Build PDF binary ─────────────────────────────────────────────────────
    final pdfBytes = doc.build();

    // ── Save to device storage ───────────────────────────────────────────────
    final exportDir = await _getExportDirectory();
    final fileName =
        'expendly_financial_report_${periodName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = p.join(exportDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    AppLogger.i('PdfReportService: Financial PDF Report saved to $filePath');
    return filePath;
  }

  Future<Directory> _getExportDirectory() async {
    final candidateDirs = <Future<Directory?>>[
      if (Platform.isAndroid)
        getExternalStorageDirectories(type: StorageDirectory.downloads).then(
            (dirs) => dirs != null && dirs.isNotEmpty ? dirs.first : null),
      if (Platform.isAndroid) getExternalStorageDirectory(),
      getDownloadsDirectory(),
      getApplicationDocumentsDirectory(),
    ];

    for (final dirFuture in candidateDirs) {
      try {
        final dir = await dirFuture;
        if (dir == null) continue;
        final expendlyDir = Directory(p.join(dir.path, 'Expendly'));
        if (!await expendlyDir.exists()) {
          await expendlyDir.create(recursive: true);
        }
        return expendlyDir;
      } catch (_) {}
    }

    return await getApplicationDocumentsDirectory();
  }
}
