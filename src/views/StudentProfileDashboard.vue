<template>
  <main v-if="profile" class="student-profile-page">
    <section class="profile-grid">
      <article class="student-card" aria-label="O'quvchi kartasi">
        <div class="student-accent"></div>
        <div class="student-main">
          <div class="student-balance">{{ money(student.balance) }} so'm</div>
          <div class="student-identity">
            <div class="student-avatar">{{ student.name.slice(0, 1).toLowerCase() }}</div>
            <div class="student-name-area">
              <h1>{{ student.name }}</h1>
              <div class="student-meta">
                <span class="rating">Baho: {{ Number(student.rating).toFixed(2) }}</span>
                <img v-if="qrCode" :src="qrCode" alt="O'quvchi QR kodi" class="qr-code" />
              </div>
              <span class="student-id">ID: {{ student.id }}</span>
            </div>
          </div>
          <div class="student-fields">
            <div><span>Telefon raqam :</span><strong>{{ student.phone }}</strong></div>
            <div><span>Tug'ilgan sanasi :</span><strong>{{ student.birthDate }}</strong></div>
          </div>
          <div class="app-status"><span>Ilova holati :</span><b>Ilova ishlatmaydi</b></div>
        </div>
        <div class="student-actions">
          <button class="action-button outline" type="button" @click="openAdditionalInfo">O'QUVCHIGA QO'SHIMCHA MA'LUMOT QO'SHISH</button>
          <div class="button-row">
            <button class="action-button primary" type="button" @click="openGroupAssignment">＋ GURUHGA QO'SHISH</button>
            <button class="action-button outline" type="button" @click="openPaymentForm"><CreditCard :size="13" /> TO'LOV QILISH</button>
          </div>
          <button class="action-button danger" type="button" @click="confirmAction('refund')"><Wallet :size="13" /> PUL QAYTARISH</button>
          <button class="action-button outline" type="button" @click="notify('Beyjik chiqarish')"><ContactRound :size="13" /> BEYJIK CHIQARISH</button>
          <button class="action-button danger" type="button" @click="confirmAction('blacklist')"><Shield :size="13" /> QORA RO'YXATGA OLISH</button>
          <div class="button-row icon-actions">
            <button class="action-button outline" aria-label="Izoh" title="Izoh" @click="notify('Izoh yozish')"><MessageSquareText :size="13" /></button>
            <button class="action-button outline" aria-label="Tahrirlash" title="Tahrirlash" @click="openStudentEdit"><Pencil :size="13" /></button>
          </div>
        </div>
      </article>

      <section class="profile-right">
        <div class="help-row">
          <button class="help-button" type="button" @click="notify('O‘quvchilar sahifasi bo‘yicha qo‘llanma')">
            <CirclePlay :size="13" /> O'quvchilar sahifasidan qanday foydalaniladi?
          </button>
        </div>
        <div class="tabs-wrap">
          <div class="tabs" role="tablist" aria-label="O'quvchi bo'limlari">
            <button v-for="tab in tabs" :key="tab.label" class="tab-button" :class="{ active: activeTab === tab.label }" role="tab" :aria-selected="activeTab === tab.label" @click="activeTab = tab.label">
              <component :is="tab.icon" :size="13" /> {{ tab.label }}
            </button>
          </div>
          <button class="tab-next" aria-label="Tablarni o'ngga surish" @click="scrollTabs"><ChevronRight :size="15" /></button>
        </div>

        <article v-if="activeTab === 'GURUHLAR'" class="group-card">
          <header class="group-header">
            <div class="group-wallet"><Wallet :size="12" /><span>{{ money(group.balance) }} so'm</span></div>
            <div class="group-controls">
              <label class="status-select"><select v-model="group.status" aria-label="Guruh holati"><option>Faol</option><option>Muzlatilgan</option><option>Tugatilgan</option></select><ChevronDown :size="12" /></label>
              <button aria-label="Guruh menyusi" class="more-button" @click="notify('Guruh amallari')"><MoreVertical :size="15" /></button>
            </div>
          </header>
          <div class="group-body">
            <div class="group-title"><h2>{{ group.name }}</h2><span class="rating">Baho: {{ Number(group.rating).toFixed(2) }}</span></div>
            <div class="group-info"><span>Guruh intervali :</span><strong>{{ group.intervalStartDate }}/{{ group.endDate }}</strong></div>
            <div class="teacher"><GraduationCap :size="12" /> {{ group.teacher }}</div>
            <div class="group-info"><span>Dars vaqti :</span><strong>{{ group.lessonTime }}</strong></div>
            <div class="lesson-days"><span>Dars kunlari :</span><div><b v-for="day in group.lessonDays" :key="day">{{ day }}</b></div></div>
            <div class="date-pair">
              <div><span>Boshlangan sana</span><strong class="start-date"><CalendarDays :size="11" /> {{ group.startDate }}</strong></div>
              <div><span>O'chiriladigan sana</span><strong class="end-date"><CalendarDays :size="11" /> {{ group.endDate }}</strong></div>
            </div>
            <div class="payment-pair">
              <div><b>Keyingi to'lov</b><span><Clock3 :size="11" /> {{ group.nextPaymentDate }}</span></div>
              <div><b>To'lov narxi</b><strong>{{ money(group.price) }} so'm</strong></div>
            </div>
            <hr />
            <section class="attendance">
              <div class="calendar-heading">
                <button aria-label="Oldingi oy" @click="shiftMonth(-1)"><ChevronLeft :size="13" /></button>
                <h3>Darslar taqvimi ({{ monthLabel }})</h3>
                <button aria-label="Keyingi oy" @click="shiftMonth(1)"><ChevronRight :size="13" /></button>
              </div>
              <div class="stats">
                <span class="came">Kelgan: {{ attendance.stats.came }}</span>
                <span class="absent">Kelmagan: {{ attendance.stats.absent }}</span>
                <span class="excused">Sababli kelmagan: {{ attendance.stats.excused }}</span>
                <span class="not-done">Qilinmagan: {{ attendance.stats.notDone }}</span>
              </div>
              <div class="calendar-days">
                <div v-for="entry in calendarDays" :key="entry.day" class="day-cell" :class="entry.status" :title="statusLabel(entry.status)">
                  {{ entry.day }}<i v-if="entry.status === 'absent'"></i>
                </div>
              </div>
              <div class="legend">
                <span><i class="paid"></i>To'langan</span><span><i class="debt"></i>Qarzdor</span><span><i class="excused-key"></i>Sababli kelmagan</span><span><i class="pending"></i>Kutilayotgan</span><span><i class="absent-dot"></i>Kelmagan</span>
              </div>
            </section>
          </div>
        </article>
        <div v-else class="empty-tab">{{ activeTab }} bo'limida hozircha ma'lumot yo'q.</div>
      </section>
    </section>

    <section class="history-section">
      <div class="history-heading">
        <h2>To'lov tarixi</h2>
        <button class="archive-button" @click="showArchived = !showArchived"><Download :size="11" /> {{ showArchived ? "FAOL GURUHLARNI KO'RISH" : "ARXIVDAGI GURUHLARNI KO'RISH" }}</button>
      </div>
      <div class="history-tools">
        <button class="excel-button" aria-label="Excelga yuklab olish" @click="exportCsv"><FileSpreadsheet :size="14" /></button>
        <label class="group-filter"><span class="sr-only">Guruh</span><select v-model="selectedGroup"><option value="">Guruh</option><option v-for="name in groupNames" :key="name">{{ name }}</option></select><ChevronDown :size="12" /></label>
        <label class="date-filter"><span>To'lov sanasi</span><input v-model="selectedDate" type="date" aria-label="To'lov sanasi" /></label>
      </div>
      <div class="history-table-wrap">
        <div class="history-table-scroll">
          <table class="history-table">
            <thead><tr><th>ID</th><th>Sana</th><th>Qaysi oy uchun</th><th>Turi</th><th>Summa</th><th>Qaytarilgan summa</th><th>Bonus</th><th>Guruh</th><th>Izoh</th><th>Yaratilgan vaqt</th><th>To'lov turi</th><th>Qabul qilgan</th><th>Amallar</th></tr></thead>
            <tbody>
              <tr v-for="payment in filteredPayments" :key="payment.id">
                <td>{{ payment.id }}</td><td>{{ payment.date }}</td><td>{{ payment.month }}</td>
                <td><span class="payment-status" :class="payment.type">{{ payment.type === 'paid' ? "To'landi" : 'Qarzdorlik' }}</span></td>
                <td>{{ money(payment.amount) }} UZS</td><td>{{ money(payment.refunded) }} UZS</td><td>{{ money(payment.bonus) }} UZS</td>
                <td>{{ payment.group }}</td><td>{{ payment.comment }}</td><td>{{ payment.createdAt }}</td><td>{{ payment.method }}</td><td>{{ payment.receivedBy }}</td>
                <td><div class="row-actions"><button aria-label="Tahrirlash" @click="notify('To‘lovni tahrirlash')"><Pencil :size="12" /></button><button v-if="payment.type === 'paid'" aria-label="O'chirish" @click="notify('To‘lovni o‘chirish')"><Trash2 :size="12" /></button><button v-if="payment.type === 'paid'" aria-label="Izoh" @click="notify('To‘lov izohi')"><MessageSquareText :size="12" /></button></div></td>
              </tr>
              <tr v-if="!filteredPayments.length"><td class="empty-row" colspan="13">To'lov tarixi topilmadi</td></tr>
            </tbody>
          </table>
        </div>
        <div class="scrollbar-track"><span></span></div>
      </div>
    </section>

    <Transition name="toast"><div v-if="notice" class="notice" role="status">{{ notice }}</div></Transition>
    <Teleport to="body">
      <div v-if="showStudentEdit" class="modal-backdrop" @click.self="closeStudentEdit">
        <form class="student-edit-modal" role="dialog" aria-modal="true" aria-labelledby="student-edit-title" @submit.prevent="saveStudentEdit">
          <h2 id="student-edit-title">O'quvchi ma'lumotlarini tahrirlash</h2>
          <input ref="photoInput" class="sr-only" type="file" accept="image/*" aria-label="O'quvchi rasmini tanlash" @change="updateStudentPhoto" />
          <button class="student-photo-button" type="button" aria-label="Rasm tanlash" @click="photoInput?.click()">
            <img v-if="studentPhoto" :src="studentPhoto" alt="O'quvchi rasmi" />
            <span v-else><Camera :size="25" :stroke-width="1.8" /><Plus :size="15" :stroke-width="2" /></span>
          </button>
          <label class="student-edit-field">
            <span>Ism familiya</span>
            <input v-model="editedStudent.name" type="text" autocomplete="name" required />
          </label>
          <label class="student-edit-field">
            <span>Telefon raqam</span>
            <input v-model="editedStudent.phone" type="tel" autocomplete="tel" required />
          </label>
          <label class="student-edit-field student-birth-field">
            <span>Tug'ilgan sana</span>
            <input v-model="editedStudent.birthDate" type="date" required />
            <CalendarDays :size="16" aria-hidden="true" />
          </label>
          <div class="student-edit-actions">
            <button class="student-edit-save" type="submit">SAQLASH</button>
            <button class="student-edit-cancel" type="button" @click="closeStudentEdit">BEKOR QILISH</button>
          </div>
        </form>
      </div>
      <div v-if="showAdditionalInfo" class="modal-backdrop" @click.self="closeAdditionalInfo">
        <form class="additional-info-modal" role="dialog" aria-modal="true" aria-labelledby="additional-info-title" @submit.prevent="saveAdditionalInfo">
          <h2 id="additional-info-title">Yangi Ma'lumot Qo'shish</h2>
          <div class="additional-info-fields">
            <input
              v-for="(name, index) in additionalInfoNames"
              :key="index"
              v-model="additionalInfoNames[index]"
              :aria-label="`Ma'lumot nomi ${index + 1}`"
              placeholder="Ma'lumot nomi"
              type="text"
              :autofocus="index === 0"
            />
          </div>
          <button class="create-info-button" type="button" @click="additionalInfoNames.push('')">
            <Plus :size="16" :stroke-width="2" aria-hidden="true" />
            YANGI YARATISH
          </button>
          <div class="additional-info-actions">
            <button class="cancel-info-button" type="button" @click="closeAdditionalInfo">BEKOR QILISH</button>
            <button class="save-info-button" type="submit">SAQLASH</button>
          </div>
        </form>
      </div>
      <div v-if="showGroupAssignment" class="modal-backdrop group-modal-backdrop" @click.self="closeGroupAssignment">
        <form class="group-assignment-modal" role="dialog" aria-modal="true" aria-labelledby="group-assignment-title" @submit.prevent="saveGroupAssignment">
          <h2 id="group-assignment-title">Guruhga biriktirish</h2>
          <p class="group-modal-help">* Guruhni tezroq topish uchun quyidagi filtrlardan foydalanishingiz mumkin</p>
          <div class="group-filter-row">
            <label><span class="sr-only">Filial</span><select v-model="groupFilters.branch"><option value="">Filial</option><option>Tasnim filiali</option></select><ChevronDown :size="14" /></label>
            <label><span class="sr-only">Ustoz</span><select v-model="groupFilters.teacher"><option value="">Ustoz</option><option>{{ group.teacher }}</option></select><ChevronDown :size="14" /></label>
            <label><span class="sr-only">Kurslar</span><select v-model="groupFilters.course"><option value="">Kurslar</option><option>Computer savodxonligi</option></select><ChevronDown :size="14" /></label>
          </div>
          <label class="group-choice">
            <span class="sr-only">Guruh</span>
            <select v-model="selectedGroupName"><option value="">Guruh</option><option>{{ group.name }}</option></select>
            <ChevronDown :size="15" />
          </label>
          <button class="new-group-toggle" type="button" @click="showNewGroup = !showNewGroup">
            <Plus :size="15" :stroke-width="2" /> Yangi yaratish
          </button>
          <input v-if="showNewGroup" v-model="newGroupName" class="new-group-input" placeholder="Yangi guruh nomi" />
          <textarea v-model="groupComment" class="group-comment" placeholder="Izoh" aria-label="Izoh"></textarea>
          <div class="group-modal-actions">
            <button class="group-save-button" type="submit">SAQLASH</button>
            <button class="group-cancel-button" type="button" @click="closeGroupAssignment">BEKOR QILISH</button>
          </div>
        </form>
      </div>
      <div v-if="showPaymentForm" class="modal-backdrop payment-modal-backdrop" @click.self="closePaymentForm">
        <form class="payment-form-modal" role="dialog" aria-modal="true" aria-labelledby="payment-form-title" @submit.prevent="savePayment">
          <h2 id="payment-form-title">To'lov</h2>
          <label class="payment-method-select">
            <span class="sr-only">To'lov usulini tanlang</span>
            <select v-model="paymentMethod"><option value="">To'lov usulini tanlang</option><option>Naqt</option><option>Click</option></select>
            <ChevronDown :size="15" />
          </label>
          <div class="payment-method-buttons">
            <button type="button" :class="{ selected: paymentMethod === 'Naqt' }" @click="paymentMethod = 'Naqt'">Naqt</button>
            <button type="button" :class="{ selected: paymentMethod === 'Click' }" @click="paymentMethod = 'Click'">Click</button>
          </div>
          <label class="payment-group-select">
            <span>Qaysi guruh uchun?</span>
            <select v-model="paymentGroup"><option value="">Guruhni tanlang</option><option :value="group.name">[web1]-{{ group.name }}-({{ group.teacher }}) • {{ group.lessonTime }} -> {{ group.status }}</option></select>
            <ChevronDown :size="15" />
            <small><b>{{ money(group.balance) }} so'm</b><i>Guruh holati: {{ group.status }}</i></small>
          </label>
          <input v-model="paymentAmount" class="payment-input" type="number" min="0" step="1000" placeholder="Summa" aria-label="Summa" />
          <textarea v-model="paymentComment" class="payment-comment" placeholder="Izoh" aria-label="Izoh"></textarea>
          <input v-model="paymentBonus" class="payment-input" type="number" min="0" step="1" placeholder="O'quvchiga bonus (pul miqdorida)" aria-label="O'quvchiga bonus" />
          <label class="payment-date-input">
            <span>To'lov sanasi</span>
            <input v-model="paymentDate" type="date" aria-label="To'lov sanasi" />
            <CalendarDays :size="17" />
          </label>
          <div class="payment-modal-actions">
            <button class="payment-save-button" type="submit">SAQLASH</button>
            <button class="payment-cancel-button" type="button" @click="closePaymentForm">BEKOR QILISH</button>
          </div>
        </form>
      </div>
      <div v-if="confirmation" class="modal-backdrop" @click.self="confirmation = ''">
        <section class="confirm-modal" role="alertdialog" aria-modal="true">
          <h2>{{ confirmation === 'refund' ? "Pul qaytarishni tasdiqlash" : "Qora ro'yxatga olish" }}</h2>
          <p>{{ confirmation === 'refund' ? "O'quvchiga pul qaytarilsinmi?" : "O'quvchi qora ro'yxatga kiritilsinmi?" }}</p>
          <div><button @click="confirmation = ''">BEKOR QILISH</button><button class="danger-confirm" @click="finishConfirmation">TASDIQLASH</button></div>
        </section>
      </div>
    </Teleport>
  </main>
  <div v-else class="loading">Ma'lumotlar yuklanmoqda...</div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import QRCode from 'qrcode'
import {
  Activity, BookOpenCheck, CalendarDays, Camera, ChevronDown, ChevronLeft, ChevronRight,
  CirclePlay, Clock3, ContactRound, Download, FileSpreadsheet, GraduationCap,
  History, MessageSquareText, MoreVertical, Pencil, Phone, Plus, Shield, Trash2,
  UserRound, UsersRound, Wallet, CreditCard,
} from 'lucide-vue-next'
import { getStudentProfile } from '../services/studentProfileService.js'

const profile = ref(null)
const qrCode = ref('')
const activeTab = ref('GURUHLAR')
const month = ref('2026-09')
const showArchived = ref(false)
const selectedGroup = ref('')
const selectedDate = ref('')
const notice = ref('')
const confirmation = ref('')
const showAdditionalInfo = ref(false)
const additionalInfoNames = ref([''])
const additionalInfo = ref([])
const showStudentEdit = ref(false)
const editedStudent = ref({ name: '', phone: '', birthDate: '' })
const studentPhoto = ref('')
const photoInput = ref(null)
const showGroupAssignment = ref(false)
const groupFilters = ref({ branch: '', teacher: '', course: '' })
const selectedGroupName = ref('')
const showNewGroup = ref(false)
const newGroupName = ref('')
const groupComment = ref('')
const showPaymentForm = ref(false)
const paymentMethod = ref('')
const paymentGroup = ref('')
const paymentAmount = ref('')
const paymentComment = ref('')
const paymentBonus = ref('')
const paymentDate = ref(new Date().toISOString().slice(0, 10))
const tabs = [
  { label: 'GURUHLAR', icon: UsersRound },
  { label: "O'QUVCHI PROGRESSI", icon: Activity },
  { label: 'TEST NATIJALARI', icon: BookOpenCheck },
  { label: 'IZOH VA ESLATMALAR', icon: MessageSquareText },
  { label: 'SMS XABARLAR', icon: MessageSquareText },
  { label: "O'QUVCHI TARIXI", icon: History },
  { label: 'OTA-ONASI', icon: UserRound },
  { label: "QO'NG'IROQLAR", icon: Phone },
]
let noticeTimer

const student = computed(() => profile.value?.student)
const group = computed(() => profile.value?.group)
const attendance = computed(() => group.value?.attendanceByMonth[month.value] ?? {
  stats: { came: 0, absent: 0, excused: 0, notDone: 0 }, days: [],
})
const monthLabel = computed(() => {
  const [year, monthNumber] = month.value.split('-').map(Number)
  return new Intl.DateTimeFormat('ru-RU', { month: 'long', year: 'numeric', timeZone: 'UTC' })
    .formatToParts(new Date(Date.UTC(year, monthNumber - 1, 1)))
    .filter((part) => part.type === 'month' || part.type === 'year')
    .map((part) => part.value)
    .join(' ')
})
const calendarDays = computed(() => {
  const [year, monthNumber] = month.value.split('-').map(Number)
  const weekdays = ['yakshanba', 'dushanba', 'seshanba', 'chorshanba', 'payshanba', 'juma', 'shanba']
  const lessonDays = new Set(group.value.lessonDays.map((day) => day.toLocaleLowerCase('uz-UZ')))
  return attendance.value.days.filter((entry) => {
    const weekday = weekdays[new Date(Date.UTC(year, monthNumber - 1, entry.day)).getUTCDay()]
    return lessonDays.has(weekday)
  })
})
const groupNames = computed(() => [...new Set(profile.value?.payments.map((payment) => payment.group) ?? [])])
const filteredPayments = computed(() => profile.value?.payments.filter((payment) =>
  Boolean(payment.archived) === showArchived.value
  && (!selectedGroup.value || payment.group === selectedGroup.value)
  && (!selectedDate.value || payment.date === selectedDate.value),
) ?? [])
const moneyFormatter = new Intl.NumberFormat('uz-UZ', { maximumFractionDigits: 0 })

onMounted(async () => {
  profile.value = await getStudentProfile()
  try {
    qrCode.value = await QRCode.toDataURL(String(profile.value.student.id), { width: 36, margin: 0 })
  } catch {
    qrCode.value = ''
  }
})

function money(value) {
  return moneyFormatter.format(value).replace(/[\u00a0\u202f,]/g, ' ')
}

function displayDate(value) {
  return new Intl.DateTimeFormat('en-CA', { year: 'numeric', month: '2-digit', day: '2-digit', timeZone: 'UTC' })
    .format(new Date(`${value}T00:00:00Z`))
}

function shiftMonth(delta) {
  const [year, monthNumber] = month.value.split('-').map(Number)
  const next = new Date(Date.UTC(year, monthNumber - 1 + delta, 1))
  month.value = `${next.getUTCFullYear()}-${String(next.getUTCMonth() + 1).padStart(2, '0')}`
}

function statusLabel(status) {
  return ({ paid: "To'langan", debt: 'Qarzdor', excused: 'Sababli kelmagan', pending: 'Kutilayotgan', absent: 'Kelmagan' })[status] ?? status
}

function notify(message) {
  notice.value = message
  window.clearTimeout(noticeTimer)
  noticeTimer = window.setTimeout(() => { notice.value = '' }, 2200)
}

function openStudentEdit() {
  editedStudent.value = {
    name: student.value.name,
    phone: student.value.phone,
    birthDate: student.value.birthDate,
  }
  showStudentEdit.value = true
}

function closeStudentEdit() {
  showStudentEdit.value = false
}

function updateStudentPhoto(event) {
  const file = event.target.files?.[0]
  if (file) studentPhoto.value = URL.createObjectURL(file)
}

function saveStudentEdit() {
  Object.assign(student.value, {
    name: editedStudent.value.name.trim(),
    phone: editedStudent.value.phone.trim(),
    birthDate: editedStudent.value.birthDate,
  })
  closeStudentEdit()
  notify("O'quvchi ma'lumotlari saqlandi")
}

function openAdditionalInfo() {
  additionalInfoNames.value = ['']
  showAdditionalInfo.value = true
}

function closeAdditionalInfo() {
  showAdditionalInfo.value = false
  additionalInfoNames.value = ['']
}

function saveAdditionalInfo() {
  const names = additionalInfoNames.value.map((name) => name.trim()).filter(Boolean)
  if (!names.length) {
    notify("Ma'lumot nomini kiriting")
    return
  }

  additionalInfo.value.push(...names)
  closeAdditionalInfo()
  notify("Qo'shimcha ma'lumot saqlandi")
}

function openGroupAssignment() {
  groupFilters.value = { branch: '', teacher: '', course: '' }
  selectedGroupName.value = ''
  showNewGroup.value = false
  newGroupName.value = ''
  groupComment.value = ''
  showGroupAssignment.value = true
}

function closeGroupAssignment() {
  showGroupAssignment.value = false
}

function saveGroupAssignment() {
  const name = newGroupName.value.trim() || selectedGroupName.value
  if (!name) {
    notify('Guruhni tanlang yoki yangi guruh nomini kiriting')
    return
  }

  group.name = name
  closeGroupAssignment()
  notify(`${name} guruhiga biriktirildi`)
}

function openPaymentForm() {
  paymentMethod.value = ''
  paymentGroup.value = group.value.name
  paymentAmount.value = ''
  paymentComment.value = ''
  paymentBonus.value = ''
  paymentDate.value = new Date().toISOString().slice(0, 10)
  showPaymentForm.value = true
}

function closePaymentForm() {
  showPaymentForm.value = false
}

function savePayment() {
  const amount = Number(paymentAmount.value)
  if (!paymentMethod.value || !paymentGroup.value || !amount) {
    notify("To'lov usuli, guruh va summani kiriting")
    return
  }

  const nextId = Math.max(0, ...profile.value.payments.map((payment) => payment.id)) + 1
  const [year, monthNumber, day] = paymentDate.value.split('-')
  profile.value.payments.unshift({
    id: nextId,
    date: paymentDate.value,
    month: `${monthNumber}.${year}`,
    type: 'paid',
    amount,
    refunded: 0,
    bonus: Number(paymentBonus.value) || 0,
    group: paymentGroup.value,
    comment: paymentComment.value.trim() || '-',
    createdAt: `${paymentDate.value} ${new Date().toTimeString().slice(0, 5)}`,
    method: paymentMethod.value,
    receivedBy: 'Admin',
    archived: false,
  })
  closePaymentForm()
  notify(`${money(amount)} so'm to'lov saqlandi`)
}

function confirmAction(action) {
  confirmation.value = action
}

function finishConfirmation() {
  const action = confirmation.value === 'refund' ? 'Pul qaytarish tasdiqlandi' : "Qora ro'yxatga olish tasdiqlandi"
  confirmation.value = ''
  notify(action)
}

function scrollTabs(event) {
  event.currentTarget.parentElement.querySelector('.tabs').scrollBy({ left: 210, behavior: 'smooth' })
}

function exportCsv() {
  const headings = ['ID', 'Sana', 'Qaysi oy uchun', 'Turi', 'Summa', 'Guruh', 'Izoh']
  const rows = filteredPayments.value.map((payment) => [payment.id, payment.date, payment.month, payment.type, payment.amount, payment.group, payment.comment])
  const content = [headings, ...rows].map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(',')).join('\r\n')
  const link = document.createElement('a')
  const url = URL.createObjectURL(new Blob([content], { type: 'text/csv;charset=utf-8' }))
  link.href = url
  link.download = 'tolov-tarixi.csv'
  link.click()
  URL.revokeObjectURL(url)
}
</script>

<style scoped>
.student-profile-page {
  width: min(100%, 1065px);
  margin: 0 auto;
  padding: 12px 0 24px;
  color: var(--ink, #1b2430);
  font-family: Inter, system-ui, sans-serif;
}

.profile-grid {
  display: grid;
  grid-template-columns: 338px minmax(0, 1fr);
  align-items: start;
  gap: 16px;
}

.student-card,
.group-card {
  overflow: hidden;
  border: 1px solid var(--line, #e4e0d6);
  border-radius: 9px;
  background: var(--surface, #fff);
  box-shadow: 0 3px 12px rgb(19 27 40 / 10%);
}

.student-accent {
  height: 20px;
  background: #6662ff;
}

.student-main {
  padding: 11px 12px 9px;
}

.student-balance {
  display: block;
  width: fit-content;
  margin: -19px 0 11px auto;
  padding: 2px 7px;
  border: 1px solid #57c95b;
  border-radius: 999px;
  background: var(--surface, #fff);
  color: #38a54a;
  font-size: 9px;
  line-height: 1.2;
}

.student-identity {
  display: flex;
  align-items: flex-start;
  gap: 9px;
}

.student-avatar {
  display: grid;
  width: 52px;
  height: 52px;
  flex: 0 0 52px;
  place-items: center;
  border-radius: 7px;
  background: #eeeefe;
  color: #5c5cff;
  font-size: 20px;
  font-weight: 600;
}

.student-name-area h1 {
  margin: 1px 0 4px;
  color: var(--ink, #1b2430);
  font-size: 14px;
  font-weight: 500;
}

.student-meta {
  display: flex;
  align-items: center;
  gap: 5px;
  height: 30px;
}

.rating {
  padding: 2px 6px;
  border: 1px solid #ed5358;
  border-radius: 999px;
  color: #d8484d;
  font-size: 9px;
  line-height: 1.2;
  white-space: nowrap;
}

.qr-code {
  width: 28px;
  height: 28px;
  image-rendering: pixelated;
}

.student-id {
  color: var(--ink-soft, #697181);
  font-size: 8px;
}

.student-fields {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-top: 10px;
}

.student-fields div,
.app-status {
  display: flex;
  min-width: 0;
  flex-direction: column;
  gap: 3px;
}

.student-fields span,
.app-status > span {
  color: var(--ink-soft, #737b8a);
  font-size: 8px;
}

.student-fields strong {
  overflow: hidden;
  color: var(--ink, #1b2430);
  font-size: 9px;
  font-weight: 400;
  text-overflow: ellipsis;
}

.app-status {
  margin-top: 8px;
}

.app-status b {
  width: fit-content;
  padding: 3px 7px;
  border-radius: 999px;
  background: #f0f1f4;
  color: #777e8c;
  font-size: 8px;
  font-weight: 400;
}

.student-actions {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 7px;
  background: color-mix(in srgb, var(--bg, #f5f3ee) 82%, var(--surface, #fff));
}

.button-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 5px;
}

.action-button {
  display: inline-flex;
  min-width: 0;
  min-height: 28px;
  align-items: center;
  justify-content: center;
  gap: 5px;
  padding: 3px 5px;
  border: 1px solid #7673ff;
  border-radius: 6px;
  background: transparent;
  color: #6662ef;
  cursor: pointer;
  font: inherit;
  font-size: 8px;
  font-weight: 600;
  line-height: 1.1;
  text-align: center;
}

.action-button:hover {
  background: color-mix(in srgb, #6662ff 8%, var(--surface, #fff));
}

.action-button.primary {
  background: #6662ff;
  color: #fff;
}

.action-button.danger {
  border-color: #ed6265;
  color: #d94b50;
}

.icon-actions .action-button {
  min-height: 24px;
}

.profile-right {
  min-width: 0;
}

.help-row {
  display: flex;
  height: 26px;
  justify-content: flex-end;
  margin-bottom: 4px;
}

.help-button {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 3px 10px;
  border: 1px solid #7779ea;
  border-radius: 999px;
  background: transparent;
  color: #625eff;
  cursor: pointer;
  font: inherit;
  font-size: 8px;
}

.tabs-wrap {
  position: relative;
  display: flex;
  align-items: stretch;
  margin-bottom: 16px;
  border-bottom: 1px solid var(--line, #e4e0d6);
}

.tabs {
  display: flex;
  min-width: 0;
  flex: 1;
  overflow-x: auto;
  scrollbar-width: none;
}

.tabs::-webkit-scrollbar {
  display: none;
}

.tab-button {
  position: relative;
  display: inline-flex;
  min-height: 32px;
  flex: 0 0 auto;
  align-items: center;
  gap: 4px;
  padding: 0 7px 6px;
  border: 0;
  background: transparent;
  color: var(--ink-soft, #737b8a);
  cursor: pointer;
  font: inherit;
  font-size: 8px;
  white-space: nowrap;
}

.tab-button.active {
  color: #625eff;
}

.tab-button.active::after {
  position: absolute;
  right: 4px;
  bottom: -1px;
  left: 4px;
  height: 2px;
  background: #625eff;
  content: '';
}

.tab-next {
  display: grid;
  width: 20px;
  flex: 0 0 20px;
  place-items: center;
  border: 0;
  background: var(--surface, #fff);
  color: var(--ink-soft, #737b8a);
  cursor: pointer;
}

.group-card {
  width: min(100%, 327px);
}

.group-header {
  display: flex;
  height: 29px;
  align-items: center;
  justify-content: space-between;
  padding: 0 9px;
  background: #6662ff;
  color: #fff;
}

.group-wallet,
.group-controls,
.group-wallet span,
.status-select {
  display: inline-flex;
  align-items: center;
}

.group-wallet {
  gap: 5px;
  font-size: 8px;
}

.group-wallet span,
.status-select {
  min-height: 17px;
  padding: 1px 6px;
  border-radius: 999px;
  background: #e4f7e7;
  color: #299147;
  font-size: 8px;
  font-weight: 600;
}

.group-controls {
  gap: 4px;
}

.status-select {
  gap: 2px;
}

.status-select select {
  max-width: 55px;
  appearance: none;
  border: 0;
  background: transparent;
  color: inherit;
  font: inherit;
  font-size: 8px;
}

.more-button {
  display: grid;
  width: 19px;
  height: 22px;
  place-items: center;
  border: 0;
  background: transparent;
  color: #fff;
  cursor: pointer;
}

.group-body {
  padding: 9px 10px 10px;
}

.group-title,
.date-pair,
.payment-pair {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.group-title {
  margin-bottom: 7px;
}

.group-title h2 {
  margin: 0;
  color: var(--ink, #1b2430);
  font-size: 14px;
  font-weight: 500;
}

.group-info {
  display: flex;
  align-items: baseline;
  gap: 5px;
  margin: 6px 0;
}

.group-info span,
.lesson-days > span,
.date-pair > div > span {
  color: var(--ink-soft, #737b8a);
  font-size: 9px;
}

.group-info strong {
  color: var(--ink, #1b2430);
  font-size: 8px;
  font-weight: 400;
}

.teacher {
  display: flex;
  align-items: center;
  gap: 4px;
  margin: 7px 0;
  color: #37a85c;
  font-size: 9px;
}

.lesson-days > div {
  display: flex;
  gap: 4px;
  margin-top: 4px;
}

.lesson-days b {
  padding: 4px 7px;
  border-radius: 999px;
  background: color-mix(in srgb, var(--ink-soft, #737b8a) 9%, var(--surface, #fff));
  color: var(--ink-soft, #737b8a);
  font-size: 7px;
  font-weight: 400;
}

.date-pair {
  margin-top: 10px;
}

.date-pair > div,
.payment-pair > div {
  display: flex;
  min-width: 0;
  flex-direction: column;
  gap: 3px;
}

.date-pair strong,
.payment-pair span,
.payment-pair strong {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: var(--ink, #1b2430);
  font-size: 8px;
  font-weight: 400;
  white-space: nowrap;
}

.date-pair .start-date,
.payment-pair > div:last-child strong {
  color: #36a450;
}

.date-pair .end-date {
  color: #d94449;
}

.payment-pair {
  align-items: flex-end;
  margin-top: 10px;
}

.payment-pair b {
  color: var(--ink, #1b2430);
  font-size: 10px;
  font-weight: 600;
}

.group-body hr {
  height: 1px;
  margin: 10px 0 7px;
  border: 0;
  background: var(--line, #e4e0d6);
}

.calendar-heading {
  display: grid;
  grid-template-columns: 19px 1fr 19px;
  align-items: center;
  gap: 4px;
}

.calendar-heading h3 {
  margin: 0;
  color: var(--ink-soft, #626a79);
  font-size: 8px;
  font-weight: 600;
  text-align: center;
}

.calendar-heading button {
  display: grid;
  width: 18px;
  height: 18px;
  place-items: center;
  border: 1px solid var(--line, #e4e0d6);
  border-radius: 50%;
  background: var(--surface, #fff);
  color: var(--ink-soft, #737b8a);
  cursor: pointer;
}

.stats {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin: 8px 0;
}

.stats span {
  padding: 3px 5px;
  border: 1px solid currentColor;
  border-radius: 999px;
  font-size: 7px;
  line-height: 1.1;
}

.stats .came { color: #32a65a; }
.stats .absent { color: #df4b4e; }
.stats .excused { color: #d88b28; }
.stats .not-done { color: #777e8c; }

.calendar-days {
  display: flex;
  gap: 6px;
  margin: 8px 0;
}

.day-cell {
  position: relative;
  display: grid;
  width: 37px;
  height: 32px;
  place-items: center;
  border-radius: 4px;
  background: #43b35d;
  color: #fff;
  font-size: 8px;
  font-weight: 600;
}

.day-cell.debt { background: #df4b4e; }
.day-cell.excused { background: #d98b2b; }
.day-cell.pending { background: #e5e7eb; color: #717887; }
.day-cell.absent { background: transparent; color: #747b88; }
.day-cell i { position: absolute; top: 3px; right: 3px; width: 5px; height: 5px; border-radius: 50%; background: #df4b4e; }

.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 8px;
  color: var(--ink-soft, #737b8a);
  font-size: 7px;
}

.legend span { display: inline-flex; align-items: center; gap: 3px; }
.legend i { width: 6px; height: 6px; border-radius: 1px; background: #43b35d; }
.legend i.debt { background: #df4b4e; }
.legend i.excused-key { background: #d98b2b; }
.legend i.pending { background: #e5e7eb; }
.legend i.absent-dot { width: 5px; height: 5px; border-radius: 50%; background: #df4b4e; }

.empty-tab {
  min-height: 110px;
  display: grid;
  place-items: center;
  border: 1px solid var(--line, #e4e0d6);
  border-radius: 8px;
  color: var(--ink-soft, #737b8a);
  font-size: 12px;
}

.history-section {
  margin-top: 25px;
}

.history-heading,
.history-tools {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.history-heading {
  margin-bottom: 8px;
}

.history-heading h2 {
  margin: 0;
  color: var(--ink, #1b2430);
  font-size: 15px;
  font-weight: 500;
}

.archive-button {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  border: 0;
  background: transparent;
  color: var(--danger, #b4462f);
  cursor: pointer;
  font: inherit;
  font-size: 7px;
  font-weight: 600;
}

.history-tools {
  justify-content: flex-end;
  gap: 6px;
  margin-bottom: 7px;
}

.excel-button,
.group-filter,
.date-filter {
  min-height: 27px;
  border: 1px solid var(--line, #e4e0d6);
  border-radius: 6px;
  background: var(--surface, #fff);
}

.excel-button {
  display: grid;
  width: 28px;
  place-items: center;
  border-color: #66bd55;
  color: #45a536;
  cursor: pointer;
}

.group-filter {
  position: relative;
  display: flex;
  width: 114px;
  align-items: center;
}

.group-filter select {
  width: 100%;
  height: 25px;
  appearance: none;
  padding: 0 22px 0 9px;
  border: 0;
  background: transparent;
  color: var(--ink-soft, #737b8a);
  font: inherit;
  font-size: 9px;
}

.group-filter svg {
  position: absolute;
  right: 6px;
  pointer-events: none;
}

.date-filter {
  display: flex;
  min-width: 114px;
  flex-direction: column;
  justify-content: center;
  padding: 2px 7px;
}

.date-filter span { color: var(--ink-soft, #737b8a); font-size: 7px; }
.date-filter input { width: 100%; border: 0; background: transparent; color: var(--ink, #1b2430); font: inherit; font-size: 8px; }

.history-table-wrap {
  overflow: hidden;
  border: 1px solid var(--line, #e4e0d6);
  border-radius: 7px;
  background: var(--surface, #fff);
}

.history-table-scroll { overflow-x: auto; }
.history-table { width: 100%; min-width: 1120px; border-collapse: collapse; white-space: nowrap; text-align: left; }
.history-table th { height: 31px; padding: 0 10px; border-bottom: 1px solid var(--line, #e4e0d6); background: color-mix(in srgb, var(--bg, #f5f3ee) 65%, var(--surface, #fff)); color: var(--ink-soft, #737b8a); font-size: 7px; font-weight: 600; text-transform: uppercase; }
.history-table td { height: 39px; padding: 0 10px; border-bottom: 1px solid var(--line, #e4e0d6); color: var(--ink-soft, #646d7d); font-size: 8px; }
.history-table tr:last-child td { border-bottom: 0; }
.payment-status { display: inline-flex; padding: 3px 7px; border-radius: 999px; color: #fff; font-size: 8px; }
.payment-status.debt { background: #ef4f51; }
.payment-status.paid { background: #50c832; }
.row-actions { display: flex; align-items: center; gap: 5px; }
.row-actions button { display: grid; width: 16px; height: 19px; place-items: center; border: 0; background: transparent; color: var(--ink-soft, #737b8a); cursor: pointer; }
.empty-row { padding: 18px !important; text-align: center; }
.scrollbar-track { height: 6px; background: color-mix(in srgb, var(--line, #e4e0d6) 60%, var(--surface, #fff)); }
.scrollbar-track span { display: block; width: 92%; height: 6px; border-radius: 999px; background: #c6c9d0; }
.sr-only { position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; }

.notice { position: fixed; right: 20px; bottom: 20px; z-index: 20; padding: 10px 14px; border: 1px solid var(--line, #e4e0d6); border-radius: 8px; background: var(--surface, #fff); color: var(--ink, #1b2430); font-size: 12px; box-shadow: 0 5px 20px rgb(0 0 0 / 12%); }
.toast-enter-active, .toast-leave-active { transition: opacity .15s ease, transform .15s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(5px); }
.modal-backdrop { position: fixed; inset: 0; z-index: 1000; display: grid; place-items: center; padding: 16px; background: rgb(0 0 0 / 45%); }
.confirm-modal { width: min(100%, 360px); padding: 20px; border: 1px solid var(--line, #e4e0d6); border-radius: 10px; background: var(--surface, #fff); color: var(--ink, #1b2430); }
.confirm-modal h2 { margin: 0 0 8px; font-size: 16px; }
.confirm-modal p { color: var(--ink-soft, #737b8a); font-size: 12px; }
.confirm-modal > div { display: flex; justify-content: flex-end; gap: 8px; margin-top: 18px; }
.confirm-modal button { min-height: 32px; padding: 0 10px; border: 1px solid var(--line, #e4e0d6); border-radius: 6px; background: transparent; color: var(--ink); cursor: pointer; font: inherit; font-size: 10px; }
.confirm-modal .danger-confirm { border-color: var(--danger); background: var(--danger); color: #fff; }
.additional-info-modal { width: min(100%, 600px); padding: 20px; border: 1px solid var(--line, #4a5068); border-radius: 9px; background: var(--surface, #30364f); color: var(--ink, #eceef6); box-shadow: 0 16px 48px rgb(0 0 0 / 28%); }
.additional-info-modal h2 { margin: 0 0 28px; color: var(--ink, #eceef6); font-size: 20px; font-weight: 600; }
.additional-info-fields { display: flex; flex-direction: column; gap: 9px; margin-bottom: 23px; }
.additional-info-fields input { width: min(100%, 240px); height: 41px; padding: 0 13px; border: 1px solid var(--line, #4a5068); border-radius: 7px; outline: 0; background: transparent; color: var(--ink, #eceef6); font: inherit; font-size: 14px; }
.additional-info-fields input::placeholder { color: var(--ink-soft, #a0a6ba); }
.additional-info-fields input:focus { border-color: #6864ff; }
.create-info-button { display: flex; width: 100%; min-height: 39px; align-items: center; justify-content: center; gap: 9px; border: 1px solid #5559b7; border-radius: 8px; background: transparent; color: #6662ff; cursor: pointer; font: inherit; font-size: 13px; font-weight: 600; }
.create-info-button:hover { background: rgb(102 98 255 / 8%); }
.additional-info-actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 19px; }
.additional-info-actions button { min-width: 113px; min-height: 38px; padding: 0 17px; border: 0; border-radius: 8px; color: #fff; cursor: pointer; font: inherit; font-size: 12px; font-weight: 600; }
.cancel-info-button { background: #ff4b50; }
.save-info-button { background: #6662ff; }
.additional-info-actions button:hover { filter: brightness(1.08); }
.group-assignment-modal { width: min(100%, 450px); max-height: min(568px, calc(100dvh - 24px)); overflow-y: auto; padding: 24px; border: 1px solid var(--line, #41475e); border-radius: 10px; background: var(--surface, #30364f); color: var(--ink, #eceef6); box-shadow: 0 18px 54px rgb(0 0 0 / 30%); }
.group-assignment-modal h2 { margin: 10px 0 42px; color: var(--ink, #eceef6); font-size: 22px; font-weight: 600; text-align: center; }
.group-modal-help { max-width: 360px; margin: 0 0 12px; color: var(--ink-soft, #9ba2b8); font-size: 12px; font-weight: 600; line-height: 1.35; }
.group-filter-row { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 11px; margin-bottom: 23px; }
.group-filter-row label,
.group-choice { position: relative; display: flex; min-width: 0; align-items: center; border: 1px solid var(--line, #484e66); border-radius: 8px; }
.group-filter-row select,
.group-choice select { width: 100%; min-width: 0; height: 39px; appearance: none; padding: 0 30px 0 12px; border: 0; outline: 0; background: transparent; color: var(--ink-soft, #a4aabe); font: inherit; font-size: 14px; }
.group-filter-row option,
.group-choice option { background: var(--surface, #30364f); color: var(--ink, #eceef6); }
.group-filter-row svg,
.group-choice svg { position: absolute; right: 10px; color: var(--ink-soft, #969db2); pointer-events: none; }
.group-choice { margin-bottom: 14px; }
.group-choice select { height: 40px; }
.new-group-toggle { display: inline-flex; align-items: center; gap: 5px; margin: 0 0 16px; padding: 0; border: 0; background: transparent; color: #6966ff; cursor: pointer; font: inherit; font-size: 14px; }
.new-group-input { width: 100%; height: 39px; margin: -5px 0 12px; padding: 0 12px; border: 1px solid var(--line, #484e66); border-radius: 8px; outline: 0; background: transparent; color: var(--ink, #eceef6); font: inherit; font-size: 13px; }
.group-comment { display: block; width: 100%; min-height: 126px; resize: vertical; margin: 0 0 32px; padding: 14px 12px; border: 1px solid var(--line, #484e66); border-radius: 9px; outline: 0; background: transparent; color: var(--ink, #eceef6); font: inherit; font-size: 14px; }
.group-comment::placeholder,
.new-group-input::placeholder { color: var(--ink-soft, #9ba2b8); }
.group-modal-actions { display: flex; justify-content: center; gap: 12px; }
.group-modal-actions button { min-width: 114px; min-height: 38px; padding: 0 18px; border: 1px solid transparent; border-radius: 8px; cursor: pointer; font: inherit; font-size: 12px; font-weight: 600; }
.group-save-button { background: #6662ff; color: #fff; }
.group-cancel-button { border-color: var(--line, #484e66) !important; background: transparent; color: var(--ink-soft, #8d94a9); }
.group-modal-actions button:hover { filter: brightness(1.08); }
.payment-form-modal { width: min(100%, 450px); max-height: min(652px, calc(100dvh - 20px)); overflow-y: auto; padding: 29px 30px 26px; border: 1px solid var(--line, #41475e); border-radius: 9px; background: var(--surface, #30364f); color: var(--ink, #eceef6); box-shadow: 0 18px 54px rgb(0 0 0 / 30%); }
.payment-form-modal h2 { margin: 4px 0 33px; color: var(--ink, #eceef6); font-size: 24px; font-weight: 600; text-align: center; }
.payment-method-select,
.payment-group-select,
.payment-input,
.payment-comment,
.payment-date-input { position: relative; display: flex; width: 100%; border: 1px solid var(--line, #484e66); border-radius: 9px; background: transparent; color: var(--ink, #eceef6); }
.payment-method-select { align-items: center; margin-bottom: 10px; }
.payment-method-select select,
.payment-group-select select { width: 100%; height: 38px; appearance: none; padding: 0 38px 0 13px; border: 0; outline: 0; background: transparent; color: var(--ink-soft, #a4aabe); font: inherit; font-size: 14px; }
.payment-method-select option,
.payment-group-select option { background: var(--surface, #30364f); color: var(--ink, #eceef6); }
.payment-method-select svg { position: absolute; right: 10px; color: var(--ink-soft, #9ba2b8); pointer-events: none; }
.payment-method-buttons { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 10px; }
.payment-method-buttons button { min-height: 38px; border: 1px solid #5659bb; border-radius: 9px; background: transparent; color: #6966ff; cursor: pointer; font: inherit; font-size: 14px; }
.payment-method-buttons button.selected { background: rgb(102 98 255 / 13%); border-color: #6864ff; }
.payment-group-select { display: block; margin: 10px 0; }
.payment-group-select > span { position: absolute; z-index: 1; top: -8px; left: 11px; padding: 0 4px; background: var(--surface, #30364f); color: #9299ae; font-size: 11px; }
.payment-group-select select { height: 47px; padding: 4px 36px 16px 13px; color: var(--ink-soft, #a4aabe); font-size: 13px; }
.payment-group-select > svg { position: absolute; top: 13px; right: 10px; color: var(--ink-soft, #9ba2b8); pointer-events: none; }
.payment-group-select small { position: absolute; right: 10px; bottom: 5px; left: 13px; display: flex; align-items: center; gap: 8px; pointer-events: none; }
.payment-group-select small b { color: #63db46; font-size: 12px; }
.payment-group-select small i { padding: 2px 7px; border: 1px solid #48a934; border-radius: 999px; color: #62d647; font-size: 9px; font-style: normal; }
.payment-input { height: 40px; margin: 10px 0; padding: 0 13px; outline: 0; font: inherit; font-size: 14px; }
.payment-input::placeholder,
.payment-comment::placeholder { color: var(--ink-soft, #a4aabe); }
.payment-input:focus,
.payment-comment:focus,
.payment-date-input:focus-within,
.payment-method-select:focus-within,
.payment-group-select:focus-within { border-color: #6864ff; }
.payment-comment { min-height: 124px; resize: vertical; margin: 0 0 10px; padding: 13px; outline: 0; font: inherit; font-size: 14px; }
.payment-date-input { min-height: 41px; flex-direction: column; justify-content: center; margin-top: 9px; padding: 4px 13px; }
.payment-date-input span { color: #9299ae; font-size: 10px; line-height: 1.1; }
.payment-date-input input { width: calc(100% - 22px); height: 18px; border: 0; outline: 0; background: transparent; color: var(--ink, #eceef6); font: inherit; font-size: 14px; }
.payment-date-input svg { position: absolute; right: 10px; bottom: 10px; color: var(--ink-soft, #a4aabe); pointer-events: none; }
.payment-modal-actions { display: flex; justify-content: center; gap: 12px; margin-top: 29px; }
.payment-modal-actions button { min-width: 114px; min-height: 39px; padding: 0 18px; border: 1px solid transparent; border-radius: 9px; cursor: pointer; font: inherit; font-size: 12px; font-weight: 600; }
.payment-save-button { background: #6662ff; color: #fff; }
.payment-cancel-button { border-color: var(--line, #484e66) !important; background: transparent; color: var(--ink-soft, #8d94a9); }
.payment-modal-actions button:hover { filter: brightness(1.08); }
.student-edit-modal { width: min(100%, 445px); max-height: min(520px, calc(100dvh - 16px)); overflow-y: auto; padding: 27px 22px 20px; border: 1px solid var(--line, #41475e); border-radius: 10px; background: var(--surface, #30364f); color: var(--ink, #eceef6); box-shadow: 0 18px 54px rgb(0 0 0 / 30%); }
.student-edit-modal h2 { margin: 8px 0 33px; color: var(--ink, #eceef6); font-size: 19px; font-weight: 600; text-align: center; }
.student-photo-button { position: relative; display: grid; width: 100px; height: 100px; place-items: center; overflow: hidden; margin: 0 auto 24px; border: 0; border-radius: 9px; background: #29405d; color: #19c7ed; cursor: pointer; }
.student-photo-button span { position: relative; display: flex; align-items: center; }
.student-photo-button span svg:last-child { position: absolute; top: -7px; right: -9px; padding: 1px; border-radius: 50%; background: #29405d; }
.student-photo-button img { width: 100%; height: 100%; object-fit: cover; }
.student-edit-field { position: relative; display: block; height: 40px; margin-bottom: 18px; border: 1px solid var(--line, #484e66); border-radius: 9px; }
.student-edit-field > span { position: absolute; z-index: 1; top: -7px; left: 10px; padding: 0 4px; background: var(--surface, #30364f); color: var(--ink-soft, #a4aabe); font-size: 10px; }
.student-edit-field input { width: 100%; height: 100%; padding: 4px 12px 0; border: 0; outline: 0; background: transparent; color: var(--ink, #eceef6); font: inherit; font-size: 14px; }
.student-edit-field:focus-within { border-color: #6864ff; }
.student-birth-field { margin-bottom: 37px; }
.student-birth-field input { width: calc(100% - 30px); }
.student-birth-field > svg { position: absolute; right: 12px; bottom: 10px; color: var(--ink, #eceef6); pointer-events: none; }
.student-edit-actions { display: flex; justify-content: center; gap: 12px; }
.student-edit-actions button { min-width: 114px; min-height: 38px; padding: 0 18px; border: 1px solid transparent; border-radius: 9px; cursor: pointer; font: inherit; font-size: 12px; font-weight: 600; }
.student-edit-save { background: #6662ff; color: #fff; }
.student-edit-cancel { border-color: var(--line, #484e66) !important; background: transparent; color: var(--ink-soft, #8d94a9); }
.student-edit-actions button:hover { filter: brightness(1.08); }
.loading { padding: 30px; color: var(--ink-soft, #737b8a); }

@media (max-width: 480px) {
  .group-assignment-modal { padding: 19px; }
  .group-assignment-modal h2 { margin-bottom: 30px; font-size: 20px; }
  .group-filter-row { gap: 6px; }
  .group-filter-row select { padding-left: 8px; font-size: 12px; }
  .group-modal-actions { gap: 8px; }
  .group-modal-actions button { min-width: 0; flex: 1; }
  .payment-form-modal { padding: 24px 22px 20px; }
  .payment-form-modal h2 { margin-bottom: 28px; font-size: 22px; }
  .payment-modal-actions { gap: 8px; }
  .payment-modal-actions button { min-width: 0; flex: 1; }
  .student-edit-modal { padding: 22px 19px 18px; }
  .student-edit-modal h2 { font-size: 17px; }
  .student-edit-actions { gap: 8px; }
  .student-edit-actions button { min-width: 0; flex: 1; }
}

@media (max-width: 900px) {
  .profile-grid { grid-template-columns: minmax(0, 338px); gap: 12px; }
  .student-card { grid-row: 2; }
  .profile-right { grid-row: 1; }
  .help-row { justify-content: flex-start; }
  .history-section { margin-top: 18px; }
}

@media (max-width: 520px) {
  .student-profile-page { padding: 8px 0 18px; }
  .profile-grid { grid-template-columns: minmax(0, 1fr); }
  .profile-right { grid-row: 1; }
  .student-card { grid-row: 2; }
  .history-heading h2 { font-size: 14px; }
}
</style>
