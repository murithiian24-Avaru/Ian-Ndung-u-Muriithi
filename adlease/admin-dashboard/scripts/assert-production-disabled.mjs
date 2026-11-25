import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const dist = new URL("../dist/", import.meta.url);
const html = readFileSync(new URL("index.html", dist), "utf8");
const assetsDir = new URL("assets/", dist);
const assets = readdirSync(assetsDir).filter((name) => name.endsWith(".js"));
if (assets.length === 0) throw new Error("Production build contains no JavaScript assets.");
const bundle = assets.map((name) => readFileSync(join(assetsDir.pathname, name), "utf8")).join("\n");
if (!bundle.includes("ADLEASE_ADMIN_PRODUCTION_DISABLED")) {
  throw new Error("Production disabled-admin shell marker is missing.");
}
for (const forbidden of ["John Kamau", "Peter Ochieng", "Revenue Overview", "Welcome back, Admin"]) {
  if (bundle.includes(forbidden)) throw new Error(`Development dashboard content leaked into production: ${forbidden}`);
}
if (!html.includes('<div id="root"></div>')) throw new Error("Production entry HTML is malformed.");
console.log("PASS: production build contains only the disabled-admin shell; demo dashboard content is absent.");
