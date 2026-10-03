<!-- TEACHER MODE: shared portal's student role view -->
<template>
  <div ref="localizedRoot" class="student-portal">
    <header class="student-portal-header">
      <a class="student-portal-brand" href="/teacher.html"><span>T</span>Tasnim</a>
      <nav aria-label="Talaba paneli bo'limlari">
        <button v-for="tab in tabs" :key="tab.id" :class="{ active: activeTab === tab.id }" @click="activeTab = tab.id">
          <component :is="tab.icon" :size="16" />{{ tab.label }}
        </button>
      </nav>
      <button class="student-language-switch" :aria-label="locale === 'uz' ? 'Русский' : 'O‘zbekcha'" @click="toggleLanguage">{{ locale.toUpperCase() }}</button>
      <button class="student-logout" @click="emit('logout')"><LogOut :size="16" />Chiqish</button>
    </header>

    <main class="student-portal-main">
      <div class="student-page-heading"><div><span class="student-kicker">TALABA PANELI</span><h1>{{ data.student?.full_name || 'Shaxsiy kabinet' }}</h1></div><span class="student-role-chip">O'quvchi</span></div>
      <div v-if="loadError" class="student-state error" role="alert"><CircleAlert :size="18" />{{ loadError }}</div>
      <div v-else-if="loading" class="student-state"><LoaderCircle class="student-spin" :size="18" />Ma'lumotlar yuklanmoqda...</div>

      <template v-else>
        <section v-if="activeTab === 'profile'" class="student-profile-grid">
          <article class="student-panel profile-summary">
            <div class="student-avatar">{{ initials }}</div><h2>{{ data.student.full_name }}</h2><span class="student-status">{{ data.student.status }}</span>
            <div class="student-info-list">
              <div><span>Telefon</span><b>{{ data.student.phone }}</b></div>
              <div><span>Tug'ilgan sana</span><b>{{ formatDate(data.student.birth_date) }}</b></div>
              <div><span>Guruhlar</span><b>{{ data.groups.length }}</b></div>
              <div><span>Reyting</span><b>{{ data.student.rating ?? '—' }}</b></div>
            </div>
          </article>
          <div class="student-profile-content">
            <section class="student-panel"><header class="student-section-head"><div><h2>Mening guruhlarim</h2><p>Biriktirilgan kurs va dars vaqtlari</p></div><BookOpenCheck :size="18" /></header>
              <div v-if="data.groups.length" class="student-group-list">
                <article v-for="group in data.groups" :key="group.id" class="student-group-item"><div><b>{{ group.name }}</b><span>{{ group.course_name }} · {{ group.teacher_name }}</span></div><span class="student-group-time">{{ group.lesson_start?.slice(0, 5) || '—' }}–{{ group.lesson_end?.slice(0, 5) || '—' }}</span></article>
              </div><div v-else class="student-empty compact"><UsersRound :size="19" />Guruhlar mavjud emas</div>
            </section>
            <section class="student-panel"><header class="student-section-head"><div><h2>Testlar va imtihonlar</h2><p>Natijalar va rejalashtirilgan imtihonlar</p></div><ClipboardCheck :size="18" /></header>
              <div v-if="data.results.length" class="student-result-list"><div v-for="result in data.results" :key="result.id"><span>{{ result.exams?.title || 'Imtihon' }}</span><b>{{ result.score ?? '—' }}<small v-if="result.max_score"> / {{ result.max_score }}</small></b></div></div>
              <div v-else class="student-empty compact"><ClipboardList :size="19" />Test va imtihon natijalari mavjud emas</div>
            </section>
          </div>
        </section>

        <section v-else-if="activeTab === 'payments'" class="student-panel student-table-panel">
          <header class="student-section-head"><div><h2>To'lovlar</h2><p>Shaxsiy to'lovlar tarixi</p></div><CreditCard :size="18" /></header>
          <div v-if="data.payments.length" class="student-table-scroll"><table class="student-table"><thead><tr><th>Sana</th><th>Guruh</th><th>Turi</th><th>Summa</th><th>Qaytarilgan</th><th>Bonus</th><th>Usul</th></tr></thead><tbody><tr v-for="payment in data.payments" :key="payment.id"><td>{{ formatDate(payment.payment_date) }}</td><td>{{ groupName(payment.group_id) }}</td><td><span class="payment-chip" :class="payment.payment_type">{{ payment.payment_type === 'paid' ? "To'landi" : payment.payment_type === 'debt' ? 'Qarzdorlik' : 'Qaytarildi' }}</span></td><td>{{ money(payment.amount) }} UZS</td><td>{{ money(payment.refunded_amount) }} UZS</td><td>{{ money(payment.bonus) }} UZS</td><td>{{ payment.payment_method || '—' }}</td></tr></tbody></table></div>
          <div v-else class="student-empty"><CreditCard :size="22" />To'lovlar mavjud emas</div>
        </section>

        <section v-else-if="activeTab === 'coins'" class="student-coins-page">
          <div class="coins-banner"><div><span>YIG'ILGAN COINLAR</span><h2>🪙 {{ coinBalance }}</h2><p>Coinlar bo'yicha reyting: {{ coinRank }}</p></div><Sparkles :size="38" /></div>
          <section class="student-panel"><header class="student-section-head"><div><h2>Coinlar do'koni</h2><p>Coin evaziga olinadigan mahsulotlar</p></div></header>
            <div class="coins-toolbar"><label class="student-search"><Search :size="15" /><input v-model="coinSearch" placeholder="Mahsulot qidirish" /></label><select v-model="coinCategory"><option value="">Barcha kategoriyalar</option><option v-for="category in coinCategories" :key="category">{{ category }}</option></select><label class="only-affordable"><input v-model="onlyAffordable" type="checkbox" />Faqat yetadiganlari</label></div>
            <div v-if="visibleProducts.length" class="product-grid"><article v-for="product in visibleProducts" :key="product.id" class="product-card"><img v-if="product.image_url" :src="product.image_url" :alt="product.name" /><div v-else class="product-image-placeholder"><Gift :size="24" /></div><span>{{ product.category || 'Mahsulot' }}</span><h3>{{ product.name }}</h3><b>🪙 {{ product.coin_price }}</b></article></div>
            <div v-else class="student-empty compact"><ShoppingBag :size="20" />Mahsulotlar mavjud emas</div>
          </section>
        </section>

        <section v-else-if="activeTab === 'materials'" class="student-panel"><header class="student-section-head"><div><h2>Darsliklar <span class="beta-chip">BETA</span></h2><p>Guruhlaringizga biriktirilgan dars materiallari</p></div><BookOpen :size="18" /></header><div v-if="data.materials.length" class="material-list"><a v-for="material in data.materials" :key="material.id" :href="material.file_url" target="_blank" rel="noreferrer"><FileText :size="18" /><span><b>{{ material.title }}</b><small>{{ material.topic || 'Mavzusiz' }}</small></span><ExternalLink :size="15" /></a></div><div v-else class="student-empty"><BookOpen :size="22" />Darsliklar hozircha mavjud emas</div></section>

        <section v-else-if="activeTab === 'courses'" class="student-panel"><header class="student-section-head"><div><h2>Mening kurslarim</h2><p>Faol va oldingi guruhlar</p></div><GraduationCap :size="18" /></header><div v-if="data.groups.length" class="student-course-list"><article v-for="group in data.groups" :key="group.id"><div class="student-course-icon"><BookOpenCheck :size="17" /></div><div><b>{{ group.course_name }}</b><span>{{ group.name }} · {{ group.teacher_name }}</span></div><span class="student-course-status">{{ group.status === 'active' ? 'Faol' : group.status }}</span></article></div><div v-else class="student-empty"><GraduationCap :size="22" />Kurslar mavjud emas</div></section>

        <section v-else class="student-panel"><header class="student-section-head"><div><h2>Support bilan dars</h2><p>Qo'shimcha mashg'ulotlar jadvali</p></div><Headphones :size="18" /></header><div v-if="data.support.length" class="support-list"><article v-for="session in data.support" :key="session.id"><CalendarDays :size="17" /><div><b>{{ formatDateTime(session.starts_at) }}</b><span>{{ groupName(session.group_id) }} · {{ session.status }}</span></div></article></div><div v-else class="student-empty"><Headphones :size="22" />Support darslari rejalashtirilmagan</div></section>
      </template>
    </main>
  </div>
</template>

<script setup>
/* TEACHER MODE: authenticated, read-only student view */
import { computed, ref } from 'vue'
import {
  BookOpen, BookOpenCheck, CalendarDays, CircleAlert, ClipboardCheck, ClipboardList,
  CreditCard, ExternalLink, FileText, Gift, GraduationCap, Headphones, LoaderCircle,
  LogOut, Search, ShoppingBag, Sparkles, UsersRound,
} from 'lucide-vue-next'
import { loadStudentData } from './teacherService.js'
import { locale, setLocale, useLocalizedDOM } from '../locale.js'

const props = defineProps({ session: { type: Object, required: true } })
const emit = defineEmits(['logout'])
const localizedRoot = ref(null)
useLocalizedDOM(localizedRoot)
function toggleLanguage() {
  setLocale(locale.value === 'uz' ? 'ru' : 'uz')
}
const loading = ref(true)
const loadError = ref('')
const data = ref({ student: null, groups: [], payments: [], coins: [], products: [], materials: [], results: [], support: [] })
const activeTab = ref('profile')
const coinSearch = ref('')
const coinCategory = ref('')
const onlyAffordable = ref(false)
const tabs = [
  { id: 'profile', label: 'Profil', icon: UsersRound },
  { id: 'payments', label: "To'lovlar", icon: CreditCard },
  { id: 'coins', label: "Yig'ilgan coinlar", icon: Sparkles },
  { id: 'materials', label: 'Darsliklar', icon: BookOpen },
  { id: 'courses', label: 'Mening kurslarim', icon: GraduationCap },
  { id: 'support', label: 'Support bilan dars', icon: Headphones },
]
const initials = computed(() => data.value.student?.full_name?.split(/\s+/).map((part) => part[0]).slice(0, 2).join('').toUpperCase() || '?')
const coinBalance = computed(() => data.value.coins.reduce((sum, item) => sum + item.amount, 0))
const coinRank = computed(() => '—')
const coinCategories = computed(() => [...new Set(data.value.products.map((product) => product.category).filter(Boolean))])
const visibleProducts = computed(() => {
  const query = coinSearch.value.trim().toLocaleLowerCase('uz-UZ')
  return data.value.products.filter((product) =>
    (!query || `${product.name} ${product.category || ''}`.toLocaleLowerCase('uz-UZ').includes(query))
    && (!coinCategory.value || product.category === coinCategory.value)
    && (!onlyAffordable.value || product.coin_price <= coinBalance.value),
  )
})
const moneyFormatter = computed(() => new Intl.NumberFormat(locale.value === 'ru' ? 'ru-RU' : 'uz-UZ', { maximumFractionDigits: 0 }))

loadStudentData(props.session.user.id)
  .then((result) => { data.value = result })
  .catch((error) => { loadError.value = error.message || "Ma'lumotlarni yuklashda xatolik yuz berdi." })
  .finally(() => { loading.value = false })

function money(value) {
  return moneyFormatter.value.format(Number(value) || 0).replace(/[\u00a0\u202f,]/g, ' ')
}
function formatDate(value) {
  if (!value) return '—'
  return new Intl.DateTimeFormat(locale.value === 'ru' ? 'ru-RU' : 'uz-UZ', { dateStyle: 'medium', timeZone: 'UTC' }).format(new Date(`${value}T00:00:00Z`))
}
function formatDateTime(value) {
  if (!value) return 'Vaqt belgilanmagan'
  return new Intl.DateTimeFormat(locale.value === 'ru' ? 'ru-RU' : 'uz-UZ', { dateStyle: 'medium', timeStyle: 'short' }).format(new Date(value))
}
function groupName(id) {
  return data.value.groups.find((group) => group.id === id)?.name || 'Guruh'
}
</script>

<style scoped>
.student-portal { min-height: 100dvh; background: var(--bg); color: var(--ink); font-family: Inter, system-ui, sans-serif; }
.student-portal-header { position: sticky; top: 0; z-index: 30; display: flex; min-height: 62px; align-items: center; gap: 20px; padding: 0 28px; border-bottom: 1px solid var(--line); background: var(--surface); }
.student-portal-brand { display: flex; align-items: center; gap: 8px; color: var(--ink); font-size: 14px; font-weight: 700; text-decoration: none; }
.student-portal-brand span { display: grid; width: 30px; height: 30px; place-items: center; border-radius: 8px; background: #6366f1; color: white; }
.student-portal-header nav { display: flex; min-width: 0; flex: 1; gap: 4px; overflow-x: auto; }
.student-portal-header nav button { display: flex; min-height: 37px; flex: 0 0 auto; align-items: center; gap: 7px; padding: 0 10px; border: 0; border-radius: 7px; background: transparent; color: var(--ink-soft); cursor: pointer; font: inherit; font-size: 10px; white-space: nowrap; }
.student-portal-header nav button.active { background: #6366f1; color: white; }
.student-logout { display: flex; align-items: center; gap: 6px; padding: 7px 10px; border: 1px solid var(--line); border-radius: 7px; background: var(--surface); color: var(--ink-soft); cursor: pointer; font: inherit; font-size: 10px; }
.student-language-switch { flex: 0 0 auto; padding: 6px 9px; border: 1px solid var(--line); border-radius: 7px; background: var(--surface); color: var(--ink); cursor: pointer; font: inherit; font-size: 10px; font-weight: 700; }
.student-portal-main { width: min(1120px, calc(100% - 40px)); margin: 0 auto; padding: 26px 0 46px; }
.student-page-heading { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; }
.student-kicker { color: #6366f1; font-size: 9px; font-weight: 700; letter-spacing: 1px; }
.student-page-heading h1 { margin: 5px 0 0; font-size: 22px; font-weight: 650; }
.student-role-chip, .student-status, .student-course-status { padding: 5px 9px; border-radius: 999px; background: #e6f5eb; color: #16834c; font-size: 9px; font-weight: 650; }
.student-state, .student-empty { display: flex; min-height: 210px; flex-direction: column; align-items: center; justify-content: center; gap: 8px; border: 1px dashed var(--line); border-radius: 10px; color: var(--ink-soft); font-size: 11px; text-align: center; }
.student-state.error { flex-direction: row; color: #c8424e; }
.student-panel { min-width: 0; padding: 16px; border: 1px solid var(--line); border-radius: 9px; background: var(--surface); }
.student-profile-grid { display: grid; grid-template-columns: 255px minmax(0, 1fr); align-items: start; gap: 15px; }
.profile-summary { text-align: center; }
.student-avatar { display: grid; width: 56px; height: 56px; place-items: center; margin: 4px auto 9px; border-radius: 50%; background: #eef0ff; color: #5559df; font-size: 17px; font-weight: 700; }
.profile-summary h2 { margin: 0 0 8px; font-size: 15px; }
.student-info-list { display: flex; flex-direction: column; gap: 12px; margin-top: 15px; padding-top: 13px; border-top: 1px solid var(--line); text-align: left; }
.student-info-list div { display: flex; flex-direction: column; gap: 3px; }
.student-info-list span, .student-info-list b { font-size: 10px; }
.student-info-list span { color: var(--ink-soft); }
.student-info-list b { overflow-wrap: anywhere; font-weight: 550; }
.student-profile-content { display: flex; flex-direction: column; gap: 13px; }
.student-section-head { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 12px; color: #6366f1; }
.student-section-head h2 { margin: 0; color: var(--ink); font-size: 14px; font-weight: 650; }
.student-section-head p { margin: 3px 0 0; color: var(--ink-soft); font-size: 10px; }
.student-group-list { display: flex; flex-direction: column; }
.student-group-item { display: flex; justify-content: space-between; gap: 10px; padding: 11px 0; border-top: 1px solid var(--line); }
.student-group-item > div, .student-course-list article > div:nth-child(2) { display: flex; min-width: 0; flex-direction: column; gap: 4px; }
.student-group-item b, .student-course-list b { font-size: 11px; }
.student-group-item span { color: var(--ink-soft); font-size: 9px; }
.student-group-time { flex: 0 0 auto; }
.student-empty.compact { min-height: 90px; border: 0; }
.student-result-list > div { display: flex; justify-content: space-between; padding: 10px 0; border-top: 1px solid var(--line); color: var(--ink-soft); font-size: 10px; }
.student-result-list b { color: var(--ink); }
.student-result-list small { color: var(--ink-soft); font-weight: 400; }
.student-table-panel { overflow: hidden; }
.student-table-scroll { overflow-x: auto; }
.student-table { width: 100%; min-width: 670px; border-collapse: collapse; text-align: left; white-space: nowrap; }
.student-table th { height: 37px; padding: 0 10px; border-bottom: 1px solid var(--line); background: var(--bg); color: var(--ink-soft); font-size: 9px; }
.student-table td { height: 42px; padding: 0 10px; border-bottom: 1px solid var(--line); color: var(--ink); font-size: 10px; }
.student-table tr:last-child td { border-bottom: 0; }
.payment-chip { padding: 4px 7px; border-radius: 999px; background: #e6f5eb; color: #16834c; font-size: 9px; }
.payment-chip.debt { background: #fff0e8; color: #c24c3b; }
.coins-banner { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; padding: 19px 22px; border-radius: 10px; background: linear-gradient(115deg, #595de2, #7775fa); color: white; }
.coins-banner span { font-size: 9px; font-weight: 700; letter-spacing: 1px; }
.coins-banner h2 { margin: 7px 0 3px; font-size: 23px; }
.coins-banner p { margin: 0; font-size: 10px; opacity: .8; }
.coins-toolbar { display: flex; flex-wrap: wrap; align-items: center; gap: 8px; margin: 14px 0; }
.student-search { display: flex; height: 34px; flex: 1 1 180px; align-items: center; gap: 7px; padding: 0 9px; border: 1px solid var(--line); border-radius: 7px; color: var(--ink-soft); }
.student-search input { width: 100%; border: 0; outline: 0; background: transparent; color: var(--ink); font: inherit; font-size: 10px; }
.coins-toolbar select { height: 34px; padding: 0 9px; border: 1px solid var(--line); border-radius: 7px; background: var(--surface); color: var(--ink); font-size: 10px; }
.only-affordable { display: flex; align-items: center; gap: 5px; color: var(--ink-soft); font-size: 10px; }
.only-affordable input { accent-color: #6366f1; }
.product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 10px; }
.product-card { padding: 10px; border: 1px solid var(--line); border-radius: 8px; }
.product-card img, .product-image-placeholder { display: grid; width: 100%; height: 96px; place-items: center; margin-bottom: 8px; border-radius: 6px; background: var(--bg); color: var(--ink-soft); object-fit: cover; }
.product-card > span { color: var(--ink-soft); font-size: 8px; }
.product-card h3 { margin: 4px 0 8px; font-size: 11px; }
.product-card > b { color: #6366f1; font-size: 10px; }
.beta-chip { margin-left: 5px; padding: 3px 5px; border-radius: 4px; background: #fff3d8; color: #a66b0c; font-size: 8px; vertical-align: 2px; }
.material-list { display: flex; flex-direction: column; }
.material-list a { display: flex; align-items: center; gap: 10px; padding: 12px 2px; border-top: 1px solid var(--line); color: #6366f1; text-decoration: none; }
.material-list a span { display: flex; flex: 1; flex-direction: column; gap: 3px; color: var(--ink); }
.material-list a b { font-size: 10px; }
.material-list a small { color: var(--ink-soft); font-size: 9px; }
.student-course-list article, .support-list article { display: flex; align-items: center; gap: 10px; padding: 11px 0; border-top: 1px solid var(--line); }
.student-course-icon { display: grid; width: 33px; height: 33px; place-items: center; border-radius: 8px; background: #eef0ff; color: #6366f1; }
.student-course-list article > div:nth-child(2) { flex: 1; }
.student-course-list article span { color: var(--ink-soft); font-size: 9px; }
.support-list article > div { display: flex; flex-direction: column; gap: 3px; }
.support-list article b { font-size: 10px; }
.support-list article span { color: var(--ink-soft); font-size: 9px; }

@media (max-width: 780px) {
  .student-portal-header { flex-wrap: wrap; gap: 8px; padding: 9px 14px; }
  .student-portal-header nav { order: 3; width: 100%; flex-basis: 100%; }
  .student-portal-header nav button { padding: 0 8px; font-size: 9px; }
  .student-portal-main { width: calc(100% - 26px); padding-top: 19px; }
  .student-profile-grid { grid-template-columns: minmax(0, 1fr); }
  .profile-summary { text-align: left; }
  .student-avatar { margin: 0 0 9px; }
}
</style>
