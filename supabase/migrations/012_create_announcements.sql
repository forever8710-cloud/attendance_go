-- 012: 공지사항 테이블

CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  site_id UUID REFERENCES sites(id) ON DELETE SET NULL,  -- NULL = 전체 공지
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_announcements_site_id ON announcements(site_id);
CREATE INDEX idx_announcements_is_active ON announcements(is_active);
CREATE INDEX idx_announcements_created_at ON announcements(created_at DESC);

-- RLS 활성화
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- 인증된 사용자는 활성 공지 SELECT 가능
CREATE POLICY "authenticated_select_announcements"
  ON announcements FOR SELECT
  TO authenticated
  USING (is_active = TRUE);

-- 관리자(center_manager 이상)만 INSERT
CREATE POLICY "manager_insert_announcements"
  ON announcements FOR INSERT
  TO authenticated
  WITH CHECK (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리자(center_manager 이상)만 UPDATE
CREATE POLICY "manager_update_announcements"
  ON announcements FOR UPDATE
  TO authenticated
  USING (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리자(center_manager 이상)만 DELETE
CREATE POLICY "manager_delete_announcements"
  ON announcements FOR DELETE
  TO authenticated
  USING (
    get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- updated_at 자동 갱신 트리거
CREATE TRIGGER set_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
