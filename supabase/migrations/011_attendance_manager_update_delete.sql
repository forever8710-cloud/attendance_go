-- 011: 관리자 근태 수정/삭제 RLS 정책

-- center_manager: 같은 사업장 근태 UPDATE
CREATE POLICY "center_manager_update_attendance"
  ON attendances FOR UPDATE
  USING (
    get_my_role() = 'center_manager'
    AND worker_id IN (
      SELECT id FROM workers WHERE site_id = get_my_site_id()
    )
  );

-- center_manager: 같은 사업장 근태 DELETE
CREATE POLICY "center_manager_delete_attendance"
  ON attendances FOR DELETE
  USING (
    get_my_role() = 'center_manager'
    AND worker_id IN (
      SELECT id FROM workers WHERE site_id = get_my_site_id()
    )
  );

-- owner/system_admin: 모든 근태 UPDATE
CREATE POLICY "admin_update_attendance"
  ON attendances FOR UPDATE
  USING (
    get_my_role() IN ('owner', 'system_admin')
  );

-- owner/system_admin: 모든 근태 DELETE
CREATE POLICY "admin_delete_attendance"
  ON attendances FOR DELETE
  USING (
    get_my_role() IN ('owner', 'system_admin')
  );
