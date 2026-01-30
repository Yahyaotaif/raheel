import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.0";

/// <reference lib="deno.window" />

const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

serve(async (req: Request) => {
  // Only accept POST requests
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const payment = await req.json();
    console.log("Moyasar webhook received:", payment);

    // Validate webhook has required data
    if (!payment || !payment.id) {
      return new Response(JSON.stringify({ error: "Invalid payload" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const { id, status, metadata } = payment;

    // Extract metadata
    const bookingId = metadata?.bookingId;
    const userId = metadata?.userId;

    if (!bookingId || !userId) {
      console.warn("Missing metadata in webhook:", { bookingId, userId });
      // Still return 200 to acknowledge receipt
      return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl, supabaseAnonKey);

    // Handle payment status
    if (status === "paid") {
      // Update trip status to 'paid'
      const { error } = await supabase
        .from("trips")
        .update({
          payment_status: "paid",
          payment_id: id,
          updated_at: new Date().toISOString(),
        })
        .eq("id", bookingId);

      if (error) {
        console.error("Failed to update trip:", error);
      } else {
        console.log("Trip marked as paid:", bookingId);
      }
    } else if (status === "failed" || status === "cancelled") {
      // Update trip status to 'payment_failed'
      const { error } = await supabase
        .from("trips")
        .update({
          payment_status: "failed",
          updated_at: new Date().toISOString(),
        })
        .eq("id", bookingId);

      if (error) {
        console.error("Failed to update trip status:", error);
      } else {
        console.log("Trip marked as payment failed:", bookingId);
      }
    }

    // Always respond with 200 OK to acknowledge receipt
    return new Response(JSON.stringify({ success: true, paymentId: id }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Webhook processing error:", error);
    // Still return 200 to prevent Moyasar from retrying indefinitely
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(
      JSON.stringify({ success: false, error: errorMessage }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
