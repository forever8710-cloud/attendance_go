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
/// [wrapWithCard]로 감싸면 Card + 너비 자동 조정까지 처리.
/// 데이터가 적으면 콘텐츠에 맞춰 축소, 많으면 스크롤.
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
  /// 데이터 행에 맞춰 Card가 축소되고, 넘칠 때만 스크롤.
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
        final cs = Theme.of(context).colorScheme;
        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 고정 헤더 ──
        Container(
          decoration: BoxDecoration(
            color: isDark ? cs.primary.withValues(alpha: 0.12) : const Color(0xFFE8EAF6),
            border: Border(
              bottom: BorderSide(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
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
                  color: isDark ? cs.primary.withValues(alpha: 0.9) : Colors.indigo[900],
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
                          color: cs.primary,
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
        Flexible(
          child: rowCount == 0
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    emptyMessage ?? '데이터가 없습니다.',
                    style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: rowCount,
                  itemBuilder: (context, rowIndex) {
                    final selected =
                        isRowSelected?.call(rowIndex) ?? false;

                    Color bgColor;
                    if (selected) {
                      bgColor = cs.primary.withValues(alpha: 0.1);
                    } else if (rowColorBuilder != null &&
                        rowColorBuilder!(rowIndex) != null) {
                      bgColor = rowColorBuilder!(rowIndex)!;
                    } else {
                      bgColor = rowIndex.isEven
                          ? (isDark ? cs.surface : Colors.white)
                          : (isDark ? cs.surface.withValues(alpha: 0.7) : const Color(0xFFFAFAFA));
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
                                BorderSide(color: cs.outlineVariant.withValues(alpha: 0.2)),
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
