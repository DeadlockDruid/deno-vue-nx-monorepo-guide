import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => {
  const DENO_APP = Deno.env.get("DENO_APP") || "Default App 2";
  const DENO_APP_OWNER = Deno.env.get("DENO_APP_OWNER") || "Default Owner 2";

  return c.json({
    message: `Deno App: ${DENO_APP} - Deno Owner Name: ${DENO_APP_OWNER} - dummy text 2`,
`,
  });
});

// Automatically extract port from Deno.args or use default
const port = parseInt(Deno.env.get("PORT") ?? "8080");

// Start the server with Deno.serve
Deno.serve({ port }, app.fetch);
