import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jamaa_frontend_mobile/core/models/transaction.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class ReceiptGenerator {
  static Future<void> downloadReceipt(BuildContext context, Transaction transaction) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Générer le PDF
      final pdf = await _generateReceiptPDF(transaction);
      
      // Fermer le dialog de chargement
      Navigator.of(context).pop();
      
      // Sauvegarder et partager le PDF
      await _savePDF(context, pdf, transaction);
      
    } catch (e) {
      // Fermer le dialog de chargement en cas d'erreur
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la génération du reçu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<pw.Document> _generateReceiptPDF(Transaction transaction) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(),
              
              pw.SizedBox(height: 30),
              
              // Titre
              pw.Center(
                child: pw.Text(
                  'REÇU DE TRANSACTION',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Informations de la transaction
              _buildTransactionInfo(transaction),
              
              pw.SizedBox(height: 20),
              
              // Détails
              _buildTransactionDetails(transaction),
              
              pw.Spacer(),
              
              // Pied de page
              _buildFooter(now),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'JAMAA',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Service de paiement multibanques',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.blue600,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionInfo(Transaction transaction) {
    final isCredit = transaction.amount > 0;
    
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Montant principal
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 15),
            decoration: pw.BoxDecoration(
              color: isCredit ? PdfColors.green50 : PdfColors.red50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                '${isCredit ? '+' : ''}${transaction.formattedAmount}',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: isCredit ? PdfColors.green800 : PdfColors.red800,
                ),
              ),
            ),
          ),
          
          pw.SizedBox(height: 15),
          
          // Statut
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: pw.BoxDecoration(
              color: transaction.status == TransactionStatus.success 
                  ? PdfColors.green100 
                  : PdfColors.red100,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              transaction.statusLabel,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: transaction.status == TransactionStatus.success 
                    ? PdfColors.green800 
                    : PdfColors.red800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionDetails(Transaction transaction) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DÉTAILS DE LA TRANSACTION',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        
        pw.SizedBox(height: 15),
        
        pw.Container(
          width: double.infinity,
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _buildTableRow('Type', transaction.typeLabel),
              _buildTableRow('Date', DateFormat('dd/MM/yyyy à HH:mm').format(transaction.createdAtOrDateEvent)),
              if (transaction.recipientName != null)
                _buildTableRow('Bénéficiaire', transaction.recipientName!),
              if (transaction.recipientPhone != null)
                _buildTableRow('Téléphone', transaction.recipientPhone!),
              if (transaction.bankName != null)
                _buildTableRow('Banque', transaction.bankName!),
              _buildTableRow('Description', transaction.description ?? 'Transaction ${transaction.typeLabel.toLowerCase()}'),
              _buildTableRow('Devise', transaction.currency),
              _buildTableRow('ID Transaction', transaction.transactionId),
              if (transaction.senderAccountNumber != null)
                _buildTableRow('Compte expéditeur', transaction.senderAccountNumber!),
              if (transaction.receiverAccountNumber != null)
                _buildTableRow('Compte destinataire', transaction.receiverAccountNumber!),
            ],
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey50,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(DateTime generatedAt) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey300,
        ),
        
        pw.SizedBox(height: 10),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(generatedAt)}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              'JAMAA - Service de paiement sécurisé',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _savePDF(BuildContext context, pw.Document pdf, Transaction transaction) async {
    try {
      // Obtenir le répertoire de téléchargement
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Demander permission pour Android
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('Impossible d\'accéder au répertoire de téléchargement');
      }

      // Créer le nom du fichier
      final fileName = 'recu_${transaction.transactionId.substring(0, 8)}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Sauvegarder le PDF
      await file.writeAsBytes(await pdf.save());
      
      // Partager le fichier
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reçu de transaction JAMAA',
      );
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reçu téléchargé: $fileName'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Partager',
            onPressed: () {
              Share.shareXFiles([XFile(file.path)]);
            },
          ),
        ),
      );
      
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }
}