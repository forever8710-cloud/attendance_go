import 'dart:js_interop';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import '../data/worker_detail_repository.dart';

class WorkerAttendanceExcelExport {
  static void exportToExcel(
    List<WorkerMonthlyAttendanceRow> data,
    String workerName,
    String yearMonth,
  ) {
    final excel = Excel.createExcel();
    final sheetName = '근태현황_${workerName}_$yearMonth';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final dateFormat = DateFormat('yyyy-MM-dd (E)', 'ko');

    // 헤더 스타일
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E8EAF6'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // 헤더 행
    final headers = ['No.', '날짜', '출근', '퇴근', '근무시간', '상태', '적요'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // 컬럼 너비 설정
    sheet.setColumnWidth(0, 8);   // No.
    sheet.setColumnWidth(1, 18);  // 날짜
    sheet.setColumnWidth(2, 10);  // 출근
    sheet.setColumnWidth(3, 10);  // 퇴근
    sheet.setColumnWidth(4, 12);  // 근무시간
    sheet.setColumnWidth(5, 10);  // 상태
    sheet.setColumnWidth(6, 16);  // 적요

    // 데이터 행
    for (int i = 0; i < data.length; i++) {
      final r = data[i];
      final rowIdx = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
        .value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
        .value = TextCellValue(dateFormat.format(r.date));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
        .value = TextCellValue(r.checkIn);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
        .value = TextCellValue(r.checkOut);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
        .value = TextCellValue(r.workHours);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
        .value = TextCellValue(r.status);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIdx))
        .value = TextCellValue(r.note);
    }

    // 합계 행
    final sumRowIdx = data.length + 1;
    final boldStyle = CellStyle(bold: true);

    final workDays = data.where((r) => r.status == '출근' || r.status == '지각' || r.status == '조퇴').length;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: sumRowIdx))
      ..value = TextCellValue('합계')
      ..cellStyle = boldStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: sumRowIdx))
      ..value = TextCellValue('출근 ${workDays}일')
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
      ..download = '근태현황_${workerName}_$yearMonth.xlsx';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
