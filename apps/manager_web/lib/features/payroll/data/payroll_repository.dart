class PayrollRow {
  const PayrollRow({
    required this.name,
    required this.part,
    required this.workDays,
    required this.totalHours,
    required this.hourlyWage,
    required this.baseSalary,
    required this.totalSalary,
  });
  final String name, part;
  final int workDays;
  final double totalHours;
  final int hourlyWage, baseSalary, totalSalary;
}

class PayrollRepository {
  Future<List<PayrollRow>> calculatePayroll(String siteId, String yearMonth) async {
    await Future.delayed(const Duration(seconds: 1));
    // Demo payroll data
    return [
      const PayrollRow(name: '김영수', part: '지게차', workDays: 22, totalHours: 198.0, hourlyWage: 12000, baseSalary: 2376000, totalSalary: 2376000),
      const PayrollRow(name: '이민호', part: '사무', workDays: 22, totalHours: 220.5, hourlyWage: 15000, baseSalary: 3307500, totalSalary: 3307500),
      const PayrollRow(name: '최지우', part: '현장', workDays: 21, totalHours: 189.0, hourlyWage: 13000, baseSalary: 2457000, totalSalary: 2457000),
      const PayrollRow(name: '박강성', part: '일용직', workDays: 20, totalHours: 180.0, hourlyWage: 11000, baseSalary: 1980000, totalSalary: 1980000),
      const PayrollRow(name: '정우성', part: '사무', workDays: 22, totalHours: 198.0, hourlyWage: 20000, baseSalary: 3960000, totalSalary: 3960000),
      const PayrollRow(name: '한지민', part: '현장', workDays: 18, totalHours: 162.0, hourlyWage: 13000, baseSalary: 2106000, totalSalary: 2106000),
    ];
  }
}
