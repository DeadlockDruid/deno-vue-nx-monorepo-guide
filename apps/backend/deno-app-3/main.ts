import { Hono } from 'hono';

const app = new Hono();

app.get('/', (c) => {
  return c.text('Hello Hono!');
});

// Automatically extract port from Deno.args or use default
const port = Number(Deno.env.get('PORT')) || 8080;

// Start the server with Deno.serve
Deno.serve({ port }, app.fetch);
