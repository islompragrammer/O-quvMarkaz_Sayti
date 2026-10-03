<!-- TEACHER MODE -->
<template>
  <main class="portal-login-page">
    <header class="portal-login-header">
      <span class="tasnim-wordmark"><b aria-hidden="true">▽</b>Tasnim</span>
      <label class="portal-language"><span class="sr-only">Til</span><select v-model="language"><option value="uz">UZ</option><option value="ru">RU</option></select><ChevronDown :size="13" /></label>
    </header>
    <section class="portal-login-content">
      <div class="portal-login-card">
        <div class="portal-login-heading">
          <div class="portal-login-icon"><LockKeyhole :size="20" /></div>
          <h1>{{ copy.title }}</h1>
        <p>{{ copy.subtitle }}</p>
        </div>

        <form class="portal-login-form" @submit.prevent="submit">
          <label class="portal-phone-field">
            <span>{{ copy.phone }}</span>
            <div class="portal-input-shell">
              <Phone :size="14" />
              <b>+998</b>
              <input v-model="phone" type="tel" inputmode="numeric" autocomplete="username" placeholder="90 123 45 67" required :disabled="loading" />
            </div>
          </label>
          <label class="portal-password-field">
            <span>{{ copy.password }}</span>
            <div class="portal-input-shell">
              <KeyRound :size="14" />
              <input v-model="password" :type="showPassword ? 'text' : 'password'" autocomplete="current-password" :placeholder="copy.password" required :disabled="loading" />
              <button type="button" :aria-label="showPassword ? copy.hidePassword : copy.showPassword" @click="showPassword = !showPassword">
                <EyeOff v-if="showPassword" :size="16" />
                <Eye v-else :size="16" />
              </button>
            </div>
          </label>
          <p v-if="error" class="portal-login-error" role="alert"><CircleAlert :size="15" />{{ error }}</p>
          <button class="portal-login-submit" type="submit" :disabled="(!configured && !localDemoAvailable) || loading">
            <LoaderCircle v-if="loading" class="portal-spin" :size="17" />
            {{ loading ? copy.loading : copy.submit }}
          </button>
        </form>
        <p v-if="!configured" class="portal-login-security portal-login-status" role="status"><TriangleAlert :size="13" />{{ localDemoAvailable ? (language === 'ru' ? 'Локальный режим проверки, без настоящего backend.' : 'Lokal sinov rejimi; haqiqiy backend ulanmagan.') : copy.config }}</p>
        <p v-else class="portal-login-security"><ShieldCheck :size="13" />{{ copy.secure }}</p>
      </div>
    </section>
  </main>
</template>

<script setup>
import { computed, ref } from 'vue'
import { AlertCircle as CircleAlert, ChevronDown, Eye, EyeOff, KeyRound, LoaderCircle, LockKeyhole, Phone, ShieldCheck, TriangleAlert } from 'lucide-vue-next'
import { locale as language } from '../locale.js'

const props = defineProps({
  configured: { type: Boolean, default: false },
  localDemoAvailable: { type: Boolean, default: false },
  loading: { type: Boolean, default: false },
  error: { type: String, default: '' },
})
const emit = defineEmits(['submit'])
const phone = ref('')
const password = ref('')
const showPassword = ref(false)
const copy = computed(() => language.value === 'ru' ? {
  title: 'Добро пожаловать в Tasnim!',
  subtitle: 'Пожалуйста, введите личные данные для входа в систему',
  phone: 'Номер телефона',
  password: 'Пароль',
  showPassword: 'Показать пароль',
  hidePassword: 'Скрыть пароль',
  submit: 'ВОЙТИ',
  loading: 'Проверка...',
  config: 'Supabase не настроен: нужен .env.',
  secure: 'Ваши данные защищены',
} : {
  title: 'Tasnim’ga xush kelibsiz',
  subtitle: 'Iltimos tizimga kirish uchun shaxsiy ma’lumotlaringizni kiriting',
  phone: 'Telefon raqam',
  password: 'Parol',
  showPassword: 'Parolni ko‘rsatish',
  hidePassword: 'Parolni yashirish',
  submit: 'KIRISH',
  loading: 'Tekshirilmoqda...',
  config: 'Supabase sozlanmagan: .env kerak.',
  secure: 'Ma’lumotlaringiz himoyalangan',
})

function submit() {
  if ((!props.configured && !props.localDemoAvailable) || props.loading) return
  emit('submit', { phone: phone.value.trim(), password: password.value })
}
</script>

<style scoped>
.portal-login-page {
  display: flex;
  flex-direction: column;
  height: 100dvh;
  min-height: 100dvh;
  overflow: hidden;
  background: #0c0f16;
  color: #edf1f8;
  font-family: Inter, system-ui, sans-serif;
}

.portal-login-header { display: flex; height: 44px; flex: 0 0 auto; align-items: center; justify-content: space-between; padding: 0 14px; border-bottom: 1px solid #232a36; background: #11151d; }
.tasnim-wordmark { display: inline-flex; align-items: center; gap: 8px; color: #f2f4f8; font-size: 13px; font-weight: 700; }
.tasnim-wordmark b { display: grid; width: 22px; height: 22px; place-items: center; border: 1px solid #303949; border-radius: 5px; background: #1b2230; color: #dce5f4; font-size: 13px; }
.portal-language { display: flex; align-items: center; padding: 0 7px; border: 1px solid #2b3342; border-radius: 7px; background: #171d28; color: #aab6ca; }
.portal-language select { width: 33px; height: 24px; appearance: none; border: 0; outline: 0; background: transparent; color: inherit; font: inherit; font-size: 11px; }
.portal-language svg { pointer-events: none; }
.portal-login-content { display: grid; flex: 1 1 auto; min-height: 0; place-items: center; overflow-y: auto; padding: 29px 16px 19px; }
.portal-login-card { width: min(100%, 360px); padding: 24px 24px 26px; border: 1px solid #252d3b; border-radius: 12px; background: #171c26; box-shadow: 0 12px 28px rgb(0 0 0 / 20%); }
.portal-login-heading { margin: 0 0 14px; }
.portal-login-icon { display: grid; width: 40px; height: 40px; margin-bottom: 11px; place-items: center; border-radius: 10px; background: #6259f5; color: #fff; }
.portal-login-heading h1 { margin: 0 0 6px; color: #f0f2f8; font-size: 19px; font-weight: 600; line-height: 1.35; }
.portal-login-heading p { margin: 0; color: #9ba7bb; font-size: 12px; line-height: 1.5; }
.portal-login-form { display: flex; flex-direction: column; gap: 11px; }
.portal-phone-field, .portal-password-field { display: flex; flex-direction: column; gap: 5px; color: #9ba7bb; font-size: 11px; }
.portal-input-shell { display: flex; min-height: 38px; align-items: center; gap: 9px; padding: 0 11px; border: 1px solid #2a3342; border-radius: 8px; background: #11161f; color: #8fa2bf; }
.portal-input-shell:focus-within { border-color: #665ef6; box-shadow: 0 0 0 1px rgb(102 94 246 / 12%); }
.portal-input-shell b { color: #e4eaf4; font-size: 12px; font-weight: 600; }
.portal-input-shell input { width: 100%; min-width: 0; border: 0; outline: 0; background: transparent; color: #edf1f8; font: inherit; font-size: 12px; }
.portal-input-shell input::placeholder { color: #73839e; }
.portal-password-field .portal-input-shell button { display: grid; width: 24px; height: 28px; flex: 0 0 auto; place-items: center; border: 0; background: transparent; color: #8fa2bf; cursor: pointer; }
.portal-login-error { display: flex; align-items: center; gap: 6px; margin: 0; color: #ff8791; font-size: 11px; }
.portal-login-submit { display: flex; min-height: 40px; align-items: center; justify-content: center; gap: 8px; margin-top: 2px; border: 0; border-radius: 8px; background: #6259f5; color: #fff; cursor: pointer; font: inherit; font-size: 13px; font-weight: 650; }
.portal-login-submit:disabled { cursor: not-allowed; opacity: .7; }
.portal-login-security { display: flex; align-items: center; justify-content: center; gap: 6px; margin: 12px 0 0; color: #8fa2bf; font-size: 11px; }
.portal-login-status { color: #d8b76f; }
.portal-spin { animation: portal-spin 1s linear infinite; }
@keyframes portal-spin { to { transform: rotate(360deg); } }
.sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }

@media (max-width: 480px) {
  .portal-login-content { padding: 10px 16px 8px; }
  .portal-login-card { padding: 16px 20px 14px; }
}
</style>
