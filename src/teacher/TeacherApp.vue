<!-- TEACHER MODE -->
<template>
  <TeacherPortal v-if="session?.profile.role === 'teacher'" :session="session" :demo="session.authMode === 'local-demo'" @logout="logout" />
  <StudentPortal v-else-if="session?.profile.role === 'student'" :session="session" @logout="logout" />
  <TeacherLogin
    v-else-if="!session"
    :configured="isSupabaseConfigured"
    :local-demo-available="localDemoAvailable"
    :loading="loading"
    :error="error"
    @submit="login"
  />
  <main v-else class="portal-role-error">Bu hisob uchun portal roli aniqlanmadi.</main>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import TeacherLogin from './TeacherLogin.vue'
import TeacherPortal from './TeacherPortal.vue'
import StudentPortal from './StudentPortal.vue'
import { isSupabaseConfigured } from './supabaseClient.js'
import { getPortalSession, signInPortal, signOutPortal } from './teacherService.js'

const session = ref(null)
const loading = ref(true)
const error = ref('')
const localDemoAvailable = ref(false)

onMounted(async () => {
  if (!isSupabaseConfigured) {
    if (import.meta.env.DEV) {
      try {
        const response = await fetch('/__local-demo-status')
        const status = await response.json()
        localDemoAvailable.value = response.ok && status.enabled === true
      } catch {
        localDemoAvailable.value = false
      }
    }
    loading.value = false
    return
  }
  try {
    session.value = await getPortalSession()
  } catch (sessionError) {
    error.value = sessionError.message
  } finally {
    loading.value = false
  }
})

async function login(credentials) {
  error.value = ''
  loading.value = true
  try {
    if (!isSupabaseConfigured && localDemoAvailable.value) {
      const response = await fetch('/__local-demo-login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      })
      const result = await response.json()
      if (!response.ok) throw new Error(result.error || 'Kirish amalga oshmadi.')
      session.value = result
      return
    }
    session.value = await signInPortal(credentials.phone, credentials.password)
  } catch (loginError) {
    error.value = loginError.message || 'Telefon yoki parol noto‘g‘ri.'
  } finally {
    loading.value = false
  }
}

async function logout() {
  error.value = ''
  if (session.value?.authMode === 'local-demo') {
    session.value = null
    return
  }
  try {
    await signOutPortal()
  } catch (logoutError) {
    error.value = logoutError.message
  } finally {
    session.value = null
  }
}
</script>
