import { Hono } from "hono";
import { cors } from "hono/cors";
import _ from "lodash";
import { z } from "zod";
import { userSchema } from "@shared/zod-schemas/users";

// Create and configure Hono app
const app = new Hono();

app.use("*", cors());

app.get("/", (c) => {
  const data = [1, 2, 3, 4, 5, 6, 7, 8];
  const chunkedData = _.chunk(data, 2);
  const APP_NAME = Deno.env.get("APP_NAME") || "Default App";
  const OWNER_NAME = Deno.env.get("OWNER_NAME") || "Default Owner";

  return c.json({
    message: `App Name: ${APP_NAME} - Owner Name: ${OWNER_NAME}`,
    chunkedData,
  });
});

app.post("/submit", async (c) => {
  try {
    const body = await c.req.json();

    userSchema.parse(body); // Validate input

    return c.json({ message: "Validation successful", data: body });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return c.json({ error: error.errors }, 400); // Return validation errors
    }

    return c.json({ error: "Internal Server Error" }, 500);
  }
});

// Automatically extract port from Deno.args or use default
const port = Number(Deno.env.get("PORT")) || 8080;

// Start the server with Deno.serve
Deno.serve({ port }, app.fetch);
