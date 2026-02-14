import 'dart:js_interop';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import '../data/payroll_repository.dart';

class PayrollExcelExport {
  static void exportToExcel(List<PayrollRow> data, String yearMonth) {
    final excel = Excel.createExcel();
    final sheetName = '급여대장_$yearMonth';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final numberFormat = NumberFormat('#,###');

    // 헤더 스타일
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8EAF6'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // 헤더 행
    final headers = ['No.', '성명', '파트', '출근일수', '총 근무시간', '시급', '기본급', '총 급여'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // 컬럼 너비 설정
    sheet.setColumnWidth(0, 8);   // No.
    sheet.setColumnWidth(1, 15);  // 성명
    sheet.setColumnWidth(2, 18);  // 파트
    sheet.setColumnWidth(3, 12);  // 출근일수
    sheet.setColumnWidth(4, 14);  // 총 근무시간
    sheet.setColumnWidth(5, 12);  // 시급
    sheet.setColumnWidth(6, 15);  // 기본급
    sheet.setColumnWidth(7, 18);  // 총 급여

    // 데이터 행
    for (int i = 0; i < data.length; i++) {
      final r = data[i];
      final rowIdx = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
        .value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
        .value = TextCellValue(r.name);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
        .value = TextCellValue(r.part);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
        .value = IntCellValue(r.workDays);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
        .value = DoubleCellValue(r.totalHours);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
        .value = TextCellValue('${numberFormat.format(r.hourlyWage)}원');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx))
        .value = TextCellValue('${numberFormat.format(r.baseSalary)}원');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIdx))
        .value = TextCellValue('${numberFormat.format(r.totalSalary)}원');
    }

    // 합계 행
    final sumRowIdx = data.length + 1;
    final boldStyle = CellStyle(bold: true);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: sumRowIdx))
      ..value = TextCellValue('합계')
      ..cellStyle = boldStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: sumRowIdx))
      ..value = IntCellValue(data.fold<int>(0, (sum, r) => sum + r.workDays))
      ..cellStyle = boldStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: sumRowIdx))
      ..value = DoubleCellValue(data.fold<double>(0, (sum, r) => sum + r.totalHours))
      ..cellStyle = boldStyle;
    final totalSalary = data.fold<int>(0, (sum, r) => sum + r.totalSalary);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: sumRowIdx))
      ..value = TextCellValue('${numberFormat.format(totalSalary)}원')
      ..cellStyle = boldStyle;

    // 파일 생성 & 브라우저 다운로드
    final bytes = excel.save();
    if (bytes == null) return;

    final uint8 = Uint8List.fromList(bytes);
    final blob = web.Blob(
      [uint8.toJS].toJS,
      web.BlobPropertyBag(type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = '급여대장_$yearMonth.xlsx';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
