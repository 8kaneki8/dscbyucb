import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "ClipForge AI — Your AI clipping studio", description: "Turn long videos into polished short-form clips with an AI-powered editing studio." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }