import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import tailwindcss from "@tailwindcss/vite";

const site =
  process.env.SITE_URL ||
  process.env.PUBLIC_SITE_URL ||
  "https://space-lab-msu.github.io";

export default defineConfig({
  site,
  base: "/LaSelvaMetaNetwork.github.io/",
  integrations: [mdx()],
  vite: {
    plugins: [tailwindcss()],
  },
});
