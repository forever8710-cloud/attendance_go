import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.fontSize = FontSizeOption.medium,
    this.tableRowsPerPage = 20,
    this.lateAlertEnabled = true,
    this.absentAlertEnabled = true,
    this.absentAlertTime = const TimeOfDay(hour: 9, minute: 30),
    this.webNotificationEnabled = true,
    this.emailNotificationEnabled = false,
  });

  final ThemeMode themeMode;
  final FontSizeOption fontSize;
  final int tableRowsPerPage;
  final bool lateAlertEnabled;
  final bool absentAlertEnabled;
  final TimeOfDay absentAlertTime;
  final bool webNotificationEnabled;
  final bool emailNotificationEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    FontSizeOption? fontSize,
    int? tableRowsPerPage,
    bool? lateAlertEnabled,
    bool? absentAlertEnabled,
    TimeOfDay? absentAlertTime,
    bool? webNotificationEnabled,
    bool? emailNotificationEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      tableRowsPerPage: tableRowsPerPage ?? this.tableRowsPerPage,
      lateAlertEnabled: lateAlertEnabled ?? this.lateAlertEnabled,
      absentAlertEnabled: absentAlertEnabled ?? this.absentAlertEnabled,
      absentAlertTime: absentAlertTime ?? this.absentAlertTime,
      webNotificationEnabled: webNotificationEnabled ?? this.webNotificationEnabled,
      emailNotificationEnabled: emailNotificationEnabled ?? this.emailNotificationEnabled,
    );
  }

  double get fontSizeValue => switch (fontSize) {
    FontSizeOption.small => 13.0,
    FontSizeOption.medium => 15.0,
    FontSizeOption.large => 17.0,
  };
}

enum FontSizeOption {
  small('소'),
  medium('중'),
  large('대');

  const FontSizeOption(this.label);
  final String label;
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings());

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setFontSize(FontSizeOption size) => state = state.copyWith(fontSize: size);
  void setTableRowsPerPage(int rows) => state = state.copyWith(tableRowsPerPage: rows);
  void setLateAlertEnabled(bool v) => state = state.copyWith(lateAlertEnabled: v);
  void setAbsentAlertEnabled(bool v) => state = state.copyWith(absentAlertEnabled: v);
  void setAbsentAlertTime(TimeOfDay t) => state = state.copyWith(absentAlertTime: t);
  void setWebNotificationEnabled(bool v) => state = state.copyWith(webNotificationEnabled: v);
  void setEmailNotificationEnabled(bool v) => state = state.copyWith(emailNotificationEnabled: v);
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);

// 관리자 계정 데이터
class AdminUser {
  const AdminUser({
    required this.name,
    required this.email,
    required this.position,
    required this.role,
    required this.isActive,
  });
  final String name, email, position, role;
  final bool isActive;
}

final adminUsersProvider = Provider<List<AdminUser>>((ref) => [
  const AdminUser(name: '박대표', email: 'park@taekyung.com', position: '대표이사', role: '대표이사', isActive: true),
  const AdminUser(name: '김부장', email: 'kim@taekyung.com', position: '부장', role: '센터장', isActive: true),
  const AdminUser(name: '이과장', email: 'lee@taekyung.com', position: '과장', role: '센터장', isActive: true),
]);
