import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface PayrollData {
  workerId: string;
  workerName: string;
  partName: string;
  totalWorkHours: number;
  totalWorkDays: number;
  hourlyWage: number;
  baseSalary: number;
  totalSalary: number;
}

serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { siteId, yearMonth } = await req.json();

    if (!siteId || !yearMonth || !/^\d{4}-\d{2}$/.test(yearMonth)) {
      return new Response(JSON.stringify({ error: "Invalid siteId or yearMonth (YYYY-MM)" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const [year, month] = yearMonth.split("-").map(Number);
    const startDate = new Date(year, month - 1, 1).toISOString();
    const endDate = new Date(year, month, 0, 23, 59, 59).toISOString();

    // Get all workers for the site with their parts
    const { data: workers, error: workersError } = await supabase
      .from("workers")
      .select("id, name, part_id, parts(name, hourly_wage)")
      .eq("site_id", siteId)
      .eq("is_active", true);

    if (workersError) throw workersError;

    // Get all attendances for the month
    const { data: attendances, error: attError } = await supabase
      .from("attendances")
      .select("worker_id, work_hours, check_in_time")
      .gte("check_in_time", startDate)
      .lte("check_in_time", endDate)
      .not("work_hours", "is", null);

    if (attError) throw attError;

    // Calculate payroll per worker
    const payrolls: PayrollData[] = (workers ?? []).map((worker: any) => {
      const workerAttendances = (attendances ?? []).filter(
        (a: any) => a.worker_id === worker.id
      );
      const totalWorkHours = workerAttendances.reduce(
        (sum: number, a: any) => sum + (a.work_hours || 0), 0
      );
      const uniqueDays = new Set(
        workerAttendances.map((a: any) => a.check_in_time.substring(0, 10))
      );
      const totalWorkDays = uniqueDays.size;
      const hourlyWage = worker.parts?.hourly_wage ?? 0;
      const baseSalary = Math.round(totalWorkHours * hourlyWage);

      return {
        workerId: worker.id,
        workerName: worker.name,
        partName: worker.parts?.name ?? "",
        totalWorkHours: Math.round(totalWorkHours * 100) / 100,
        totalWorkDays,
        hourlyWage,
        baseSalary,
        totalSalary: baseSalary,
      };
    });

    return new Response(JSON.stringify({ payrolls }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
