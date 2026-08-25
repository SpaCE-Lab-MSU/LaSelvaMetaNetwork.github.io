import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  site: "https://space-lab-msu.github.io",
  base: "/LaSelvaMetaNetwork.github.io/",
  integrations: [mdx()],
  vite: {
    plugins: [tailwindcss()],
  },
});
