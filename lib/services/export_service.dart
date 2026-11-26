import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';
import '../models/category.dart';
import '../core/currency_format.dart';

class ExportService {
  static Future<void> exportTransactionsToCSV(
    List<TransactionItem> transactions,
    List<CategoryItem> categories,
    int month,
    int year,
  ) async {
    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln('Tanggal,Kategori,Tipe,Nominal,Catatan');

      // Rows
      for (final tx in transactions) {
        final date = DateFormat('yyyy-MM-dd HH:mm').format(tx.date);
        final category = AppCategories.getCategoryById(
          tx.categoryId,
          categories,
        );
        final type = tx.type == TransactionType.income
            ? 'Pemasukan'
            : 'Pengeluaran';
        final amount = CurrencyFormat.convertToIdr(
          tx.amount,
        ).replaceAll('.', '').replaceAll('Rp', ''); // Raw number

        // Escape notes for CSV
        final note = '"${tx.note.replaceAll('"', '""')}"';

        buffer.writeln('$date,${category.name},$type,$amount,$note');
      }

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('MMM_yyyy').format(DateTime(year, month));
      final filePath = '${dir.path}/Laporan_ZenFlow_$dateStr.csv';

      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      // Share
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Keuangan ZenFlow $dateStr');
    } catch (e) {
      throw Exception('Gagal mengekspor laporan: $e');
    }
  }

  static Future<void> exportTransactionsToPDF(
    List<TransactionItem> transactions,
    List<CategoryItem> categories,
    int month,
    int year,
  ) async {
    try {
      final pdf = pw.Document();
      final dateStr = DateFormat(
        'MMMM yyyy',
        'id_ID',
      ).format(DateTime(year, month));

      double totalIncome = 0;
      double totalExpense = 0;
      for (final tx in transactions) {
        if (tx.type == TransactionType.income) totalIncome += tx.amount;
        if (tx.type == TransactionType.expense) totalExpense += tx.amount;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Laporan ZenFlow',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(dateStr, style: pw.TextStyle(fontSize: 16)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text(
                      'Total Pemasukan',
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.green),
                    ),
                    pw.Text(
                      CurrencyFormat.convertToIdr(totalIncome),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text(
                      'Total Pengeluaran',
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.red),
                    ),
                    pw.Text(
                      CurrencyFormat.convertToIdr(totalExpense),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              data: <List<String>>[
                ['Tanggal', 'Kategori', 'Tipe', 'Nominal', 'Catatan'],
                ...transactions.map((tx) {
                  final date = DateFormat('dd MMM yyyy').format(tx.date);
                  final category = AppCategories.getCategoryById(
                    tx.categoryId,
                    categories,
                  );
                  final type = tx.type == TransactionType.income
                      ? 'Pemasukan'
                      : 'Pengeluaran';
                  final amount = CurrencyFormat.convertToIdr(tx.amount);
                  return [date, category.name, type, amount, tx.note];
                }),
              ],
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileDateStr = DateFormat('MMM_yyyy').format(DateTime(year, month));
      final filePath = '${dir.path}/Laporan_ZenFlow_$fileDateStr.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Keuangan ZenFlow $dateStr (PDF)');
    } catch (e) {
      throw Exception('Gagal mengekspor laporan PDF: $e');
    }
  }
}
