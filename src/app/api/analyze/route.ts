import { NextRequest, NextResponse } from "next/server";
import { detectSource, sourceMessage } from "@/lib/source";
import { sourceSchema } from "@/lib/source";
export const runtime = "nodejs";
export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = sourceSchema.safeParse(body.url);
    if (!parsed.success) return NextResponse.json({ error: "Enter a valid video URL." }, { status: 400 });
    const source = detectSource(parsed.data);
    if (source === "unknown") return NextResponse.json({ error: sourceMessage(source), source }, { status: 422 });
    if (!body.rightsConfirmed) return NextResponse.json({ error: "Please confirm that you own this content or have permission to process it." }, { status: 403 });
    const configured = Boolean(process.env.OPENAI_API_KEY && process.env.VIDEO_WORKER_URL && process.env.VIDEO_WORKER_SECRET);
    if (!configured) return NextResponse.json({ status: "setup_required", source, message: "Source recognized. Connect an AI provider and an authorized video-processing worker to start real analysis. No clips have been generated.", guidance: sourceMessage(source) }, { status: 503 });
    return NextResponse.json({ status: "integration_required", source, message: "Provider credentials are present, but a worker adapter must be implemented for this source before jobs can be queued." }, { status: 501 });
  } catch { return NextResponse.json({ error: "Invalid request. Please try again." }, { status: 400 }); }
}