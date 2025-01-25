import { describe, it, expect } from 'vitest';
import { userSchema } from '../lib/users';

describe('userSchema', () => {
  it('validates a correct user', () => {
    const validUser = { name: 'John', email: 'john@example.com' };
    const result = userSchema.safeParse(validUser);

    expect(result.success).toBe(true);
  });

  it('fails if name has fewer than 3 characters', () => {
    const invalidUser = { name: 'Jo', email: 'jo@example.com' };
    const result = userSchema.safeParse(invalidUser);

    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].message).toBe(
        'Name should have minimum of three characters.'
      );
    }
  });

  it('fails for an invalid email format', () => {
    const invalidEmailUser = { name: 'John', email: 'not-an-email' };
    const result = userSchema.safeParse(invalidEmailUser);

    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].message).toBe('Invalid email');
    }
  });

  it('fails when there are extra unknown properties due to strict', () => {
    const extraPropsUser = { name: 'John', email: 'john@example.com', age: 30 };
    const result = userSchema.safeParse(extraPropsUser);

    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0].message).toContain(
        "Unrecognized key(s) in object: 'age'"
      );
    }
  });
});
