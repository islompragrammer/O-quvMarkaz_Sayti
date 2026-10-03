<template>
  <TeacherLogin
    v-if="!authenticated"
    :configured="false"
    :local-demo-available="demoAvailable"
    :loading="loading"
    :error="error"
    @submit="login"
  />
  <App v-else @logout="logout" />
</template>

<script setup>
import { onMounted, ref } from 'vue'
import App from './App.vue'
import TeacherLogin from './teacher/TeacherLogin.vue'

const authenticated = ref(false)
const demoAvailable = ref(false)
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  if (import.meta.env.DEV) {
    try {
      const response = await fetch('/__local-demo-status')
      const status = await response.json()
      demoAvailable.value = response.ok && status.enabled === true
    } catch {
      demoAvailable.value = false
    }
  }
  loading.value = false
})

async function login(credentials) {
  error.value = ''
  loading.value = true
  try {
    const response = await fetch('/__local-demo-login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(credentials),
    })
    const result = await response.json()
    if (!response.ok) throw new Error(result.error || 'Kirish amalga oshmadi.')
    authenticated.value = true
  } catch (loginError) {
    error.value = loginError.message || 'Telefon yoki parol noto‘g‘ri.'
  } finally {
    loading.value = false
  }
}

function logout() {
  authenticated.value = false
}
</script>
