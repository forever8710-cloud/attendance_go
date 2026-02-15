/// RBAC 권한 체계
///
/// | 역할           | 코드            | 범위     |
/// |----------------|-----------------|----------|
/// | 시스템관리자    | system_admin    | 전체     |
/// | 대표이사        | owner           | 전체     |
/// | 센터장          | center_manager  | 해당 센터 |
/// | 근로자          | worker          | 본인     |

enum AppRole {
  systemAdmin,
  owner,
  centerManager,
  worker,
}

const _roleStringMap = {
  'system_admin': AppRole.systemAdmin,
  'owner': AppRole.owner,
  'center_manager': AppRole.centerManager,
  'worker': AppRole.worker,
  // 기존 'manager' 값도 system_admin으로 매핑 (하위호환)
  'manager': AppRole.systemAdmin,
};

AppRole roleFromString(String value) {
  return _roleStringMap[value] ?? AppRole.worker;
}

String roleToString(AppRole role) {
  return switch (role) {
    AppRole.systemAdmin => 'system_admin',
    AppRole.owner => 'owner',
    AppRole.centerManager => 'center_manager',
    AppRole.worker => 'worker',
  };
}

String roleDisplayName(AppRole role) {
  return switch (role) {
    AppRole.systemAdmin => '시스템관리자',
    AppRole.owner => '대표이사',
    AppRole.centerManager => '센터장',
    AppRole.worker => '근로자',
  };
}

/// 메뉴별 접근 권한
/// index: 0=홈, 1=근로자관리, 2=근태기록, 3=급여관리, 4=설정
bool canAccessMenu(AppRole role, int menuIndex) {
  return switch (menuIndex) {
    0 => true,                                          // 홈: 모두
    1 => role != AppRole.worker,                        // 근로자관리: center_manager 이상
    2 => role != AppRole.worker,                        // 근태기록: center_manager 이상
    3 => role != AppRole.worker,                        // 급여관리: center_manager 이상 (조회만 가능 여부는 별도)
    4 => role != AppRole.worker,                        // 설정: 센터장 이상
    5 => role == AppRole.systemAdmin,                   // 계정관리: system_admin만
    _ => false,
  };
}

/// 관리자 웹 로그인 가능 여부 (worker 제외)
bool canAccessManagerWeb(AppRole role) {
  return role != AppRole.worker;
}

/// 근로자 등록/수정 권한
bool canEditWorkers(AppRole role) {
  return role != AppRole.worker;
}

/// 급여 수정 (생성/확정) 권한 — center_manager는 조회만
bool canEditPayroll(AppRole role) {
  return role == AppRole.systemAdmin || role == AppRole.owner;
}

/// 계정 관리 권한
bool canManageAccounts(AppRole role) {
  return role == AppRole.systemAdmin || role == AppRole.owner;
}

/// 설정 접근 권한 (센터장 이상)
bool canAccessSettings(AppRole role) {
  return role != AppRole.worker;
}

/// 근태 기록 수정/삭제 권한 (center_manager 이상)
bool canEditAttendance(AppRole role) {
  return role != AppRole.worker;
}

/// 전체 센터 데이터 접근 (owner, system_admin)
bool canAccessAllSites(AppRole role) {
  return role == AppRole.systemAdmin || role == AppRole.owner;
}
