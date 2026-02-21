import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { to_email, name, login_email, password, web_url } = await req.json();

    if (!to_email || !name || !login_email) {
      return new Response(
        JSON.stringify({ error: "to_email, name, login_email은 필수입니다" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ error: "RESEND_API_KEY가 설정되지 않았습니다" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const siteUrl = web_url || "https://myprojectjihun.web.app";

    // 비밀번호 포함 여부에 따라 이메일 내용 분기
    const passwordSection = password
      ? `<tr>
           <td style="padding:8px 16px;color:#64748b;font-size:14px;width:120px;">초기 비밀번호</td>
           <td style="padding:8px 16px;font-size:14px;font-weight:600;color:#0f172a;">${password}</td>
         </tr>`
      : `<tr>
           <td style="padding:8px 16px;color:#64748b;font-size:14px;width:120px;">비밀번호</td>
           <td style="padding:8px 16px;font-size:14px;color:#64748b;">관리자에게 문의하세요</td>
         </tr>`;

    const htmlContent = `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#f1f5f9;font-family:'Apple SD Gothic Neo','Malgun Gothic',sans-serif;">
  <div style="max-width:520px;margin:40px auto;background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
    <!-- Header -->
    <div style="background:linear-gradient(135deg,#4f46e5,#6366f1);padding:32px 24px;text-align:center;">
      <h1 style="color:#ffffff;font-size:22px;margin:0;">WorkFlow</h1>
      <p style="color:#c7d2fe;font-size:14px;margin:8px 0 0;">근태 및 급여 관리 시스템</p>
    </div>
    <!-- Body -->
    <div style="padding:32px 24px;">
      <p style="font-size:16px;color:#1e293b;margin:0 0 8px;"><strong>${name}</strong>님, 안녕하세요!</p>
      <p style="font-size:14px;color:#475569;margin:0 0 24px;line-height:1.6;">WorkFlow 관리자 계정이 생성되었습니다.<br>아래 정보로 로그인하실 수 있습니다.</p>

      <table style="width:100%;border-collapse:collapse;background:#f8fafc;border-radius:8px;overflow:hidden;">
        <tr style="border-bottom:1px solid #e2e8f0;">
          <td style="padding:8px 16px;color:#64748b;font-size:14px;width:120px;">로그인 아이디</td>
          <td style="padding:8px 16px;font-size:14px;font-weight:600;color:#0f172a;">${login_email}</td>
        </tr>
        ${passwordSection}
        <tr>
          <td style="padding:8px 16px;color:#64748b;font-size:14px;">접속 주소</td>
          <td style="padding:8px 16px;font-size:14px;"><a href="${siteUrl}" style="color:#4f46e5;text-decoration:none;font-weight:600;">${siteUrl}</a></td>
        </tr>
      </table>

      <div style="margin-top:24px;padding:16px;background:#fef3c7;border-radius:8px;border-left:4px solid #f59e0b;">
        <p style="font-size:13px;color:#92400e;margin:0;">&#9888;&#65039; 보안을 위해 최초 로그인 후 반드시 비밀번호를 변경해 주세요.</p>
      </div>

      <div style="text-align:center;margin-top:28px;">
        <a href="${siteUrl}" style="display:inline-block;padding:12px 32px;background:#4f46e5;color:#ffffff;border-radius:8px;text-decoration:none;font-size:14px;font-weight:600;">로그인 하러 가기</a>
      </div>
    </div>
    <!-- Footer -->
    <div style="padding:16px 24px;background:#f8fafc;border-top:1px solid #e2e8f0;text-align:center;">
      <p style="font-size:12px;color:#94a3b8;margin:0;">본 메일은 WorkFlow 시스템에서 자동 발송되었습니다.</p>
    </div>
  </div>
</body>
</html>`;

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: "WorkFlow <onboarding@resend.dev>",
        to: [to_email],
        subject: `[WorkFlow] ${name}님의 계정 가입정보 안내`,
        html: htmlContent,
      }),
    });

    const resendData = await resendRes.json();

    if (!resendRes.ok) {
      return new Response(
        JSON.stringify({ error: resendData.message || "이메일 전송에 실패했습니다" }),
        { status: resendRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, id: resendData.id }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
