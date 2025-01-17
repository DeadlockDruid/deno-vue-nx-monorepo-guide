<template>
  <div>
    <h1>User Form</h1>
    <form @submit.prevent="submitForm">
      <div>
        <label for="name">Name:</label>
        <input
          id="name"
          v-model="user.name"
          type="text"
          required
        >
      </div>
      <div>
        <label for="email">Email:</label>
        <input
          id="email"
          v-model="user.email"
          type="email"
          required
        >
      </div>
      <button type="submit">
        Submit
      </button>
    </form>
    <p v-if="message">
      {{ message }}
    </p>
    <p
      v-if="error"
      style="color: red"
    >
      {{ error }}
    </p>
  </div>
</template>
<script lang="ts">
import { ref } from 'vue';
import axios from 'axios';
import { userSchema } from '@shared/zod-schemas/users';
import { z } from 'zod';

export default {
  setup() {
    const user = ref({ name: '', email: '' });
    const message = ref('');
    const error = ref('');

    const submitForm = async () => {
      try {
        userSchema.parse(user.value);

        const response = await axios.post(
          `${process.env.VITE_API_BASE_URL}/submit`,
          user.value
        );
        message.value = response.data.message;
        error.value = '';
      } catch (err) {
        if (err instanceof z.ZodError) {
          error.value = err.errors[0].message;
        } else if (err.response && err.response.data.error) {
          error.value = err.response.data.error[0].message;
        } else {
          error.value = 'An unexpected error occurred.';
        }
        message.value = '';
      }
    };

    return { user, message, error, submitForm };
  },
};
</script>
