-- 006_fix_rls_policies_for_new_roles.sql
-- 기존 role='manager' 기반 RLS 정책을 새 역할 체계에 맞게 수정
-- 역할: worker, center_manager, owner, system_admin

-- ============================================================
-- 1. 기존 정책 DROP
-- ============================================================

-- workers 테이블
DROP POLICY IF EXISTS worker_select_own ON workers;
DROP POLICY IF EXISTS manager_select_site ON workers;
DROP POLICY IF EXISTS manager_insert_workers ON workers;
DROP POLICY IF EXISTS manager_update_workers ON workers;
DROP POLICY IF EXISTS manager_delete_workers ON workers;

-- attendances 테이블
DROP POLICY IF EXISTS worker_own_attendance ON attendances;
DROP POLICY IF EXISTS worker_create_attendance ON attendances;
DROP POLICY IF EXISTS worker_update_own_attendance ON attendances;
DROP POLICY IF EXISTS manager_view_site_attendance ON attendances;

-- payrolls 테이블
DROP POLICY IF EXISTS worker_own_payroll ON payrolls;
DROP POLICY IF EXISTS manager_view_site_payroll ON payrolls;
DROP POLICY IF EXISTS manager_create_payroll ON payrolls;
DROP POLICY IF EXISTS manager_update_payroll ON payrolls;

-- ============================================================
-- 2. 헬퍼 함수: 현재 사용자의 역할 조회
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT role::text FROM workers WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.get_my_site_id()
RETURNS uuid
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT site_id FROM workers WHERE id = auth.uid();
$$;

-- ============================================================
-- 3. workers 정책 재생성
-- ============================================================

-- 근로자: 자신의 정보 조회
CREATE POLICY worker_select_own ON workers FOR SELECT
  USING (auth.uid() = id);

-- center_manager: 같은 사업장 근로자 조회
CREATE POLICY center_manager_select_site ON workers FOR SELECT
  USING (
    site_id = public.get_my_site_id()
    AND public.get_my_role() = 'center_manager'
  );

-- owner/system_admin: 모든 근로자 조회 (site_id NULL 대응)
CREATE POLICY admin_select_all ON workers FOR SELECT
  USING (
    public.get_my_role() IN ('owner', 'system_admin')
  );

-- 관리 역할(center_manager, owner, system_admin)만 등록
CREATE POLICY admin_insert_workers ON workers FOR INSERT
  WITH CHECK (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할만 수정
CREATE POLICY admin_update_workers ON workers FOR UPDATE
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할만 삭제
CREATE POLICY admin_delete_workers ON workers FOR DELETE
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- ============================================================
-- 4. attendances 정책 재생성
-- ============================================================

-- 근로자: 자신의 출퇴근 기록 조회
CREATE POLICY worker_own_attendance ON attendances FOR SELECT
  USING (worker_id = auth.uid());

-- 근로자: 자신의 출퇴근 기록 생성
CREATE POLICY worker_create_attendance ON attendances FOR INSERT
  WITH CHECK (worker_id = auth.uid());

-- 근로자: 자신의 퇴근 기록 수정
CREATE POLICY worker_update_own_attendance ON attendances FOR UPDATE
  USING (worker_id = auth.uid());

-- center_manager: 같은 사업장 출퇴근 기록 조회
CREATE POLICY center_manager_view_site_attendance ON attendances FOR SELECT
  USING (
    public.get_my_role() = 'center_manager'
    AND worker_id IN (
      SELECT id FROM workers WHERE site_id = public.get_my_site_id()
    )
  );

-- owner/system_admin: 모든 출퇴근 기록 조회
CREATE POLICY admin_view_all_attendance ON attendances FOR SELECT
  USING (
    public.get_my_role() IN ('owner', 'system_admin')
  );

-- ============================================================
-- 5. payrolls 정책 재생성
-- ============================================================

-- 근로자: 자신의 급여 조회
CREATE POLICY worker_own_payroll ON payrolls FOR SELECT
  USING (worker_id = auth.uid());

-- center_manager: 같은 사업장 급여 조회
CREATE POLICY center_manager_view_site_payroll ON payrolls FOR SELECT
  USING (
    public.get_my_role() = 'center_manager'
    AND worker_id IN (
      SELECT id FROM workers WHERE site_id = public.get_my_site_id()
    )
  );

-- owner/system_admin: 모든 급여 조회
CREATE POLICY admin_view_all_payroll ON payrolls FOR SELECT
  USING (
    public.get_my_role() IN ('owner', 'system_admin')
  );

-- 관리 역할만 급여 생성
CREATE POLICY admin_create_payroll ON payrolls FOR INSERT
  WITH CHECK (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할만 급여 수정
CREATE POLICY admin_update_payroll ON payrolls FOR UPDATE
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- ============================================================
-- 6. 트리거 함수 search_path 보안 수정
-- ============================================================

CREATE OR REPLACE FUNCTION public.calculate_work_hours()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF NEW.check_out_time IS NOT NULL THEN
    NEW.work_hours := EXTRACT(EPOCH FROM (NEW.check_out_time - NEW.check_in_time)) / 3600.0;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;
