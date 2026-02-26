import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const {
      request_id,
      site_id,
      part_id,
      company,
      employee_id,
      position,
      employment_status,
      job,
    } = await req.json();

    // ── 입력 검증 ──
    if (!request_id || !site_id || !part_id || !company || !employee_id) {
      return new Response(
        JSON.stringify({
          error:
            "필수 항목 누락: request_id, site_id, part_id, company, employee_id",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // service_role 클라이언트 (RLS 우회)
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    // ── 1. 가입 요청 조회 ──
    const { data: request, error: reqError } = await supabase
      .from("registration_requests")
      .select("*")
      .eq("id", request_id)
      .single();

    if (reqError || !request) {
      return new Response(
        JSON.stringify({ error: "가입 요청을 찾을 수 없습니다." }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (request.status !== "pending") {
      return new Response(
        JSON.stringify({
          error: `이미 처리된 요청입니다. (상태: ${request.status})`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const authUserId = request.auth_user_id;
    const workerName = request.name;
    const workerPhone = request.phone;

    // ── 2. workers 레코드 생성 ──
    // id = auth_user_id (Supabase Auth와 연결)
    const { error: workerError } = await supabase.from("workers").insert({
      id: authUserId,
      name: workerName,
      phone: workerPhone,
      site_id: site_id,
      part_id: part_id,
      role: "worker",
      is_active: true,
      position: position || null,
    });

    if (workerError) {
      // 중복 phone 등 제약 조건 위반
      return new Response(
        JSON.stringify({
          error: `근로자 생성 실패: ${workerError.message}`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ── 3. worker_profiles 레코드 생성 ──
    const { error: profileError } = await supabase
      .from("worker_profiles")
      .insert({
        worker_id: authUserId,
        company: company,
        employee_id: employee_id,
        address: request.address || null,
        detail_address: request.detail_address || null,
        ssn: request.ssn || null,
        bank: request.bank || null,
        account_number: request.account_number || null,
        employment_status: employment_status || null,
        job: job || null,
        join_date: new Date().toISOString().substring(0, 10),
      });

    if (profileError) {
      // 롤백: worker 삭제
      await supabase.from("workers").delete().eq("id", authUserId);
      return new Response(
        JSON.stringify({
          error: `프로필 생성 실패: ${profileError.message}`,
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // ── 4. 가입 요청 상태 업데이트 → approved ──
    // JWT에서 호출자 ID 추출 (reviewed_by)
    let reviewedBy: string | null = null;
    const authHeader = req.headers.get("Authorization");
    if (authHeader) {
      try {
        const token = authHeader.replace("Bearer ", "");
        const payload = JSON.parse(atob(token.split(".")[1]));
        reviewedBy = payload.sub || null;
      } catch (_) {
        // JWT 파싱 실패 시 무시
      }
    }

    const { error: updateError } = await supabase
      .from("registration_requests")
      .update({
        status: "approved",
        reviewed_by: reviewedBy,
        reviewed_at: new Date().toISOString(),
      })
      .eq("id", request_id);

    if (updateError) {
      console.error("registration_requests 업데이트 실패:", updateError);
      // worker는 이미 생성됨 → 치명적이지 않음
    }

    return new Response(
      JSON.stringify({
        success: true,
        worker_id: authUserId,
        employee_id: employee_id,
        message: `${workerName}님의 가입이 승인되었습니다.`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
