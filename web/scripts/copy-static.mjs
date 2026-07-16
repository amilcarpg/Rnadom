import { cp, mkdir, rm } from "node:fs/promises";

const target = new URL("../public/decisor", import.meta.url);
await rm(target, { recursive: true, force: true });
await mkdir(target, { recursive: true });
for (const filename of ["index.html", "styles.css", "data.js", "app.js"]) {
  await cp(new URL(`../${filename}`, import.meta.url), new URL(filename, target));
}
