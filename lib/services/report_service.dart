import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../calculations.dart';
import '../models.dart';
import '../protection_models.dart';

class ReportService {
  const ReportService._();

  static Future<Uint8List> buildCoordinatedReport({
    required CableDesignResult cable,
    required TransformerDesignResult transformer,
    required ProtectionDesignResult protection,
  }) async {
    final pdf = pw.Document(
      title: 'Auto MV Cable & TX Sizing Pro — Preliminary Design Report',
      author: 'AiZahid',
      subject: 'MV cable and transformer coordinated preliminary design',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 10),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColor(0.7608, 0.0941, 0.3569), width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              const pw.Text(
                'AUTO MV CABLE & TX SIZING PRO',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor(0.5333, 0.0549, 0.3098),
                ),
              ),
              const pw.Text('MVTX-CALC-V1'),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
        ),
        build: (context) => [
          const pw.SizedBox(height: 12),
          const pw.Text(
            'Coordinated MV Cable and Transformer Preliminary Design',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          const pw.SizedBox(height: 8),
          const pw.Container(
            padding: pw.EdgeInsets.all(10),
            color: PdfColor(1.0, 0.9176, 0.9529),
            child: pw.Text(
              'Engineering design aid only. Verify exact manufacturer data, utility fault level, cable screen bonding, protection clearing time, TNB/ST requirements and project-specific studies before final issue.',
            ),
          ),
          const pw.SizedBox(height: 16),
          _heading('Transformer selection'),
          _table([
            ['Selected transformer', transformer.transformer.shortLabel],
            ['Design demand', '${transformer.designDemandKva.toStringAsFixed(2)} kVA'],
            ['Normal loading', '${transformer.normalLoadingPercent.toStringAsFixed(2)} %'],
            ['MV full-load current', '${transformer.primaryCurrentA.toStringAsFixed(2)} A'],
            ['Approx. LV terminal fault', '${transformer.approxFaultCurrentKa.toStringAsFixed(2)} kA'],
            ['Status', transformer.status.label],
          ]),
          const pw.SizedBox(height: 16),
          _heading('MV cable selection'),
          _table([
            ['Selected cable', cable.cable.shortLabel],
            ['Voltage designation', cable.cable.voltageDesignation],
            ['Design current', '${cable.designCurrentA.toStringAsFixed(2)} A'],
            ['Derated ampacity', '${cable.deratedAmpacityA.toStringAsFixed(2)} A'],
            ['Voltage drop', '${cable.voltageDropPercent.toStringAsFixed(3)} %'],
            ['Conductor withstand', '${cable.shortCircuitWithstandKa.toStringAsFixed(2)} kA'],
            ['Charging current', '${cable.chargingCurrentA.toStringAsFixed(3)} A'],
            ['Status', cable.status.label],
          ]),
          const pw.SizedBox(height: 16),
          _heading('Protection and switchgear selection'),
          _table([
            ['Preferred MV protection', protection.preferredMvDevice],
            ['VCB requirement', '${protection.vcbRatedVoltageKv.toStringAsFixed(1)} kV / ${protection.vcbRatedCurrentA.toStringAsFixed(0)} A / ${protection.vcbBreakingCurrentKa.toStringAsFixed(1)} kA'],
            ['MV fuse starting point', '${protection.fuseCurrentA.toStringAsFixed(1)} A'],
            ['Protection CT', protection.ctRatio],
            ['LV ACB frame / sensor', '${protection.acbFrameA.toStringAsFixed(0)} A / ${protection.acbSensorA.toStringAsFixed(0)} A'],
            ['LV ACB breaking duty', 'Icu >= ${protection.acbBreakingCurrentKa.toStringAsFixed(1)} kA'],
            ['ACB long/short pickup', '${protection.longTimePickupA.toStringAsFixed(0)} A / ${protection.shortTimePickupA.toStringAsFixed(0)} A'],
            ['ACB instantaneous', protection.instantaneousPickupA == null ? 'OFF / project review' : '${protection.instantaneousPickupA!.toStringAsFixed(0)} A'],
            ['Protection status', protection.status.label],
          ]),
          const pw.SizedBox(height: 10),
          _heading('Recommended relay functions'),
          ...protection.relayFunctions.map((item) => pw.Bullet(text: item)),
          const pw.SizedBox(height: 16),
          _heading('Required verification'),
          pw.Bullet(text: 'Exact manufacturer cable and transformer datasheets or nameplates.'),
          pw.Bullet(text: 'IEC 60287 current-rating study and project installation conditions.'),
          pw.Bullet(text: 'IEC 60909 short-circuit study including upstream and motor contribution.'),
          pw.Bullet(text: 'MV cable screen bonding, sheath-voltage and screen earth-fault duty.'),
          pw.Bullet(text: 'Protection grading, breaker duty and TNB/ST/project requirements.'),
          pw.Bullet(text: 'Exact VCB, fuse and ACB models including Icu, Ics, Icw, type-tested panel ratings and accessories.'),
          pw.Bullet(text: 'CT ratio, class, burden, ALF/knee point, lead resistance and saturation for OC/EF/differential/REF.'),
          pw.Bullet(text: 'Transformer inrush, minimum/maximum fault, relay curves, LSIG settings and manufacturer selectivity tables.'),
        ],
      ),
    );
    return pdf.save();
  }

  static Future<void> previewCoordinatedReport({
    required CableDesignResult cable,
    required TransformerDesignResult transformer,
    required ProtectionDesignResult protection,
  }) async {
    await Printing.layoutPdf(
      name: 'Auto_MV_Cable_TX_Preliminary_Report.pdf',
      onLayout: (_) => buildCoordinatedReport(
        cable: cable,
        transformer: transformer,
        protection: protection,
      ),
    );
  }

  static pw.Widget _heading(String text) => pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor(0.7608, 0.0941, 0.3569),
        ),
      );

  static pw.Widget _table(List<List<String>> rows) => pw.TableHelper.fromTextArray(
        headers: const ['Item', 'Value'],
        data: rows,
        headerStyle: const pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColor(0.7608, 0.0941, 0.3569)),
        cellPadding: const pw.EdgeInsets.all(7),
        columnWidths: {
          0: const pw.FlexColumnWidth(1.2),
          1: const pw.FlexColumnWidth(2.2),
        },
      );
}
