import { z } from "zod";
export const sourceSchema = z.string().url().max(2048);
export type SourceKind = "youtube"|"twitch"|"kick"|"tiktok"|"instagram"|"facebook"|"x"|"direct"|"unknown";
export function detectSource(raw: string): SourceKind {
  let host: string;
  try { host = new URL(raw).hostname.toLowerCase().replace(/^www\./, ""); } catch { return "unknown"; }
  if (host === "youtube.com" || host === "youtu.be" || host.endsWith(".youtube.com")) return "youtube";
  if (host === "twitch.tv" || host.endsWith(".twitch.tv")) return "twitch";
  if (host === "kick.com" || host.endsWith(".kick.com")) return "kick";
  if (host === "tiktok.com" || host.endsWith(".tiktok.com")) return "tiktok";
  if (host === "instagram.com" || host.endsWith(".instagram.com")) return "instagram";
  if (host === "facebook.com" || host.endsWith(".facebook.com") || host === "fb.watch") return "facebook";
  if (["x.com","twitter.com","t.co"].includes(host)) return "x";
  if (/\.(mp4|mov|webm|m4v)(\?.*)?$/.test(new URL(raw).pathname.toLowerCase())) return "direct";
  return "unknown";
}
export function sourceMessage(kind: SourceKind) {
  if (kind === "unknown") return "This URL is not recognized. Try a supported platform or a direct video file.";
  if (kind === "direct") return "Direct video URL detected. The file must be publicly reachable and permitted for processing.";
  return `${kind[0].toUpperCase()+kind.slice(1)} link detected. Availability depends on official API access, permissions and the source's terms. If retrieval is unavailable, upload an authorized copy.`;
}