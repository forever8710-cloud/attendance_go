-- 014: 보안 경고 수정

-- 1. to_kst_date 함수 search_path 설정
CREATE OR REPLACE FUNCTION to_kst_date(ts timestamptz)
RETURNS date
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$ SELECT (ts AT TIME ZONE 'Asia/Seoul')::date $$;

-- 2. calendar_events RLS 강화 (관리자만 INSERT/UPDATE/DELETE)
DROP POLICY IF EXISTS calendar_events_insert ON calendar_events;
DROP POLICY IF EXISTS calendar_events_update ON calendar_events;
DROP POLICY IF EXISTS calendar_events_delete ON calendar_events;

CREATE POLICY calendar_events_insert ON calendar_events FOR INSERT
  TO authenticated
  WITH CHECK (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

CREATE POLICY calendar_events_update ON calendar_events FOR UPDATE
  TO authenticated
  USING (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

CREATE POLICY calendar_events_delete ON calendar_events FOR DELETE
  TO authenticated
  USING (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );
