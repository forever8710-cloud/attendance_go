-- 013: 트리거 및 제약조건 수정
-- 1. work_hours 음수 방지 (GREATEST(0, ...))
-- 2. 공지사항 updated_at 트리거 함수명 수정
-- 3. 동일 근로자 동일 날짜 중복 출근 방지 인덱스

-- 1. work_hours 계산 트리거 수정 (음수 방지)
CREATE OR REPLACE FUNCTION calculate_work_hours()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.check_out_time IS NOT NULL AND NEW.check_in_time IS NOT NULL THEN
    NEW.work_hours := GREATEST(0, EXTRACT(EPOCH FROM (NEW.check_out_time - NEW.check_in_time)) / 3600.0);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. 공지사항 updated_at 트리거 수정 (함수명 불일치 해결)
DROP TRIGGER IF EXISTS set_announcements_updated_at ON announcements;

CREATE TRIGGER set_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- 3. 동일 근로자 동일 날짜 중복 출근 방지
-- timestamptz를 KST 기준 date로 변환하는 IMMUTABLE 함수
CREATE OR REPLACE FUNCTION to_kst_date(ts timestamptz)
RETURNS date
LANGUAGE sql
IMMUTABLE
AS $$ SELECT (ts AT TIME ZONE 'Asia/Seoul')::date $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_attendances_worker_daily
  ON attendances (worker_id, to_kst_date(check_in_time));
