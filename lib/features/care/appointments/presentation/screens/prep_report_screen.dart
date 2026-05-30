import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/user_session.dart';
import '../../../../../data/demo_reports.dart';

class PrepReportScreen extends StatefulWidget {
  const PrepReportScreen({super.key});
  @override
  State<PrepReportScreen> createState() => _PrepReportScreenState();
}

class _PrepReportScreenState extends State<PrepReportScreen> {
  bool _generating = false;

  DemoReport _report() {
    final name = UserSession().name;
    return demoReports.firstWhere(
      (r) => r.patientName == name,
      orElse: () => demoReports.first,
    );
  }

  // ── Share / print sheet ───────────────────────────────────────────────────────

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: RColors.sand200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: RColors.teal50, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.print_rounded,
                    color: RColors.teal700, size: 20),
              ),
              title: const Text('Print / Save as PDF',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: RColors.sand950)),
              subtitle: const Text('Opens system print dialog',
                  style: TextStyle(fontSize: 11, color: RColors.sand400)),
              onTap: () {
                Navigator.pop(ctx);
                _generateAndPrint();
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: RColors.plum100, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.ios_share_rounded,
                    color: RColors.plum700, size: 20),
              ),
              title: const Text('Share PDF file',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: RColors.sand950)),
              subtitle: const Text('Send via email, WhatsApp, etc.',
                  style: TextStyle(fontSize: 11, color: RColors.sand400)),
              onTap: () {
                Navigator.pop(ctx);
                _generateAndShare();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndPrint() async {
    setState(() => _generating = true);
    try {
      final r = _report();
      final pdf = await _buildPdf(r);
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'rehlah_prep_${r.patientName.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _generateAndShare() async {
    setState(() => _generating = true);
    try {
      final r = _report();
      final pdf = await _buildPdf(r);
      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'rehlah_prep_${r.patientName.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  // ── PDF builder ───────────────────────────────────────────────────────────────

  Future<pw.Document> _buildPdf(DemoReport r) async {
    final doc = pw.Document(
      title: 'Rehlah Prep Report — ${r.patientName}',
      author: 'Rehlah',
    );

    final cTeal    = PdfColor.fromHex('#275350');
    final cSand900 = PdfColor.fromHex('#231E16');
    final cSand700 = PdfColor.fromHex('#4F473C');
    final cSand500 = PdfColor.fromHex('#7E7468');
    final cSand200 = PdfColor.fromHex('#E6E1D7');
    final cClay    = PdfColor.fromHex('#C76F47');
    final cClay100 = PdfColor.fromHex('#FAEAE0');
    final cSaffron    = PdfColor.fromHex('#D4A258');
    final cSaffron100 = PdfColor.fromHex('#FAF1DE');
    final cSage    = PdfColor.fromHex('#7CA773');
    final cSage100 = PdfColor.fromHex('#E8F1E5');
    final cPlum    = PdfColor.fromHex('#5B4276');
    final cPlum100 = PdfColor.fromHex('#EDE3EE');

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
      header: (ctx) => pw.Column(children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('REHLAH',
                style: pw.TextStyle(
                    fontSize: 10,
                    color: cTeal,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5)),
            pw.Text('Pre-Consultation Clinical Summary',
                style: pw.TextStyle(fontSize: 9, color: cSand500)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: cSand200, thickness: 0.5),
        pw.SizedBox(height: 2),
      ]),
      footer: (ctx) => pw.Column(children: [
        pw.SizedBox(height: 4),
        pw.Divider(color: cSand200, thickness: 0.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Confidential — For care team use only',
                style: pw.TextStyle(fontSize: 7, color: cSand500)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 7, color: cSand500)),
          ],
        ),
      ]),
      build: (ctx) {
        final w = <pw.Widget>[];

        // Patient header block
        w.add(pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: cSand200, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(r.patientName,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: cSand900)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                        color: cPlum100,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4))),
                    child: pw.Text(r.protocol,
                        style: pw.TextStyle(
                            fontSize: 9,
                            color: cPlum,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(r.diagnosis,
                  style: pw.TextStyle(fontSize: 10, color: cSand500)),
              pw.SizedBox(height: 6),
              pw.Text(
                  '${r.cycleLabel} · Day ${r.daysSinceInfusion} since infusion',
                  style: pw.TextStyle(fontSize: 11, color: cSand700)),
              pw.Text(r.phaseEnglish,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: cSand900)),
              pw.SizedBox(height: 6),
              pw.Row(children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: r.nadirActive ? cClay100 : cSage100,
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(
                    r.nadirActive
                        ? 'Nadir Active'
                        : 'Nadir window: ${r.nadirWindow}',
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: r.nadirActive ? cClay : cSage),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'Check-ins: ${r.checkinsCompleted}/${r.checkinsTotalDays} days '
                  '(${(r.checkinsCompleted / r.checkinsTotalDays * 100).round()}%)',
                  style: pw.TextStyle(fontSize: 9, color: cSand700),
                ),
              ]),
              pw.SizedBox(height: 4),
              pw.Text(r.appointmentLabel,
                  style: pw.TextStyle(fontSize: 9, color: cSand500)),
            ],
          ),
        ));
        w.add(pw.SizedBox(height: 16));

        // Section 1
        w.add(_pdfSection('1 — PROTOCOL CONTEXT', cTeal, cSand200));
        w.add(pw.Text(r.protocolContext,
            style: pw.TextStyle(fontSize: 11, color: cSand700)));
        w.add(pw.SizedBox(height: 14));

        // Section 2
        w.add(_pdfSection('2 — SYMPTOM SUMMARY', cTeal, cSand200));
        w.add(pw.Text(r.symptomSummary,
            style: pw.TextStyle(fontSize: 11, color: cSand700)));
        w.add(pw.SizedBox(height: 14));

        // Section 3
        w.add(_pdfSection('3 — THRESHOLD ALERTS', cTeal, cSand200));
        for (final a in r.alerts) {
          final bg  = a.level == 'HIGH' ? cClay100 : a.level == 'MODERATE' ? cSaffron100 : cSage100;
          final fg  = a.level == 'HIGH' ? cClay    : a.level == 'MODERATE' ? cSaffron    : cSage;
          final lbl = a.level == 'HIGH' ? 'HIGH'   : a.level == 'MODERATE' ? 'MODERATE'  : 'STABLE';
          w.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: pw.BoxDecoration(
              color: bg,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              border: pw.Border(left: pw.BorderSide(color: fg, width: 3)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                      color: fg,
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(3))),
                  child: pw.Text(lbl,
                      style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(a.symptom,
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: cSand900)),
                      pw.SizedBox(height: 3),
                      pw.Text(a.detail,
                          style:
                              pw.TextStyle(fontSize: 10, color: cSand700)),
                    ],
                  ),
                ),
              ],
            ),
          ));
        }
        w.add(pw.SizedBox(height: 8));

        // Section 4
        w.add(_pdfSection('4 — MEDICATION ADHERENCE', cTeal, cSand200));
        for (final m in r.medications) {
          final pct = m.totalDays > 0 ? m.takenDays / m.totalDays : 0.0;
          final pctInt = (pct * 100).round();
          final barColor =
              pct >= 0.8 ? cSage : pct >= 0.6 ? cSaffron : cClay;
          w.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cSand200, width: 0.5),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(m.name,
                        style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: cSand900)),
                    pw.Text(
                        '$pctInt%  (${m.takenDays}/${m.totalDays} days)',
                        style: pw.TextStyle(
                            fontSize: 10,
                            color: barColor,
                            fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                if (m.missedDates.isNotEmpty ||
                    m.missedReason.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    [
                      if (m.missedDates.isNotEmpty)
                        'Missed: ${m.missedDates.join(', ')}',
                      if (m.missedReason.isNotEmpty) m.missedReason,
                    ].join(' · '),
                    style: pw.TextStyle(fontSize: 9, color: cSand500),
                  ),
                ],
                if (m.refillAlert != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('! ${m.refillAlert}',
                      style: pw.TextStyle(fontSize: 9, color: cClay)),
                ],
              ],
            ),
          ));
        }
        w.add(pw.SizedBox(height: 8));

        // Section 5
        w.add(_pdfSection('5 — LAB CORRELATION', cTeal, cSand200));
        for (final l in r.labs) {
          final sc =
              l.status == 'LOW' ? cClay : l.status == 'HIGH' ? cSaffron : cSage;
          final sl =
              l.status == 'LOW' ? 'LOW' : l.status == 'HIGH' ? 'HIGH' : 'NORMAL';
          w.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 6),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cSand200, width: 0.5),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(l.testName,
                            style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: cSand900)),
                        pw.Text(l.uploadDate,
                            style: pw.TextStyle(
                                fontSize: 9, color: cSand500)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                          color: sc,
                          borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(3))),
                      child: pw.Text(sl,
                          style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text('${l.value}   |   Normal: ${l.normalRange}',
                    style: pw.TextStyle(fontSize: 10, color: cSand700)),
                pw.SizedBox(height: 3),
                pw.Text(l.clinicalNote,
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: cSand500,
                        fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ));
        }
        w.add(pw.SizedBox(height: 8));

        // Section 6
        w.add(_pdfSection(
            '6 — TALKING POINTS FOR THE ONCOLOGIST', cTeal, cSand200));
        w.add(pw.Text(
          'Generated from 14-day patient data · Protocol-aware · Phase-specific',
          style: pw.TextStyle(
              fontSize: 8,
              color: cSand500,
              fontStyle: pw.FontStyle.italic),
        ));
        w.add(pw.SizedBox(height: 8));
        for (final t in r.talkingPoints) {
          final fb = t.flagLevel == 'HIGH'
              ? cClay
              : t.flagLevel == 'MODERATE'
                  ? cSaffron100
                  : cSage;
          final ff =
              t.flagLevel == 'MODERATE' ? cSaffron : PdfColors.white;
          final fl = t.flagLevel == 'HIGH'
              ? 'HIGH — Clinically unexpected'
              : t.flagLevel == 'MODERATE'
                  ? 'MODERATE — Monitor closely'
                  : 'STABLE — Within expected range';
          w.add(pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: cSand200, width: 0.5),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                      color: fb,
                      borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4))),
                  child: pw.Text(fl,
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: ff,
                          fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 8),
                pw.Text(t.english,
                    style:
                        pw.TextStyle(fontSize: 11, color: cSand900)),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
                  decoration: pw.BoxDecoration(
                    color: cPlum100,
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4)),
                    border:
                        pw.Border(left: pw.BorderSide(color: cPlum, width: 3)),
                  ),
                  child: pw.Row(children: [
                    pw.Text('Action  ',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: cPlum)),
                    pw.Expanded(
                      child: pw.Text(t.checklistItem,
                          style: pw.TextStyle(
                              fontSize: 10, color: cSand900)),
                    ),
                  ]),
                ),
              ],
            ),
          ));
        }

        // Section 7 — Cardiovascular readiness
        final vitals = UserSession().vitals;
        if (vitals.isNotEmpty) {
          w.add(pw.SizedBox(height: 8));
          w.add(_pdfSection('7 — CARDIOVASCULAR READINESS', cTeal, cSand200));

          final latest = vitals.last;
          final cardioRows = <List<String>>[];
          if (latest.temperatureCelsius != null) {
            final f = latest.tempFlag;
            cardioRows.add([
              'Temperature',
              '${latest.temperatureCelsius!.toStringAsFixed(1)} °C',
              f == VitalFlag.high ? 'HIGH' : f == VitalFlag.moderate ? 'MODERATE' : 'STABLE',
            ]);
          }
          if (latest.systolicBp != null && latest.diastolicBp != null) {
            final f = latest.bpFlag;
            cardioRows.add([
              'Blood pressure',
              '${latest.systolicBp}/${latest.diastolicBp} mmHg',
              f == VitalFlag.high ? 'HIGH' : f == VitalFlag.moderate ? 'MODERATE' : 'STABLE',
            ]);
          }
          if (latest.heartRateBpm != null) {
            final f = latest.hrFlag;
            cardioRows.add([
              'Heart rate',
              '${latest.heartRateBpm} bpm',
              f == VitalFlag.high ? 'HIGH' : f == VitalFlag.moderate ? 'MODERATE' : 'STABLE',
            ]);
          }
          if (latest.spo2Pct != null) {
            final f = latest.spo2Flag;
            cardioRows.add([
              'SpO₂',
              '${latest.spo2Pct}%',
              f == VitalFlag.high ? 'HIGH' : f == VitalFlag.moderate ? 'MODERATE' : 'STABLE',
            ]);
          }
          if (latest.glucoseMmol != null) {
            final f = latest.glucoseFlag;
            cardioRows.add([
              'Blood glucose',
              '${latest.glucoseMmol!.toStringAsFixed(1)} mmol/L',
              f == VitalFlag.high ? 'HIGH' : f == VitalFlag.moderate ? 'MODERATE' : 'STABLE',
            ]);
          }
          if (latest.weightKg != null) {
            cardioRows.add(['Weight', '${latest.weightKg!.toStringAsFixed(1)} kg', 'STABLE']);
          }

          for (final row in cardioRows) {
            final statusColor = row[2] == 'HIGH' ? cClay
                : row[2] == 'MODERATE' ? cSaffron
                : cSage;
            final statusBg = row[2] == 'HIGH' ? cClay100
                : row[2] == 'MODERATE' ? cSaffron100
                : cSage100;
            w.add(pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 5),
              padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cSand200, width: 0.5),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(row[0],
                      style: pw.TextStyle(fontSize: 10, color: cSand700)),
                  pw.Row(children: [
                    pw.Text(row[1],
                        style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: cSand900)),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: pw.BoxDecoration(
                          color: statusBg,
                          borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(3))),
                      child: pw.Text(row[2],
                          style: pw.TextStyle(
                              fontSize: 8,
                              color: statusColor,
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
            ));
          }
          w.add(pw.SizedBox(height: 4));
        }

        // Bilingual note
        w.add(pw.SizedBox(height: 8));
        w.add(pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: cPlum100,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            'Arabic bilingual version available in the Rehlah app.',
            style: pw.TextStyle(fontSize: 9, color: cPlum),
          ),
        ));

        return w;
      },
    ));

    return doc;
  }

  static pw.Widget _pdfSection(
      String title, PdfColor color, PdfColor divColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: pw.FontWeight.bold,
                color: color)),
        pw.Divider(color: divColor, thickness: 0.5),
        pw.SizedBox(height: 6),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = _report();
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _headerCard(r),
                  _sectionHeader(
                    'Section 1 — Protocol Context',
                    'السياق السريري للبروتوكول',
                  ),
                  _textBlock(r.protocolContext, r.protocolContextArabic),
                  _sectionHeader(
                    'Section 2 — Symptom Summary',
                    'ملخص الأعراض — ما هو غير متوقع فقط',
                  ),
                  _textBlock(r.symptomSummary, r.symptomSummaryArabic),
                  _sectionHeader(
                    'Section 3 — Threshold Alerts',
                    'تنبيهات العتبة السريرية',
                  ),
                  ...r.alerts.map(_alertCard),
                  _sectionHeader(
                    'Section 4 — Medication Adherence',
                    'الالتزام الدوائي',
                  ),
                  ...r.medications.map(_medRow),
                  _sectionHeader(
                    'Section 5 — Lab Correlation',
                    'ربط نتائج التحاليل',
                  ),
                  ...r.labs.map(_labCard),
                  _sectionHeader(
                    'Section 6 — Talking Points for the Oncologist',
                    'نقاط النقاش مع طبيبتكِ — ما قبل الاستشارة',
                  ),
                  _section6Note(),
                  ...r.talkingPoints.map(_talkingPointCard),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _footer(context),
        ]),
      ),
    );
  }

  // ── Topbar ────────────────────────────────────────────────────────────────────

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop()
                ? context.pop()
                : context.go('/care/appointments')),
        const Expanded(
            child: Center(
                child: Text('Prep report',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2)))),
        _iconBtn(Icons.ios_share_rounded, onTap: _showShareSheet),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: RColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RColors.sand200),
        ),
        child: Icon(icon, color: RColors.sand700, size: 20),
      ),
    );
  }

  // ── Footer button ─────────────────────────────────────────────────────────────

  Widget _footer(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        border: Border(top: BorderSide(color: RColors.sand200, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: _generating
          ? const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: RColors.teal700,
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: _showShareSheet,
              child: Container(
                height: 48,
                decoration: const BoxDecoration(
                  color: RColors.teal700,
                  borderRadius: RRadius.pillBR,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Share / Print Report',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Header card ───────────────────────────────────────────────────────────────

  Widget _headerCard(DemoReport r) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(r.patientName,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: RColors.sand950)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: const BoxDecoration(
                  color: RColors.plum100, borderRadius: RRadius.pillBR),
              child: Text(r.protocol,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: RColors.plum700)),
            ),
          ]),
          const SizedBox(height: 2),
          Text(r.diagnosis,
              style:
                  const TextStyle(fontSize: 11, color: RColors.sand500)),
          const SizedBox(height: 6),
          Text(
              '${r.cycleLabel} · Day ${r.daysSinceInfusion} since infusion',
              style: const TextStyle(
                  fontSize: 12, color: RColors.sand700, height: 1.4)),
          const SizedBox(height: 2),
          Text(r.phaseEnglish,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: RColors.sand900)),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(r.phaseArabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 11, color: RColors.plum500, height: 1.4)),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: r.nadirActive
                  ? RColors.clay100
                  : RColors.sand100,
              borderRadius: RRadius.pillBR,
            ),
            child: Text(
              r.nadirActive
                  ? '⚠ Nadir Active'
                  : 'Nadir window: ${r.nadirWindow}',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: r.nadirActive
                      ? RColors.clay700
                      : RColors.sand500),
            ),
          ),
          const SizedBox(height: 10),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${r.checkinsCompleted} of ${r.checkinsTotalDays} days',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: RColors.sand700)),
                Text(
                  '${(r.checkinsCompleted / r.checkinsTotalDays * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: RColors.teal700),
                ),
              ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: r.checkinsCompleted / r.checkinsTotalDays,
              minHeight: 4,
              backgroundColor: RColors.sand200,
              valueColor:
                  const AlwaysStoppedAnimation(RColors.teal500),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 12, color: RColors.sand400),
            const SizedBox(width: 5),
            Text(r.appointmentLabel,
                style: const TextStyle(
                    fontSize: 11, color: RColors.sand500)),
          ]),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, String arabicSubtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: RColors.sand700)),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(arabicSubtitle,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 10,
                    color: RColors.plum500,
                    height: 1.3)),
          ),
        ],
      ),
    );
  }

  // ── Text block (Sections 1 & 2) ───────────────────────────────────────────────

  Widget _textBlock(String english, String arabic) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(english,
              style: const TextStyle(
                  fontSize: 13,
                  color: RColors.sand900,
                  height: 1.6)),
          const Divider(height: 20, color: RColors.sand200),
          Align(
            alignment: Alignment.centerRight,
            child: Text(arabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 13,
                    color: RColors.sand900,
                    height: 1.7)),
          ),
        ],
      ),
    );
  }

  // ── Alert card (Section 3) ────────────────────────────────────────────────────

  Widget _alertCard(DemoAlert alert) {
    final (bg, leftColor, badgeBg, badgeFg, badgeLabel) =
        switch (alert.level) {
      'HIGH' => (
          RColors.clay100,
          RColors.clay500,
          RColors.clay500,
          Colors.white,
          '🔴 HIGH'
        ),
      'MODERATE' => (
          RColors.saffron100,
          RColors.saffron500,
          RColors.saffron300,
          RColors.saffron700,
          '🟡 MODERATE'
        ),
      _ => (
          RColors.sage100,
          RColors.sage500,
          RColors.sage500,
          Colors.white,
          '✅ STABLE'
        ),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RRadius.mdBR,
        border: Border(left: BorderSide(color: leftColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: badgeBg, borderRadius: RRadius.pillBR),
              child: Text(badgeLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badgeFg)),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Text(alert.symptom,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: RColors.sand950))),
          ]),
          const SizedBox(height: 6),
          Text(alert.detail,
              style: const TextStyle(
                  fontSize: 12, color: RColors.sand700, height: 1.5)),
        ],
      ),
    );
  }

  // ── Medication row (Section 4) ────────────────────────────────────────────────

  Widget _medRow(DemoMedication med) {
    final pct = med.totalDays > 0 ? med.takenDays / med.totalDays : 0.0;
    final pctInt = (pct * 100).round();
    final barColor = pct >= 0.8
        ? RColors.sage500
        : pct >= 0.6
            ? RColors.saffron500
            : RColors.clay500;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(med.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: RColors.sand950))),
            Text('$pctInt%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: barColor)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: RColors.sand200,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (med.missedDates.isNotEmpty ||
              med.missedReason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (med.missedDates.isNotEmpty)
                  'Missed: ${med.missedDates.join(', ')}',
                if (med.missedReason.isNotEmpty) med.missedReason,
              ].join(' · '),
              style: const TextStyle(
                  fontSize: 11,
                  color: RColors.sand400,
                  height: 1.4),
            ),
          ],
          if (med.refillAlert != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: const BoxDecoration(
                  color: RColors.clay100,
                  borderRadius: RRadius.pillBR),
              child: Text(med.refillAlert!,
                  style: const TextStyle(
                      fontSize: 10,
                      color: RColors.clay700,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }

  // ── Lab card (Section 5) ──────────────────────────────────────────────────────

  Widget _labCard(DemoLab lab) {
    final (statusBg, statusFg, statusLabel) = switch (lab.status) {
      'LOW' => (RColors.clay100, RColors.clay700, 'LOW'),
      'HIGH' => (RColors.saffron100, RColors.saffron700, 'HIGH'),
      _ => (RColors.sage100, RColors.sage700, 'NORMAL'),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lab.testName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: RColors.sand950)),
                Text(lab.uploadDate,
                    style: const TextStyle(
                        fontSize: 10, color: RColors.sand400)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: RRadius.pillBR),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusFg)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Text(lab.value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: RColors.sand900)),
            const SizedBox(width: 8),
            Text('Normal: ${lab.normalRange}',
                style: const TextStyle(
                    fontSize: 11, color: RColors.sand400)),
          ]),
          const SizedBox(height: 6),
          Text(lab.clinicalNote,
              style: const TextStyle(
                  fontSize: 12,
                  color: RColors.sand500,
                  height: 1.5,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // ── Section 6 note ────────────────────────────────────────────────────────────

  Widget _section6Note() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        'Generated from 14-day patient data · Protocol-aware · Phase-specific',
        style: TextStyle(
            fontSize: 10.5,
            color: RColors.sand400,
            fontStyle: FontStyle.italic),
      ),
    );
  }

  // ── Talking point card (Section 6) ───────────────────────────────────────────

  Widget _talkingPointCard(DemoTalkingPoint point) {
    final flag = point.flagLevel;
    final (badgeBg, badgeFg, badgeLabel) = switch (flag) {
      'HIGH' => (
          RColors.clay500,
          Colors.white,
          '🔴 HIGH — Clinically unexpected'
        ),
      'MODERATE' => (
          RColors.saffron300,
          RColors.saffron700,
          '🟡 MODERATE — Monitor closely'
        ),
      _ => (
          RColors.sage500,
          Colors.white,
          '✅ STABLE — Within expected range'
        ),
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: badgeBg, borderRadius: RRadius.pillBR),
            child: Text(badgeLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeFg)),
          ),
          const SizedBox(height: 10),
          Text(point.english,
              style: const TextStyle(
                  fontSize: 13, color: RColors.sand900, height: 1.6)),
          const Divider(height: 20, color: RColors.sand200),
          Align(
            alignment: Alignment.centerRight,
            child: Text(point.arabic,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 13,
                    color: RColors.sand900,
                    height: 1.7)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: RColors.plum100,
              borderRadius: RRadius.smBR,
              border: Border(
                  left: BorderSide(color: RColors.plum500, width: 3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('→ Action',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: RColors.plum700)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(point.checklistItem,
                        style: const TextStyle(
                            fontSize: 12,
                            color: RColors.sand900,
                            height: 1.4))),
              ],
            ),
          ),
          if (point.patientWordsUsed) ...[
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('بكلمات المريضة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 10,
                      color: RColors.plum500,
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}
