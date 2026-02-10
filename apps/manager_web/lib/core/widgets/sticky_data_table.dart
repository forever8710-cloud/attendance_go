import 'dart:math';
import 'package:flutter/material.dart';

/// 테이블 컬럼 정의
class TableColumnDef {
  final String label;
  final double width;
  final bool numeric;
  final VoidCallback? onSort;
  final bool? sortAscending; // null=정렬안함, true=오름차순, false=내림차순

  const TableColumnDef({
    required this.label,
    required this.width,
    this.numeric = false,
    this.onSort,
    this.sortAscending,
  });

  /// 컬럼 리스트의 전체 너비 (좌우 패딩 + Card 보더 포함)
  static double totalWidth(List<TableColumnDef> columns) =>
      columns.fold<double>(0, (sum, col) => sum + col.width) + 34;
}

/// 고정 헤더 + 스크롤 바디 테이블 위젯
///
/// 부모가 반드시 bounded height + bounded width를 제공해야 함.
/// [wrapWithCard]로 감싸면 Card + 너비 자동 조정까지 처리.
class StickyHeaderTable extends StatelessWidget {
  final List<TableColumnDef> columns;
  final int rowCount;
  final Widget Function(int columnIndex, int rowIndex) cellBuilder;
  final void Function(int rowIndex)? onRowTap;
  final bool Function(int rowIndex)? isRowSelected;
  final Color? Function(int rowIndex)? rowColorBuilder;
  final String? emptyMessage;

  const StickyHeaderTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
    this.onRowTap,
    this.isRowSelected,
    this.rowColorBuilder,
    this.emptyMessage,
  });

  /// Card로 감싼 StickyHeaderTable을 반환 (너비를 컬럼에 맞게 자동 조정)
  /// 부모가 bounded height를 제공해야 함 (Expanded 등)
  static Widget wrapWithCard({
    required List<TableColumnDef> columns,
    required int rowCount,
    required Widget Function(int columnIndex, int rowIndex) cellBuilder,
    void Function(int rowIndex)? onRowTap,
    bool Function(int rowIndex)? isRowSelected,
    Color? Function(int rowIndex)? rowColorBuilder,
    String? emptyMessage,
  }) {
    final tableWidth = TableColumnDef.totalWidth(columns);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 헤더(46) + 행당(43) + 테두리(2) → 데이터에 맞는 높이, 최대 constraints
        final contentHeight = 46.0 + rowCount * 43.0 + 2.0;
        final effectiveHeight = min(contentHeight, constraints.maxHeight);
        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            height: effectiveHeight,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: StickyHeaderTable(
                columns: columns,
                rowCount: rowCount,
                cellBuilder: cellBuilder,
                onRowTap: onRowTap,
                isRowSelected: isRowSelected,
                rowColorBuilder: rowColorBuilder,
                emptyMessage: emptyMessage,
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── 고정 헤더 ──
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6), // indigo[50]
            border: Border(
              bottom: BorderSide(color: Colors.indigo.shade200, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: columns.map((col) {
              Widget label = Text(
                col.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.indigo[900],
                ),
              );

              if (col.onSort != null) {
                label = InkWell(
                  onTap: col.onSort,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      label,
                      if (col.sortAscending != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          col.sortAscending!
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: Colors.indigo,
                        ),
                      ],
                    ],
                  ),
                );
              }

              return SizedBox(
                width: col.width,
                child: col.numeric
                    ? Align(alignment: Alignment.centerRight, child: label)
                    : label,
              );
            }).toList(),
          ),
        ),

        // ── 스크롤 바디 ──
        Expanded(
          child: rowCount == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      emptyMessage ?? '데이터가 없습니다.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: rowCount,
                  itemBuilder: (context, rowIndex) {
                    final selected =
                        isRowSelected?.call(rowIndex) ?? false;

                    Color bgColor;
                    if (selected) {
                      bgColor = Colors.indigo.withValues(alpha: 0.1);
                    } else if (rowColorBuilder != null &&
                        rowColorBuilder!(rowIndex) != null) {
                      bgColor = rowColorBuilder!(rowIndex)!;
                    } else {
                      bgColor = rowIndex.isEven
                          ? Colors.white
                          : const Color(0xFFFAFAFA);
                    }

                    return InkWell(
                      onTap: onRowTap != null
                          ? () => onRowTap!(rowIndex)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border(
                            bottom:
                                BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: List.generate(
                            columns.length,
                            (colIndex) => SizedBox(
                              width: columns[colIndex].width,
                              child: columns[colIndex].numeric
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: cellBuilder(
                                          colIndex, rowIndex),
                                    )
                                  : cellBuilder(colIndex, rowIndex),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
