-- 007_create_worker_profiles.sql
-- workers와 1:1 관계의 HR 프로필 테이블

CREATE TABLE worker_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  worker_id UUID NOT NULL UNIQUE REFERENCES workers(id) ON DELETE CASCADE,
  company VARCHAR(10),              -- 회사코드: 'BT' 또는 'TK'
  employee_id VARCHAR(20),          -- 사번: BT-IC001 형식
  ssn VARCHAR(20),                  -- 주민번호 (마스킹)
  gender VARCHAR(10),               -- 성별
  address TEXT,                     -- 주소
  detail_address TEXT,              -- 상세주소 (동/호수)
  email VARCHAR(100),               -- 이메일
  emergency_contact VARCHAR(20),    -- 비상연락망
  resume_file TEXT,                 -- 이력서 파일 경로
  employment_status VARCHAR(20),    -- 재직상태: 정규직, 계약직, 일용직, 파견, 육아휴직
  join_date DATE,                   -- 입사일
  leave_date DATE,                  -- 퇴사일
  position VARCHAR(20),             -- 직위: 사원, 대리, 과장, 부장, 대표
  title VARCHAR(20),                -- 직책: 조장, 파트장
  job VARCHAR(30),                  -- 직무: 지게차, 피커, 검수, 사무 등
  photo_url TEXT,                   -- 사진 URL
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_worker_profiles_worker_id ON worker_profiles(worker_id);
CREATE INDEX idx_worker_profiles_employee_id ON worker_profiles(employee_id);
CREATE INDEX idx_worker_profiles_company ON worker_profiles(company);

-- updated_at 트리거
CREATE TRIGGER trg_worker_profiles_updated_at
  BEFORE UPDATE ON worker_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS 활성화
ALTER TABLE worker_profiles ENABLE ROW LEVEL SECURITY;

-- 근로자: 자신의 프로필 조회
CREATE POLICY worker_select_own_profile ON worker_profiles FOR SELECT
  USING (worker_id = auth.uid());

-- 관리 역할: 모든 프로필 조회
CREATE POLICY admin_select_all_profiles ON worker_profiles FOR SELECT
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할: 프로필 생성
CREATE POLICY admin_insert_profiles ON worker_profiles FOR INSERT
  WITH CHECK (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할: 프로필 수정
CREATE POLICY admin_update_profiles ON worker_profiles FOR UPDATE
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );

-- 관리 역할: 프로필 삭제
CREATE POLICY admin_delete_profiles ON worker_profiles FOR DELETE
  USING (
    public.get_my_role() IN ('center_manager', 'owner', 'system_admin')
  );
