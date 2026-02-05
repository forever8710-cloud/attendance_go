import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountRow {
  AccountRow({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.role = 'worker',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // worker | manager
  final bool isActive;
  final DateTime? createdAt;
}

class AccountsRepository {
  final List<AccountRow> _accounts = [
    AccountRow(id: '1', name: '김영수', phone: '010-1234-0001', email: 'kim@email.com', role: 'worker', isActive: true, createdAt: DateTime(2020, 3, 1)),
    AccountRow(id: '2', name: '이민호', phone: '010-1234-0002', email: 'lee@email.com', role: 'worker', isActive: true, createdAt: DateTime(2019, 5, 15)),
    AccountRow(id: '3', name: '최지우', phone: '010-1234-0003', email: 'choi@email.com', role: 'worker', isActive: true, createdAt: DateTime(2023, 1, 10)),
    AccountRow(id: '4', name: '박강성', phone: '010-1234-0004', email: 'park@email.com', role: 'worker', isActive: true, createdAt: DateTime(2024, 6, 1)),
    AccountRow(id: '5', name: '정우성', phone: '010-1234-0005', email: 'jung@email.com', role: 'manager', isActive: true, createdAt: DateTime(2015, 2, 1)),
    AccountRow(id: '6', name: '한지민', phone: '010-1234-0006', email: 'han@email.com', role: 'worker', isActive: false, createdAt: DateTime(2021, 8, 1)),
  ];

  Future<List<AccountRow>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_accounts);
  }

  Future<void> saveAccount(AccountRow account) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _accounts.indexWhere((a) => a.id == account.id);
    if (idx != -1) {
      _accounts[idx] = account;
    } else {
      _accounts.add(account);
    }
  }

  Future<void> toggleAccountStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _accounts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final old = _accounts[idx];
      _accounts[idx] = AccountRow(
        id: old.id,
        name: old.name,
        phone: old.phone,
        email: old.email,
        role: old.role,
        isActive: !old.isActive,
        createdAt: old.createdAt,
      );
    }
  }
}

final accountsRepositoryProvider = Provider((ref) => AccountsRepository());

final accountsProvider = FutureProvider<List<AccountRow>>((ref) {
  return ref.watch(accountsRepositoryProvider).getAccounts();
});
