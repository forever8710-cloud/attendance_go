-- 010: get_my_role / get_my_site_id를 SECURITY DEFINER로 변경
-- RLS 정책에서 workers 테이블을 재귀 조회하는 무한루프 방지

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role::text FROM workers WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.get_my_site_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT site_id FROM workers WHERE id = auth.uid();
$$;
