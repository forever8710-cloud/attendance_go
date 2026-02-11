-- 009_allow_anon_select_sites_parts.sql
-- sites/parts는 공개 참조데이터이므로 anon 키로도 SELECT 허용

-- 기존 정책 DROP
DROP POLICY IF EXISTS sites_select ON sites;
DROP POLICY IF EXISTS parts_select ON parts;

-- anon + authenticated 모두 SELECT 허용
CREATE POLICY sites_select_public ON sites FOR SELECT
  USING (true);

CREATE POLICY parts_select_public ON parts FOR SELECT
  USING (true);
