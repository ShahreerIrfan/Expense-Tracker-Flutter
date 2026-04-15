import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/daos/expense_dao.dart';
import '../core/constants/app_constants.dart';

class ExportService {
  Future<String> generatePdfReport({
    required String userName,
    required double totalIncome,
    required double totalExpense,
    required List<CategoryTotal> categoryTotals,
    required DateTime startDate,
    required DateTime endDate,
    String currency = 'BDT',
  }) async {
    final pdf = pw.Document();
    final symbol = AppConstants.currencySymbols[currency] ?? currency;
    final formatter = NumberFormat('#,##0.00');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Expense Tracker Report',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('By Muhammad Shahreer Irfan',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                pw.SizedBox(height: 8),
                pw.Text('User: $userName',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Text(
                    'Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.Divider(),
              ],
            ),
          ),

          // Summary
          pw.Header(level: 1, text: 'Summary'),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellPadding: const pw.EdgeInsets.all(8),
            data: [
              ['Metric', 'Amount'],
              ['Total Income', '$symbol${formatter.format(totalIncome)}'],
              ['Total Expense', '$symbol${formatter.format(totalExpense)}'],
              [
                'Net Balance',
                '$symbol${formatter.format(totalIncome - totalExpense)}'
              ],
            ],
          ),
          pw.SizedBox(height: 20),

          // Category breakdown
          pw.Header(level: 1, text: 'Expense by Category'),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellPadding: const pw.EdgeInsets.all(8),
            data: [
              ['Category', 'Amount', 'Percentage'],
              ...categoryTotals.map((ct) {
                final pct = totalExpense > 0
                    ? (ct.total / totalExpense * 100).toStringAsFixed(1)
                    : '0.0';
                return [
                  ct.categoryName,
                  '$symbol${formatter.format(ct.total)}',
                  '$pct%',
                ];
              }),
            ],
          ),

          pw.SizedBox(height: 30),
          pw.Text(
            'Generated on ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
          pw.Text(
            'Expense Tracker by Muhammad Shahreer Irfan',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/report_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
