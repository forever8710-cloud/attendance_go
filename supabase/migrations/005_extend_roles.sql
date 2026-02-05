-- 005_extend_roles.sql
-- RBAC 역할 확장: worker, center_manager, owner, system_admin

-- 기존 role CHECK 제약 제거 후 새 제약 추가
ALTER TABLE workers DROP CONSTRAINT IF EXISTS workers_role_check;
ALTER TABLE workers ADD CONSTRAINT workers_role_check
  CHECK (role IN ('worker', 'center_manager', 'owner', 'system_admin'));

-- owner/system_admin은 site_id NULL 허용 (전체 센터 접근)
ALTER TABLE workers ALTER COLUMN site_id DROP NOT NULL;

-- 기존 manager → system_admin 으로 마이그레이션
UPDATE workers SET role = 'system_admin' WHERE role = 'manager';
