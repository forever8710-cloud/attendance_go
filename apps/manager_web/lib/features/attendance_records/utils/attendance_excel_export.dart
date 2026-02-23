import 'dart:js_interop';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import '../data/attendance_records_repository.dart';

class AttendanceExcelExport {
  static void exportToExcel(List<AttendanceRecordRow> data, String dateRangeLabel) {
    final excel = Excel.createExcel();
    final sheetName = '근태현황_$dateRangeLabel';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final dateFormat = DateFormat('yyyy-MM-dd');

    // 헤더 스타일
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8EAF6'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // 헤더 행
    final headers = ['No.', '날짜', '성명', '직위', '직무', '사업장', '출근', '퇴근', '근무시간', '상태'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // 컬럼 너비 설정
    sheet.setColumnWidth(0, 8);   // No.
    sheet.setColumnWidth(1, 14);  // 날짜
    sheet.setColumnWidth(2, 12);  // 성명
    sheet.setColumnWidth(3, 10);  // 직위
    sheet.setColumnWidth(4, 14);  // 직무
    sheet.setColumnWidth(5, 12);  // 사업장
    sheet.setColumnWidth(6, 10);  // 출근
    sheet.setColumnWidth(7, 10);  // 퇴근
    sheet.setColumnWidth(8, 12);  // 근무시간
    sheet.setColumnWidth(9, 10);  // 상태

    // 데이터 행
    for (int i = 0; i < data.length; i++) {
      final r = data[i];
      final rowIdx = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
        .value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
        .value = TextCellValue(dateFormat.format(r.date));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
        .value = TextCellValue(r.workerName);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
        .value = TextCellValue(r.position);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
        .value = TextCellValue(r.job);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
        .value = TextCellValue(r.site);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx))
        .value = TextCellValue(r.checkInTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIdx))
        .value = TextCellValue(r.checkOutTime);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIdx))
        .value = TextCellValue(r.workHours);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIdx))
        .value = TextCellValue(r.status);
    }

    // 합계 행
    final sumRowIdx = data.length + 1;
    final boldStyle = CellStyle(bold: true);

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: sumRowIdx))
      ..value = TextCellValue('합계')
      ..cellStyle = boldStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: sumRowIdx))
      ..value = TextCellValue('${data.length}건')
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
      ..download = '근태현황_$dateRangeLabel.xlsx';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
