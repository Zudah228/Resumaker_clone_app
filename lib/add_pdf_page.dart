import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:resumakerapp/pdf_view_page.dart';

import 'db/Resume.dart';

class AddPDFPage extends StatefulWidget {
  @override
  _AddPDFPageState createState() => _AddPDFPageState();
}

class CreatePdf {
  static Future<String> createPdfA4({Resume resume}) async {
    final pw.Document pdf = pw.Document();

    Future<dynamic> getFontData() async {
      final ByteData bytes = await rootBundle.load('assets/fonts/ipaexm.ttf');
      final Uint8List fontData = bytes.buffer.asUint8List();
      return pw.Font.ttf(fontData.buffer.asByteData());
    }

    final font = await getFontData();

    pdf.addPage(
        pw.MultiPage(
            margin: pw.EdgeInsets.symmetric(horizontal: 60.0, vertical: 50.0),
            pageFormat: PdfPageFormat.a4,
            orientation: pw.PageOrientation.portrait,
            header: (pw.Context context) {
              if (context.pageNumber == 0) {
                return null;
              }
                return pw.Container(
                  margin: const pw.EdgeInsets.only(
                      bottom: 3.0 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(
                      bottom: 3.0 * PdfPageFormat.mm),
                  decoration: const pw.BoxDecoration(
                      border: pw.BoxBorder(
                          bottom: true, width: 0.5, color: PdfColors.red)
                  ),
                  child: pw.Text(
                    'Portable Document Format',
                    style: pw.Theme
                        .of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.red),
                  ),
                );
            },
            build: (pw.Context context) => <pw.Widget>[
              pw.Container(
                child: pw.Text(resume.title, style: pw.TextStyle(font: font)),
              ),
              pw.Container(
                child: pw.Text(resume.name, style: pw.TextStyle(font: font)),
              ),
              pw.Container(
                child: pw.Text(resume.date.toString(), style: pw.TextStyle(font: font))
              )
            ],
        ),
    );
    Directory _temporaryDirectory = await getTemporaryDirectory();
    String temporaryDirectoryPath = _temporaryDirectory.path;
    String _filePath = '$temporaryDirectoryPath/resume.pdf';

    List<int> _pdfSaveData = pdf.save();
    File _file = File(_filePath);
    await _file.writeAsBytes(_pdfSaveData);

    return _filePath;

  }
}

class _AddPDFPageState extends State<AddPDFPage> {
  List<Resume> resume = [];
  TextEditingController txtController = TextEditingController();
  TextEditingController txtController2 = TextEditingController();

  DateTime _time = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _time,
        firstDate: new DateTime(1945),
        lastDate: new DateTime.now().add(new Duration(days: 360))
    );
    if(picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PDFを追加"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: txtController,
                    decoration: InputDecoration(
                      hintText: 'Title'
                    ),
                  ),
                  TextField(
                    controller: txtController2,
                      decoration: InputDecoration(
                          hintText: 'Name'
                      )
                  ),
                  Text((DateFormat.yMMMd()).format(_time)),
                  RaisedButton(
                    onPressed: () => _selectDate(context),child: Text('時間選択')
                  ),
                  RaisedButton(
                    child: Text("Create PDF"),
                    onPressed: () async{
                      Resume newResume = Resume(title: txtController.text, name: txtController2.text, date: _time);
                      resume.add(newResume);
                      String _filePath = await CreatePdf.createPdfA4(resume: newResume);
                      print(_filePath);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfViewPage(
                            filePath: _filePath,
                          ),
                        ),
                      );
                    },
                  )
                ]
            )
        )
    );
  }
}
