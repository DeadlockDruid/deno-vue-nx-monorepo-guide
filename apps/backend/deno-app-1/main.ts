import { Hono } from 'hono';
import { cors } from 'hono/cors';
import _ from 'lodash';
import { z } from 'zod';
import { userSchema } from '@shared/zod-schemas/users';

// Create and configure Hono app
const app = new Hono();

app.use('*', cors());

app.get('/', (c) => {
  const data = [1, 2, 3, 4, 5, 6];
  const chunkedData = _.chunk(data, 2);
  return c.json({ message: 'Hello Hono!', chunkedData });
});

app.post('/submit', async (c) => {
  try {
    const body = await c.req.json();
    userSchema.parse(body); // Validate input
    return c.json({ message: 'Validation successful', data: body });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return c.json({ error: error.errors }, 400); // Return validation errors
    }
    return c.json({ error: 'Internal Server Error' }, 500);
  }
});

// Start the server
Deno.serve(app.fetch);
