import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Tira Suerte | Decisor",
  description: "Decide al azar con una moneda, números y ruletas personalizadas.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="es"><body>{children}</body></html>;
}
