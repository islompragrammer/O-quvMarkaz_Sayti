<template>
  <div id="headerwrap">
    <div id="topbar">
      <div class="brand"><span class="mark">▽</span>Tasnim</div>
      <button
        class="mobile-menu-toggle"
        type="button"
        :aria-expanded="mobileMenuOpen"
        aria-controls="navbar"
        :aria-label="mobileMenuOpen ? 'Menyuni yopish' : 'Menyuni ochish'"
        @click="mobileMenuOpen = !mobileMenuOpen"
      >
        <span aria-hidden="true">{{ mobileMenuOpen ? '×' : '☰' }}</span>
      </button>
      <div id="liveDateTime" class="live-date-time" aria-live="off">
        <span id="liveDate"></span>
        <time id="liveClock"></time>
      </div>
      <button class="btn-sorovnoma">✦ SO'ROVNOMA</button>
      <div class="search-wrap">
        <input type="search" placeholder="Qidirish..." /><span
          class="search-chev"
          >▾</span
        >
      </div>
      <button class="icon-btn">⊞</button>
      <button class="btn-tolov">TO'LOV</button>
      <div class="filial-select" id="roleSel">
        Tasnim Filliali<span class="chev2">▾</span>
      </div>
      <button class="icon-circle">⚙</button>
      <button class="icon-circle" style="color: #2c7be5" @click="toggleLanguage" :aria-label="locale === 'uz' ? 'Переключить язык на русский' : 'Tilni o‘zbekchaga almashtirish'" :title="locale === 'uz' ? 'Русский' : 'O‘zbekcha'">🌐</button>
      <button class="icon-circle">🛡</button>
      <button class="icon-circle">🔔</button>
      <div class="profile-menu-anchor" @click.stop>
        <button class="avatar-wrap" type="button" aria-label="Profil menyusi" :aria-expanded="profileMenuOpen" @click="toggleProfileMenu">
          <span class="avatar-user">👤</span><span class="online-dot"></span>
        </button>
        <section v-if="profileMenuOpen" class="profile-menu" aria-label="Profil menyusi">
          <div class="profile-menu-head">
            <span class="profile-menu-avatar">👤</span>
            <div class="profile-menu-person">
              <strong>{{ profileRecord.name }}</strong>
              <small>{{ profileRecord.role }}</small>
              <span>{{ profileRecord.phone }}</span>
            </div>
            <button class="profile-qr-button" type="button" aria-label="Beyjik QR kodini ochish" @click="openProfileBadge">
              <img v-if="profileQrCode" :src="profileQrCode" alt="Profil QR kodi" />
              <QrCode v-else :size="25" />
            </button>
            <button class="profile-edit-button" type="button" aria-label="Profilni tahrirlash" title="Tahrirlash" @click="editProfile">
              <SquarePen :size="20" />
            </button>
          </div>
          <button class="profile-menu-item profile-badge-item" type="button" @click="openProfileBadge"><IdCard :size="19" />MENING BEYJIGIM</button>
          <button class="profile-menu-item profile-green-item" type="button" @click="openProfileSection('finance')"><Banknote :size="19" />O'QUV MARKAZ TO'LOVLARI</button>
          <button class="profile-menu-item profile-green-item" type="button" @click="openReceiptSettings"><ReceiptText :size="19" />CHEK SOZLAMALARI</button>
          <button class="profile-menu-item profile-memory-item" type="button" :aria-expanded="memoryDetailsOpen" @click="memoryDetailsOpen = !memoryDetailsOpen"><Database :size="18" /><span>XOTIRA</span><small>{{ storageUsage }}</small></button>
          <div v-if="memoryDetailsOpen" class="profile-menu-detail">CRM ma'lumotlari ushbu brauzerda saqlanadi. {{ storageUsage }} ishlatilgan.</div>
          <button class="profile-menu-item profile-telegram-item" type="button" role="switch" :aria-checked="telegramLinkRequested" @click="toggleTelegramRequest"><Send :size="18" /><span>Telegramga ulanish</span><i :class="{ enabled: telegramLinkRequested }"></i></button>
          <div v-if="telegramLinkRequested" class="profile-menu-detail">Telegram bot backend’i hali ulanmagan.</div>
          <button class="profile-menu-item profile-logout-item" type="button" @click="$emit('logout')"><LogOut :size="18" />Chiqish</button>
        </section>
      </div>
    </div>
    <nav id="navbar" :class="{ 'mobile-open': mobileMenuOpen }"></nav>
  </div>
  <div v-if="profileBadgeOpen" class="profile-badge-overlay" @click.self="profileBadgeOpen = false">
    <section class="profile-badge-card" role="dialog" aria-modal="true" aria-labelledby="profileBadgeTitle">
      <button class="profile-badge-close" type="button" aria-label="Yopish" @click="profileBadgeOpen = false">×</button>
      <img v-if="profileQrCode" :src="profileQrCode" alt="Profil QR kodi" />
      <h2 id="profileBadgeTitle">{{ profileRecord.name }}</h2>
      <p>{{ profileRecord.role }}</p>
      <strong>{{ profileRecord.phone }}</strong>
      <button class="profile-badge-print" type="button" @click="printProfileBadge">Chop etish</button>
    </section>
  </div>
  <div id="content"></div>
  <div class="drawer-overlay" id="drawerOverlay" onclick="closeDrawer()"></div>
  <div class="drawer" id="drawer">
    <div class="drawer-head">
      <div>
        <h3 id="drawerTitle">Kurs qo'shish</h3>
        <div class="dsub" id="drawerSub">sole</div>
      </div>
      <div style="display: flex; align-items: flex-start">
        <div class="dmem" id="drawerMem">XOTIRA<b>0 B / 5 GB</b></div>
        <span class="drawer-close" onclick="closeDrawer()">×</span>
      </div>
    </div>
    <div class="drawer-body">
      <div
        id="drawerFieldsCourse"
        style="display: flex; flex-direction: column; gap: 20px"
      >
        <div class="field-float">
          <label>Nomi</label><input type="text" id="drNomi" />
        </div>
        <div class="field-float">
          <label>Kurs narxi</label><input type="text" id="drNarx" />
        </div>
        <label class="drawer-check" id="drNarxCheckRow" style="display: none"
          ><input type="checkbox" /><span
            >Narx shu oydan ta'sir qilsinmi?</span
          ></label
        >
        <div class="field-float">
          <label>Kurs davomiyligi (oy)</label><input type="text" id="drDavr" />
        </div>
        <div class="field-expand">
          <span>Baholash tizimi</span><span>+</span>
        </div>
        <div class="field-float">
          <label>Izoh</label><textarea id="drIzoh"></textarea>
        </div>
        <div class="field-expand"><span>Rang tanlash</span><span>+</span></div>
      </div>
      <div
        id="drawerFieldsHoliday"
        style="display: none; flex-direction: column; gap: 16px"
      >
        <div class="field-plain">
          <input type="date" id="drSana" aria-label="Sanani tanlang" /><span
            class="cal-ic"
            >📅</span
          >
        </div>
        <div class="field-plain">
          <textarea id="drSabab" placeholder="Sabab"></textarea>
        </div>
      </div>
      <div
        id="drawerFieldsSchool"
        style="display: none; flex-direction: column; gap: 6px"
      >
        <div class="field-plain field-err">
          <input type="text" id="drMaktab" placeholder="Maktab" />
        </div>
        <div class="field-err-msg">Maktab nomini kiriting</div>
      </div>
      <div
        id="drawerFieldsRoom"
        style="display: none; flex-direction: column; gap: 15px"
      >
        <div class="field-plain">
          <input type="text" id="drXonaNomi" placeholder="Xona nomi" />
        </div>
        <div class="field-plain">
          <input type="number" id="drXonaSigim" min="1" step="1" placeholder="Sig'im" />
        </div>
      </div>
      <div
        id="drawerFieldsEmployee"
        style="display: none; flex-direction: column; gap: 18px"
      >
        <div style="display: flex; justify-content: center; margin-bottom: 2px">
          <div
            style="
              width: 60px;
              height: 60px;
              border-radius: 12px;
              background: #eaf6fb;
              display: flex;
              align-items: center;
              justify-content: center;
              color: #2c9fc9;
              font-size: 20px;
              cursor: pointer;
              position: relative;
            "
          >
            📷<span
              style="
                position: absolute;
                top: -3px;
                right: -3px;
                background: #2c9fc9;
                color: #fff;
                width: 16px;
                height: 16px;
                border-radius: 50%;
                font-size: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
              "
              >+</span
            >
          </div>
        </div>
        <div class="df-box">
          <input type="text" placeholder="Ism familiya" />
        </div>
        <div class="df-box labeled">
          <span class="df-label">Telefon raqam</span>
          <input class="phone-input" type="tel" inputmode="tel" autocomplete="tel" placeholder="+998 (__) ___-__-__" oninput="formatUzbekPhoneInput(this)" />
        </div>
        <div class="df-box labeled">
          <span class="df-label">Tug'ilgan sana</span>
          <div>26.09.2026</div>
          <span class="df-icon">📅</span>
        </div>
        <div class="df-box labeled">
          <span class="df-label">Ishga olingan sana</span>
          <div>26.09.2026</div>
          <span class="df-icon">📅</span>
        </div>
        <div class="df-box labeled">
          <span class="df-label">Filial</span>
          <div>Tasnim Filliali</div>
          <span class="df-icon">▾</span>
        </div>
        <div class="df-box" style="cursor: pointer">
          <select id="drEmployeeRole" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
            <option value="" disabled selected>Rollar</option>
            <option>Admin</option>
            <option selected>O'qituvchi</option>
            <option>CEO</option>
            <option>Kassir</option>
            <option>Boshqa</option>
            <option>Support Teacher</option>
            <option>Watcher</option>
          </select>
          <span class="df-icon">▾</span>
        </div>
        <div class="row" style="gap: 12px; margin: 0">
          <div class="df-box labeled" style="flex: 1">
            <span class="df-label">Foiz ulushi</span
            ><input id="drEmployeeShare" type="text" value="0" />
          </div>
          <div class="df-box" style="flex: 1">
            <input id="drEmployeeSalary" type="text" placeholder="Oylik ish haqi" />
          </div>
        </div>
        <div>
          <div style="font-size: 13px; color: var(--ink); margin-bottom: 10px">
            Jinsini tanlang
          </div>
          <div style="display: flex; gap: 24px">
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins"
                checked
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Erkak</label
            >
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins"
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Ayol</label
            >
          </div>
        </div>
        <div
          class="df-box"
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
          "
        >
          <input type="text" placeholder="Parol" /><span
            style="color: var(--ink-soft); cursor: pointer"
            >🔄</span
          >
        </div>
      </div>
      <div
        id="drawerFieldsStudent"
        style="display: none; flex-direction: column; gap: 18px"
      >
        <div style="display: flex; justify-content: center; margin-bottom: 2px">
          <div
            style="
              width: 60px;
              height: 60px;
              border-radius: 12px;
              background: #eaf6fb;
              display: flex;
              align-items: center;
              justify-content: center;
              color: #2c9fc9;
              font-size: 20px;
              cursor: pointer;
              position: relative;
            "
          >
            📷<span
              style="
                position: absolute;
                top: -3px;
                right: -3px;
                background: #2c9fc9;
                color: #fff;
                width: 16px;
                height: 16px;
                border-radius: 50%;
                font-size: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
              "
              >+</span
            >
          </div>
        </div>
        <div class="df-box">
          <input id="drEmployeeName" type="text" placeholder="Ism familiya" />
        </div>
        <div class="df-box labeled">
          <span class="df-label">Telefon raqam</span>
          <input id="drEmployeePhone" class="phone-input" type="tel" inputmode="tel" autocomplete="tel" placeholder="+998 (__) ___-__-__" oninput="formatUzbekPhoneInput(this)" />
        </div>
        <div class="df-box labeled">
          <span class="df-label">Tug'ilgan sana</span>
          <input id="drEmployeeBirth" type="date" style="width:100%; border:none; background:transparent; color:var(--ink);" />
          <span class="df-icon">📅</span>
        </div>
        <div class="df-box labeled">
          <span class="df-label">Ishga olingan sana</span>
          <input id="drEmployeeHired" type="date" style="width:100%; border:none; background:transparent; color:var(--ink);" />
          <span class="df-icon">📅</span>
        </div>
        <div>
          <div
            style="
              font-size: 13px;
              color: var(--ink);
              margin-bottom: 10px;
              display: flex;
              align-items: center;
              gap: 6px;
            "
          >
            Maosh hisoblash usuli
            <span
              style="
                color: var(--ink-soft);
                font-size: 11px;
                border: 1px solid var(--ink-soft);
                border-radius: 50%;
                width: 15px;
                height: 15px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
              "
              >?</span
            >
          </div>
          <div class="maosh-tabs">
            <div
              class="maosh-tab active"
              onclick="
                document
                  .querySelectorAll('.maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              Foiz
            </div>
            <div
              class="maosh-tab"
              onclick="
                document
                  .querySelectorAll('.maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              Oylik
            </div>
            <div
              class="maosh-tab"
              onclick="
                document
                  .querySelectorAll('.maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              Dars haqi
            </div>
            <div
              class="maosh-tab"
              onclick="
                document
                  .querySelectorAll('.maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              Talaba ulushi
            </div>
          </div>
        </div>
        <div class="df-box labeled">
          <span class="df-label">⏱ Foiz ulushi</span
          ><input type="text" value="0" />
        </div>
        <div>
          <div style="font-size: 13px; color: var(--ink); margin-bottom: 10px">
            Jinsini tanlang
          </div>
          <div style="display: flex; gap: 24px">
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins2"
                checked
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Erkak</label
            >
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins2"
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Ayol</label
            >
          </div>
        </div>
        <div
          class="df-box"
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
          "
        >
          <input type="text" placeholder="Parol" /><span
            style="color: var(--ink-soft); cursor: pointer"
            >🔄</span
          >
        </div>
      </div>
      <div
        id="drawerFieldsGroup"
        style="display: none; flex-direction: column; gap: 18px"
      >
        <div class="df-box">
          <input type="text" id="drGuruhNomi" placeholder="Guruh nomi" />
        </div>
        <div class="df-box" style="cursor: pointer">
          <select id="drGuruhKurs" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
            <option value="" disabled selected>Kurslar</option>
            <option>koputur savotxonligi</option></select
          ><span class="df-icon">▾</span>
        </div>
        <div>
          <div class="df-box" style="cursor: pointer">
            <select
              style="appearance: none; color: var(--ink-soft); cursor: pointer"
              onchange="this.style.color = 'var(--ink)'"
            >
              <option value="" disabled selected>
                Baholash tizimini almashtirish (ixtiyoriy)
              </option></select
            ><span class="df-icon">▾</span>
          </div>
          <div class="note" style="margin-top: 6px; margin-bottom: 0">
            Agar tanlanmasa, kursning baholash tizimi qo'llaniladi.
          </div>
        </div>
        <div class="df-box" style="cursor: pointer">
          <select id="drGuruhDays" style="appearance: none; cursor: pointer">
            <option>Juft kunlari</option>
            <option selected>Toq kunlari</option>
            <option>Har kuni</option></select
          ><span class="df-icon">▾</span>
        </div>
        <label
          style="
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: var(--ink-soft);
            cursor: pointer;
          "
          ><span class="toggle" onclick="this.classList.toggle('on')"
            ><i></i></span
          >⚙ Har bir kunga alohida sozlama</label
        >
        <div class="df-box" style="cursor: pointer">
          <select id="drGuruhRoom" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
            <option value="" disabled selected>Xona</option></select
          ><span class="df-icon">▾</span>
        </div>
        <div>
          <div style="font-size: 13px; color: var(--ink); margin-bottom: 10px">
            O'qituvchilar va ulushlar (maksimal 3)
          </div>
          <div
            id="oqituvchilarWrap"
            style="display: flex; flex-direction: column; gap: 14px"
          >
            <div
              class="oqituvchi-block"
              style="display: flex; flex-direction: column; gap: 10px"
            >
              <div class="df-box" style="cursor: pointer">
                <select id="drGuruhTeacher" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
                  <option value="" disabled selected>O'qituvchi</option>
                  <option selected>islom</option></select
                ><span class="df-icon">▾</span>
              </div>
              <div class="row" style="gap: 10px; margin: 0">
                <div class="df-box labeled" style="flex: 1; cursor: pointer">
                  <span class="df-label">Rol</span>
                  <div>Asosiy (Main)</div>
                  <span class="df-icon">▾</span>
                </div>
                <div class="df-box labeled" style="flex: 1; cursor: pointer">
                  <span class="df-label">Ulush turi</span>
                  <div>Foiz (%)</div>
                  <span class="df-icon">▾</span>
                </div>
              </div>
              <div class="df-box">
                <input type="text" placeholder="Foiz (%)" />
              </div>
            </div>
          </div>
          <button
            class="btn-outline2"
            id="addOqituvchiBtn"
            style="margin-top: 12px; width: 100%"
            onclick="addOqituvchiRow()"
          >
            + O'QITUVCHI QO'SHISH
          </button>
        </div>
        <div class="df-box labeled">
          <span class="df-label">Boshlanish sanasi</span>
          <input id="drGuruhDate" type="date" style="width:100%; border:none; background:transparent; color:var(--ink);" />
        </div>
        <div
          class="df-box"
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
          "
        >
          <input id="drGuruhStartTime" type="time" aria-label="Boshlanish vaqti" /><span
            style="color: var(--ink-soft)"
            >🕐</span
          >
        </div>
        <div
          class="df-box"
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
          "
        >
          <input id="drGuruhEndTime" type="time" aria-label="Tugash vaqti" /><span
            style="color: var(--ink-soft)"
            >🕐</span
          >
        </div>
      </div>
      <div
        id="drawerFieldsOquvchi"
        style="display: none; flex-direction: column; gap: 18px"
      >
        <div style="display: flex; justify-content: center; margin-bottom: 2px">
          <div
            style="
              width: 60px;
              height: 60px;
              border-radius: 12px;
              background: #eaf6fb;
              display: flex;
              align-items: center;
              justify-content: center;
              color: #2c9fc9;
              font-size: 20px;
              cursor: pointer;
              position: relative;
            "
          >
            📷<span
              style="
                position: absolute;
                top: -3px;
                right: -3px;
                background: #2c9fc9;
                color: #fff;
                width: 16px;
                height: 16px;
                border-radius: 50%;
                font-size: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
              "
              >+</span
            >
          </div>
        </div>
        <div class="df-box"><input id="drStudentName" type="text" placeholder="Ism" /></div>
        <div class="df-box labeled">
          <span class="df-label">Telefon raqam</span>
          <div style="display: flex; gap: 6px">
            <input id="drStudentPhone" class="phone-input" type="tel" inputmode="tel" autocomplete="tel" placeholder="+998 (__) ___-__-__" oninput="formatUzbekPhoneInput(this)" />
          </div>
        </div>
        <div class="df-box labeled">
          <span class="df-label">Tug'ilgan sana</span>
          <input id="drStudentBirth" type="date" style="width:100%; border:none; background:transparent; color:var(--ink);" />
          <span class="df-icon">📅</span>
        </div>
        <div
          class="df-box"
          style="
            display: flex;
            align-items: center;
            justify-content: space-between;
          "
        >
          <input id="drStudentPassword" type="text" placeholder="Parol" /><span
            style="color: var(--ink-soft); cursor: pointer"
            >🔄</span
          >
        </div>
        <div class="df-box" style="cursor: pointer">
          <select id="drStudentSource" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
            <option value="" disabled selected>Manba</option>
            <option>Instagram</option>
            <option>Referral</option>
            <option>Google Ads</option>
            <option>Telegram</option></select
          ><span class="df-icon">▾</span>
        </div>
        <div>
          <div style="font-size: 13px; color: var(--ink); margin-bottom: 10px">
            Jinsini tanlang
          </div>
          <div style="display: flex; gap: 24px">
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins3"
                value="Erkak"
                checked
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Erkak</label
            >
            <label
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                cursor: pointer;
              "
              ><input
                type="radio"
                name="jins3"
                value="Ayol"
                style="width: 16px; height: 16px; accent-color: #5a55e0"
              />Ayol</label
            >
          </div>
        </div>
        <div style="border: 1px solid var(--line); border-radius: 8px; overflow: hidden">
          <div style="border-bottom: 1px solid var(--line)">
            <button type="button" class="field-expand student-extra-toggle" aria-expanded="false" onclick="toggleStudentSection('groups', this)">
              <span>Guruhga qo'shish</span><span>+</span>
            </button>
            <div id="studentGroupsSection" class="student-extra-content" style="display:none">
              <div id="studentGroupOptions" style="display:flex;flex-direction:column;gap:10px"></div>
            </div>
          </div>
          <div style="border-bottom: 1px solid var(--line)">
            <button type="button" class="field-expand student-extra-toggle" aria-expanded="false" onclick="toggleStudentSection('parent', this)">
              <span>Ota-ona telefon raqamini qo'shish</span><span>+</span>
            </button>
            <div id="studentParentSection" class="student-extra-content" style="display:none">
              <input id="drStudentParentName" type="text" placeholder="Ota-ona ismi" />
              <input id="drStudentParentPhone" type="tel" inputmode="tel" autocomplete="tel" placeholder="+998 (__) ___-__-__" oninput="formatUzbekPhoneInput(this)" />
            </div>
          </div>
          <div>
            <button type="button" class="field-expand student-extra-toggle" aria-expanded="false" onclick="toggleStudentSection('school', this)">
              <span>Maktab qo'shish</span><span>+</span>
            </button>
            <div id="studentSchoolSection" class="student-extra-content" style="display:none">
              <select id="drStudentSchool" aria-label="Maktabni tanlang">
                <option value="">Maktabni tanlang</option>
              </select>
              <input id="drStudentNewSchool" type="text" placeholder="Yangi maktab nomi" />
              <button type="button" class="btn-outline2" onclick="addStudentSchool()">+ MAKTAB YARATISH</button>
            </div>
          </div>
        </div>
      </div>
      <div
        id="drawerFieldsImtihon"
        style="display: none; flex-direction: column; gap: 18px"
      >
        <div>
          <div class="note" style="margin: 0 0 8px">Imtihon turi</div>
          <div class="maosh-tabs">
            <div
              class="maosh-tab active"
              style="padding: 12px 6px"
              onclick="
                document
                  .querySelectorAll('#drawerFieldsImtihon .maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              👥 GURUH IMTIHONI
            </div>
            <div
              class="maosh-tab"
              style="padding: 12px 6px"
              onclick="
                document
                  .querySelectorAll('#drawerFieldsImtihon .maosh-tab')
                  .forEach((t) => t.classList.remove('active'));
                this.classList.add('active');
              "
            >
              🎓 MOCK IMTIHON
            </div>
          </div>
        </div>
        <div class="df-box">
          <input id="drImtihonNomi" type="text" placeholder="Imtihon nomi" />
        </div>
        <div style="border-top: 1px solid var(--line); margin: -6px 0"></div>
        <div class="df-box" style="cursor: pointer">
          <select id="drImtihonGroup" style="appearance: none; color: var(--ink-soft); cursor: pointer" onchange="this.style.color = 'var(--ink)'">
            <option value="" disabled selected>Guruh</option>
            <option>web1</option></select
          ><span class="df-icon">▾</span>
        </div>
        <label
          style="
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            color: var(--ink);
            cursor: pointer;
          "
          ><input
            type="checkbox"
            style="width: 17px; height: 17px; accent-color: #5a55e0"
          />Qayta topshirish</label
        >
        <div class="df-box labeled">
          <span class="df-label">Imtihon sanasi</span>
          <input id="drImtihonDate" type="date" style="width:100%; border:none; background:transparent; color:var(--ink);" />
        </div>
        <div class="row" style="gap: 10px; margin: 0">
          <div class="df-box labeled" style="flex: 1">
            <span class="df-label">Boshlanish vaqti</span>
            <input id="drImtihonStartTime" type="time" aria-label="Imtihon boshlanish vaqti" />
          </div>
          <div class="df-box labeled" style="flex: 1">
            <span class="df-label">Tugash vaqti</span>
            <input id="drImtihonEndTime" type="time" aria-label="Imtihon tugash vaqti" />
          </div>
        </div>
        <div
          class="field-expand"
          style="background: var(--bg)"
          onclick="
            const b = document.getElementById('qoshimchaBody');
            const open = b.style.display !== 'none';
            b.style.display = open ? 'none' : 'flex';
            this.querySelector('.chev3').style.transform = open
              ? 'rotate(0deg)'
              : 'rotate(180deg)';
          "
        >
          <span>Qo'shimcha ma'lumotlar</span
          ><span
            class="chev3"
            style="
              display: inline-block;
              transition: transform 0.15s;
              transform: rotate(180deg);
            "
            >⌄</span
          >
        </div>
        <div
          id="qoshimchaBody"
          style="display: flex; flex-direction: column; gap: 18px"
        >
          <div class="df-box labeled">
            <span class="df-label">Baholash tizimi</span>
            <div>Maxsus</div>
            <span class="df-icon">▾</span>
          </div>
          <div class="row" style="gap: 10px; margin: 0">
            <div class="df-box" style="flex: 1">
              <select id="drImtihonPassScore" aria-label="O'tish ball">
                <option value="0">0 ball</option>
                <option value="25">25 ball</option>
                <option value="50">50 ball</option>
                <option value="75">75 ball</option>
                <option value="100">100 ball</option>
              </select>
            </div>
            <div class="df-box labeled" style="flex: 1">
              <span class="df-label">Maksimal ball</span
              ><input id="drImtihonMaxScore" type="number" min="0" max="100" step="25" value="100" />
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="drawer-foot">
      <button id="drawerBtn" onclick="saveDrawer()">DAVOM ETISH</button>
    </div>
  </div>

  <div
    class="modal-overlay"
    id="tplModalOverlay"
    onclick="closeTplModal()"
  ></div>
  <div class="modal-box" id="tplModal">
    <h2 style="margin: 0 0 6px; font-size: 19px">
      Tavsiya etilgan andozalarni tanlang
    </h2>
    <p class="note" style="margin: 0 0 16px">
      Faqat belgilangan andozalar yaratiladi. Belgilanmaganlari qo'shilmaydi.
    </p>
    <label class="tpl-check"
      ><input type="checkbox" checked />CEFR baholash tizimi</label
    >
    <label class="tpl-check"
      ><input type="checkbox" checked />DTM baholash tizimi</label
    >
    <label class="tpl-check"
      ><input type="checkbox" checked />IELTS baholash tizimi</label
    >
    <label class="tpl-check"
      ><input type="checkbox" checked />Standart 1–5 baholash</label
    >
    <label class="tpl-check"><input type="checkbox" checked />ABCF</label>
    <label class="tpl-check"
      ><input type="checkbox" checked />Sof 100 ballik baholash</label
    >
    <div
      class="row"
      style="
        justify-content: flex-end;
        gap: 14px;
        margin-top: 20px;
        margin-bottom: 0;
      "
    >
      <button class="btn-outline2" onclick="closeTplModal()">
        BEKOR QILISH
      </button>
      <button class="btn-solid">TAVSIYA ETILGAN ANDOZALARNI QO'SHISH</button>
    </div>
  </div>

  <div
    class="modal-overlay"
    id="bolimModalOverlay"
    onclick="closeBolimModal()"
  ></div>
  <div
    class="modal-box"
    id="bolimModal"
    style="width: 380px; padding: 26px 28px"
  >
    <div
      class="row"
      style="
        justify-content: space-between;
        align-items: center;
        margin-bottom: 18px;
      "
    >
      <h2 style="margin: 0; font-size: 19px; font-weight: 700">
        Yangi bo'lim qo'shish
      </h2>
      <span
        style="cursor: pointer; color: var(--ink-soft); font-size: 18px"
        onclick="closeBolimModal()"
        >×</span
      >
    </div>
    <input
      type="text"
      id="bolimNomi"
      placeholder="Bo'lim nomi"
      style="
        width: 100%;
        padding: 12px 14px;
        border: 1px solid var(--line);
        border-radius: 8px;
        font-size: 13.5px;
        box-sizing: border-box;
        margin-bottom: 18px;
      "
    />
    <button class="btn-solid" style="width: 100%" onclick="closeBolimModal()">
      YARATISH
    </button>
  </div>

  <div
    class="modal-overlay"
    id="faolModalOverlay"
    onclick="closeFaolModal()"
  ></div>
  <div
    class="modal-box"
    id="faolModal"
    style="width: 400px; padding: 28px 30px; text-align: center"
  >
    <h2 style="margin: 0 0 8px; font-size: 17px; font-weight: 700">
      Barcha o'quvchilarni faollashtirish
    </h2>
    <p
      style="
        margin: 0 0 20px;
        font-size: 13px;
        color: var(--ink-soft);
        line-height: 1.5;
      "
    >
      Barcha yangi o'quvchilarni faollashtirish uchun sanani tanlang
    </p>
    <div class="df-box labeled" style="text-align: left">
      <span class="df-label">Qo'shilgan sanasi *</span>
      <div>2026-09-26</div>
      <span class="df-icon">📅</span>
    </div>
    <div class="row" style="gap: 12px; margin-top: 20px; margin-bottom: 0">
      <button
        class="btn-outline2"
        style="flex: 1; border-color: var(--danger); color: var(--danger)"
        onclick="closeFaolModal()"
      >
        BEKOR QILISH
      </button>
      <button class="btn-solid" style="flex: 1" onclick="closeFaolModal()">
        FAOLLASHTIRISH
      </button>
    </div>
  </div>
</template>

<script>
import { createApp } from "vue";
import QRCode from "qrcode";
import { Banknote, Database, IdCard, LogOut, QrCode, ReceiptText, Send, SquarePen } from "lucide-vue-next";
import StudentProfileDashboard from "./views/StudentProfileDashboard.vue";
import { applyTranslations, locale, setLocale } from "./locale.js";

export default {
  name: "App",
  emits: ["logout"],
  components: { Banknote, Database, IdCard, LogOut, QrCode, ReceiptText, Send, SquarePen },
  data() {
    return {
      locale: locale.value,
      clockTimer: null,
      mobileMenuOpen: false,
      profileMenuOpen: false,
      profileBadgeOpen: false,
      memoryDetailsOpen: false,
      telegramLinkRequested: localStorage.getItem("tasnim-telegram-link-requested") === "true",
      storageUsage: "0 KB",
      profileRecord: { name: "Ergashov Islom", role: "ceo", phone: "+998930010528" },
      profileEmployeeId: 1,
      profileQrCode: "",
      profileOutsideHandler: null,
      profileEscapeHandler: null,
    };
  },
  methods: {
    async toggleLanguage() {
      this.locale = this.locale === "uz" ? "ru" : "uz";
      setLocale(this.locale);
      await this.$nextTick();
      applyTranslations(document.body, this.locale);
    },
    toggleProfileMenu() {
      this.profileMenuOpen = !this.profileMenuOpen;
      if (!this.profileMenuOpen) return;
      this.refreshProfileRecord();
      this.refreshStorageUsage();
      this.telegramLinkRequested = localStorage.getItem("tasnim-telegram-link-requested") === "true";
      this.createProfileQr();
    },
    refreshProfileRecord() {
      try {
        const saved = JSON.parse(localStorage.getItem("tasnim-crm-data-v1") || "{}");
        const employee = (saved.employees || []).find((item) => item.role === "ceo") || saved.employees?.[0];
        if (employee) {
          this.profileEmployeeId = employee.id;
          this.profileRecord = {
            name: employee.name || "Ergashov Islom",
            role: employee.role || "ceo",
            phone: employee.phone || "+998930010528",
          };
        }
      } catch {
        this.profileEmployeeId = 1;
      }
    },
    async createProfileQr() {
      try {
        this.profileQrCode = await QRCode.toDataURL(JSON.stringify(this.profileRecord), { width: 120, margin: 1 });
      } catch {
        this.profileQrCode = "";
      }
    },
    editProfile() {
      this.profileMenuOpen = false;
      this.refreshProfileRecord();
      if (window.openRecordEditor) window.openRecordEditor("employees", this.profileEmployeeId);
    },
    openProfileBadge() {
      this.profileMenuOpen = false;
      this.refreshProfileRecord();
      this.profileBadgeOpen = true;
      this.createProfileQr();
    },
    openProfileSection(section) {
      this.profileMenuOpen = false;
      window.show(section);
    },
    openReceiptSettings() {
      this.profileMenuOpen = false;
      window.settingsSub = "Umumiy sozlamalar";
      window.show("settings");
      requestAnimationFrame(() => {
        const settingsCard = [...document.querySelectorAll(".settings-card")]
          .find((card) => card.textContent.includes("Chek chiqariladi"));
        settingsCard?.scrollIntoView({ behavior: "smooth", block: "center" });
      });
    },
    refreshStorageUsage() {
      const byteCount = Object.keys(localStorage).reduce((total, key) =>
        total + (key.length + localStorage.getItem(key).length) * 2, 0);
      this.storageUsage = byteCount < 1024
        ? `${byteCount} B`
        : `${(byteCount / 1024).toFixed(1)} KB`;
    },
    toggleTelegramRequest() {
      this.telegramLinkRequested = !this.telegramLinkRequested;
      localStorage.setItem("tasnim-telegram-link-requested", String(this.telegramLinkRequested));
    },
    printProfileBadge() {
      window.print();
    },
  },
  beforeUnmount() {
    if (this.clockTimer) window.clearInterval(this.clockTimer);
    if (this.profileOutsideHandler) document.removeEventListener("pointerdown", this.profileOutsideHandler, true);
    if (this.profileEscapeHandler) document.removeEventListener("keydown", this.profileEscapeHandler);
  },
  mounted() {
    this.profileOutsideHandler = (event) => {
      if (!event.target.closest?.(".profile-menu-anchor")) this.profileMenuOpen = false;
    };
    this.profileEscapeHandler = (event) => {
      if (event.key === "Escape") {
        this.profileMenuOpen = false;
        this.profileBadgeOpen = false;
      }
    };
    document.addEventListener("pointerdown", this.profileOutsideHandler, true);
    document.addEventListener("keydown", this.profileEscapeHandler);
    const SCORE_LEVELS = [0, 25, 50, 75, 100];
    function buildDefaultData() {
      const today = new Date();
      const groupEnd = new Date(today);
      groupEnd.setDate(groupEnd.getDate() + 60);
      const dateLabel = (date) => date.toLocaleDateString("uk-UA").replace(/\./g, "/");
      return {
        teachers: [
          {
            id: 1,
            name: "islom",
            phone: "+998881792919",
            salary: "0 UZS",
            share: "0 %",
            role: "teacher",
            birthday: "2026-09-25",
            hiredAt: "2026-09-25",
          },
        ],
        students: [],
        groups: [
          {
            id: 1,
            name: "web1",
            course: "koputur savotxonligi",
            teacher: "islom",
            support: "-",
            days: "Toq kunlari",
            time: "08:00 / 09:30",
            count: 0,
            opened: dateLabel(today),
            ends: dateLabel(groupEnd),
            status: "Faol",
          },
        ],
        courses: [
          {
            id: 1,
            name: "koputur savotxonligi",
            price: "400 000",
            branch: "Tasnim Filliali",
            duration: "2",
            note: "",
          },
        ],
        rooms: [
          { id: 1, name: "1-xona", branch: "Tasnim Filliali", capacity: "15" },
          { id: 2, name: "2-xona", branch: "Tasnim Filliali", capacity: "15" },
          { id: 3, name: "3-xona", branch: "Tasnim Filliali", capacity: "15" },
          { id: 4, name: "4-xona", branch: "Tasnim Filliali", capacity: "15" },
          { id: 5, name: "5-xona", branch: "Tasnim Filliali", capacity: "15" },
        ],
        schools: [],
        holidays: [],
        scoreLevels: SCORE_LEVELS,
        employees: [
          {
            id: 1,
            name: "Ergashov Islom",
            phone: "+998930010528",
            salary: "0 UZS",
            share: "0 %",
            role: "ceo",
            birthday: "2026-09-25",
          },
        ],
      };
    }
    function sortRooms(rooms) {
      return [...rooms].sort((left, right) => {
        const leftNumber = Number(left.name.match(/\d+/)?.[0] || 0);
        const rightNumber = Number(right.name.match(/\d+/)?.[0] || 0);
        return leftNumber - rightNumber || left.name.localeCompare(right.name);
      });
    }
    function getTableData() {
      try {
        const raw = localStorage.getItem("tasnim-crm-data-v1");
        if (!raw) {
          const data = buildDefaultData();
          localStorage.setItem("tasnim-crm-data-v1", JSON.stringify(data));
          return data;
        }
        const parsed = JSON.parse(raw);
        const data = { ...buildDefaultData(), ...parsed };
        const storedRooms = Array.isArray(parsed.rooms) ? parsed.rooms : [];
        const oldDemoNames = new Set(["3-xona", "4-xona", "5-xona"]);
        const isLegacyDemoRooms = storedRooms.length === 3 && storedRooms.every((room) => oldDemoNames.has(room.name));
        if (isLegacyDemoRooms) {
          data.rooms.push(
            { id: Date.now() + 1, name: "1-xona", branch: "Tasnim Filliali", capacity: "15" },
            { id: Date.now() + 2, name: "2-xona", branch: "Tasnim Filliali", capacity: "15" },
          );
          data.rooms = sortRooms(data.rooms);
          saveTableData(data);
        }
        return data;
      } catch (error) {
        return buildDefaultData();
      }
    }
    function saveTableData(data) {
      localStorage.setItem("tasnim-crm-data-v1", JSON.stringify(data));
    }
    function pushRecord(kind, record) {
      const data = getTableData();
      const rw = Array.isArray(data[kind]) ? data[kind] : [];
      rw.unshift({ ...record, id: record.id || Date.now() + Math.random() });
      data[kind] = rw;
      saveTableData(data);
      return data;
    }
    function safeText(value) {
      return (value ?? "").toString().trim();
    }
    function formatUzbekPhoneValue(value) {
      let digits = String(value ?? "").replace(/\D/g, "");
      if (digits.startsWith("998")) digits = digits.slice(3);
      else if (digits.startsWith("0") && digits.length > 9) digits = digits.slice(1);
      const local = digits.slice(0, 9);
      if (!local) return "";
      let formatted = `+998 (${local.slice(0, 2)}`;
      if (local.length >= 2) formatted += ")";
      if (local.length > 2) formatted += ` ${local.slice(2, 5)}`;
      if (local.length > 5) formatted += `-${local.slice(5, 7)}`;
      if (local.length > 7) formatted += `-${local.slice(7, 9)}`;
      return formatted;
    }
    function formatUzbekPhoneInput(input) {
      const original = input.value;
      const cursor = input.selectionStart ?? original.length;
      let digitsBeforeCursor = original.slice(0, cursor).replace(/\D/g, "");
      let allDigits = original.replace(/\D/g, "");
      if (allDigits.startsWith("998")) {
        allDigits = allDigits.slice(3);
        digitsBeforeCursor = Math.max(0, digitsBeforeCursor.length - 3);
      } else if (allDigits.startsWith("0") && allDigits.length > 9) {
        allDigits = allDigits.slice(1);
        digitsBeforeCursor = Math.max(0, digitsBeforeCursor.length - 1);
      }
      const formatted = formatUzbekPhoneValue(allDigits);
      input.value = formatted;
      let countryDigits = 0;
      let localDigits = 0;
      let nextCursor = formatted.length;
      for (let index = 0; index < formatted.length; index += 1) {
        if (!/\d/.test(formatted[index])) continue;
        if (countryDigits < 3) {
          countryDigits += 1;
          continue;
        }
        localDigits += 1;
        if (localDigits >= digitsBeforeCursor) {
          nextCursor = index + 1;
          break;
        }
      }
      if (digitsBeforeCursor === 0 && formatted) nextCursor = 4;
      input.setSelectionRange(nextCursor, nextCursor);
    }
    function findCurrentView() {
      return window.currentSection || "dash";
    }
    function refreshCurrentView() {
      const view = findCurrentView();
      if (typeof show === "function") show(view);
    }
    function saveDrawer() {
      const mode = window.__drawerMode || "add";
      const data = getTableData();
      const text = (id) => safeText(document.getElementById(id)?.value);
      if (mode === "course" || mode === "add" || mode === "edit") {
        const course = {
          id: Date.now(),
          name: text("drNomi") || "Yangi kurs",
          price: text("drNarx") || "0",
          branch: "Tasnim Filliali",
          duration: text("drDavr") || "1",
          note: safeText(document.getElementById("drIzoh")?.value),
        };
        const list = Array.isArray(data.courses) ? data.courses : [];
        list.unshift(course);
        data.courses = list;
        saveTableData(data);
      } else if (mode === "room") {
        const room = {
          id: Date.now(),
          name: text("drXonaNomi") || "Yangi xona",
          branch: "Tasnim Filliali",
          capacity: text("drXonaSigim") || "1",
        };
        pushRecord("rooms", room);
      } else if (mode === "school") {
        const school = {
          id: Date.now(),
          name: text("drMaktab") || "Yangi maktab",
          students: 0,
        };
        pushRecord("schools", school);
      } else if (mode === "holiday") {
        const holiday = {
          id: Date.now(),
          date: text("drSana") || formatLocalDate(new Date()),
          reason: text("drSabab") || "Dam olish kuni",
        };
        pushRecord("holidays", holiday);
      } else if (mode === "employee") {
        const employee = {
          id: Date.now(),
          name: safeText(document.getElementById("drEmployeeName")?.value) || "Yangi xodim",
          phone: formatUzbekPhoneValue(safeText(document.getElementById("drEmployeePhone")?.value)) || "+998 (90) 000-00-00",
          salary: safeText(document.getElementById("drEmployeeSalary")?.value) || "0 UZS",
          share: safeText(document.getElementById("drEmployeeShare")?.value) || "0 %",
          role: safeText(document.getElementById("drEmployeeRole")?.value) || "teacher",
          birthday: safeText(document.getElementById("drEmployeeBirth")?.value),
          hiredAt: safeText(document.getElementById("drEmployeeHired")?.value) || formatLocalDate(new Date()),
        };
        pushRecord("employees", employee);
      } else if (mode === "student" || mode === "oquvchi") {
        const student = {
          id: Date.now(),
          name: safeText(document.getElementById("drStudentName")?.value) || "Yangi o'quvchi",
          phone: formatUzbekPhoneValue(safeText(document.getElementById("drStudentPhone")?.value)) || "+998 (90) 000-00-00",
          birthday: safeText(document.getElementById("drStudentBirth")?.value),
          source: safeText(document.getElementById("drStudentSource")?.value) || "Instagram",
          gender: safeText(document.querySelector('input[name="jins3"]:checked')?.value || "Erkak"),
          password: safeText(document.getElementById("drStudentPassword")?.value) || "123456",
          parentName: safeText(document.getElementById("drStudentParentName")?.value),
          parentPhone: formatUzbekPhoneValue(safeText(document.getElementById("drStudentParentPhone")?.value)),
          groupIds: Array.from(document.querySelectorAll("#studentGroupOptions input:checked"), (input) => input.value),
          groups: Array.from(document.querySelectorAll("#studentGroupOptions input:checked"), (input) => input.dataset.name).join(", "),
          schoolId: safeText(document.getElementById("drStudentSchool")?.value),
          school: document.getElementById("drStudentSchool")?.value
            ? document.getElementById("drStudentSchool").selectedOptions[0].textContent
            : "",
          status: "Faol",
          balance: "0 UZS",
          nextPayment: "-",
          note: "",
          grade: "-",
        };
        pushRecord("students", student);
      } else if (mode === "group") {
        const startDate = text("drGuruhDate") || formatLocalDate(new Date());
        const endDate = new Date(`${startDate}T00:00:00`);
        endDate.setDate(endDate.getDate() + 60);
        const formatDate = (date) => date.toLocaleDateString("uk-UA").replace(/\./g, "/");
        const group = {
          id: Date.now(),
          name: text("drGuruhNomi") || "Yangi guruh",
          course: safeText(document.getElementById("drGuruhKurs")?.value) || "koputur savotxonligi",
          teacher: safeText(document.getElementById("drGuruhTeacher")?.value) || "islom",
          support: "-",
          days: safeText(document.getElementById("drGuruhDays")?.value) || "Toq kunlari",
          room: safeText(document.getElementById("drGuruhRoom")?.value),
          startDate,
          endDate: formatLocalDate(endDate),
          startTime: text("drGuruhStartTime") || "08:00",
          endTime: text("drGuruhEndTime") || "09:30",
          time: `${text("drGuruhStartTime") || "08:00"} / ${text("drGuruhEndTime") || "09:30"}`,
          count: 0,
          opened: formatDate(new Date(`${startDate}T00:00:00`)),
          ends: formatDate(endDate),
          status: "Faol",
        };
        pushRecord("groups", group);
      } else if (mode === "imtihon") {
        const examStartTime = text("drImtihonStartTime") || "09:00";
        const examEndTime = text("drImtihonEndTime") || "10:00";
        const exam = {
          id: Date.now(),
          name: safeText(document.getElementById("drImtihonNomi")?.value) || "Yangi imtihon",
          type: "Guruh imtihoni",
          group: safeText(document.getElementById("drImtihonGroup")?.value) || "web1",
          date: text("drImtihonDate") || formatLocalDate(new Date()),
          time: `${examStartTime} / ${examEndTime}`,
          passScore: Number(text("drImtihonPassScore") || 0),
          maxScore: Number(text("drImtihonMaxScore") || 100),
          status: "Boshlanmagan",
        };
        pushRecord("exams", exam);
      }
      closeDrawer();
      refreshCurrentView();
    }
    window.saveDrawer = saveDrawer;
    // --- Original dastur kodi (o'zgarishsiz, faqat mounted() ichiga ko'chirildi) ---
    function openBolimModal() {
      document.getElementById("bolimModalOverlay").classList.add("show");
      document.getElementById("bolimModal").classList.add("show");
    }
    function closeBolimModal() {
      document.getElementById("bolimModalOverlay").classList.remove("show");
      document.getElementById("bolimModal").classList.remove("show");
    }

    function openFaolModal() {
      document.getElementById("faolModalOverlay").classList.add("show");
      document.getElementById("faolModal").classList.add("show");
    }
    function closeFaolModal() {
      document.getElementById("faolModalOverlay").classList.remove("show");
      document.getElementById("faolModal").classList.remove("show");
    }

    const NAV = [
      { id: "dash", icon: "📊", label: "Bosh sahifa" },
      { id: "leads", icon: "📝", label: "Lidlar" },
      { id: "teachers", icon: "👨‍🏫", label: "O'qituvchilar" },
      { id: "groups", icon: "📚", label: "Guruhlar" },
      { id: "students", icon: "🎓", label: "O'quvchilar" },
      { id: "exams", icon: "📝", label: "Imtihonlar" },
      { id: "finance", icon: "💰", label: "Moliya" },
      { id: "reports", icon: "📈", label: "Hisobotlar" },
      { id: "settings", icon: "⚙️", label: "Sozlamalar" },
    ];
    const REPORTS_MENU = [
      "To'lovlar hisoboti",
      "O'quvchilar to'lovi",
      "Ketgan o'quvchilar hisoboti",
      "Bitiruvchilar hisoboti",
      "Xodimlar Davomati Hisoboti",
      "Coinlar",
      "Lidlar Hisoboti",
      "O'quvchilar Hisoboti",
      "Markaz Faoliyati Statistikasi",
    ].map((t) => ({ t, a: false }));
    const SETTINGS_MENU = [
      { t: "SMS Sozlamalari", a: false },
      { t: "Chek sozlamalari", a: false },
      {
        t: "Ofis",
        a: true,
        sub: [
          "Kurslar",
          "Xonalar",
          "Dam olish kunlari",
          "Maktablar",
          "Coin sozlamalari",
        ],
      },
      {
        t: "CEO",
        a: true,
        sub: ["Umumiy sozlamalar", "Xodimlar", { t: "Rollar", badge: "Beta" }],
      },
      {
        t: "Harakatlar tarixi",
        a: true,
        sub: [
          { t: "Qo'ng'iroqlar", underline: true },
          "Tizimga kirishlar",
          "To'lovlar",
          "Bot xabarnoma",
          "Yuborilgan SMS lar",
        ],
      },
      { t: "Formalar", a: false },
      {
        t: "Integratsiyalar",
        a: true,
        sub: ["Amo CRM sozlamalari", "FaceId sozlamalari"],
      },
    ];
    const DROPDOWNS = {
      reports: { items: REPORTS_MENU, target: "reports" },
      settings: { items: SETTINGS_MENU, target: "settings" },
    };
    const navlist = document.getElementById("navbar");
    NAV.forEach((n) => {
      const d = document.createElement("div");
      d.className = "nav-item" + (n.id === "dash" ? " active" : "");
      d.dataset.id = n.id;
      if (DROPDOWNS[n.id]) {
        const cfg = DROPDOWNS[n.id];
        d.classList.add("has-dd");
        d.innerHTML = `<span class="nav-icon">${n.icon}</span><span>${n.label}</span><span class="chev">⌄</span>`;
        const dd = document.createElement("div");
        dd.className = "dropdown-menu";
        dd.innerHTML =
          "<ul>" +
          cfg.items
            .map((it) => {
              if (it.sub) {
                return `<li class="has-sub"><div class="sub-head"><span class="li-l">${it.t}</span><span class="arrow sub-arrow">⌄</span></div><ul class="submenu">${it.sub
                  .map((s) => {
                    const so = typeof s === "string" ? { t: s } : s;
                    return `<li class="sub-item" data-t="${so.t}"><span class="li-l"${so.underline ? ' style="text-decoration:underline"' : ""}>${so.t}</span>${so.badge ? `<span class="badge-pill">${so.badge}</span>` : ""}</li>`;
                  })
                  .join("")}</ul></li>`;
              }
              return `<li data-t="${it.t}"><span class="li-l">${it.t}</span>${it.a ? '<span class="arrow">›</span>' : ""}</li>`;
            })
            .join("") +
          "</ul>";
        document.body.appendChild(dd);
        d.onclick = (e) => {
          e.stopPropagation();
          const am = document.getElementById("actionMenu");
          if (am) am.classList.remove("show");
          const willOpen = !d.classList.contains("open");
          document.querySelectorAll(".nav-item.open").forEach((x) => {
            x.classList.remove("open");
          });
          document
            .querySelectorAll(".dropdown-menu.show")
            .forEach((m) => m.classList.remove("show"));
          if (willOpen) {
            d.classList.add("open");
            const r = d.getBoundingClientRect();
            dd.style.top = r.bottom + 6 + "px";
            dd.style.left = r.left + "px";
            dd.style.visibility = "hidden";
            dd.style.display = "block";
            const dw = dd.offsetWidth,
              margin = 10,
              vw = window.innerWidth;
            let left = r.right - dw;
            if (left + dw > vw - margin) left = vw - dw - margin;
            if (left < margin) left = margin;
            dd.style.left = left + "px";
            dd.style.display = "";
            dd.style.visibility = "";
            dd.classList.add("show");
          }
        };
        dd.querySelectorAll(":scope > ul > li.has-sub > .sub-head").forEach(
          (h) =>
            (h.onclick = (e) => {
              e.stopPropagation();
              h.parentElement.classList.toggle("open");
            }),
        );
        dd.querySelectorAll(
          ":scope > ul > li:not(.has-sub), .submenu li",
        ).forEach(
          (li) =>
            (li.onclick = (e) => {
              e.stopPropagation();
              window[cfg.target + "Sub"] = li.dataset.t || null;
              dd.classList.remove("show");
              d.classList.remove("open");
              this.mobileMenuOpen = false;
              show(cfg.target);
            }),
        );
      } else {
        d.innerHTML = `<span class="nav-icon">${n.icon}</span><span>${n.label}</span>`;
        d.onclick = () => {
          this.mobileMenuOpen = false;
          show(n.id);
        };
      }
      navlist.appendChild(d);
    });
    document.addEventListener("click", () => {
      document
        .querySelectorAll(".nav-item.open")
        .forEach((x) => x.classList.remove("open"));
      document
        .querySelectorAll(".dropdown-menu.show")
        .forEach((m) => m.classList.remove("show"));
    });

    function badge(s) {
      const m = {
        Faol: "ok",
        "Faol o'quvchi": "ok",
        Qarzdor: "bad",
        Kutilmoqda: "warn",
        Yakunlangan: "ok",
        Boshlanmagan: "warn",
        "Sinov darsi": "warn",
        Arxiv: "bad",
      };
      return `<span class="badge ${m[s] || "ok"}">${s}</span>`;
    }
    function switchStudentSubTab(name) {
      const a = document.getElementById("studSubTabAtt"),
        o = document.getElementById("studSubTabOzl");
      const pa = document.getElementById("studPanelAtt"),
        po = document.getElementById("studPanelOzl");
      if (!a || !o || !pa || !po) return;
      a.classList.toggle("active", name === "att");
      o.classList.toggle("active", name === "ozl");
      pa.style.display = name === "att" ? "" : "none";
      po.style.display = name === "ozl" ? "" : "none";
    }
    function openTplModal() {
      document.getElementById("tplModalOverlay").classList.add("show");
      document.getElementById("tplModal").classList.add("show");
    }
    function closeTplModal() {
      document.getElementById("tplModalOverlay").classList.remove("show");
      document.getElementById("tplModal").classList.remove("show");
    }
    function initials(name) {
      return name
        .split(" ")
        .map((w) => w[0])
        .slice(0, 2)
        .join("");
    }
    function tbl(cols, rows) {
      let h =
        '<div class="tblwrap"><table><thead><tr>' +
        cols.map((c) => `<th>${c}</th>`).join("") +
        "</tr></thead><tbody>";
      rows.forEach((r) => {
        h += "<tr>" + r.map((c) => `<td>${c}</td>`).join("") + "</tr>";
      });
      return h + "</tbody></table></div>";
    }

    const MARKAZ_FOYDALILIK = 0;
    const UZBEK_MONTHS = ["Yanvar", "Fevral", "Mart", "Aprel", "May", "Iyun", "Iyul", "Avgust", "Sentabr", "Oktabr", "Noyabr", "Dekabr"];
    const UZBEK_WEEKDAYS = ["Yakshanba", "Dushanba", "Seshanba", "Chorshanba", "Payshanba", "Juma", "Shanba"];
    const STATS = [
      ["✔️", "Faol lidlar", 0, "leads"],
      ["🗂️", "Guruhlar", 1, "groups"],
      ["⚠️", "Qolgan qarzlar", 0, "students"],
      ["❗", "Qarzdorlar", 0, "students"],
      ["⏰", "To'lovi yaqinlashgan", 0, "students"],
      ["🎓", "Faol talabalar", 0, "students"],
      ["👥", "Guruhdagi jami", 0, "groups"],
      ["📅", "Sinov darsida", 1, "leads"],
      ["🚪", "Kelib ketganlar", 0, "reports", "Ketgan o'quvchilar hisoboti"],
      ["🧑‍🏫", "O'qituvchilar", 1, "teachers"],
      ["📋", "Imtihonlar", 0, "exams"],
      ["✨", "Yangi guruh qabul", 0, "groups"],
    ];
    let selectedCalendarDate = new Date();
    let calendarIntervalMinutes = 15;
    let selectedAttendanceDate = formatLocalDate(new Date());
    function formatLocalDate(date) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, "0");
      const day = String(date.getDate()).padStart(2, "0");
      return `${year}-${month}-${day}`;
    }
    function refreshPeriodSelects(root) {
      const now = new Date();
      const currentYear = now.getFullYear();
      const monthNames = Array.from({ length: 12 }, (_, month) => {
        const date = new Date(currentYear, month, 1);
        return {
          month,
          names: [
            UZBEK_MONTHS[month],
            new Intl.DateTimeFormat("ru-RU", { month: "long" }).format(date),
            new Intl.DateTimeFormat("en-US", { month: "long" }).format(date),
          ],
        };
      });
      const monthLookup = new Map();
      monthNames.forEach(({ month, names }) => {
        names.forEach((name) => monthLookup.set(name.toLocaleLowerCase().replace(/[^\p{L}]/gu, ""), month));
      });
      monthLookup.set("sentyabr", 8);
      root.querySelectorAll("select").forEach((select) => {
        if (select.options.length !== 1) return;
        const label = select.options[0].textContent.trim();
        if (/^\D*20\d{2}\D*$/.test(label)) {
          select.replaceChildren();
          for (let year = currentYear - 4; year <= currentYear + 1; year += 1) {
            select.add(new Option(String(year), String(year), false, year === currentYear));
          }
          return;
        }
        const normalizedLabel = label.toLocaleLowerCase().replace(/[^\p{L}]/gu, "");
        if (!monthLookup.has(normalizedLabel)) return;
        select.replaceChildren();
        monthNames.forEach(({ month, names }) => {
          const labelForLocale = locale.value === "ru" ? names[1] : names[0];
          select.add(new Option(labelForLocale, String(month + 1), false, month === now.getMonth()));
        });
      });
    }
    function localizedWeekday(date, short = false) {
      if (locale.value === "ru") {
        return new Intl.DateTimeFormat("ru-RU", { weekday: short ? "short" : "long" }).format(date);
      }
      const weekday = UZBEK_WEEKDAYS[date.getDay()];
      return short ? ["Ya", "Du", "Se", "Cho", "Pay", "Ju", "Sha"][date.getDay()] : weekday;
    }
    function localizedCalendarDate(date, includeYear = false) {
      if (locale.value === "ru") {
        return new Intl.DateTimeFormat("ru-RU", {
          day: "numeric",
          month: "long",
          ...(includeYear ? { year: "numeric" } : {}),
        }).format(date);
      }
      const month = UZBEK_MONTHS[date.getMonth()].toLocaleLowerCase();
      return `${date.getDate()}-${month}${includeYear ? ` ${date.getFullYear()}` : ""}`;
    }
    function getWeekStart(date) {
      const start = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 12);
      start.setDate(start.getDate() - ((start.getDay() + 6) % 7));
      return start;
    }
    function changeCalendarDate(value) {
      const [year, month, day] = value.split("-").map(Number);
      if (!year || !month || !day) return;
      selectedCalendarDate = new Date(year, month - 1, day, 12);
      show("dash");
    }
    function shiftCalendarWeek(weeks) {
      const nextDate = new Date(selectedCalendarDate);
      nextDate.setDate(nextDate.getDate() + weeks * 7);
      selectedCalendarDate = nextDate;
      show("dash");
    }
    function goToToday() {
      selectedCalendarDate = new Date();
      show("dash");
    }

    function timeGridHTML() {
      const timeSlots = [];
      for (let minutes = 8 * 60; minutes <= 20 * 60; minutes += calendarIntervalMinutes) {
        timeSlots.push(`${String(Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`);
      }
      const data = getTableData();
      const rooms = data.rooms.length ? sortRooms(data.rooms).map((room) => room.name) : ["Xona yo'q"];
      const selectedDate = new Date(`${formatLocalDate(selectedCalendarDate)}T12:00:00`);
      const parseGroupDate = (value) => {
        if (!value) return null;
        if (/^\d{4}-\d{2}-\d{2}$/.test(value)) return new Date(`${value}T12:00:00`);
        const [day, month, year] = value.split(/[/.]/).map(Number);
        return year && month && day ? new Date(year, month - 1, day, 12) : null;
      };
      const groupsForDate = data.groups.filter((group) => {
        const start = parseGroupDate(group.startDate || group.opened);
        const end = parseGroupDate(group.endDate || group.ends);
        if (start && selectedDate < start) return false;
        if (end && selectedDate > end) return false;
        const isoDay = selectedDate.getDay() || 7;
        const pattern = String(group.days || "").toLocaleLowerCase();
        if (pattern.includes("har kuni")) return true;
        if (pattern.includes("juft")) return isoDay % 2 === 0;
        if (pattern.includes("toq")) return isoDay % 2 === 1;
        return true;
      });
      const escapeHtml = (value) => String(value ?? "").replace(/[&<>"']/g, (character) => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      })[character]);
      let head =
        "<tr><th>Xonalar / Soat</th>" +
        timeSlots.map((time) => `<th>${time}</th>`).join("") +
        "</tr>";
      let body = rooms.map((room) => {
        const roomGroups = groupsForDate.filter((group) => (group.room || rooms[0]) === room);
        const events = roomGroups.map((group) => {
          const timeRange = String(group.time || "08:00 / 09:30").split("/").map((part) => part.trim());
          const startTime = group.startTime || timeRange[0];
          const endTime = group.endTime || timeRange[1];
          const toMinutes = (value) => {
            const [hour, minute] = value.split(":").map(Number);
            return hour * 60 + minute;
          };
          const start = toMinutes(startTime);
          const end = toMinutes(endTime);
          const firstSlot = Math.max(0, Math.floor((start - 8 * 60) / calendarIntervalMinutes));
          const afterLastSlot = Math.min(timeSlots.length, Math.max(firstSlot + 1, Math.ceil((end - 8 * 60) / calendarIntervalMinutes)));
          return { group, startTime, endTime, firstSlot, afterLastSlot };
        }).filter((event) => event.firstSlot < timeSlots.length && event.endTime > event.startTime);
        let slot = 0;
        let cells = "";
        while (slot < timeSlots.length) {
          const activeEvents = events.filter((event) => event.firstSlot <= slot && event.afterLastSlot > slot);
          if (!activeEvents.length) {
            cells += "<td></td>";
            slot += 1;
            continue;
          }
          const nextStart = events
            .filter((event) => event.firstSlot > slot)
            .reduce((next, event) => Math.min(next, event.firstSlot), timeSlots.length);
          const nextEnd = activeEvents.reduce((next, event) => Math.min(next, event.afterLastSlot), timeSlots.length);
          const span = Math.max(1, Math.min(nextStart, nextEnd) - slot);
          const title = activeEvents
            .map(({ group, startTime, endTime }) => `${group.name} · ${startTime}–${endTime} · ${group.teacher || ""}`)
            .join("; ");
          const label = activeEvents
            .filter((event) => event.firstSlot === slot)
            .map(({ group, startTime, endTime }) => `<span>${escapeHtml(startTime)} - ${escapeHtml(endTime)} / ${escapeHtml(group.name)}<br>O'qituvchi: ${escapeHtml(group.teacher || "- ")}</span>`)
            .join("");
          cells += `<td class="busy" colspan="${span}" title="${escapeHtml(title)}"><div class="calendar-event">${label}</div></td>`;
          slot += span;
        }
        return `<tr><td>${escapeHtml(room)}</td>${cells}</tr>`;
      }).join("");
      return `<div class="timegrid"><table><thead>${head}</thead><tbody>${body}</tbody></table></div>`;
    }
    function calendarBlock() {
      const weekStart = getWeekStart(selectedCalendarDate);
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);
      const days = Array.from({ length: 7 }, (_, index) => {
        const date = new Date(weekStart);
        date.setDate(date.getDate() + index);
        const dateValue = formatLocalDate(date);
        const dayName = localizedWeekday(date).toLocaleUpperCase();
        return `<button type="button" class="daytab${dateValue === formatLocalDate(selectedCalendarDate) ? " active" : ""}" data-date="${dateValue}" aria-pressed="${dateValue === formatLocalDate(selectedCalendarDate)}">${dayName}</button>`;
      }).join("");
      return `<div class="calendar-strip">
        <div class="daytabs" role="tablist" aria-label="Hafta kunlari">${days}</div>
        <label class="calendar-interval"><span>Vaqt oralig'i</span><select id="calendarInterval"><option value="15"${calendarIntervalMinutes === 15 ? " selected" : ""}>15 daqiqa</option><option value="30"${calendarIntervalMinutes === 30 ? " selected" : ""}>30 daqiqa</option></select></label>
      </div>${timeGridHTML()}`;
    }

    function toggleNums() {
      const shown = document
        .getElementById("statGrid")
        .classList.toggle("nums-shown");
      document.querySelectorAll("#statGrid .v").forEach((el) => {
        el.textContent = shown ? el.dataset.val : "***";
      });
      document.getElementById("viewNumsLbl").textContent = shown
        ? locale.value === "ru" ? "Скрыть цифры" : "Raqamlarni yashirish"
        : locale.value === "ru" ? "Показать цифры" : "Raqamlarni ko'rish";
    }
    function dashHTML() {
      let cards = STATS.map(
        ([ic, l, v, target, sub], i) =>
          `<div class="stat-card" data-target="${target}"${sub ? ` data-sub="${sub}"` : ""} role="button" tabindex="0" style="position:relative">${i === 11 ? '<span style="position:absolute;top:8px;right:8px;background:var(--navy);color:#fff;font-size:9px;font-weight:700;padding:2px 6px;border-radius:5px">NEW</span>' : ""}<div class="ic">${ic}</div><div class="l">${l}</div><div class="v" data-val="${v}">***</div></div>`,
      ).join("");
      return `
 <div class="row" style="justify-content:flex-end;margin-bottom:2px">
  <button class="btn-view-nums" id="viewNumsBtn" onclick="toggleNums()">👁 <span id="viewNumsLbl">Raqamlarni ko'rish</span></button>
 </div>
 <div class="grid stat-grid" id="statGrid">${cards}</div>
 <div class="row" style="margin-top:14px;justify-content:flex-end">
  <button class="cta" style="background:var(--danger)" onclick="window.reportsSub='Markaz Faoliyati Statistikasi';show('reports')">MARKAZ FOYDALILIGI ${MARKAZ_FOYDALILIK}%</button></div>
 <div class="panel"><h2>Haftalik jadval</h2>
 ${calendarBlock()}</div>
 <div class="panel"><h2>Umumiy raqamlar</h2>
 <div class="row">
  <div class="filterbox"><span>Filialni tanlang</span><select><option>Tasnim Filiali</option></select></div>
  <div class="filterbox"><span>Yilni tanlang</span><select><option>2026</option></select></div>
  <div class="filterbox"><span>Oyni tanlang</span><select><option>Sentabr</option></select></div>
  <div class="filterbox"><span>Sana oralig'i</span><input type="text" placeholder="yyyy-MM-dd ~ yyyy-MM-dd"></div>
  <div class="filterbox"><span>To'lov turi</span><select><option>Barchasi</option></select></div>
 </div>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-bottom:18px">
  <div class="fin-card"><span class="badge-ic" style="background:#FDECC8">💰</span><div><div class="fv">0 UZS</div><div class="fl">Tushumlar</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#FBDCD6">📉</span><div><div class="fv">0 UZS</div><div class="fl">Chiqimlar</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#DBF3E4">📈</span><div><div class="fv">0 UZS</div><div class="fl">Foyda</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#DCEEDC">💳</span><div><div class="fv">0 UZS</div><div class="fl">Aktiv balans</div></div></div>
 </div>
 <div class="grid" style="grid-template-columns:1fr 1.4fr;gap:16px">
  <div class="emptystate">
   <svg width="150" height="110" viewBox="0 0 150 110" style="margin-bottom:6px"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
   <div style="font-weight:600;color:var(--ink)">To'lovlar mavjud emas</div>
  </div>
  <div class="chartcard"><h3>2026 yildagi aylanmalar</h3>
   <div class="nodata-pill">Ma'lumot yetarli emas</div>
   <div class="chart-legend"><span><i style="background:#D9534F"></i>Chiqimlar</span><span><i style="background:#E8B75E"></i>Tushumlar</span><span><i style="background:#3FA76A"></i>Foyda</span></div>
  </div>
 </div></div>`;
    }

    function leadsHTML() {
      const rows = [
        [
          "Aziz Karimov",
          "+998 90 123 45 67",
          "14:00",
          "N. Yusupova",
          "Dush/Chor",
          "Instagram",
          badge("Kutilmoqda"),
        ],
        [
          "Malika Tosheva",
          "+998 91 234 56 78",
          "16:00",
          "J. Rustamov",
          "Sesh/Pay",
          "Referral",
          badge("Faol"),
        ],
        [
          "Diyor Nazarov",
          "+998 93 345 67 89",
          "10:00",
          "N. Yusupova",
          "Dush/Chor",
          "Google Ads",
          badge("Sinov darsi"),
        ],
        [
          "Sevinch Ergasheva",
          "+998 94 456 78 90",
          "18:00",
          "F. Aliyev",
          "Shanba",
          "Telegram",
          badge("Kutilmoqda"),
        ],
      ];
      return `<div class="panel">
 <div class="row">
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:170px"><span class="ic">🔍</span></div>
  <div class="inp-ic"><input type="text" placeholder="Dars vaqtini tanla..." style="min-width:150px"><span class="ic">🕐</span></div>
  <select class="dash-select"><option>O'qituvchini tanlang</option></select>
  <select class="dash-select"><option>Kunni tanlang</option></select>
  <label style="display:flex;align-items:center;gap:8px;font-size:13px;color:var(--ink-soft)"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span>Arxiv</label>
  <button class="btn-outline">MANBA</button>
  <div class="spacer"></div>
  <span class="icon-circle danger">🗑️</span>
  <span class="icon-circle warn">✏️</span>
  <button class="btn-solid" onclick="openBolimModal()">+ BO'LIM YARATISH</button>
 </div>
 <div class="row">
  <select class="dash-select" style="min-width:110px"><option>LEADS (0)</option></select>
  <div class="spacer"></div>
  <button class="btn-outline">+ LIDLARNI GURUHGA QO'SHISH</button>
  <button class="btn-excel">📗 EXCEL</button>
 </div>
 <div class="row"><button class="btn-outline" style="width:100%;padding:12px;border-style:dashed">+ QO'SHIMCHA USTUN QO'SHISH</button></div>
 ${tbl(["Ism familiya", "Telefon", "Dars vaqti", "O'qituvchi", "Kun", "Manba", "Status"], rows)}
 <div class="note">Filtrlarni tozalab qidirish · Arxivdan qidirish · Jami: 128 ta lid</div></div>`;
    }

    function teachersHTML() {
      const data = getTableData();
      const rows = (data.teachers || []).map((teacher, index) => [
        `${index + 1}.`,
        `<span class="avatar-round">👤</span>`,
        teacher.name || "Noma'lum",
        teacher.phone || "+998900000000",
        teacher.salary || "0 UZS",
        teacher.share || "0 %",
        teacher.role === "ceo" ? "ceo" : "0 so'm",
        teacher.birthday || "2026-09-25",
        teacher.hiredAt || "2026-09-25",
        recordActionButton("teachers", teacher.id),
      ]);
      return `<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">Mentorlar</h2><span class="count-badge">${rows.length}</span>
  <label style="display:flex;align-items:center;gap:8px;font-size:13px;color:var(--ink-soft);margin-left:8px"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span>Arxiv</label>
  <div class="spacer"></div>
  <button class="btn-sms">💬 SMS YUBORISH</button>
  <button class="btn-solid" onclick="openDrawer('student')">+ YANGI QO'SHISH</button>
 </div>
 <div class="tabs-plain"><div class="tab active">O'QITUVCHILAR</div><div class="tab">SUPPORT O'QITUVCHILAR</div></div>
 <div class="table-card">${tbl(["ID", "Rasm", "Ism familiya", "Telefon raqam", "Doimiy oylik", "Foiz ulush (%)", "Dars haqi", "Tug'ilgan sana", "Ishga olingan sana", ""], rows.length ? rows : [["-", "", "Hech narsa yo'q", "", "", "", "", "", "", ""]])}</div>
 </div>`;
    }

    function groupsHTML() {
      const data = getTableData();
      const rows = (data.groups || []).map((group, index) => [
        `${index + 1}.`,
        `<b>${group.name || "Guruh"}</b>`,
        group.course || "Kurs",
        group.teacher || "islom",
        group.support || "-",
        group.days || "Toq kunlari",
        group.time || "08:00 / 09:30",
        `<span style="color:#5A55E0;font-weight:600">${group.count || 0}</span>`,
        group.opened || "27/09/2026",
        group.ends || "27/11/2026",
        `<span class="badge ok">✓ ${group.status || "Faol"}</span>`,
        recordActionButton("groups", group.id),
      ]);
      return `<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">Guruhlar</h2><span class="count-badge">${rows.length}</span>
  <div class="spacer"></div>
  <button class="btn-solid" onclick="openDrawer('group')">+ YANGI QO'SHISH</button>
 </div>
 <div class="row" style="margin-top:16px">
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:160px"><span class="ic">🔍</span></div>
  <div class="filterbox"><span>Status</span><select><option>Faol</option></select></div>
  <select class="dash-select"><option>O'qituvchi</option></select>
  <select class="dash-select"><option>Kurs</option></select>
  <select class="dash-select"><option>Dars Kunlari</option></select>
  <button class="btn-excel">📗 EXCEL</button>
  <span class="icon-circle">🖥️</span>
 </div>
 <div class="table-card">${tbl(["ID", "Guruh nomi ↕", "Kurs", "O'qituvchi", "Support ustoz", "Dars Kunlari", "Dars vaqti", "O'quvchilar soni", "Ochilgan", "Yakunlanadi", "Status", ""], rows.length ? rows : [["-", "Hech narsa yo'q", "", "", "", "", "", "", "", "", "", ""]])}</div>
 <div class="row" style="margin-top:14px;margin-bottom:0"><select class="dash-select" style="min-width:70px"><option>10</option><option>20</option><option>50</option></select></div>
 </div>`;
    }

    function studentsHTML() {
      const data = getTableData();
      const rows = (data.students || []).map((student, index) => [
        `${index + 1}.`,
        `<span class="avatar-round">👤</span>`,
        student.name || "Noma'lum",
        studentScoreSummary(student),
        student.nextPayment || "-",
        student.phone || "+998900000000",
        student.note || "",
        student.groups || "",
        student.balance || "0 UZS",
        recordActionButton("students", student.id),
      ]);
      return `<div class="panel students-panel">
 <div class="row" style="align-items:flex-start;margin-bottom:0">
  <div>
   <h2 style="margin:0 0 8px;font-size:20px">O'quvchilar</h2>
   <span class="pill blue">O'quvchilar soni: ${rows.length} ta</span> <span class="pill red">Qarzdorlik : ${rows.length ? '0 so\'m' : '0 so\'m'}</span>
  </div>
  <div class="spacer"></div>
  <div style="display:flex;flex-direction:column;gap:8px;align-items:flex-end">
   <div style="display:flex;gap:8px"><button class="btn-excel">📗 EXCEL</button><button class="btn-sms">💬 SMS YUBORISH</button><button class="btn-outline2">🏷️ Faol</button><button class="btn-solid" onclick="openFaolModal()">FAOLLASHTIRISH</button></div>
   <div style="display:flex;gap:8px"><button class="btn-outline2">📑 EXCEL ORQALI QO'SHISH</button><button class="btn-solid" onclick="openDrawer('oquvchi')">+ YANGI QO'SHISH</button><button class="btn-outline2">🏷️ BEYJIKLAR</button></div>
  </div>
 </div>
 <div class="row" style="margin-top:20px">
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:150px"><span class="ic">🔍</span></div>
  <select class="dash-select"><option>Kurslar</option></select>
  <select class="dash-select"><option>Maktab</option></select>
  <div class="filterbox"><span>Guruhdagi holati</span><select><option>Faol</option></select></div>
  <div class="filterbox"><span>To'lov holati</span><select><option>Qarzdor</option></select></div>
  <div class="filterbox"><span>Oy kesimida balans</span><input type="text" placeholder="MM/YYYY"></div>
  <select class="dash-select"><option>Guruh</option></select>
  <select class="dash-select"><option>Ustoz</option></select>
 </div>
 <div class="table-card">${tbl(["ID ↑", "Rasm", "Ism familiya ↕", "Baho ↕", "Keyingi to'lov", "Telefon", "Izoh", "Guruhlar", "Balans ↕", "Harakatlar"], rows.length ? rows : [["-", "", "Hech narsa yo'q", "", "", "", "", "", "", ""]])}</div>
 ${rows.length ? '' : `<div class="empty-note">...</div>`}
 </div>`;
    }

    function examsHTML() {
      const data = getTableData();
      const rows = (data.exams || []).map((exam, index) => [
        `${index + 1}.`,
        exam.name || "Imtihon",
        exam.type || "Guruh imtihoni",
        exam.group || "-",
        exam.date || "-",
        "-",
        "-",
        exam.time || "-",
        "0",
        exam.passScore ?? "0",
        exam.maxScore ?? "100",
        recordActionButton("exams", exam.id),
      ]);
      return `<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">Imtihonlar</h2>
  <div class="spacer"></div>
  <span class="count-badge">${rows.length}</span>
  <button class="btn-solid" onclick="openDrawer('imtihon')">+ IMTIHON QO'SHISH</button>
 </div>
 <div class="tabs-plain"><div class="tab active">Guruh imtihonlari <span class="count-badge" style="margin-left:6px">${rows.length}</span></div><div class="tab">Mock imtihonlar <span class="count-badge" style="margin-left:6px">0</span></div></div>
 <div class="row" style="margin-top:16px">
  <div class="filterbox" style="flex:1;max-width:320px"><span>Holati</span><select><option>Boshlanmagan</option></select></div>
  <div class="filterbox" style="flex:1;max-width:320px"><span>Guruh</span><select><option>Guruh</option></select></div>
  <div class="filterbox" style="flex:1;max-width:260px;position:relative"><span>Dan - Gacha</span><input type="text" value="25/09/2026 ~ 25/10/2026" readonly><span style="position:absolute;right:10px;top:34px;color:var(--ink-soft);cursor:pointer">✕</span></div>
 </div>
 <div class="table-card">${tbl(["ID", "Imtihon nomi", "Turi", "Guruh", "Sana", "Imtihon oluvchi", "Xona", "Vaqt", "O'quvchilar", "Min. ball", "Maks. ball", "Amallar"], rows.length ? rows : [["-", "Hech narsa yo'q", "", "", "", "", "", "", "", "", "", ""]])}</div>
 ${rows.length ? "" : `<div class="empty-note">
  <svg width="150" height="110" viewBox="0 0 150 110"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
  <div style="margin-top:10px;font-weight:600;color:var(--ink)">Hech qanday ma'lumot yo'q</div>
 </div>`}
 </div>`;
    }

    function financeHTML() {
      return `<div class="panel">
 <div class="row">
  <div class="filterbox"><span>Filialni tanlang</span><select><option>Tasnim Filiali</option></select></div>
  <div class="filterbox"><span>Yilni tanlang</span><select><option>2026</option></select></div>
  <div class="filterbox"><span>Oyni tanlang</span><select><option>Sentabr</option></select></div>
  <div class="filterbox"><span>Sana oralig'i</span><input type="text" placeholder="yyyy-MM-dd ~ yyyy-MM-dd"></div>
  <div class="filterbox"><span>To'lov turi</span><select><option>Barchasi</option></select></div>
 </div>
 <h2>Umumiy raqamlar</h2>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-bottom:14px">
  <div class="fin-card"><span class="badge-ic" style="background:#FDECC8">💰</span><div><div class="fv">0 UZS</div><div class="fl">Tushumlar</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#FBDCD6">📉</span><div><div class="fv">0 UZS</div><div class="fl">Chiqimlar</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#DBF3E4">📈</span><div><div class="fv">0 UZS</div><div class="fl">Foyda</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#DCEEDC">💳</span><div><div class="fv">0 UZS</div><div class="fl">Aktiv balans</div></div></div>
 </div>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-bottom:18px">
  <div class="fin-card"><span class="badge-ic" style="background:#DBF3E4">🎓</span><div><div class="fv">0 UZS</div><div class="fl">LTV</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#FDECC8">👥</span><div><div class="fv">0 UZS</div><div class="fl">CAC</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#E3E1FB">📊</span><div><div class="fv">0 %</div><div class="fl">Marketing samaradorligi</div></div></div>
  <div class="fin-card"><span class="badge-ic" style="background:#DCEEF5">👁️</span><div><div class="fv">0 UZS</div><div class="fl">O'rtacha to'lov</div></div></div>
 </div>
 <div class="grid" style="grid-template-columns:1fr 1.4fr;gap:16px">
  <div class="emptystate">
   <svg width="150" height="110" viewBox="0 0 150 110" style="margin-bottom:6px"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
   <div style="font-weight:600;color:var(--ink)">To'lovlar mavjud emas</div>
  </div>
  <div class="chartcard"><h3>2026 yildagi aylanmalar</h3>
   <div class="nodata-pill">Ma'lumot yetarli emas</div>
   <div class="chart-legend"><span><i style="background:#D9534F"></i>Chiqimlar</span><span><i style="background:#E8B75E"></i>Tushumlar</span><span><i style="background:#3FA76A"></i>Foyda</span></div>
  </div>
 </div>
 </div>
 <div class="panel">
  <div class="plan-head">
   <h2 style="margin:0;font-size:19px">2026, Sentabr - oyidagi rejasi</h2>
   <div class="spacer"></div>
   <label class="plan-toggle"><span class="toggle on" onclick="this.classList.toggle('on')"><i></i></span>Tasir vaqti</label>
   <div class="filterbox"><span>Filial</span><select><option>Tasnim Filiali</option></select></div>
   <div class="filterbox"><span>Yil</span><select><option>2026</option></select></div>
   <div class="filterbox"><span>Oy</span><select><option>Sentabr</option></select></div>
   <span class="icon-circle">📅</span>
  </div>
  <div class="subbar">Bajarilish ko'rsatkichlari</div>
  <div class="progress-box">
   <div><div class="pl">Erishilgan summa ⓘ</div><div class="pv">0 so'm</div><div class="ppct">0.0% BAJARILDI</div></div>
   <div style="text-align:right"><div class="pl">Kutilayotgan ⓘ</div><div class="pv">0 so'm</div><div class="ppct">0.0% QOLDI</div></div>
  </div>
  <div class="plan-foot"><span>REJA BAJARILISHI: <b style="color:var(--danger)">0.0%</b></span><span><span style="color:#D9534F">●</span> ERISHILGAN &nbsp; <span style="color:#B7A6F2">●</span> KUTILAYOTGAN</span></div>
  <div class="plan-cards">
   <div class="plan-card" style="background:#5A55E0"><span class="pc-ic">📊</span><div class="pc-l">Oylik reja</div><div class="pc-v">0 so'm</div></div>
   <div class="plan-card" style="background:#E0A934"><span class="pc-ic">📉</span><div class="pc-l">Faol qarzdorlik</div><div class="pc-v">0 so'm</div></div>
   <div class="plan-card" style="background:#4CAF3D"><span class="pc-ic">📈</span><div class="pc-l">Oldindan to'lovlar</div><div class="pc-v">0 so'm</div></div>
   <div class="plan-card" style="background:#D9534F"><span class="pc-ic">📊</span><div class="pc-l">Joriy oy ulushiga</div><div class="pc-v">0 so'm</div></div>
  </div>
 </div>
 <div class="panel">
  <div class="row" style="margin-bottom:0"><h2 style="margin:0;font-size:17px;font-weight:500;color:var(--ink-soft)">Chiqim hisoboti</h2><div class="spacer"></div><button class="btn-solid">+ BO'LIM</button></div>
  <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-top:14px">
   <div class="stat-card" style="text-align:left;padding:16px"><div class="fl" style="font-size:15px;font-weight:600;color:var(--ink);margin-bottom:6px">Avans</div><div class="v">0 UZS</div></div>
   <div class="stat-card" style="text-align:left;padding:16px"><div class="fl" style="font-size:15px;font-weight:600;color:var(--ink);margin-bottom:6px">Marketing</div><div class="v">0 UZS</div></div>
  </div>
 </div>
 <div class="panel">
  <div class="row" style="margin-bottom:0"><h2 style="margin:0;font-size:17px;font-weight:500;color:var(--ink-soft)">Kirim hisoboti</h2><div class="spacer"></div><button class="btn-solid">+ BO'LIM</button></div>
  <div class="empty-note">
   <svg width="150" height="110" viewBox="0 0 150 110"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
   <div style="margin-top:10px;font-weight:600;color:var(--ink)">Hech qanday ma'lumot yo'q</div>
  </div>
 </div>
 <div class="panel">
  <h2 style="font-size:17px;font-weight:500;color:var(--ink-soft)">Xodimlarga bonus va jarimalar</h2>
  <div class="grid" style="grid-template-columns:1fr 1fr;gap:16px">
   <div class="bonus-card"><div class="bl">Bonus</div><div class="bv">0 UZS</div></div>
   <div class="bonus-card"><div class="bl">Jarima</div><div class="bv">0 UZS</div></div>
  </div>
 </div>
 <div class="panel">
  <div class="row" style="margin-bottom:0;align-items:flex-start">
   <div><h2 style="margin:0 0 4px;font-size:17px">Ish haqi hisobotlari</h2><div class="note" style="margin:0">Oylik ish haqi tarixi. Tafsilotlarni ko'rish uchun istalgan oyni tanlang.</div></div>
   <div class="spacer"></div><button class="btn-excel">📄 Eksport</button>
  </div>
  <div class="calc-bar"><span>HISOBLASH TURLARI</span><span>Foiz hisoblash: <b>Kurs narxi</b></span><span>To'lov hisoblash: <b>Qo'shilgan sana</b></span></div>
  <div class="table-card">${tbl(
    [
      "№",
      "OY ↓",
      "XODIMLAR ↕",
      "DOIMIY ↕",
      "FOIZ ↕",
      "DARS ↕",
      "O'QUVCHI ↕",
      "BONUS ↕",
      "JARIMA ↕",
      "AVANS ↕",
      "JAMI ↕",
      "",
    ],
    [
      [
        "1",
        "Sentabr 2026",
        "2",
        "—",
        "0",
        "—",
        "—",
        "—",
        "—",
        "—",
        '<span style="color:#5A55E0">0</span>',
        '<span class="dots">›</span>',
      ],
    ],
  )}</div>
 </div>`;
    }

    function paymentsReportHTML() {
      const teacherRows = [
        [
          "1",
          "islom",
          "1",
          '<span class="pill blue">koputur savotxonligi</span>',
          "1",
          "0 so'm",
          '<span style="color:var(--ok);font-weight:700">0 so\'m</span>',
        ],
      ];
      const statCard = (
        bg,
        ic,
        label,
      ) => `<div class="stat-card" style="text-align:left;padding:14px;position:relative">
  <div class="row" style="margin:0"><span class="ic" style="margin:0;background:${bg}">${ic}</span><span class="spacer"></span><span style="color:var(--danger);font-size:11px;font-weight:700">↓ 0%</span></div>
  <div class="v" style="text-align:left;margin-top:10px">0</div><div class="l" style="text-align:left">${label}</div>
 </div>`;
      return `<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">To'lovlar hisoboti</h2>
  <div class="spacer"></div>
  <div class="filterbox"><span>Filialni tanlang</span><select><option>Tasnim Filiali</option></select></div>
  <div class="filterbox"><span>Yilni tanlang</span><select><option>2026</option></select></div>
  <div class="filterbox"><span>Oyni tanlang</span><select><option>Sentabr</option></select></div>
  <div class="filterbox"><span>Sana oralig'i</span><input type="text" placeholder="yyyy-MM-dd ~ yyyy-MM-dd"></div>
 </div>
 <div class="grid" style="grid-template-columns:repeat(6,1fr);margin-top:18px">
  ${statCard("#EAF2FE", "💳", "Jami to'lov summasi")}
  ${statCard("#DBF3E4", "%", "Vaqtida to'lovlar statistikasi")}
  <div class="stat-card" style="text-align:left;padding:14px;position:relative;overflow:hidden">
   <div style="filter:blur(3px);opacity:.5">
    <div class="row" style="margin:0"><span class="ic" style="margin:0;background:#FBDCD6">📉</span><span class="spacer"></span><span style="color:var(--danger);font-size:11px;font-weight:700">↓ 0%</span></div>
    <div class="v" style="text-align:left;margin-top:10px">0</div><div class="l" style="text-align:left">Qarzdorlik</div>
   </div>
   <div class="nodata-pill" style="background:#5A55E0">Ma'lumot yetarli emas</div>
  </div>
  ${statCard("#E3E1FB", "$", "Jami chegirmalar summasi")}
  ${statCard("#FDECC8", "🎁", "Jami bonus summasi")}
  ${statCard("#DCEEF5", "🔄", "Qaytarilgan to'lovlar")}
 </div>
 <div style="display:inline-block;background:var(--ink);color:#fff;font-size:11.5px;padding:6px 12px;border-radius:6px;margin-top:18px">Barcha filiallar bo'yicha jami to'lovlar summasi</div>
 <div class="tabs-plain" style="margin-top:2px"><div class="tab active">O'QITUVCHILAR</div><div class="tab">XODIMLAR</div></div>
 <div class="row" style="margin-top:14px;margin-bottom:0">
  <h2 style="margin:0;font-size:19px">O'qituvchilar ro'yxati</h2>
  <div class="spacer"></div>
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:200px"><span class="ic">🔍</span></div>
  <button class="btn-excel">📗 EXCEL</button>
 </div>
 <div class="table-card">${tbl(["№", "TO'LIQ ISM", "GURUHLAR SONI", "KURSLAR", "TALABALAR SONI", "JAMI TO'LOV", "QARZ"], teacherRows)}</div>
 <div class="row" style="justify-content:flex-end;margin-top:10px;color:var(--ink-soft);font-size:12.5px">
  <span>Rows per page:</span><select style="min-width:70px;margin:0 10px"><option>100</option></select><span>1–1 of 1</span>
  <span class="dots">‹</span><span class="dots">›</span>
 </div>
 </div>`;
    }

    function studentsPaymentHTML() {
      return `<div>
<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">O'quvchilar to'lovi</h2>
  <span class="count-badge">0</span>
  <span class="pill green">0 so'm</span>
  <div class="spacer"></div>
  <label style="display:flex;align-items:center;gap:8px;font-size:13px;color:var(--ink-soft)"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span>To'lov sanasi bo'yicha</label>
  <button class="btn-excel">📗 EXCEL</button>
 </div>
 <div class="row" style="margin-top:16px">
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:150px"><span class="ic">🔍</span></div>
  <select class="dash-select"><option>Guruhlar</option></select>
  <select class="dash-select"><option>To'lov turi</option></select>
  <select class="dash-select"><option>O'qituvchilar</option></select>
  <select class="dash-select"><option>Kurslar</option></select>
  <select class="dash-select"><option>O'quvchi bonusi</option></select>
  <div class="filterbox" style="min-width:150px"><input type="text" placeholder="dd/MM/yyyy ~"></div>
  <select class="dash-select"><option>Qabul qilgan xodim</option></select>
 </div>
 <div class="table-card">${tbl(["ID O'quvchi", "Guruhi", "O'qituvchi", "To'lov miqdori", "O'quvchi bonuslari", "To'lov sanasi", "Tasir vaqti", "Izoh", "Qabul qilgan xodim", "To'lov turi", "Amallar"], [])}</div>
 <div class="emptystate" style="border:none;margin-top:6px">
  <svg width="150" height="110" viewBox="0 0 150 110" style="margin-bottom:6px"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
  <div style="font-weight:600;color:var(--ink)">Ma'lumot topilmadi</div>
 </div>
   </div>
   <div id="student-profile-dashboard"></div>
   </div>`;
    }

    function churnReportHTML() {
      const kpi = (
        label,
        value,
      ) => `<div class="fin-card" style="flex-direction:column;align-items:stretch;gap:14px;padding:18px">
  <div class="row" style="margin:0"><span style="color:var(--ink-soft);font-size:13px">${label}</span><span class="spacer"></span><span style="color:#5A55E0;font-size:14px">ⓘ</span></div>
  <div style="font-size:26px;font-weight:700;font-family:'Sora',sans-serif">${value}</div>
 </div>`;
      return `<div class="panel">
 <div class="row" style="align-items:flex-start;margin-bottom:0">
  <div><h2 style="margin:0 0 4px;font-size:20px">Ketish va guruh o'zgarishi tahlili</h2><div class="note" style="margin:0">Saqlab qolishni tahlil qilish, xavflarni aniqlash va LTVni oshirishga yordam beradi</div></div>
  <div class="spacer"></div>
  <button class="btn-solid">⚙ SABABLARNI SOZLASH</button>
 </div>
 <div class="row" style="margin-top:18px">
  <div class="filterbox"><span>Joriy oy</span><select><option>Joriy oy</option></select></div>
  <div style="position:relative"><input type="text" value="09/01/2026 ~ 09/26/2026" readonly style="padding:9px 30px 9px 12px;border:1px solid var(--line);border-radius:8px;background:var(--surface);color:var(--ink);font-size:13px;min-width:170px"><span style="position:absolute;right:10px;top:10px;color:var(--ink-soft);cursor:pointer">✕</span></div>
  <div class="filterbox"><span>Barcha filiallar</span><select><option>Tasnim Filiali</option></select></div>
  <select class="dash-select"><option>Barcha kurslar</option></select>
  <select class="dash-select"><option>Barcha o'qituvchilar</option></select>
 </div>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-top:18px">
  ${kpi("Ketish koeffitsienti", "0%")}
  ${kpi("Ketganlar soni", "0")}
  ${kpi("Yo'qotilgan daromad", "0.00")}
  ${kpi("O'rtacha umr", "0 oy")}
 </div>
 <div class="grid" style="grid-template-columns:1fr 1fr;gap:16px;margin-top:16px">
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px">
   <h3 style="margin:0 0 4px;font-size:16px;font-weight:700;color:var(--ink)">Ketish dinamikasi</h3>
   <div class="note" style="margin:0 0 14px">Oxirgi 30 kun ichida ketgan talabalar soni</div>
   <svg width="100%" height="230" viewBox="0 0 700 230" preserveAspectRatio="none">
    <line x1="40" y1="10" x2="40" y2="190" stroke="var(--line)"/>
    <line x1="40" y1="190" x2="680" y2="190" stroke="var(--line)"/>
    <text x="12" y="119" font-size="11" fill="var(--ink-soft)">0</text>
    <polyline points="${Array.from({ length: 26 }, (_, i) => `${40 + i * (640 / 25)},115`).join(" ")}" fill="none" stroke="#5A55E0" stroke-width="1.5" stroke-dasharray="1,6"/>
    ${Array.from({ length: 26 }, (_, i) => `<circle cx="${40 + i * (640 / 25)}" cy="115" r="3" fill="#5A55E0"/>`).join("")}
    <text x="40" y="212" font-size="11" fill="#5A55E0">01/09</text>
    <text x="168" y="212" font-size="11" fill="#5A55E0">06/09</text>
    <text x="296" y="212" font-size="11" fill="var(--ink-soft)">11/09</text>
    <text x="424" y="212" font-size="11" fill="#5A55E0">16/09</text>
    <text x="552" y="212" font-size="11" fill="#5A55E0">21/09</text>
    <text x="670" y="212" font-size="11" fill="#5A55E0" text-anchor="end">26/09</text>
   </svg>
  </div>
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px;position:relative">
   <div class="row" style="margin:0 0 4px"><h3 style="margin:0;font-size:16px;font-weight:700;color:var(--ink)">Asosiy ketish sabablari</h3><span class="spacer"></span><span style="font-size:12px;color:var(--ink-soft)">Jami: 11</span></div>
   <div class="note" style="margin:0 0 20px">Nima uchun talabalar ketmoqda?</div>
   <div style="filter:blur(2.5px);opacity:.65;display:flex;flex-direction:column;gap:18px">
    <div style="display:flex;align-items:center;gap:10px"><span style="width:52px;font-size:11px;color:var(--ink-soft)">Narx</span><div style="height:22px;border-radius:6px;background:#E0417E;width:18%"></div></div>
    <div style="display:flex;align-items:center;gap:10px"><span style="width:52px;font-size:11px;color:var(--ink-soft)">Vaqt</span><div style="height:22px;border-radius:6px;background:#5A55E0;width:32%"></div></div>
    <div style="display:flex;align-items:center;gap:10px"><span style="width:52px;font-size:11px;color:var(--ink-soft)">Sifat</span><div style="height:22px;border-radius:6px;background:#1DB854;width:55%"></div></div>
    <div style="display:flex;align-items:center;gap:10px"><span style="width:52px;font-size:11px;color:var(--ink-soft)">Boshqa</span><div style="height:22px;border-radius:6px;background:#E0A934;width:68%"></div></div>
   </div>
   <div class="nodata-pill" style="background:#5A55E0">MA'LUMOT YETARLI EMAS</div>
  </div>
 </div>
 <div class="row" style="align-items:flex-start;margin-top:20px;margin-bottom:0">
  <div><h2 style="margin:0 0 4px;font-size:19px">Sabablarni chuqur tahlil qilish</h2><div class="note" style="margin:0">Yo'nalishlar va sabablar bo'yicha taqsimot</div></div>
  <div class="spacer"></div>
  <div class="row" style="gap:8px;flex-wrap:wrap;justify-content:flex-end;margin:0">
   ${["Kurs Bo'yicha", "O'qituvchi Bo'yicha", "Filial Bo'yicha", "Status Bo'yicha", "Sabab Bo'yicha", "Joriy oyda qo'shilib ketgan"].map((t) => `<span style="padding:8px 14px;border-radius:20px;font-size:12px;font-weight:600;white-space:nowrap;background:${t === "Sabab Bo'yicha" ? "#DCEEF5" : "var(--bg)"};color:${t === "Sabab Bo'yicha" ? "#1878A8" : "var(--ink-soft)"};cursor:pointer">${t}</span>`).join("")}
  </div>
 </div>
 <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px;margin-top:14px;position:relative">
  <svg width="100%" height="300" viewBox="0 0 1000 300" style="filter:blur(2.5px);opacity:.65">
   ${Array.from({ length: 9 }, (_, i) => {
     const y = 20 + i * 28;
     return `<line x1="60" y1="${y}" x2="960" y2="${y}" stroke="var(--line)" stroke-width="1"/><text x="45" y="${y + 4}" font-size="10" fill="var(--ink-soft)" text-anchor="end">${8 - i}</text>`;
   }).join("")}
   <rect x="140" y="120" width="150" height="132" rx="6" fill="#E0A934"/>
   <text x="215" y="192" font-size="11" fill="#fff" text-anchor="middle">0</text>
   <text x="215" y="272" font-size="10" fill="var(--ink-soft)" text-anchor="middle">Narx</text>
   <rect x="380" y="160" width="150" height="92" rx="6" fill="#1DB854"/>
   <text x="455" y="212" font-size="11" fill="#fff" text-anchor="middle">0</text>
   <text x="455" y="272" font-size="10" fill="var(--ink-soft)" text-anchor="middle">O'qituvchi</text>
   <rect x="620" y="190" width="150" height="62" rx="6" fill="#7C5CE0"/>
   <text x="695" y="227" font-size="11" fill="#fff" text-anchor="middle">0</text>
   <text x="695" y="272" font-size="10" fill="var(--ink-soft)" text-anchor="middle">Vaqt</text>
   <rect x="800" y="210" width="150" height="42" rx="6" fill="#E0417E"/>
   <text x="875" y="237" font-size="11" fill="#fff" text-anchor="middle">0</text>
   <text x="875" y="272" font-size="10" fill="var(--ink-soft)" text-anchor="middle">Boshqa</text>
  </svg>
  <div class="nodata-pill" style="background:#5A55E0">MA'LUMOT YETARLI EMAS</div>
 </div>
 <div class="row" style="margin-top:22px;margin-bottom:0"><h2 style="margin:0;font-size:19px">Guruh o'zgarishi (Ichki migratsiya)</h2><span style="background:#3B82F6;color:#fff;font-size:11px;font-weight:700;padding:5px 12px;border-radius:20px;margin-left:10px">Saqlab qolish vositasi</span></div>
 <div class="grid" style="grid-template-columns:1fr 1fr;gap:16px;margin-top:14px">
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px">
   <div style="color:var(--ink-soft);font-size:13px;margin-bottom:8px">⇄ Jami o'zgarishlar</div>
   <div style="font-size:26px;font-weight:700;font-family:'Sora',sans-serif">0</div>
  </div>
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px">
   <div style="color:var(--ink-soft);font-size:13px;margin-bottom:8px">👥→ O'zgargandan keyin ketish</div>
   <div style="font-size:26px;font-weight:700;font-family:'Sora',sans-serif">0.0%</div>
  </div>
 </div>
 <div class="grid" style="grid-template-columns:1fr 1fr;gap:16px;margin-top:16px">
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px;position:relative">
   <h3 style="margin:0 0 18px;font-size:16px;font-weight:700;color:var(--ink)">Nima uchun guruh o'zgartirildi?</h3>
   <div class="row" style="align-items:center;filter:blur(2px);opacity:.7">
    <div style="width:170px;height:170px;border-radius:50%;background:conic-gradient(#E0A934 0% 40%,#22C3C9 40% 50%,#7C5CE0 50% 75%,#1DB854 75% 100%);position:relative;flex:0 0 auto">
     <div style="position:absolute;inset:32px;background:var(--surface);border-radius:50%"></div>
    </div>
    <div style="display:flex;flex-direction:column;gap:10px;font-size:12px;color:var(--ink-soft)">
     <span><i style="display:inline-block;width:9px;height:9px;border-radius:50%;background:#E0A934;margin-right:6px"></i>Narx (40%, 40.0%)</span>
     <span><i style="display:inline-block;width:9px;height:9px;border-radius:50%;background:#22C3C9;margin-right:6px"></i>Jadval (10%, 10.0%)</span>
     <span><i style="display:inline-block;width:9px;height:9px;border-radius:50%;background:#7C5CE0;margin-right:6px"></i>Ustoz (25%, 25.0%)</span>
     <span><i style="display:inline-block;width:9px;height:9px;border-radius:50%;background:#1DB854;margin-right:6px"></i>Boshqa (25%, 25.0%)</span>
    </div>
   </div>
   <div class="nodata-pill" style="background:#5A55E0">MA'LUMOT YETARLI EMAS</div>
  </div>
  <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:18px;position:relative">
   <h3 style="margin:0 0 18px;font-size:16px;font-weight:700;color:var(--ink)">Chegirmalarning ta'siri</h3>
   <svg width="100%" height="230" viewBox="0 0 500 230" style="filter:blur(2.5px);opacity:.65">
    ${Array.from({ length: 5 }, (_, i) => {
      const y = 20 + i * 36;
      return `<line x1="50" y1="${y}" x2="470" y2="${y}" stroke="var(--line)"/><text x="38" y="${y + 4}" font-size="10" text-anchor="end" fill="var(--ink-soft)">${(4 - i) * 10}</text>`;
    }).join("")}
    <rect x="130" y="120" width="90" height="60" rx="6" fill="#1DB854"/>
    <text x="175" y="212" font-size="10" fill="var(--ink-soft)" text-anchor="middle">Chegirma olganlar</text>
    <rect x="300" y="80" width="90" height="100" rx="6" fill="#E15C5C"/>
    <text x="345" y="212" font-size="10" fill="var(--ink-soft)" text-anchor="middle">Chegirma olmaganlar</text>
   </svg>
   <div class="nodata-pill" style="background:#5A55E0">MA'LUMOT YETARLI EMAS</div>
  </div>
 </div>
 <div class="row" style="margin-top:22px;margin-bottom:0"><h2 style="margin:0;font-size:19px">Ketgan talabalar ro'yxati</h2><div class="spacer"></div><span class="count-badge">0</span></div>
 <div class="row" style="margin-top:14px">
  <div class="inp-ic"><input type="text" placeholder="Qidirish (Ism, Telefon)" style="min-width:200px"><span class="ic">🔍</span></div>
  <select class="dash-select"><option>Kursni tanlang</option></select>
  <select class="dash-select"><option>Guruhni tanlang</option></select>
  <select class="dash-select"><option>O'qituvchini tanlang</option></select>
  <select class="dash-select"><option>Sababni tanlang</option></select>
  <select class="dash-select"><option>Chegirma holati</option></select>
 </div>
 <div class="table-card">${tbl(["#", "ISM FAMILIYA", "GURUH", "KURS", "CHEGIRMA", "O'QITUVCHI", "SABAB", "KETGAN SANA", "KIM TOMONIDAN CHIQARILGAN", "IZOH"], [])}</div>
 <div class="emptystate" style="border:none;margin-top:0">
  <svg width="150" height="110" viewBox="0 0 150 110" style="margin-bottom:6px"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
  <div style="font-weight:600;color:var(--ink)">Hech qanday ma'lumot yo'q</div>
 </div>
 </div>`;
    }

    function graduatesReportHTML() {
      const card = (
        label,
        sub,
        icBg,
        ic,
        value,
        valueExtra,
        foot,
        footColor,
      ) => `<div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px;position:relative">
  <div class="row" style="margin:0"><div><div style="font-size:11.5px;font-weight:700;letter-spacing:.3px;color:var(--ink)">${label}</div>${sub ? `<div style="font-size:11px;color:var(--ink-soft);margin-top:2px;max-width:110px">${sub}</div>` : ""}</div><span class="spacer"></span><span style="width:34px;height:34px;border-radius:50%;background:${icBg};display:inline-flex;align-items:center;justify-content:center;font-size:15px;flex:0 0 auto">${ic}</span></div>
  <div style="margin-top:16px;display:flex;align-items:baseline;gap:8px"><span style="font-size:22px;font-weight:700;font-family:'Sora',sans-serif">${value}</span>${valueExtra ? `<span style="font-size:12px;font-weight:700;color:${valueExtra.color}">${valueExtra.text}</span>` : ""}</div>
  <div style="font-size:12px;color:${footColor};font-weight:600;margin-top:4px">${foot}</div>
 </div>`;
      return `<div class="panel">
 <div class="row" style="align-items:flex-start;margin-bottom:0">
  <div><h2 style="margin:0 0 4px;font-size:20px">Bitiruvchilar hisoboti</h2><div class="note" style="margin:0">Bitiruvchilar natijalari va ustozlar samaradorligi tahlili</div></div>
  <div class="spacer"></div>
  <select class="dash-select"><option>🏢 Barcha filiallar</option></select>
  <select class="dash-select"><option>📅 2026</option></select>
  <select class="dash-select"><option>📅 Barcha oylar</option></select>
 </div>
 <div class="row" style="justify-content:flex-end;margin-top:14px">
  <button class="btn-outline2">☰ Kartalarni sozlash</button>
 </div>
 <div class="grid" style="grid-template-columns:repeat(6,1fr);margin-top:16px">
  ${card("NATIJADORLIK", "Bitiruvchilar ko'rsatkichi", "#DCEEF5", "🏆", "0 nafar", { text: "0%", color: "#5A55E0" }, "Jami bitiruvchilar", "#1DB854")}
  ${card("ENG YAXSHI USTOZ", "", "#FDECC8", "⭐", "N/A", { text: "undefined%", color: "var(--warn)" }, "Eng yuqori natija", "var(--ink-soft)")}
  ${card("O'RTACHA IELTS", "", "#DBF3E4", "📈", "0", null, "Batafsil ko'rish", "#5A55E0")}
  ${card("O'RTACHA CEFR", "", "#FBD9E6", "📖", "0", null, "Batafsil ko'rish", "#5A55E0")}
  ${card("OTMGA KIRISH", "", "#FDECC8", "🎓", "0%", null, "OTMga kirish darajasi", "var(--ink-soft)")}
  ${card("ISHGA JOYLASHISH", "", "#E9E9EF", "💼", "0%", null, "Bandlik darajasi", "var(--ink-soft)")}
 </div>
 <div class="row" style="margin-top:22px;align-items:flex-start">
  <div><h2 style="margin:0 0 8px;font-size:19px">Batafsil bitiruvchilar ro'yxati</h2>
   <div class="row" style="margin:0;gap:8px">
    <span class="pill blue" style="border-color:var(--line);color:var(--ink-soft)">👥 0 TALABA</span>
    <span class="pill green">✓ 0 NATIJA</span>
    <span class="pill blue">⚡ 0% MUVAFFAQIYAT</span>
   </div>
  </div>
  <div class="spacer"></div>
  <div class="inp-ic"><input type="text" placeholder="Talaba yoki guruhni qidirish..." style="min-width:220px"><span class="ic">🔍</span></div>
 </div>
 <div class="row" style="margin-top:14px">
  <button class="btn-outline2">💬 Barcha guruhlar ⌄</button>
  <button class="btn-outline2">👤 Barcha ustozlar ⌄</button>
  <button class="btn-outline2">▽ Barcha natijalar ⌄</button>
  <button class="btn-outline2">📖 Barcha kurslar ⌄</button>
 </div>
 <div class="table-card">${tbl(["#", "F.I.SH", "GURUH / FILIAL", "USTOZ", "BITIRUV SANASI", "NATIJALAR"], [])}<div style="text-align:center;color:var(--ink-soft);font-size:13px;padding:16px 0;border-top:1px solid var(--line)">Ma'lumot yo'q</div></div>
 <div class="row" style="margin-top:12px;color:var(--ink-soft);font-size:12px">
  <span style="font-weight:700">SAHIFADA KO'RSATISH:</span>
  <select class="dash-select" style="min-width:90px"><option>10 tadan</option></select>
  <div class="spacer"></div>
  <span>0 dan 0 gacha, jami 0 ta bitiruvchi</span>
  <span class="dots">«</span><span class="dots">‹</span><span>1 / 1</span><span class="dots">›</span><span class="dots">»</span>
 </div>
 </div>`;
    }

    function attendanceReportHTML() {
      const statCard = (
        title,
        value,
        valColor,
        sub,
        ic,
      ) => `<div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px">
  <div class="row" style="margin:0"><span style="font-size:13px;color:var(--ink-soft)">${title}</span><span class="spacer"></span><span style="color:var(--ink-soft);font-size:14px">${ic}</span></div>
  <div style="font-size:24px;font-weight:700;font-family:'Sora',sans-serif;color:${valColor};margin-top:8px">${value}</div>
  <div style="font-size:12px;color:var(--ink-soft);margin-top:2px">${sub}</div>
 </div>`;
      const today = selectedAttendanceDate;
      const nowork =
        '<span style="background:var(--bg);color:var(--ink-soft);font-size:11px;padding:4px 10px;border-radius:14px;white-space:nowrap">ish kuni emas</span>';
      const dash = '<span style="color:#5A55E0">—</span>';
      const rows = [
        [
          "1",
          `<a style="color:#5A55E0;font-weight:600;cursor:pointer">Ergashov Islom</a>`,
          "Tasnim Filliali",
          dash,
          "—",
          dash,
          "—",
          "—",
          "—",
          "—",
          nowork,
        ],
        [
          "2",
          `<a style="color:#5A55E0;font-weight:600;cursor:pointer">islom</a>`,
          "Tasnim Filliali",
          dash,
          "—",
          dash,
          "—",
          "—",
          "—",
          "—",
          nowork,
        ],
      ];
      return `<div>
 <div class="row" style="align-items:flex-start;margin-bottom:0">
  <div><div class="row" style="margin:0"><h2 style="margin:0;font-size:20px">Hodimlar davomati boshqaruv paneli</h2><button class="btn-outline2" style="padding:6px 14px;font-size:12px">Eski versiyani ko'rish</button></div>
   <div class="note" style="margin:4px 0 0">Xodimlar davomat hisoboti va statistikasi</div></div>
  <div class="spacer"></div>
  <select class="dash-select"><option>📅 Sentyabr</option></select>
  <select class="dash-select"><option>2026</option></select>
  <select class="dash-select"><option>Barcha filiallar</option></select>
 </div>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);gap:14px;margin-top:16px">
  ${statCard("Jami hodimlar", "2", "var(--ink)", "Faol xodimlar soni", "👥")}
  ${statCard(`Bugun kelganlar(${today})`, "0", "#3B82F6", "0% davomat", "🕐")}
  ${statCard(`Bugun kechikkanlar(${today})`, "0", "var(--warn)", "0% kechikish", "📈")}
  ${statCard(`Bugun kelmaganlar(${today})`, "0", "var(--danger)", "0% yo'qlik", "📄")}
 </div>
 <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px;margin-top:14px;display:flex;gap:24px;align-items:center;flex-wrap:wrap">
  <div class="filterbox"><span>☰ Kun bo'yicha filter:</span><select><option></option></select></div>
  <div class="filterbox"><span>Sana tanlash</span><input id="attendanceDatePicker" type="date" value="${today}" style="min-width:150px"></div>
 </div>
 <div style="background:var(--line);border-radius:var(--radius);padding:6px;margin-top:14px;display:flex;gap:4px;flex-wrap:wrap">
  <div style="background:var(--surface);border-radius:8px;padding:10px 18px;font-size:13px;font-weight:600;color:var(--ink)">📅 Kunlik</div>
  <div style="padding:10px 18px;font-size:13px;font-weight:600;color:var(--ink-soft)">📅 Haftalik</div>
  <div style="padding:10px 18px;font-size:13px;font-weight:600;color:var(--ink-soft)">📊 Oylik</div>
  <div style="padding:10px 18px;font-size:13px;font-weight:600;color:var(--ink-soft)">🏛 Statistika</div>
  <div style="padding:10px 18px;font-size:13px;font-weight:600;color:var(--ink-soft)">🕐 Ish jadvallari</div>
 </div>
 <div class="panel" style="margin-top:14px">
  <h3 style="margin:0 0 2px;font-size:16px">📅 ${today} - Kunlik hisobot</h3>
  <div class="note" style="margin:0 0 14px">Tanlangan kun uchun davomat ma'lumotlari</div>
  <div class="table-card">${tbl(["T/R", "HODIM", "FILIAL", "KUTILAYOTGAN KIRISH VAQTI", "KIRISH VAQTI", "KUTILAYOTGAN CHIQISH VAQTI", "CHIQISH VAQTI", "KECHIKISH", "ERTA KETISH", "ISHLANGAN VAQT", "HOLAT"], rows)}</div>
 </div>
 </div>`;
    }

    function coinsReportHTML() {
      const kpi = (
        bg,
        ic,
        value,
        label,
      ) => `<div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px;display:flex;align-items:center;gap:14px">
  <span style="width:40px;height:40px;border-radius:10px;background:${bg};display:inline-flex;align-items:center;justify-content:center;font-size:17px;flex:0 0 auto">${ic}</span>
  <div><div style="font-size:19px;font-weight:700;font-family:'Sora',sans-serif">${value}</div><div style="font-size:12px;color:var(--ink-soft)">${label}</div></div>
 </div>`;
      const rows = [
        [
          '<span style="font-size:16px">🏆</span>',
          "samandar",
          '<span style="color:#5A55E0;font-weight:600">🪙 0</span>',
          '<span style="color:#1DB854;font-weight:600">0</span>',
          '<span style="color:var(--warn);font-weight:600">0</span>',
          "-",
          '<button class="btn-outline2" style="padding:6px 16px;font-size:12px">KO\'RISH</button>',
        ],
      ];
      return `<div class="panel">
 <h2 style="margin:0 0 4px;font-size:20px">Coinlar hisoboti</h2>
 <div class="note" style="margin:0">Coin tizimi reytingi va boshqaruvi</div>
 <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-top:16px">
  ${kpi("#DCEEDC", "🤲🪙", "0", "Jami berilgan coinlar")}
  ${kpi("#FDECC8", "🛒", "0", "Jami ishlatilgan coinlar")}
  ${kpi("#DCEEF5", "🛍️", "0", "Marketplace xaridlari")}
  ${kpi("#E3E1FB", "👥", "0", "Coinli faol o'quvchilar")}
 </div>
 <div class="tabs-plain" style="margin-top:20px"><div class="tab active">REYTING</div><div class="tab">MARKETPLACE</div><div class="tab">XARID SO'ROVLARI</div></div>
 <div class="row" style="margin-top:16px;margin-bottom:0">
  <h3 style="margin:0;font-size:17px">Reyting</h3>
  <div class="spacer"></div>
  <span class="pill blue">Jami: 1 o'quvchi</span>
 </div>
 <div class="row" style="margin-top:14px">
  <div class="inp-ic"><input type="text" placeholder="Qidirish" style="min-width:130px"><span class="ic">🔍</span></div>
  <select class="dash-select"><option>Filial</option></select>
  <select class="dash-select"><option>Kurs</option></select>
  <select class="dash-select"><option>Guruh</option></select>
  <div class="filterbox"><input type="text" placeholder="Boshlanish sanasi 📅"></div>
  <div class="filterbox"><input type="text" placeholder="Tugash sanasi 📅"></div>
  <div class="spacer"></div>
  <div style="display:flex;border:1px solid var(--line);border-radius:8px;overflow:hidden">
   <span style="padding:9px 14px;font-size:12px;font-weight:700;color:var(--ink-soft);cursor:pointer">HAFTALIK</span>
   <span style="padding:9px 14px;font-size:12px;font-weight:700;color:var(--ink-soft);cursor:pointer;border-left:1px solid var(--line)">OYLIK</span>
   <span style="padding:9px 14px;font-size:12px;font-weight:700;color:#fff;background:#5A55E0;cursor:pointer;border-left:1px solid var(--line)">BARCHASI</span>
  </div>
 </div>
 <div class="table-card">${tbl(["O'RIN", "O'QUVCHI", "JORIY COIN", "JAMI YIG'ILGAN", "JAMI SARFLANGAN", "SO'NGGI FAOLLIK", "AMALLAR"], rows)}</div>
 </div>`;
    }

    function studentsReportHTML() {
      const card = (
        bg,
        ic,
        trend,
        trendUp,
        value,
        label,
      ) => `<div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:14px">
  <div class="row" style="margin:0"><span style="width:32px;height:32px;border-radius:8px;background:${bg};display:inline-flex;align-items:center;justify-content:center;font-size:14px">${ic}</span><span class="spacer"></span><span style="background:${trendUp ? "#DBF3E4" : "#FBDCD6"};color:${trendUp ? "#1DB854" : "var(--danger)"};font-size:11px;font-weight:700;padding:3px 8px;border-radius:14px">${trendUp ? "↑" : "↓"} ${trend}</span></div>
  <div style="font-size:20px;font-weight:700;font-family:'Sora',sans-serif;margin-top:10px">${value}</div>
  <div style="font-size:12px;color:var(--ink-soft);margin-top:2px">${label}</div>
  <div style="font-size:12px;color:#5A55E0;font-weight:600;margin-top:8px;cursor:pointer">To'liqroq ma'lumot</div>
 </div>`;
      return `<div class="panel">
 <h2 style="margin:0 0 16px;font-size:20px">O'quvchilar hisoboti</h2>
 <div class="row" style="margin:0">
  <div class="filterbox"><span>Filial</span><select><option>Tasnim Filiali</option></select></div>
  <div class="filterbox"><span>Yil</span><select><option>2026</option></select></div>
  <div class="filterbox"><span>Oy</span><select><option>Sentyabr</option></select></div>
  <div class="filterbox"><span>&nbsp;</span><input type="text" placeholder="yyyy-MM-dd ~ yyyy-MM-dd"></div>
 </div>
 <div class="grid" style="grid-template-columns:repeat(6,1fr);margin-top:16px">
  ${card("#DCEEF5", "👥", "100%", true, "1", "Jami o'quvchilar")}
  ${card("#E3E1FB", "🧑‍🤝‍🧑", "0%", false, "1", "Yangi qo'shilgan o'quvchilar")}
  ${card("#DCEEF5", "📖", "0%", false, "0", "2 va undan ortiq kursda o'qiyotganlar")}
  ${card("#DBF3E4", "🕐", "0%", false, "0%", "Umumiy davomat")}
  ${card("#FDECC8", "🏅", "0%", false, "0", "O'rtacha baho")}
  ${card("#E3E1FB", "📱", "0%", true, "0 ta (0.0%)", "Ilovadan foydalanish")}
 </div>
 <div class="tabs-plain" style="margin-top:22px"><div id="studSubTabAtt" class="stab active" onclick="switchStudentSubTab('att')">DAVOMATLAR HISOBOTI</div><div id="studSubTabOzl" class="stab" onclick="switchStudentSubTab('ozl')">O'ZLASHTIRISH DARAJASI</div></div>
 <div id="studPanelAtt" class="panel" style="position:relative">
  <h2 style="margin:0 0 4px;font-size:19px">Davomatlar hisoboti</h2>
  <div class="note" style="margin:0 0 14px">Guruhlar bo'yicha davomatlar ma'lumotlari</div>
  <div class="row">
   <div class="filterbox"><span>Yil</span><select><option>2026</option></select></div>
   <div class="filterbox"><span>Oy</span><select><option>Sentyabr</option></select></div>
   <div style="position:relative"><input type="text" value="2026-09-25 ~ 2026-09-26" readonly style="padding:9px 30px 9px 12px;border:1px solid var(--line);border-radius:8px;background:var(--surface);color:var(--ink);font-size:13px;min-width:190px"><span style="position:absolute;right:10px;top:10px;color:var(--ink-soft);cursor:pointer">✕</span></div>
  </div>
  <div class="row">
   <select class="dash-select"><option>Guruhlar</option></select>
   <select class="dash-select"><option>Barcha o'qituvchilar</option></select>
   <div class="filterbox"><span>Holatlar</span><select><option>Barcha holatlar</option></select></div>
  </div>
  <span style="position:absolute;top:96px;right:150px;width:38px;height:38px;border-radius:50%;background:#5A55E0;color:#fff;display:inline-flex;align-items:center;justify-content:center;font-size:15px;box-shadow:0 4px 10px rgba(90,85,224,.4)">⚙️</span>
  <div class="grid" style="grid-template-columns:repeat(4,1fr);margin-top:14px">
   <div style="border:1px solid var(--line);border-radius:var(--radius);padding:16px;text-align:center"><div style="font-size:13px;color:#3B82F6;font-weight:600">Jami davomat qilinishi kerak edi</div><div style="font-size:22px;font-weight:700;font-family:'Sora',sans-serif;color:#3B82F6;margin-top:8px">0</div></div>
   <div style="border:1px solid var(--line);border-radius:var(--radius);padding:16px;text-align:center"><div style="font-size:13px;color:#1DB854;font-weight:600">Kelgan</div><div style="font-size:22px;font-weight:700;font-family:'Sora',sans-serif;color:#1DB854;margin-top:8px">0</div></div>
   <div style="border:1px solid var(--line);border-radius:var(--radius);padding:16px;text-align:center"><div style="font-size:13px;color:var(--danger);font-weight:600">Kelmagan</div><div style="font-size:22px;font-weight:700;font-family:'Sora',sans-serif;color:var(--danger);margin-top:8px">0</div></div>
   <div style="border:1px solid var(--line);border-radius:var(--radius);padding:16px;text-align:center"><div style="font-size:13px;color:var(--ink-soft);font-weight:600">Davomat qilinmagan</div><div style="font-size:22px;font-weight:700;font-family:'Sora',sans-serif;color:var(--ink);margin-top:8px">0</div></div>
  </div>
  <div class="table-card">${tbl(["№", "Guruh nomi", "O'qituvchi F.I.O", "Talabalar soni", "Qilinmagan davomatlar", "Darsga kelmaganlar", "Darsga kelganlar"], [])}</div>
  <div class="emptystate" style="border:none;margin-top:0">
   <svg width="150" height="110" viewBox="0 0 150 110" style="margin-bottom:6px"><rect x="20" y="55" width="14" height="40" rx="3" fill="var(--navy-2)"/><rect x="45" y="35" width="14" height="60" rx="3" fill="var(--gold)"/><rect x="70" y="60" width="14" height="35" rx="3" fill="var(--navy-2)"/><circle cx="110" cy="50" r="14" fill="var(--ink-soft)" opacity=".3"/><circle cx="120" cy="80" r="10" fill="var(--ink-soft)" opacity=".2"/></svg>
   <div style="font-weight:600;color:var(--ink)">Hech qanday ma'lumot yo'q</div>
  </div>
  <div class="row" style="margin-top:6px">
   <span style="font-size:12.5px;color:var(--ink-soft)">Sahifadagilar:</span>
   <select class="dash-select" style="min-width:70px"><option>10</option></select>
   <div class="spacer"></div>
   <span class="dots">‹</span><span class="dots">›</span>
  </div>
 </div>
 <div id="studPanelOzl" class="panel" style="display:none">
  <h2 style="margin:0 0 4px;font-size:19px">O'quvchi o'zlashtirish darajasi jadvali</h2>
  <div class="note" style="margin:0 0 14px">O'quvchilarning o'zlashtirish darajasi</div>
  <div class="row">
   <div class="filterbox"><span>Yil</span><select><option>2026</option></select></div>
   <div class="filterbox"><span>Oy</span><select><option>Sentyabr</option></select></div>
   <div class="filterbox"><input type="text" placeholder="yyyy-MM-dd ~ yyyy-MM-dd"></div>
  </div>
  <div class="row">
   <select class="dash-select"><option>Guruhlar</option></select>
   <select class="dash-select"><option>Barcha o'qituvchilar</option></select>
   <div class="filterbox"><span>Kurslar</span><select><option>Barcha kurslar</option></select></div>
  </div>
  <div class="table-card">${tbl(["№", "O'QUVCHI FIO", "O'QUVCHINING GURUHLARI", "O'QITUVCHILARI", "KURSLARI", "BAHOLARI", "UMUMIY O'RTACHA"], [])}</div>
  <div style="text-align:center;color:var(--ink);font-size:13px;font-weight:600;padding:22px 0;border:1px solid var(--line);border-top:none">No rows</div>
  <div class="row" style="margin-top:10px">
   <span style="font-size:12.5px;color:var(--ink-soft)">Har sahifada:</span>
   <select class="dash-select" style="min-width:70px"><option>10</option></select>
   <span style="font-size:12.5px;color:var(--ink-soft)">qator</span>
   <div class="spacer"></div>
   <button class="btn-outline2" disabled style="opacity:.5;cursor:not-allowed">‹ OLDINGI</button>
   <button class="btn-outline2" disabled style="opacity:.5;cursor:not-allowed">KEYINGI ›</button>
  </div>
 </div>
 </div>`;
    }

    function centerStatsHTML() {
      const card = (
        bg,
        ic,
        value,
        label,
      ) => `<div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:14px">
  <span style="width:32px;height:32px;border-radius:8px;background:${bg};display:inline-flex;align-items:center;justify-content:center;font-size:14px">${ic}</span>
  <div style="font-size:20px;font-weight:700;font-family:'Sora',sans-serif;margin-top:12px">${value}</div>
  <div style="font-size:12px;color:var(--ink-soft);margin-top:2px">${label}</div>
  <div style="font-size:12px;color:#5A55E0;font-weight:600;margin-top:8px;cursor:pointer">To'liqroq ma'lumot</div>
 </div>`;
      const blurCard = (
        bg,
        ic,
      ) => `<div style="background:var(--bg);border-radius:var(--radius);padding:14px;position:relative;overflow:hidden">
  <div style="filter:blur(2.5px);opacity:.6">
   <span style="width:32px;height:32px;border-radius:8px;background:${bg};display:inline-flex;align-items:center;justify-content:center;font-size:14px">${ic}</span>
   <div style="font-size:20px;font-weight:700;font-family:'Sora',sans-serif;margin-top:12px">0%</div>
   <div style="font-size:12px;color:var(--ink-soft);margin-top:2px">Ma'lumot</div>
   <div style="font-size:12px;color:#5A55E0;font-weight:600;margin-top:8px">To'liqroq ma'lumot</div>
  </div>
  <div class="nodata-pill" style="background:#5A55E0;white-space:normal;text-align:center;width:90px">Malumot yetarli emas</div>
 </div>`;
      return `<div class="panel">
 <div class="row" style="margin-bottom:0">
  <h2 style="margin:0;font-size:20px">Markaz Faoliyati Statistikasi</h2>
  <div class="spacer"></div>
  <button class="btn-solid">⚙ XONA SIG'IMLARINI YANGILASH</button>
 </div>
 <div style="background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);padding:16px;margin-top:16px;display:flex;gap:16px;align-items:flex-end;flex-wrap:wrap">
  <div class="filterbox"><span>Filial tanlash</span><select><option>Tasnim Filiali</option></select></div>
  <div class="filterbox"><span>Yil tanlash</span><select><option>2026</option></select></div>
  <div class="filterbox"><span>Oy tanlash</span><select><option>Sentabr</option></select></div>
  <div style="display:flex;border:1px solid var(--line);border-radius:8px;overflow:hidden">
   <span style="padding:9px 14px;font-size:12px;font-weight:700;background:var(--bg);color:var(--ink)">OYLIK</span>
   <span style="padding:9px 14px;font-size:12px;font-weight:700;color:var(--ink-soft);border-left:1px solid var(--line)">HAFTALIK</span>
   <span style="padding:9px 14px;font-size:12px;font-weight:700;color:var(--ink-soft);border-left:1px solid var(--line)">KUNLIK</span>
  </div>
  <div class="spacer"></div>
  <div style="border:1px solid var(--line);border-radius:8px;padding:8px 14px;display:flex;align-items:center;gap:8px">
   <span>📅</span><div><div style="font-weight:700;font-size:13px">Sentabr 2026</div><div style="font-size:11px;color:var(--ink-soft)">2026-09-01 – 2026-09-30</div></div>
  </div>
 </div>
 <div class="grid" style="grid-template-columns:repeat(6,1fr);margin-top:16px">
  ${blurCard("#DCEEF5", "📊")}
  ${blurCard("#FDECC8", "🏫")}
  ${card("#DBF3E4", "👥", "1", "Amaldagi o'quvchilar")}
  ${card("#FBDCD6", "$", "400 000 UZS", "Potensial qo'shimcha daromad")}
  ${card("#E3E1FB", "🪑", "14", "Bo'sh o'rinlar")}
  ${card("#E3E1FB", "🪑", "50", "Yana o'qishi mumkin bo'lgan o'quvchilar soni")}
 </div>
 <div class="table-card">
  <div class="tblwrap"><table>
   <thead><tr><th>XONALAR ↕</th><th>SIG'IM ↕</th><th>ISH VAQTI ↕</th><th>GURUHLAR ↕</th><th>O'QUVCHILAR SONI ↕</th><th>BO'SH O'RINLAR</th><th>DARS SOATLARI</th><th>KURS NARXI</th><th>JAMI SUMMA</th><th>BO'SH VAQT</th><th>O'RINSOAT</th><th>AMALDAGI O'RINSOAT</th><th>REJA O'RINSOAT</th><th>FIK (%)</th></tr></thead>
   <tbody>
    <tr><td>1-xona</td><td>15</td><td>0.00</td><td><i style="color:var(--ink-soft)">Guruh biriktirilmagan</i></td><td style="background:#FBF3D9;color:var(--warn);font-weight:700">0</td><td>15</td><td>0.00</td><td>0 UZS</td><td>0 UZS</td><td>0.00</td><td>0</td><td>0</td><td>0.00</td><td style="color:var(--danger)">0%</td></tr>
    <tr><td>2-xona</td><td>15</td><td>0.00</td><td style="font-weight:600">web1</td><td style="background:#FBF3D9;color:var(--warn);font-weight:700">1</td><td>14</td><td>18.00</td><td>400 000 UZS</td><td>400 000 UZS</td><td>0.00</td><td>18</td><td>18</td><td>0.00</td><td style="color:var(--danger)">0%</td></tr>
    <tr><td>3-xona</td><td>15</td><td>0.00</td><td><i style="color:var(--ink-soft)">Guruh biriktirilmagan</i></td><td style="background:#FBF3D9;color:var(--warn);font-weight:700">0</td><td>15</td><td>0.00</td><td>0 UZS</td><td>0 UZS</td><td>0.00</td><td>0</td><td>0</td><td>0.00</td><td style="color:var(--danger)">0%</td></tr>
    <tr><td>4-xona</td><td>15</td><td>0.00</td><td><i style="color:var(--ink-soft)">Guruh biriktirilmagan</i></td><td style="background:#FBF3D9;color:var(--warn);font-weight:700">0</td><td>15</td><td>0.00</td><td>0 UZS</td><td>0 UZS</td><td>0.00</td><td>0</td><td>0</td><td>0.00</td><td style="color:var(--danger)">0%</td></tr>
    <tr style="background:var(--bg)"><td>5-xona</td><td>15</td><td>0.00</td><td><i style="color:var(--ink-soft)">Guruh biriktirilmagan</i></td><td style="background:#FBF3D9;color:var(--warn);font-weight:700">0</td><td>15</td><td>0.00</td><td>0 UZS</td><td>0 UZS</td><td>0.00</td><td>0</td><td>0</td><td>0.00</td><td style="color:var(--danger)">0%</td></tr>
    <tr style="background:#FBF3D9;font-weight:700"><td>Jami</td><td>75</td><td>0.00</td><td>1</td><td>1</td><td>14</td><td>18.00</td><td>400 000 UZS</td><td>400 000 UZS</td><td>0.00</td><td>18</td><td>18</td><td>0.00</td><td>${MARKAZ_FOYDALILIK.toFixed(2)}%</td></tr>
   </tbody>
  </table></div>
 </div>
 </div>`;
    }

    function reportsHTML() {
      if (window.reportsSub === "To'lovlar hisoboti")
        return paymentsReportHTML();
      if (window.reportsSub === "O'quvchilar to'lovi")
        return studentsPaymentHTML();
      if (window.reportsSub === "Ketgan o'quvchilar hisoboti")
        return churnReportHTML();
      if (window.reportsSub === "Bitiruvchilar hisoboti")
        return graduatesReportHTML();
      if (window.reportsSub === "Xodimlar Davomati Hisoboti")
        return attendanceReportHTML();
      if (window.reportsSub === "Coinlar") return coinsReportHTML();
      if (window.reportsSub === "O'quvchilar Hisoboti")
        return studentsReportHTML();
      if (window.reportsSub === "Markaz Faoliyati Statistikasi")
        return centerStatsHTML();
      const cards = [
        [
          "Moliyaviy hisobotlar",
          "Tushum, chiqim, foyda va qarzdorlik — kunlik/oylik/yillik kesimda, naqd va plastik pul harakati bilan.",
        ],
        [
          "O'quvchilar hisoboti",
          "Qabul qilinganlar, ketib qolganlar, sinov darsidagilar, o'zlashtirish va davomat ko'rsatkichlari.",
        ],
        [
          "Lidlar hisoboti",
          "Menejerlar samaradorligi, manbalar kesimida lidlar oqimi va guruhga aylanish foizi.",
        ],
        [
          "O'qituvchilar hisoboti",
          "Dars soatlari, oyliklar va foiz ulushlari bo'yicha hisob-kitob.",
        ],
      ];
      return `<div class="panel"><h2>Hisobotlar</h2><div class="grid" style="grid-template-columns:repeat(auto-fit,minmax(240px,1fr))">
 ${cards.map(([t, d]) => `<div class="settings-card"><h3>${t}</h3><p>${d}</p><button class="primary">Ko'rish</button></div>`).join("")}</div></div>`;
    }

    function openActionMenu(e, items) {
      e.stopPropagation();
      let m = document.getElementById("actionMenu");
      if (!m) {
        m = document.createElement("div");
        m.id = "actionMenu";
        m.className = "action-menu";
        document.body.appendChild(m);
      }
      if (m.classList.contains("show") && m._trigger === e.currentTarget) {
        m.classList.remove("show");
        return;
      }
      m.replaceChildren();
      items.forEach((item) => {
        const menuItem = document.createElement("div");
        menuItem.className = "ai";
        menuItem.setAttribute("role", "menuitem");
        menuItem.tabIndex = 0;
        menuItem.textContent = `${item.icon} ${item.label}`;
        menuItem.addEventListener("click", (event) => {
          event.stopPropagation();
          m.classList.remove("show");
          item.action?.();
        });
        menuItem.addEventListener("keydown", (event) => {
          if (event.key !== "Enter" && event.key !== " ") return;
          event.preventDefault();
          menuItem.click();
        });
        m.appendChild(menuItem);
      });
      const r = e.currentTarget.getBoundingClientRect();
      m._trigger = e.currentTarget;
      m.style.visibility = "hidden";
      m.classList.add("show");
      const mw = m.offsetWidth;
      const mh = m.offsetHeight;
      let left = r.right - mw;
      if (left < 8) left = 8;
      if (left + mw > window.innerWidth - 8) left = window.innerWidth - mw - 8;
      const top = r.bottom + mh + 4 <= window.innerHeight - 8
        ? r.bottom + 4
        : Math.max(8, r.top - mh - 4);
      m.style.top = `${top}px`;
      m.style.left = left + "px";
      m.style.visibility = "";
    }
    const editableFields = {
      teachers: [
        { key: "name", label: "Ism familiya" }, { key: "phone", label: "Telefon", type: "tel" },
        { key: "salary", label: "Doimiy oylik" }, { key: "share", label: "Foiz ulushi" },
        { key: "role", label: "Kasbi" }, { key: "birthday", label: "Tug'ilgan sana", type: "date" },
        { key: "hiredAt", label: "Ishga olingan sana", type: "date" },
      ],
      employees: [
        { key: "name", label: "Ism familiya" }, { key: "phone", label: "Telefon", type: "tel" },
        { key: "salary", label: "Doimiy oylik" }, { key: "share", label: "Foiz ulushi" },
        { key: "role", label: "Kasbi" }, { key: "birthday", label: "Tug'ilgan sana", type: "date" },
        { key: "hiredAt", label: "Ishga olingan sana", type: "date" },
      ],
      students: [
        { key: "name", label: "Ism familiya" }, { key: "phone", label: "Telefon", type: "tel" },
        { key: "password", label: "Parol", type: "password" },
        { key: "birthday", label: "Tug'ilgan sana", type: "date" }, { key: "parentName", label: "Ota-ona ismi" },
        { key: "parentPhone", label: "Ota-ona telefoni", type: "tel" }, { key: "groups", label: "Guruhlar" },
        { key: "school", label: "Maktab" }, { key: "balance", label: "Balans" },
      ],
      groups: [
        { key: "name", label: "Guruh nomi" }, { key: "course", label: "Kurs" },
        { key: "teacher", label: "O'qituvchi" }, { key: "room", label: "Xona" },
        { key: "days", label: "Dars kunlari" }, { key: "startDate", label: "Boshlanish sanasi", type: "date" },
        { key: "endDate", label: "Tugash sanasi", type: "date" }, { key: "startTime", label: "Boshlanish vaqti", type: "time" },
        { key: "endTime", label: "Tugash vaqti", type: "time" },
      ],
      exams: [
        { key: "name", label: "Imtihon nomi" }, { key: "group", label: "Guruh" },
        { key: "date", label: "Sana", type: "date" }, { key: "time", label: "Vaqt oralig'i" },
        { key: "passScore", label: "O'tish balli", type: "select", options: SCORE_LEVELS.map((score) => ({ value: score, label: `${score} ball` })) },
        { key: "maxScore", label: "Maksimal ball", type: "select", options: SCORE_LEVELS.map((score) => ({ value: score, label: `${score} ball` })) },
      ],
      courses: [
        { key: "name", label: "Kurs nomi" }, { key: "price", label: "Narxi" },
        { key: "duration", label: "Davomiyligi (oy)" }, { key: "note", label: "Izoh", type: "textarea" },
      ],
      rooms: [
        { key: "name", label: "Xona nomi" }, { key: "capacity", label: "Sig'imi", type: "number" },
        { key: "branch", label: "Filial" },
      ],
      schools: [{ key: "name", label: "Maktab nomi" }],
      holidays: [
        { key: "date", label: "Sana", type: "date" }, { key: "reason", label: "Sabab", type: "textarea" },
      ],
    };
    function escapeRecordHtml(value) {
      return String(value ?? "").replace(/[&<>"']/g, (character) => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;",
      })[character]);
    }
    function openRecordDialog(title, fields, values, onSave) {
      document.querySelector(".record-editor-overlay")?.remove();
      const overlay = document.createElement("div");
      overlay.className = "record-editor-overlay";
      overlay.innerHTML = `<section class="record-editor" role="dialog" aria-modal="true" aria-label="${escapeRecordHtml(title)}">
        <header><h2>${escapeRecordHtml(title)}</h2><button type="button" class="record-editor-close" aria-label="Yopish">×</button></header>
        <form><div class="record-editor-fields">${fields.map((field) => {
          const value = escapeRecordHtml(values[field.key]);
          if (field.type === "textarea") return `<label>${escapeRecordHtml(field.label)}<textarea name="${field.key}">${value}</textarea></label>`;
          if (field.type === "select") return `<label>${escapeRecordHtml(field.label)}<select name="${field.key}">${field.options.map((option) => `<option value="${escapeRecordHtml(option.value)}"${String(values[field.key]) === String(option.value) ? " selected" : ""}>${escapeRecordHtml(option.label)}</option>`).join("")}</select></label>`;
          return `<label>${escapeRecordHtml(field.label)}<input name="${field.key}" type="${field.type || "text"}" value="${value}"${field.type === "number" ? ' step="any"' : ""} /></label>`;
        }).join("")}</div><footer><button type="button" class="btn-outline2 record-editor-cancel">BEKOR QILISH</button><button type="submit" class="btn-solid">SAQLASH</button></footer></form>
      </section>`;
      document.body.appendChild(overlay);
      const close = () => overlay.remove();
      overlay.addEventListener("click", (event) => { if (event.target === overlay) close(); });
      overlay.querySelector(".record-editor-close").addEventListener("click", close);
      overlay.querySelector(".record-editor-cancel").addEventListener("click", close);
      overlay.querySelector("form").addEventListener("submit", (event) => {
        event.preventDefault();
        const updates = Object.fromEntries(new FormData(event.currentTarget).entries());
        fields.forEach((field) => {
          if (field.type === "number") updates[field.key] = updates[field.key] === "" ? "" : Number(updates[field.key]);
        });
        onSave(updates);
        close();
      });
    }
    function openRecordEditor(kind, id) {
      const fields = editableFields[kind];
      const data = getTableData();
      const record = data[kind]?.find((item) => String(item.id) === String(id));
      if (!record || !fields) return;
      openRecordDialog("Yozuvni tahrirlash", fields, record, (updates) => {
        Object.assign(record, updates);
        if (kind === "students") {
          record.phone = formatUzbekPhoneValue(record.phone) || record.phone;
          record.parentPhone = formatUzbekPhoneValue(record.parentPhone);
        }
        saveTableData(data);
        refreshCurrentView();
      });
    }
    function deleteRecord(kind, id) {
      const data = getTableData();
      const record = data[kind]?.find((item) => String(item.id) === String(id));
      if (!record || !window.confirm(`"${record.name || record.reason || "Yozuv"}" o'chirilsinmi?`)) return;
      data[kind] = data[kind].filter((item) => String(item.id) !== String(id));
      if (kind === "groups") {
        data.students.forEach((student) => {
          student.groupIds = (student.groupIds || []).filter((groupId) => String(groupId) !== String(id));
          student.groups = (student.groups || "").split(", ").filter((name) => name !== record.name).join(", ");
        });
      }
      if (kind === "schools") {
        data.students.forEach((student) => {
          if (String(student.schoolId) === String(id)) {
            student.schoolId = "";
            student.school = "";
          }
        });
      }
      saveTableData(data);
      refreshCurrentView();
    }
    function recordActionButton(kind, id) {
      const encodedId = JSON.stringify(id).replace(/"/g, "&quot;");
      return `<span class="dots" role="button" tabindex="0" aria-label="Amallar" onclick="openRecordActions(event,'${kind}',${encodedId})" onkeydown="if(event.key==='Enter'){openRecordActions(event,'${kind}',${encodedId})}">⋮</span>`;
    }
    function openRecordActions(event, kind, id) {
      const actions = [];
      if (kind === "students") actions.push({ icon: "🏅", label: "Ball kiritish", action: () => openStudentScoreEditor(id) });
      actions.push(
        { icon: "✏️", label: "Tahrirlash", action: () => openRecordEditor(kind, id) },
        { icon: "🗑️", label: "O'chirish", action: () => deleteRecord(kind, id) },
      );
      openActionMenu(event, actions);
    }
    function studentScoreSummary(student) {
      const scores = (student.assessments || []).map((item) => Number(item.score)).filter((score) => Number.isFinite(score) && score >= 0 && score <= 100);
      if (!scores.length) return student.grade || "-";
      const average = Math.round(scores.reduce((sum, score) => sum + score, 0) / scores.length);
      const level = SCORE_LEVELS.filter((threshold) => threshold <= average).at(-1) ?? 0;
      return `${average} ball · ${level} daraja`;
    }
    function openStudentScoreEditor(id) {
      const data = getTableData();
      const student = data.students.find((item) => String(item.id) === String(id));
      if (!student) return;
      openRecordDialog("O'quvchi bahosini kiritish", [
        { key: "title", label: "Baholash nomi" },
        { key: "score", label: "Ball", type: "select", options: SCORE_LEVELS.map((score) => ({ value: score, label: `${score} ball` })) },
        { key: "date", label: "Sana", type: "date" },
      ], { title: "Imtihon", score: 0, date: formatLocalDate(new Date()) }, (values) => {
        student.assessments = Array.isArray(student.assessments) ? student.assessments : [];
        student.assessments.unshift({ id: Date.now(), title: values.title || "Imtihon", score: Number(values.score), maxScore: 100, date: values.date || formatLocalDate(new Date()) });
        student.grade = studentScoreSummary(student);
        saveTableData(data);
        refreshCurrentView();
      });
    }
    document.addEventListener("pointerdown", (event) => {
      const m = document.getElementById("actionMenu");
      if (!m?.classList.contains("show")) return;
      if (m.contains(event.target) || event.target.closest?.('.dots[aria-label="Amallar"]')) return;
      m.classList.remove("show");
    }, true);

    function toggleStudentSection(sectionName, trigger) {
      const section = document.getElementById(`student${sectionName[0].toUpperCase()}${sectionName.slice(1)}Section`);
      const isOpen = section.style.display !== "none";
      section.style.display = isOpen ? "none" : "flex";
      trigger.setAttribute("aria-expanded", String(!isOpen));
      trigger.lastElementChild.textContent = isOpen ? "+" : "−";
    }

    function populateStudentExtras() {
      const data = getTableData();
      const groupOptions = document.getElementById("studentGroupOptions");
      groupOptions.replaceChildren();
      if (!data.groups.length) {
        const emptyMessage = document.createElement("div");
        emptyMessage.className = "note";
        emptyMessage.textContent = "Guruhlar mavjud emas";
        groupOptions.appendChild(emptyMessage);
      } else {
        data.groups.forEach((group) => {
          const label = document.createElement("label");
          label.className = "student-group-option";
          const checkbox = document.createElement("input");
          checkbox.type = "checkbox";
          checkbox.value = String(group.id);
          checkbox.dataset.name = group.name;
          const name = document.createElement("span");
          name.textContent = group.name;
          label.append(checkbox, name);
          groupOptions.appendChild(label);
        });
      }

      const schoolSelect = document.getElementById("drStudentSchool");
      schoolSelect.replaceChildren(new Option("Maktabni tanlang", ""));
      data.schools.forEach((school) => {
        schoolSelect.add(new Option(school.name, String(school.id)));
      });
    }

    function addStudentSchool() {
      const input = document.getElementById("drStudentNewSchool");
      const name = safeText(input.value);
      if (!name) {
        input.focus();
        return;
      }
      const data = getTableData();
      let school = data.schools.find((item) => item.name.toLowerCase() === name.toLowerCase());
      if (!school) {
        school = { id: Date.now(), name, students: 0 };
        data.schools.unshift(school);
        saveTableData(data);
      }
      const schoolSelect = document.getElementById("drStudentSchool");
      if (!Array.from(schoolSelect.options).some((option) => option.value === String(school.id))) {
        schoolSelect.add(new Option(school.name, String(school.id)));
      }
      schoolSelect.value = String(school.id);
      input.value = "";
    }

    function openDrawer(mode, data) {
      window.__drawerMode = mode;
      data = data || {};
      const isHoliday = mode === "holiday";
      const isRoom = mode === "room";
      const isSchool = mode === "school";
      const isEmployee = mode === "employee";
      const isStudent = mode === "student";
      const isGroup = mode === "group";
      const isOquvchi = mode === "oquvchi";
      const isImtihon = mode === "imtihon";
      document.getElementById("drawerFieldsCourse").style.display =
        !isHoliday &&
        !isRoom &&
        !isSchool &&
        !isEmployee &&
        !isStudent &&
        !isGroup &&
        !isOquvchi &&
        !isImtihon
          ? "flex"
          : "none";
      document.getElementById("drawerFieldsHoliday").style.display = isHoliday
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsSchool").style.display = isSchool
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsRoom").style.display = isRoom
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsEmployee").style.display = isEmployee
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsStudent").style.display = isStudent
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsGroup").style.display = isGroup
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsOquvchi").style.display = isOquvchi
        ? "flex"
        : "none";
      document.getElementById("drawerFieldsImtihon").style.display = isImtihon
        ? "flex"
        : "none";
      document.getElementById("drawerSub").style.display =
        isHoliday ||
        isRoom ||
        isSchool ||
        isEmployee ||
        isStudent ||
        isGroup ||
        isOquvchi ||
        isImtihon
          ? "none"
          : "block";
      document.getElementById("drawerMem").style.display =
        isHoliday ||
        isRoom ||
        isSchool ||
        isEmployee ||
        isStudent ||
        isGroup ||
        isOquvchi ||
        isImtihon
          ? "none"
          : "block";
      document.getElementById("drawer").classList.toggle("room-mode", isRoom);
      if (isRoom) {
        document.getElementById("drawerTitle").textContent = "Yangi xona qo'shish";
        document.getElementById("drXonaNomi").value = "";
        document.getElementById("drXonaSigim").value = "";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isImtihon) {
        document.getElementById("drawerTitle").textContent = "Imtihon qo'shish";
        document.getElementById("drImtihonDate").value = formatLocalDate(new Date());
        document.getElementById("drImtihonStartTime").value = "09:00";
        document.getElementById("drImtihonEndTime").value = "10:00";
        document.getElementById("drImtihonPassScore").value = "0";
        document.getElementById("drImtihonMaxScore").value = "100";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isOquvchi) {
        document.getElementById("drawerTitle").textContent =
          "O'quvchi qo'shish";
        document.getElementById("drStudentName").value = "";
        document.getElementById("drStudentPhone").value = "";
        document.getElementById("drStudentParentName").value = "";
        document.getElementById("drStudentParentPhone").value = "";
        document.getElementById("drStudentNewSchool").value = "";
        ["groups", "parent", "school"].forEach((sectionName) => {
          const section = document.getElementById(`student${sectionName[0].toUpperCase()}${sectionName.slice(1)}Section`);
          section.style.display = "none";
        });
        document.querySelectorAll(".student-extra-toggle").forEach((toggle) => {
          toggle.setAttribute("aria-expanded", "false");
          toggle.lastElementChild.textContent = "+";
        });
        populateStudentExtras();
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isGroup) {
        document.getElementById("drawerTitle").textContent = "Guruh qo'shish";
        document.getElementById("drGuruhNomi").value = "";
        const today = new Date();
        document.getElementById("drGuruhDate").value = [
          today.getFullYear(),
          String(today.getMonth() + 1).padStart(2, "0"),
          String(today.getDate()).padStart(2, "0"),
        ].join("-");
        document.getElementById("drGuruhStartTime").value = "08:00";
        document.getElementById("drGuruhEndTime").value = "09:30";
        const roomSelect = document.getElementById("drGuruhRoom");
        roomSelect.replaceChildren(new Option("Xona", "", true, true));
        sortRooms(getTableData().rooms).forEach((room) => {
          roomSelect.add(new Option(room.name, room.name));
        });
        const wrap = document.getElementById("oqituvchilarWrap");
        while (wrap.children.length > 1) wrap.removeChild(wrap.lastChild);
        document.getElementById("addOqituvchiBtn").style.display = "";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isStudent) {
        document.getElementById("drawerTitle").textContent =
          "O'qituvchi qo'shish";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isEmployee) {
        document.getElementById("drawerTitle").textContent = "Xodim qo'shish";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isSchool) {
        document.getElementById("drawerTitle").textContent =
          "Yangi maktab qo'shish";
        document.getElementById("drMaktab").value = "";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else if (isHoliday) {
        document.getElementById("drawerTitle").textContent =
          "Dam olish kuni qo'shish";
        document.getElementById("drSana").value = formatLocalDate(new Date());
        document.getElementById("drSabab").value = "";
        document.getElementById("drawerBtn").textContent = "SAQLASH";
      } else {
        document.getElementById("drawerTitle").textContent =
          mode === "edit" ? "Kurs tahrirlash" : "Kurs qo'shish";
        document.getElementById("drNomi").value = data.nomi || "";
        document.getElementById("drNarx").value = data.narx || "";
        document.getElementById("drDavr").value = data.davr || "";
        document.getElementById("drIzoh").value = data.izoh || "";
        document.getElementById("drNarxCheckRow").style.display =
          mode === "edit" ? "flex" : "none";
        document.getElementById("drawerBtn").textContent =
          mode === "edit" ? "SAQLASH" : "DAVOM ETISH";
      }
      document.getElementById("drawerOverlay").classList.add("show");
      document.getElementById("drawer").classList.add("show");
    }
    function addOqituvchiRow() {
      const wrap = document.getElementById("oqituvchilarWrap");
      if (wrap.children.length >= 3) return;
      wrap.appendChild(wrap.children[0].cloneNode(true));
      if (wrap.children.length >= 3)
        document.getElementById("addOqituvchiBtn").style.display = "none";
    }
    function closeDrawer() {
      window.__drawerMode = null;
      document.getElementById("drawerOverlay").classList.remove("show");
      document.getElementById("drawer").classList.remove("show");
    }

    function coursesHTML() {
      const data = getTableData();
      const rows = (data.courses || []).map((course) => [
        course.name,
        course.note || "",
        `${course.price || "0"} so'm`,
        course.branch || "Tasnim Filliali",
        `${course.duration || "1"} oy`,
        "Sozlanmagan",
        recordActionButton("courses", course.id),
      ]);
      return `<div class="panel">
 <div class="row" style="justify-content:flex-end;margin-bottom:14px">
  <button class="btn-outline2">▶ Kurslar sahifasidan qanday foydalaniladi?</button>
 </div>
 <div class="row" style="margin-bottom:14px">
  <h2 style="margin:0">Kurslar</h2><div class="spacer"></div>
  <button class="btn-solid" onclick="openDrawer('add')">+ YANGI KURS QO'SHISH</button>
 </div>
 <div class="table-card">${tbl(["Kurslar", "Izoh", "Kurs narxi", "Filial", "Kurs davomiyligi (oy)", "Baholash tizimi", "Harakatlar"], rows.length ? rows : [["Hech narsa yo'q", "", "", "", "", "", ""]])}</div>
 </div>`;
    }

    function roomsHTML() {
      const rooms = sortRooms(getTableData().rooms);
      const rows = rooms.map((room, i) => [
        String(i + 1) + ".",
        room.name,
        room.branch || "Tasnim Filliali",
        room.capacity || "15",
        recordActionButton("rooms", room.id),
      ]);
      return `<div class="panel">
 <div class="row" style="margin-bottom:14px">
  <h2 style="margin:0">Xonalar</h2><div class="spacer"></div>
  <button class="btn-solid" onclick="openDrawer('room')">+ YANGI XONA QO'SHISH</button>
 </div>
 <div class="table-card">${tbl(["ID", "Nomi", "Filial", "Xona hajmi", "Harakatlar"], rows)}</div>
 </div>`;
    }

    function holidaysHTML() {
      const data = getTableData();
      const rows = (data.holidays || []).map((holiday, i) => [
        String(i + 1) + ".",
        holiday.date || "-",
        holiday.reason || "Dam olish kuni",
        recordActionButton("holidays", holiday.id),
      ]);
      return `<div class="panel">
 <div class="row" style="justify-content:flex-end;margin-bottom:14px">
  <button class="btn-outline2">▶ Dam olish kunlari sahifasidan qanday foydalaniladi?</button>
 </div>
 <div class="row" style="margin-bottom:14px">
  <h2 style="margin:0">Dam olish kunlari</h2><div class="spacer"></div>
  <button class="btn-solid" onclick="openDrawer('holiday')">+ YANGI QO'SHISH</button>
 </div>
 <div class="table-card">${tbl(["ID", "Sana", "Sabab", "Harakatlar"], rows.length ? rows : [["-", "Hech narsa yo'q", "", ""]])}</div>
 </div>`;
    }

    function schoolsHTML() {
      const data = getTableData();
      const rows = (data.schools || []).map((school, i) => [
        String(i + 1) + ".",
        school.name || "Maktab",
        school.students || 0,
        recordActionButton("schools", school.id),
      ]);
      return `<div class="panel">
 <div class="row" style="justify-content:flex-end;margin-bottom:14px">
  <button class="btn-outline2">▶ Xonalar sahifasidan qanday foydalaniladi?</button>
 </div>
 <div class="row" style="margin-bottom:14px">
  <h2 style="margin:0">Maktablar</h2><div class="spacer"></div>
  <button class="btn-solid" onclick="openDrawer('school')">+ YANGI MAKTAB QO'SHISH</button>
 </div>
 <div class="table-card">${tbl(["ID", "Nomi", "O'quvchilar soni", "Harakatlar"], rows.length ? rows : [["-", "Hech narsa yo'q", "", ""]])}</div>
 </div>`;
    }

    function coinSettingsHTML() {
      const rows = [
        ["📅", "Davomat", "+5"],
        ["📖", "Uy vazifasi", "+10"],
        ["📋", "Test natijasi", "+20"],
        ["🎂", "Tug'ilgan kun", "+50"],
      ];
      return `<div class="panel">
 <h2 style="margin:0">Coin sozlamalari</h2>
 <p style="color:var(--ink-soft);font-size:13px;margin:4px 0 16px">Butun o'quv markazi uchun coin tizimini sozlash</p>
 <div class="settings-card" style="display:flex;align-items:center;justify-content:space-between;gap:12px">
  <div><h3 style="margin:0 0 4px">Avtomatik coin tizimi</h3><p style="margin:0">O'chirilganda avtomatik coinlar berilmaydi. Qo'lda berish ishlashda davom etadi.</p></div>
  <span class="toggle" onclick="this.classList.toggle('on')"><i></i></span>
 </div>
 <div class="settings-card">
  <h3 style="margin:0 0 4px">Avtomatik coin qoidalari</h3>
  <p style="margin:0 0 14px">O'quvchilarga qachon avtomatik tarzda coin berilishini sozlang.</p>
  <div class="table-card">${tbl(
    ["Hodisa", "Coin miqdori", "Holat", "Amallar"],
    rows.map(([ic, name, amt]) => [
      `${ic} ${name}`,
      `<span style="color:#1DB854;font-weight:600">🪙 ${amt}</span>`,
      '<span class="pill-green">Faol</span>',
      '<span class="dots">✏️</span>',
    ]),
  )}</div>
 </div>
 <div class="settings-card">
  <div class="row" style="margin-bottom:4px">
   <h3 style="margin:0">Qo'lda beriladigan coin sabablari</h3><div class="spacer"></div>
   <button class="btn-solid">+ SABAB QO'SHISH</button>
  </div>
  <p style="margin:0 0 14px">O'qituvchilar faqat oldindan belgilangan sabablar orqali coin bera oladi.</p>
  <div class="table-card">${tbl(
    ["Sabab", "Maksimal coin", "Holat", "Amallar"],
    [
      "Darsga vaqtida keldi",
      "Aktiv qatnashdi",
      "Uyga vazifa qilgan",
      "Yaxshi ozlashtirdi",
      "Oquvchi olib keldi",
    ].map((s) => [
      s,
      '<span style="color:#1DB854;font-weight:600">100 gacha</span>',
      '<span class="pill-green">Faol</span>',
      '<span class="dots">✏️</span> <span class="dots" style="color:#E15C5C">🗑️</span>',
    ]),
  )}</div>
 </div>
 </div>`;
    }

    function baholashCreateHTML() {
      const tpl = window.ceoBaholashTemplate === "cefr";
      return `<div>
 <div style="padding-bottom:16px;margin-bottom:20px;border-bottom:1px solid var(--line)">
  <span style="color:#5A55E0;font-weight:600;font-size:13px;cursor:pointer" onclick="window.ceoBaholashView=null;window.ceoBaholashTemplate=null;show('settings')">← TIZIMLAR RO'YXATIGA QAYTISH</span>
 </div>
 <h1 style="font-size:26px;margin:0 0 8px;font-family:'Sora',sans-serif;color:var(--ink)">Tavsiya etilgan andozalardan baholash tizimini yaratish</h1>
 <p style="color:var(--ink-soft);font-size:13.5px;margin:0 0 20px">Tavsiya etilgan andozani tanlang, xohlasangiz qiymatlarni tahrirlang va baholash tizimini bir bosqichda yarating.</p>
 <div style="display:flex;gap:12px;align-items:flex-start;background:#E4F3F8;border-radius:10px;padding:14px 18px;margin-bottom:20px">
  <span style="color:#2C8FB0;font-size:16px">ⓘ</span>
  <span style="font-size:13px;color:#2C6E82">Tavsiya etilgan baholash andozalari oldindan to'ldirilgan. Saqlashdan oldin ularni xavfsiz tahrir qilishingiz mumkin.</span>
 </div>
 <div class="panel" style="margin-top:0">
  <h2 style="margin:0 0 14px">Tavsiya etilgan andoza</h2>
  <div style="display:flex;gap:12px;flex-wrap:wrap">
   <button class="${tpl ? "btn-outline2" : "btn-solid"}" onclick="window.ceoBaholashTemplate=null;show('settings')">+ YANGI BAHOLASH TIZIMI YARATISH</button>
   <button class="${tpl ? "btn-solid" : "btn-outline2"}" onclick="window.ceoBaholashTemplate='cefr';show('settings')">ANDOZADAN FOYDALANISH</button>
  </div>
  <p class="note" style="margin-top:14px">Agar andoza mos kelmasa, baholash tizimini noldan yarating.</p>
  ${
    tpl
      ? `
  <div class="field-float" style="margin-top:6px">
   <label>Tavsiya etilgan andoza</label>
   <select><option>CEFR baholash tizimi</option></select>
  </div>
  <p class="note" style="margin-top:14px">Andozalar ta'limdagi eng ko'p uchraydigan baholash jarayonlari uchun tayyorlangan.</p>
  <p class="note" style="margin-top:4px">Joylashtirish va diagnostik testlar uchun ko'p darajali CEFR baholash tizimi (maksimal samarali ball: 75).</p>`
      : ""
  }
 </div>
 <div class="panel">
  <h2 style="margin:0 0 16px">Tizim sozlamalari</h2>
  <div class="grid" style="grid-template-columns:1fr 1fr;gap:16px">
   <div>
    <input type="text" placeholder="Tizim nomi" value="${tpl ? "CEFR baholash tizimi" : ""}" style="width:100%">
    <div class="note" style="margin-top:6px">Nomi hozir yoki keyin o'zgartirilishi mumkin.</div>
   </div>
   <div>
    <select style="width:100%">${tpl ? "<option>Standart</option>" : "<option>Tanlang</option>"}</select>
    <div class="note" style="margin-top:6px">Yaxlitlash baholash natijalari qanday ko'rinishini belgilaydi.</div>
   </div>
  </div>
 </div>
 <div class="panel">
  <div class="row" style="justify-content:space-between;align-items:flex-start;margin-bottom:${tpl ? "16" : "4"}px">
   <div>
    <h2 style="margin:0 0 4px">Standart darajalar</h2>
    <p class="note" style="margin:0">Bu darajalarni tahrirlash mumkin va saqlashdan oldin istalgan vaqtda tiklash mumkin.</p>
   </div>
   ${
     tpl
       ? `<div style="text-align:right">
    <span style="color:#5A55E0;font-weight:700;font-size:12px;cursor:pointer;white-space:nowrap">TAVSIYA ETILGAN QIYMATLARGA TIKLASH</span>
    <div class="note" style="margin-top:3px;white-space:nowrap">Tanlangan andozaning boshlang'ich qiymatlarini qaytarish uchun ishlating.</div>
   </div>`
       : ""
   }
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr 2fr 1fr;padding:10px 4px;color:var(--ink-soft);font-size:12px;font-weight:600;border-bottom:1px solid var(--line)">
   <span>BELGI</span><span>MIN</span><span>MAX</span><span>TAVSIF</span><span style="text-align:right">AMALLAR</span>
  </div>
  ${
    tpl
      ? [
          [
            "C1",
            "65",
            "75",
            "Murakkab va akademik matnlarni tushunadi, fikrini erkin va aniq ifodalay oladi.",
          ],
          [
            "B2",
            "51",
            "64",
            "Ko'pchilik mavzularda mustaqil va ishonchli muloqot qila oladi.",
          ],
          [
            "B1",
            "38",
            "50",
            "Tanish vaziyatlarda muloqot qila oladi, asosiy fikrlarni ifodalaydi.",
          ],
          [
            "A2",
            "21",
            "37",
            "Oddiy kundalik gaplarni tushunadi, lekin murakkab muloqotda qiynaladi.",
          ],
          [
            "A1",
            "0",
            "20",
            "Oddiy so'z va iboralarni biladi, lekin to'liq gaplasha olmaydi.",
          ],
        ]
          .map(
            (
              [b, mn, mx, d],
              i,
              arr,
            ) => `<div style="display:grid;grid-template-columns:1fr 1fr 1fr 2fr 1fr;align-items:center;padding:16px 4px;border-bottom:1px solid var(--line);gap:10px">
    <span style="border-bottom:1px solid var(--line);padding-bottom:8px;font-size:13.5px">${b}</span>
    <span style="border-bottom:1px solid var(--line);padding-bottom:8px;font-size:13.5px">${mn}</span>
    <span style="border-bottom:1px solid var(--line);padding-bottom:8px;font-size:13.5px">${mx}</span>
    <div><div style="border-bottom:1px solid var(--line);padding-bottom:8px;font-size:13.5px;color:var(--ink)">${d}</div><div class="note" style="margin-top:6px">O'quvchi natijasini sodda tilda ifodalaydi</div></div>
    <div style="display:flex;gap:10px;justify-content:flex-end;color:var(--ink-soft)"><span style="${i === 0 ? "color:#D8D8E0;cursor:default" : "cursor:pointer"}">↑</span><span style="${i === arr.length - 1 ? "color:#D8D8E0;cursor:default" : "cursor:pointer"}">↓</span><span style="cursor:pointer;color:#D9534F">🗑️</span></div>
   </div>`,
          )
          .join("")
      : `<div style="text-align:center;color:var(--ink-soft);font-size:13px;padding:22px 4px;border-bottom:1px solid var(--line)">Baholash darajalari hali qo'shilmagan. + Daraja qo'shish orqali boshlang.</div>`
  }
  <button class="btn-outline2" style="margin-top:16px">+ DARAJA QO'SHISH</button>
 </div>
 <div class="panel" style="display:flex;justify-content:flex-end;align-items:flex-start;gap:14px;flex-wrap:wrap">
  <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px">
   <div style="display:flex;gap:12px">
    <button class="btn-outline2" onclick="window.ceoBaholashView=null;window.ceoBaholashTemplate=null;show('settings')">BEKOR QILISH</button>
    ${tpl ? '<button class="btn-solid">TIZIM YARATISH</button>' : '<button class="btn-solid" disabled style="background:#D8D8E4;color:#9A9AAE;cursor:not-allowed">TIZIM YARATISH</button>'}
   </div>
   ${tpl ? "" : '<span style="color:#C9822C;font-size:12px;font-weight:600">Tizim nomini kiriting</span>'}
  </div>
 </div>
 </div>`;
    }

    function ceoGeneralHTML() {
      if (window.ceoBaholashView === "create") return baholashCreateHTML();
      return `<div>
 <div class="tabs-plain" style="margin-top:0">
  <div class="tab active">📚 MARKAZ SOZLAMALARI</div>
  <div class="tab">📱 AUTO SMS SOZLAMALARI</div>
 </div>
 <div class="grid settings-overview-grid" style="grid-template-columns:1fr 1fr;gap:18px;margin-top:18px;align-items:start">
  <div style="display:flex;flex-direction:column;gap:16px">
   <div class="settings-card" style="margin-bottom:0">
    <div class="ceo-row">
     <span class="ceo-label">Tashkilot nomi:</span>
     <input type="text" value="Tasnim">
     <span class="icon-circle">✏️</span>
    </div>
    <div class="ceo-row" style="margin-top:16px">
     <span class="ceo-label">Logo:</span>
     <span class="logo-chip">🎓 Tasnim</span>
     <button class="btn-solid">⬆ YANGILASH</button>
    </div>
   </div>
   <div class="settings-card" style="margin-bottom:0">
    <div class="ceo-row top">
     <span class="ceo-label">To'lov usullari:</span>
     <div class="ceo-stack">
      <div class="ceo-input-row"><input type="text" value="Karta orqali"><span class="icon-circle">✏️</span><span class="icon-circle danger">🗑️</span></div>
      <div class="ceo-input-row"><input type="text" value="Naqt"><span class="icon-circle">✏️</span><span class="icon-circle danger">🗑️</span></div>
      <div class="ceo-input-row"><input type="text" value="Click"><span class="icon-circle">✏️</span><span class="icon-circle danger">🗑️</span></div>
      <button class="btn-outline2" style="width:100%">+ YANGI</button>
     </div>
    </div>
   </div>
   <div class="settings-card" style="margin-bottom:0;position:relative">
    <span style="position:absolute;top:18px;right:18px;color:var(--ink-soft);font-size:15px">❓</span>
    <div style="display:flex;flex-wrap:wrap;gap:10px;margin-bottom:24px;padding-right:26px">
     <span class="pill green">Chek chiqariladi</span>
     <span class="pill red">Davomat qilishda izoh yoza olmaydi</span>
     <span class="pill red">O'qituvchiga oylik ko'rinmasligi</span>
     <span class="pill red">Ortiqcha to'lov keyingi oylarga bo'lib yuborilmaydi</span>
     <span class="pill green">Guruhga dam berilganda o'qituvchiga oylik yoziladi</span>
     <span class="pill red">O'qituvchi o'quvchi qo'sha olmaydi</span>
    </div>
    <div style="display:flex;flex-direction:column;gap:18px">
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span><span>O'quvchini ortiqcha to'lovi keyingi oylarga bo'lib yuborilishi</span></label>
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span><span>Admin amallarini CEO tasdig'idan o'tkazish</span></label>
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle on" onclick="this.classList.toggle('on')"><i></i></span><span>To'lov qilgandan so'ng chek chiqishi</span></label>
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle on" onclick="this.classList.toggle('on')"><i></i></span><span>Pul qaytarish funksiyasi</span></label>
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span><span>Davomatga izoh yozish</span></label>
     <label style="display:flex;align-items:center;gap:12px;cursor:pointer"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span><span>Ustozlar va support ustozlar imtihon jadvalini ko'rsin</span></label>
    </div>
   </div>
   <div class="settings-card" style="margin-bottom:0">
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">Faqat dars vaqtida yoqlama qilish mumkin</div>
     <div class="tr-desc">Yoqilsa, o'qituvchi faqat dars boshlanish va tugash oralig'ida yoqlama qila oladi. Admin va CEO uchun cheklov yo'q.</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">O'qituvchiga oylik maoshi ko'rinadi</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg on" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">Guruhga dam berilganida o'qituvchiga oylik maosh yozilishi</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">O'qituvchiga faqat kelgan darslar uchun oylik yozilsin</div>
     <div class="tr-desc">O'quvchi kelmagan dars — yoki umuman yoqlama qilinmagan dars — o'qituvchiga hech narsa keltirmaydi. Yoqlama "Qilinmagan" bo'lib qolsa ham oylik yozilmaydi.</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">O'qituvchi o'quvchi qo'sha oladi</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">Har qanday support ustozga yozilish</div>
     <div class="tr-desc">Yoqilsa, o'quvchi o'z guruhiga biriktirilmagan support ustozlarga ham uchrashuv band qila oladi. Markazdagi barcha support ustozlar bir xil fanni olib borsa yoqing.</div></div>
    </label>
    <label class="toggle-row">
     <span class="toggle lg" onclick="this.classList.toggle('on')"><i></i></span>
     <div><div class="tr-title">Guruhli support uchrashuvlariga ruxsat</div>
     <div class="tr-desc">Yoqilsa, bitta support ustozning bitta vaqt oralig'iga bir nechta o'quvchi yozila oladi. O'chiq bo'lsa — slotda bitta o'quvchi.</div></div>
    </label>
   </div>
  </div>
  <div style="display:flex;flex-direction:column;gap:16px">
   <div class="settings-card" style="margin-bottom:0">
    <div class="ceo-row top">
     <span class="ceo-label">Filiallar:</span>
     <div class="ceo-stack">
      <div class="ceo-input-row"><input type="text" value="Tasnim Filliali"><span class="icon-circle">✏️</span><span class="icon-circle danger">🗑️</span></div>
      <button class="btn-outline2" style="width:100%">+ YANGI</button>
     </div>
    </div>
   </div>
   <div class="settings-card" style="margin-bottom:0">
    <div class="ceo-row">
     <span class="ceo-label">Ish boshlanish vaqti:</span>
     <input type="text" value="08:00:00" style="max-width:180px">
     <span class="icon-circle">✏️</span>
    </div>
    <div class="ceo-row" style="margin-top:14px">
     <span class="ceo-label">Ish tugash vaqti:</span>
     <input type="text" value="20:00:00" style="max-width:180px">
     <span class="icon-circle">✏️</span>
    </div>
   </div>
   <div class="settings-card" style="margin-bottom:0">
    <div class="row" style="justify-content:space-between;margin-bottom:12px">
     <h3 style="margin:0">Vaqt intervali</h3><span style="color:var(--ink-soft)">❓</span>
    </div>
    <label class="radio-row"><input type="radio" name="vaqtint" checked>15 daqiqa</label>
    <label class="radio-row"><input type="radio" name="vaqtint">30 daqiqa</label>
   </div>
  </div>
 </div>
 <div class="panel" style="margin-top:16px">
  <div class="row" style="margin-bottom:0">
   <h2 style="margin:0;font-size:17px">Baholash Tizimlarini Boshqarish</h2>
   <div class="spacer"></div>
   <button class="btn-solid" onclick="window.ceoBaholashView='create';show('settings')">+ TIZIM YARATISH</button>
  </div>
  <div class="tabs-plain" style="margin-top:14px">
   <div class="tab active">TIZIMLAR RO'YXATI</div>
  </div>
  <div class="assessment-scale" aria-label="Standart baholash ballari">
   <span>Standart ball shkalasi</span>
   ${SCORE_LEVELS.map((score) => `<b>${score}</b>`).join("")}
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;padding:14px 4px;color:var(--ink-soft);font-size:12px;font-weight:600;border-bottom:1px solid var(--line);margin-top:2px">
   <span>NOMI</span><span>YAXLITLASH TURI</span><span>DARAJALAR SONI</span><span style="text-align:right">AMALLAR</span>
  </div>
  <div style="text-align:center;padding:44px 20px 34px">
   <div style="font-weight:700;font-size:16px;color:var(--ink);margin-bottom:10px">Baholash tizimlari mavjud emas</div>
   <div style="color:var(--ink-soft);font-size:13px;max-width:480px;margin:0 auto 22px;line-height:1.6">Siz barcha baholash tizimlarini o'chirgansiz. Yangi tizim yaratishingiz yoki tavsiya etilgan andozalardan foydalanishingiz mumkin.</div>
   <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
    <button class="btn-solid" onclick="window.ceoBaholashView='create';show('settings')">+ YANGI TIZIM YARATISH</button>
    <button class="btn-outline2" onclick="openTplModal()">TAVSIYA ETILGAN ANDOZALARNI QO'SHISH</button>
   </div>
  </div>
 </div>
 </div>`;
    }

    function xodimlarHTML() {
      const data = getTableData();
      const rows = (data.employees || []).map((employee, index) => [
        `${index + 1}.`,
        employee.name || "Noma'lum",
        employee.phone || "+998900000000",
        employee.salary || "0 UZS",
        employee.share || "0 %",
        employee.role || "teacher",
        employee.hiredAt || employee.birthday || "-",
        recordActionButton("employees", employee.id),
      ]);
      return `<div class="panel">
 <div class="row" style="justify-content:space-between;align-items:center;margin-bottom:18px">
  <h2 style="margin:0;font-size:20px">Xodimlar</h2>
  <div style="display:flex;gap:10px">
   <div class="inp-ic"><input type="text" placeholder="Xodim qidirish..." style="min-width:210px"><span class="ic">🔍</span></div>
   <button class="btn-solid" onclick="openDrawer('employee')">+ YANGI QO'SHISH</button>
  </div>
 </div>
 <div class="chip-row" style="margin-bottom:16px">
  <span class="chip active">BARCHASI - ${rows.length}</span>
  <span class="chip">ADMIN - 0</span>
  <span class="chip">O'QITUVCHI - ${rows.filter((r) => String(r[5]).toLowerCase().includes('teacher')).length}</span>
  <span class="chip">CEO - ${rows.filter((r) => String(r[5]).toLowerCase().includes('ceo')).length}</span>
  <span class="chip">KASSIR - 0</span>
  <span class="chip">BOSHQA - 0</span>
  <span class="chip">SUPPORT TEACHER - 0</span>
  <span class="chip">WATCHER - 0</span>
 </div>
 <div class="row" style="gap:16px;margin-bottom:0">
  <label style="display:flex;align-items:center;gap:8px;font-size:13px;color:var(--ink-soft);cursor:pointer"><span class="toggle" onclick="this.classList.toggle('on')"><i></i></span>Arxiv</label>
  <button class="btn-excel">📊 EXCEL</button>
  <button class="btn-outline2">XODIMLAR DAVOMATI</button>
 </div>
 <div class="table-card">${tbl(
   [
     "#",
     "Ism familiya",
     "Telefon raqam",
     "Doimiy oylik",
     "Foiz ulush (%)",
     "Kasbi",
     "Ishga olingan sana",
     "",
   ],
   rows,
 )}</div>
 </div>`;
    }

    function amoCrmHTML() {
      return `<div>
 <div class="row" style="justify-content:flex-end;margin-bottom:30px">
  <button class="btn-outline2" style="display:flex;align-items:center;gap:8px">
   <span style="background:#5A55E0;color:#fff;width:20px;height:20px;border-radius:5px;display:inline-flex;align-items:center;justify-content:center;font-size:10px">▶</span>
   Amo crm sahifasidan qanday foydalaniladi?
  </button>
 </div>
 <div style="max-width:600px;margin:0 auto">
  <div style="text-align:center;margin-bottom:34px">
   <span style="font-family:'Sora',sans-serif;font-weight:700;font-size:38px;color:#AFAFAF;font-style:italic">amo</span><span style="font-family:'Sora',sans-serif;font-weight:700;font-size:38px;color:#4FC3E8;font-style:italic">CRM</span><span style="font-family:'Sora',sans-serif;font-weight:700;font-size:38px;color:#4FC3E8">.</span>
  </div>
  <div style="display:flex;flex-direction:column;gap:14px">
   <input type="text" placeholder="Secret Key" style="width:100%;padding:14px;border:1px solid var(--line);border-radius:8px;font-size:13.5px;box-sizing:border-box">
   <input type="text" placeholder="Integration ID" style="width:100%;padding:14px;border:1px solid var(--line);border-radius:8px;font-size:13.5px;box-sizing:border-box">
   <input type="text" placeholder="Authorization Code" style="width:100%;padding:14px;border:1px solid var(--line);border-radius:8px;font-size:13.5px;box-sizing:border-box">
   <input type="text" placeholder="Sub Domain" style="width:100%;padding:14px;border:1px solid var(--line);border-radius:8px;font-size:13.5px;box-sizing:border-box">
  </div>
  <div class="row" style="justify-content:flex-end;margin-top:20px">
   <button class="btn-solid" disabled style="background:#E4E4EC;color:#A9A9B8;cursor:not-allowed">SAQLASH</button>
  </div>
 </div>
 </div>`;
    }

    function settingsHTML() {
      if (window.settingsSub === "Umumiy sozlamalar") return ceoGeneralHTML();
      if (window.settingsSub === "Xodimlar") return xodimlarHTML();
      if (window.settingsSub === "Amo CRM sozlamalari") return amoCrmHTML();
      if (window.settingsSub === "Kurslar") return coursesHTML();
      if (window.settingsSub === "Xonalar") return roomsHTML();
      if (window.settingsSub === "Dam olish kunlari") return holidaysHTML();
      if (window.settingsSub === "Maktablar") return schoolsHTML();
      if (window.settingsSub === "Coin sozlamalari") return coinSettingsHTML();
      const blocks = [
        [
          "Markaz va filiallar",
          "Nomi, logotip, manzil, telefon raqamlari va filiallarni qo'shish/tahrirlash.",
          ["Markaz nomi", "Manzil", "Telefon"],
        ],
        [
          "Xodimlar va rollar",
          "Super Admin, Filial direktori, Menejer, O'qituvchi, Kassir uchun huquqlarni belgilash.",
          ["Foydalanuvchi", "Rol", "Filial"],
        ],
        [
          "Kurslar va xonalar",
          "Kurslar ro'yxati, narx va davomiylik; dars xonalari ro'yxati.",
          ["Kurs nomi", "Narxi", "Davomiyligi"],
        ],
        [
          "SMS va integratsiyalar",
          "SMS shablonlari, provayder va to'lov tizimlari ulanishi.",
          ["SMS provayder", "API kalit", "To'lov tizimi"],
        ],
      ];
      return `<div class="panel"><h2>Sozlamalar</h2>
 ${blocks
   .map(
     ([t, d, fields]) => `<div class="settings-card"><h3>${t}</h3><p>${d}</p>
 <div class="field-row">${fields.map((f) => `<input type="text" placeholder="${f}">`).join("")}</div>
 <div style="margin-top:10px"><button class="primary">Saqlash</button></div></div>`,
   )
   .join("")}</div>`;
    }

    const RENDER = {
      dash: dashHTML,
      leads: leadsHTML,
      teachers: teachersHTML,
      groups: groupsHTML,
      students: studentsHTML,
      exams: examsHTML,
      finance: financeHTML,
      reports: reportsHTML,
      settings: settingsHTML,
    };
    const TITLES = {
      dash: "Bosh sahifa",
      leads: "Lidlar",
      teachers: "O'qituvchilar",
      groups: "Guruhlar",
      students: "O'quvchilar",
      exams: "Imtihonlar",
      finance: "Moliya",
      reports: "Hisobotlar",
      settings: "Sozlamalar",
    };
    const content = document.getElementById("content");
    let studentProfileApp = null;
    function show(id) {
      window.currentSection = id;
      const am = document.getElementById("actionMenu");
      if (am) am.classList.remove("show");
      if (studentProfileApp) {
        studentProfileApp.unmount();
        studentProfileApp = null;
      }
      document
        .querySelectorAll(".nav-item")
        .forEach((n) => n.classList.toggle("active", n.dataset.id === id));
      content.innerHTML = RENDER[id]();
      applyTranslations(content);
      refreshPeriodSelects(content);
      if (id === "reports" && window.reportsSub === "O'quvchilar to'lovi") {
        studentProfileApp = createApp(StudentProfileDashboard);
        studentProfileApp.mount(content.querySelector("#student-profile-dashboard"));
      }
      content.querySelectorAll(".stat-card").forEach((card) => {
        const navigate = () => {
          if (card.dataset.sub) window.reportsSub = card.dataset.sub;
          show(card.dataset.target);
        };
        card.addEventListener("click", navigate);
        card.addEventListener("keydown", (event) => {
          if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            navigate();
          }
        });
      });
      content.querySelectorAll(".tab").forEach(
        (t) =>
          (t.onclick = () => {
            content
              .querySelectorAll(".tab")
              .forEach((x) => x.classList.remove("active"));
            t.classList.add("active");
          }),
      );
      content.querySelectorAll(".daytab").forEach((dayButton) => {
        dayButton.addEventListener("click", () => changeCalendarDate(dayButton.dataset.date));
      });
      content.querySelector("#calendarInterval")?.addEventListener("change", (event) => {
        calendarIntervalMinutes = Number(event.target.value) === 30 ? 30 : 15;
        show("dash");
      });
      content.querySelector("#attendanceDatePicker")?.addEventListener("change", (event) => {
        selectedAttendanceDate = event.target.value || formatLocalDate(new Date());
        show("reports");
      });
    }
    show("dash");
    applyTranslations(document.body);

    // Yuqoridagi funksiyalarni global (window) darajasiga chiqaramiz,
    // chunki HTML ichidagi onclick="..." atributlari ularni shu yerdan qidiradi.
    window.show = show;
    window.closeDrawer = closeDrawer;
    window.openDrawer = openDrawer;
    window.closeFaolModal = closeFaolModal;
    window.openFaolModal = openFaolModal;
    window.closeTplModal = closeTplModal;
    window.openTplModal = openTplModal;
    window.closeBolimModal = closeBolimModal;
    window.openBolimModal = openBolimModal;
    window.switchStudentSubTab = switchStudentSubTab;
    window.toggleNums = toggleNums;
    window.openActionMenu = openActionMenu;
    window.addOqituvchiRow = addOqituvchiRow;
    window.toggleStudentSection = toggleStudentSection;
    window.addStudentSchool = addStudentSchool;
    window.formatUzbekPhoneInput = formatUzbekPhoneInput;
    window.openRecordActions = openRecordActions;
    window.openRecordEditor = openRecordEditor;
    window.deleteRecord = deleteRecord;
    window.openStudentScoreEditor = openStudentScoreEditor;
    const updateLiveDateTime = () => {
      const now = new Date();
      const language = locale.value === "ru" ? "ru-RU" : "uz-UZ";
      document.getElementById("liveDate").textContent = `${localizedWeekday(now)}, ${localizedCalendarDate(now, true)}`;
      document.getElementById("liveClock").textContent = new Intl.DateTimeFormat(language, {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hour12: false,
      }).format(now);
    };
    updateLiveDateTime();
    this.clockTimer = window.setInterval(updateLiveDateTime, 1000);
  },
};
</script>

<style>
:root {
  --bg: #f5f3ee;
  --surface: #ffffff;
  --ink: #1b2430;
  --ink-soft: #5b6472;
  --line: #e4e0d6;
  --navy: #12213a;
  --navy-2: #1b3252;
  --gold: #b8863b;
  --gold-soft: #f1e4cb;
  --ok: #2f7d5c;
  --warn: #b8863b;
  --danger: #b4462f;
  --active-txt: #12213a;
  --radius: 10px;
  box-sizing: border-box;
  padding-top: env(safe-area-inset-top, 0px);
  padding-bottom: env(safe-area-inset-bottom, 0px);
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --bg: #14181f;
    --surface: #1b212b;
    --ink: #edeff2;
    --ink-soft: #9aa3b1;
    --line: #2a3140;
    --gold-soft: #3a2f1c;
    --active-txt: #e8b75e;
  }
}
:root[data-theme="dark"] {
  --bg: #14181f;
  --surface: #1b212b;
  --ink: #edeff2;
  --ink-soft: #9aa3b1;
  --line: #2a3140;
  --gold-soft: #3a2f1c;
  --active-txt: #e8b75e;
}
* {
  box-sizing: border-box;
}
html,
body {
  height: 100%;
  margin: 0;
}
body {
  background: var(--bg);
  color: var(--ink);
  font-family: "Inter", system-ui, sans-serif;
  font-size: 14px;
  min-height: 100vh;
}
h1,
h2,
h3,
.brand,
.navlabel {
  font-family: "Sora", system-ui, sans-serif;
}
::-webkit-scrollbar {
  height: 8px;
  width: 8px;
}
::-webkit-scrollbar-thumb {
  background: var(--line);
  border-radius: 8px;
}

/* Top bar */
#headerwrap {
  position: sticky;
  top: 0;
  z-index: 10;
  padding-top: env(safe-area-inset-top, 0px);
  background: var(--surface);
}
#topbar {
  background: var(--surface);
  border-bottom: 1px solid var(--line);
  padding: 12px 24px;
  display: flex;
  align-items: center;
  gap: 12px;
  justify-content: space-between;
}
.brand {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 16px;
  font-weight: 700;
  color: var(--ink);
  white-space: nowrap;
}
.mobile-menu-toggle {
  display: none;
  width: 36px;
  height: 36px;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  color: var(--ink);
  font-size: 20px;
  line-height: 1;
  cursor: pointer;
}
.brand .mark {
  width: 30px;
  height: 30px;
  border-radius: 7px;
  background: #12213a;
  color: #fff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
}
.live-date-time {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 0 0 auto;
  color: var(--ink-soft);
  font-size: 11px;
  white-space: nowrap;
}
.live-date-time span {
  text-transform: capitalize;
}
.live-date-time time {
  color: var(--ink);
  font-size: 13px;
  font-variant-numeric: tabular-nums;
  font-weight: 700;
}
@media (max-width: 900px) {
  #topbar {
    flex-wrap: wrap;
    justify-content: flex-start;
    gap: 8px;
    padding: 10px 16px;
  }
  .live-date-time {
    display: none;
  }
  .btn-sorovnoma,
  .icon-btn,
  .btn-tolov {
    display: none;
  }
  .search-wrap {
    flex: 1 1 180px;
    min-width: 160px;
  }
  .filial-select {
    margin-left: auto;
  }
}
@media (max-width: 560px) {
  .settings-card [style*="flex-wrap:wrap"] .pill {
    max-width: 100%;
    min-width: 0;
    white-space: normal;
    overflow-wrap: anywhere;
  }
  .ceo-row,
  .ceo-row.top {
    flex-wrap: wrap;
    gap: 8px;
  }
  .ceo-label {
    width: 100%;
    flex: 1 1 100%;
    padding-top: 0;
  }
  .ceo-row input[type="text"],
  .ceo-stack {
    min-width: 0;
    flex: 1 1 100%;
  }
  .ceo-input-row,
  .ceo-input-row input {
    min-width: 0;
  }
  #topbar {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto auto auto auto;
    gap: 8px;
    padding: 10px 12px;
  }
  #topbar .brand {
    grid-column: 1;
  }
  #topbar .mobile-menu-toggle {
    grid-column: 2;
  }
  #topbar .filial-select {
    grid-column: 3;
    margin-left: 0;
  }
  #topbar > .icon-circle:not([aria-label]) {
    display: none;
  }
  #topbar > .icon-circle[aria-label] {
    grid-column: 4;
  }
  #topbar .profile-menu-anchor {
    grid-column: 5;
  }
  #topbar .search-wrap {
    grid-column: 1 / -1;
    grid-row: 2;
    min-width: 0;
    width: 100%;
  }
  #content {
    padding: 14px 12px 28px;
  }
  .panel {
    padding: 12px;
  }
  .drawer.room-mode {
    width: 100vw;
    max-width: 100vw;
  }
  .drawer.room-mode .drawer-body {
    flex: 1 1 auto;
    overflow-y: auto;
    padding: 16px;
  }
}
.btn-sorovnoma {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  border-radius: 8px;
  border: 1px solid #d8d5f7;
  background: #f5f4fe;
  color: #5a55e0;
  font-weight: 600;
  font-size: 12.5px;
  cursor: pointer;
  white-space: nowrap;
}
.search-wrap {
  position: relative;
  flex: 0 1 460px;
}
.search-wrap input {
  width: 100%;
  padding: 9px 32px 9px 12px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--bg);
  color: var(--ink);
  font-size: 13px;
}
.search-wrap .search-chev {
  position: absolute;
  right: 11px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--ink-soft);
  font-size: 10px;
  pointer-events: none;
}
.icon-btn {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--bg);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  cursor: pointer;
  flex: 0 0 auto;
}
.btn-tolov {
  padding: 9px 20px;
  border-radius: 8px;
  border: none;
  background: #5a55e0;
  color: #fff;
  font-weight: 700;
  font-size: 12.5px;
  cursor: pointer;
  white-space: nowrap;
}
.filial-select {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  font-weight: 600;
  color: var(--ink);
  cursor: pointer;
  white-space: nowrap;
}
.filial-select .chev2 {
  font-size: 10px;
  color: var(--ink-soft);
}
.icon-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid var(--line);
  background: var(--surface);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  cursor: pointer;
  flex: 0 0 auto;
  color: var(--ink-soft);
}
.profile-menu-anchor {
  position: relative;
  display: flex;
  flex: 0 0 auto;
}
.avatar-wrap {
  position: relative;
  flex: 0 0 auto;
  display: inline-flex;
  padding: 0;
  border: 0;
  border-radius: 50%;
  background: transparent;
  cursor: pointer;
}
.avatar-user {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #e4e4ec;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  color: #9a9aae;
  cursor: pointer;
}
.online-dot {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: #3ebd6e;
  border: 2px solid var(--surface);
}
.profile-menu {
  position: absolute;
  top: calc(100% + 10px);
  right: 0;
  z-index: 1500;
  width: min(290px, calc(100vw - 24px));
  overflow: hidden;
  border: 1px solid #414762;
  border-radius: 10px;
  background: #2d324e;
  color: #dfe2f1;
  box-shadow: 0 14px 32px rgb(0 0 0 / 35%);
}
.profile-menu-head {
  display: flex;
  align-items: flex-start;
  gap: 9px;
  padding: 13px 12px 10px;
  border-bottom: 1px solid rgb(221 226 255 / 10%);
}
.profile-menu-avatar,
.profile-qr-button,
.profile-edit-button {
  display: grid;
  flex: 0 0 auto;
  place-items: center;
}
.profile-menu-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #454b65;
  font-size: 18px;
}
.profile-menu-person {
  display: flex;
  min-width: 0;
  flex: 1 1 auto;
  flex-direction: column;
  gap: 3px;
  padding-top: 1px;
  overflow-wrap: anywhere;
}
.profile-menu-person strong { color: #eef0fb; font-size: 13px; }
.profile-menu-person small { color: #aeb6c9; font-size: 11px; text-decoration: underline; }
.profile-menu-person > span { margin-top: 4px; color: #c7cce0; font-size: 12px; }
.profile-qr-button,
.profile-edit-button {
  width: 30px;
  height: 30px;
  padding: 0;
  border: 0;
  border-radius: 5px;
  background: transparent;
  color: #cbd1e7;
  cursor: pointer;
}
.profile-qr-button { background: #fff; color: #252a3e; }
.profile-qr-button img { width: 28px; height: 28px; }
.profile-menu-item {
  display: flex;
  width: 100%;
  min-height: 40px;
  align-items: center;
  gap: 9px;
  padding: 0 13px;
  border: 0;
  border-bottom: 1px solid rgb(221 226 255 / 7%);
  background: transparent;
  color: #7781ff;
  font: inherit;
  font-size: 12px;
  font-weight: 650;
  text-align: left;
  cursor: pointer;
}
.profile-menu-item:hover,
.profile-qr-button:hover,
.profile-edit-button:hover { background: rgb(255 255 255 / 7%); }
.profile-menu-item > svg { flex: 0 0 auto; }
.profile-menu-item.profile-green-item { color: #4ccf28; }
.profile-menu-item.profile-memory-item { color: #7180ff; }
.profile-memory-item small { margin-left: auto; color: #bac2d6; font-size: 10px; font-weight: 400; }
.profile-menu-item.profile-telegram-item { color: #aab3c7; }
.profile-telegram-item i {
  position: relative;
  width: 28px;
  height: 15px;
  margin-left: auto;
  border-radius: 10px;
  background: #596078;
}
.profile-telegram-item i::before {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 11px;
  height: 11px;
  border-radius: 50%;
  background: #f1f3f8;
  content: "";
  transition: transform .16s ease;
}
.profile-telegram-item i.enabled { background: #287a50; }
.profile-telegram-item i.enabled::before { transform: translateX(13px); }
.profile-menu-detail {
  padding: 8px 14px 10px 40px;
  border-bottom: 1px solid rgb(221 226 255 / 7%);
  color: #b7c0d5;
  font-size: 10px;
  line-height: 1.4;
}
.profile-menu-item.profile-logout-item { color: #d5d8e5; }
.profile-badge-overlay {
  position: fixed;
  inset: 0;
  z-index: 1700;
  display: grid;
  place-items: center;
  padding: 18px;
  background: rgb(5 8 14 / 70%);
}
.profile-badge-card {
  position: relative;
  display: flex;
  width: min(320px, 100%);
  flex-direction: column;
  align-items: center;
  padding: 24px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--surface);
  color: var(--ink);
  text-align: center;
}
.profile-badge-card > img { width: 144px; height: 144px; image-rendering: pixelated; }
.profile-badge-card h2 { margin: 12px 0 3px; font-size: 18px; }
.profile-badge-card p { margin: 0 0 8px; color: var(--ink-soft); text-transform: uppercase; }
.profile-badge-close { position: absolute; top: 8px; right: 10px; border: 0; background: transparent; color: var(--ink-soft); font-size: 22px; cursor: pointer; }
.profile-badge-print { margin-top: 16px; padding: 9px 16px; border: 0; border-radius: 7px; background: #5a55e0; color: #fff; cursor: pointer; }

/* Nav row */
#navbar {
  background: var(--surface);
  border-bottom: 1px solid var(--line);
  padding: 8px 24px;
  display: flex;
  gap: 6px;
  overflow-x: auto;
  align-items: center;
  justify-content: space-evenly;
}
@media (max-width: 700px) {
  .mobile-menu-toggle {
    display: inline-flex;
  }
  #navbar:not(.mobile-open) {
    display: none;
  }
  #navbar.mobile-open {
    display: flex;
    flex-direction: column;
    align-items: stretch;
    justify-content: flex-start;
    gap: 4px;
    padding: 8px 12px;
    overflow: visible;
  }
  #navbar.mobile-open .nav-item {
    width: 100%;
  }
}
.nav-item {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 9px 14px;
  color: var(--ink-soft);
  cursor: pointer;
  font-size: 13.5px;
  font-weight: 600;
  white-space: nowrap;
  border-radius: 8px;
}
.nav-item:hover {
  color: var(--ink);
  background: var(--bg);
}
.nav-item.active {
  color: #fff;
  background: #5a55e0;
}
.nav-item.active:hover {
  background: #5a55e0;
}
.nav-icon {
  font-size: 15px;
}
.maosh-tabs {
  display: flex;
  border: 1px solid var(--line);
  border-radius: 8px;
  overflow: hidden;
}
.maosh-tab {
  flex: 1;
  text-align: center;
  padding: 10px 4px;
  font-size: 12px;
  color: var(--ink-soft);
  cursor: pointer;
  border-right: 1px solid var(--line);
}
.maosh-tab:last-child {
  border-right: none;
}
.maosh-tab.active {
  background: #f1f0fe;
  color: #5a55e0;
  font-weight: 600;
}
.btn-view-nums {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 9px 16px;
  border-radius: 8px;
  border: 1px solid #d8d5f7;
  background: var(--surface);
  color: #5a55e0;
  font-weight: 600;
  font-size: 13px;
  cursor: pointer;
  white-space: nowrap;
}
.btn-view-nums:hover {
  background: #f5f4fe;
}

/* Main */
#content {
  padding: 22px 24px 40px;
  overflow-x: hidden;
  width: 100%;
}
.section {
  display: none;
}
.section.active {
  display: block;
}

/* Cards */
.grid {
  display: grid;
  gap: 12px;
}
.stat-grid {
  grid-template-columns: repeat(6, 1fr);
}
@media (max-width: 900px) {
  .stat-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .settings-overview-grid {
    display: flex !important;
    flex-direction: column;
    width: 100%;
  }
  .settings-overview-grid > * {
    width: 100%;
    min-width: 0;
  }
}
@media (max-width: 700px) {
  .panel .grid[style*="repeat(4,1fr)"] {
    grid-template-columns: repeat(2, 1fr) !important;
  }
  .panel .grid[style*="1fr 1.4fr"] {
    grid-template-columns: 1fr !important;
  }
  .plan-cards {
    grid-template-columns: repeat(2, 1fr);
  }
}
@media (max-width: 560px) {
  .stat-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .grid[style*="repeat(6,1fr)"] {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
  }
  .grid[style*="repeat(4,1fr)"] {
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
  }
  .grid[style*="1fr 1.4fr"],
  .grid[style*="1fr 1fr"] {
    grid-template-columns: 1fr !important;
  }
  .calendar-strip {
    gap: 4px;
  }
  .daytab {
    min-width: 68px;
    padding-right: 7px;
    padding-left: 7px;
  }
}
.stat-card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 16px 14px;
  text-align: center;
  cursor: pointer;
}
.stat-card:hover,
.stat-card:focus-visible {
  border-color: var(--gold);
  outline: none;
}
.stat-card .ic {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: var(--gold-soft);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 15px;
  margin-bottom: 8px;
}
.stat-card .v {
  font-size: 19px;
  font-weight: 700;
  font-family: "Sora", sans-serif;
}
.stat-card .l {
  color: var(--ink-soft);
  font-size: 12px;
  margin-top: 3px;
}
.stat-card.gold {
  background: var(--gold-soft);
  border-color: var(--gold);
}

.panel {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 18px;
  margin-top: 16px;
}
.panel h2 {
  font-size: 15px;
  margin: 0 0 12px;
  font-weight: 600;
}
.row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  align-items: center;
  margin-bottom: 14px;
}
input[type="text"],
select {
  padding: 8px 11px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--bg);
  color: var(--ink);
  font-size: 13px;
}
input,
textarea,
[contenteditable="true"] {
  caret-color: var(--gold);
}
input:focus-visible,
textarea:focus-visible,
select:focus-visible,
[contenteditable="true"]:focus-visible {
  outline: 2px solid var(--gold);
  outline-offset: 2px;
}
select option {
  background: var(--surface);
  color: var(--ink);
}
button {
  padding: 8px 14px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--bg);
  color: var(--ink);
  font-size: 13px;
  cursor: pointer;
  font-family: "Inter", sans-serif;
}
button.primary {
  background: var(--navy);
  color: #fff;
  border-color: var(--navy);
}
button.gold {
  background: var(--gold);
  color: #fff;
  border-color: var(--gold);
}
button:hover {
  filter: brightness(0.96);
}
.spacer {
  flex: 1;
}

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}
.tblwrap {
  overflow-x: auto;
}
th {
  text-align: left;
  color: var(--ink-soft);
  font-weight: 600;
  font-size: 12px;
  text-transform: none;
  padding: 9px 10px;
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
td {
  padding: 9px 10px;
  border-bottom: 1px solid var(--line);
  white-space: nowrap;
}
tr:hover td {
  background: var(--bg);
}
.badge {
  padding: 3px 9px;
  border-radius: 20px;
  font-size: 11.5px;
  font-weight: 600;
}
.badge.ok {
  background: #dceee4;
  color: var(--ok);
}
.badge.warn {
  background: var(--gold-soft);
  color: var(--warn);
}
.badge.bad {
  background: #f5deda;
  color: var(--danger);
}
.avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: var(--navy-2);
  color: #fff;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
}
.dots {
  cursor: pointer;
  color: var(--ink-soft);
  padding: 2px 6px;
}
.tabs {
  display: flex;
  gap: 4px;
  margin-bottom: 14px;
  border-bottom: 1px solid var(--line);
}
.tab {
  padding: 9px 14px;
  cursor: pointer;
  color: var(--ink-soft);
  font-size: 13px;
  border-bottom: 2px solid transparent;
}
.tab.active {
  color: var(--ink);
  border-color: var(--gold);
  font-weight: 600;
}
.note {
  color: var(--ink-soft);
  font-size: 12.5px;
  margin-top: 10px;
}
.daytabs {
  display: flex;
  flex: 1 1 auto;
  gap: 2px;
  min-width: 0;
  overflow-x: auto;
  scrollbar-width: none;
}
.daytabs::-webkit-scrollbar {
  display: none;
}
.daytab {
  flex: 1 0 auto;
  min-width: 80px;
  padding: 14px 10px 11px;
  border: 0;
  border-bottom: 2px solid transparent;
  border-radius: 0;
  background: transparent;
  font-size: 11.5px;
  font-weight: 600;
  color: var(--ink-soft);
  cursor: pointer;
  white-space: nowrap;
  text-transform: uppercase;
}
.daytab.active {
  color: #5a55e0;
  border-bottom-color: #5a55e0;
  background: transparent;
}
.calendar-strip {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
  margin: -8px -4px 4px;
  border-bottom: 1px solid var(--line);
}
.calendar-interval {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 2px;
  flex: 0 0 auto;
  margin-left: auto;
  padding: 0 8px 8px 0;
  color: var(--ink-soft);
  font-size: 10px;
  white-space: nowrap;
}
.calendar-interval select {
  min-height: 32px;
  min-width: 120px;
  padding: 5px 8px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  color: var(--ink);
  font-size: 12px;
}
.calendar-date-input:focus-visible,
.calendar-interval select:focus-visible,
.calendar-nav button:focus-visible,
.daytab:focus-visible {
  outline: 2px solid var(--gold);
  outline-offset: 2px;
}
.timegrid {
  overflow-x: auto;
  border: 1px solid var(--line);
  border-radius: 8px;
}
.timegrid table {
  width: max-content;
  min-width: 100%;
  border-collapse: collapse;
  table-layout: fixed;
}
.timegrid th,
.timegrid td {
  border-right: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  padding: 8px 10px;
  font-size: 11px;
  min-width: 52px;
  text-align: center;
}
.timegrid th:first-child,
.timegrid td:first-child {
  position: sticky;
  left: 0;
  background: var(--surface);
  text-align: left;
  min-width: 76px;
  font-weight: 600;
  font-size: 12px;
  z-index: 2;
}
.timegrid thead th {
  background: var(--bg);
  color: var(--ink-soft);
  font-weight: 600;
}
.timegrid td.busy {
  padding: 3px;
  background: transparent;
  color: var(--ink);
  font-weight: 400;
}
.calendar-event {
  min-width: 116px;
  min-height: 36px;
  padding: 6px 8px;
  border-radius: 8px;
  background: #fff;
  color: #1b2430;
  font-size: 10px;
  line-height: 1.35;
  overflow: hidden;
}
.calendar-event span {
  display: block;
  white-space: nowrap;
}
.filterbox {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.filterbox span {
  font-size: 11px;
  color: var(--ink-soft);
}
.filterbox select,
.filterbox input {
  padding: 8px 11px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  color: var(--ink);
  font-size: 13px;
  min-width: 150px;
}
.fin-card {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.fin-card .badge-ic {
  width: 38px;
  height: 38px;
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  flex: 0 0 auto;
}
.fin-card .fv {
  font-size: 18px;
  font-weight: 700;
  font-family: "Sora", sans-serif;
}
.fin-card .fl {
  font-size: 12px;
  color: var(--ink-soft);
}
.emptystate {
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 30px 20px;
  text-align: center;
  color: var(--ink-soft);
}
.chartcard {
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 18px;
  position: relative;
  min-height: 260px;
}
.chartcard h3 {
  margin: 0 0 16px;
  font-size: 14px;
  color: var(--ink-soft);
  font-weight: 600;
}
.nodata-pill {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: var(--navy-2);
  color: #fff;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 12.5px;
  font-weight: 600;
}
.chart-legend {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-top: 10px;
  font-size: 12px;
  color: var(--ink-soft);
}
.chart-legend i {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
  margin-right: 5px;
}
.accent {
  --accent: #5a55e0;
}
.inp-ic {
  position: relative;
}
.inp-ic input {
  padding-right: 32px;
}
.inp-ic .ic {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--ink-soft);
  font-size: 13px;
  pointer-events: none;
}
.toggle {
  width: 36px;
  height: 20px;
  border-radius: 20px;
  background: var(--line);
  position: relative;
  cursor: pointer;
  flex: 0 0 auto;
}
.toggle i {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #fff;
  transition: 0.15s;
}
.toggle.on {
  background: #5a55e0;
}
.toggle.on i {
  left: 18px;
}
.btn-outline {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid #5a55e0;
  background: var(--surface);
  color: #5a55e0;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}
.btn-solid {
  padding: 9px 18px;
  border-radius: 8px;
  border: none;
  background: #5a55e0;
  color: #fff;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}
.btn-excel {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid var(--ok);
  background: var(--surface);
  color: var(--ok);
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}
.icon-circle {
  width: 34px;
  height: 34px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--surface);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  flex: 0 0 auto;
}
.icon-circle.danger {
  color: var(--danger);
  border-color: #f3c9c0;
}
.icon-circle.warn {
  color: var(--warn);
  border-color: #ebd3a3;
}
.dash-select {
  padding: 9px 14px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--surface);
  color: var(--ink);
  font-size: 13px;
  min-width: 130px;
}
.count-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px;
  height: 22px;
  border-radius: 50%;
  border: 1px solid #5a55e0;
  color: #5a55e0;
  font-size: 11.5px;
  font-weight: 700;
  margin-left: 6px;
}
.btn-sms {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid var(--warn);
  background: var(--surface);
  color: var(--warn);
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}
.mentor-head,
.mentor-row {
  display: grid;
  grid-template-columns: 34px 46px 1.3fr 1.1fr 1fr 1fr 1fr 1fr 1fr 24px;
  align-items: center;
  gap: 10px;
  padding: 13px 16px;
}
.mentor-head {
  border: 1px solid var(--line);
  border-radius: 10px;
  color: var(--ink-soft);
  font-weight: 600;
  font-size: 12px;
  margin-bottom: 10px;
}
.mentor-row {
  border: 1px solid var(--line);
  border-radius: 10px;
  margin-bottom: 8px;
  font-size: 13px;
}
.mentor-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--gold-soft);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
}
.count-badge {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  border: 1.5px solid #5a55e0;
  color: #5a55e0;
  font-size: 11px;
  font-weight: 700;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.btn-sms {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid #e8b75e;
  background: var(--surface);
  color: #c9822c;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}
.tabs-plain {
  display: flex;
  gap: 22px;
  border-bottom: 1px solid var(--line);
  margin: 16px 0 0;
}
.tabs-plain .tab {
  padding: 10px 2px;
  border-bottom: 2px solid transparent;
  color: var(--ink-soft);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
.tabs-plain .tab.active {
  color: #5a55e0;
  border-color: #5a55e0;
}
.stab {
  padding: 10px 2px;
  border-bottom: 2px solid transparent;
  color: var(--ink-soft);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
}
.stab.active {
  color: #5a55e0;
  border-color: #5a55e0;
}
.table-card {
  border: 1px solid var(--line);
  border-radius: var(--radius);
  overflow: hidden;
  margin-top: 16px;
}
.table-card table {
  width: 100%;
}
.table-card th {
  background: var(--surface);
}
.avatar-round {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: #eaf2fe;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
}
.pill {
  display: inline-flex;
  align-items: center;
  padding: 6px 14px;
  border-radius: 20px;
  border: 1px solid;
  font-size: 12.5px;
  font-weight: 600;
  background: var(--surface);
  white-space: nowrap;
}
.pill.blue {
  color: #5a55e0;
  border-color: #5a55e0;
}
.pill.red {
  color: var(--danger);
  border-color: #e0a99e;
}
.empty-note {
  text-align: center;
  color: var(--ink-soft);
  font-size: 13px;
  padding: 30px 10px 10px;
}
.empty-note .pill {
  margin: 0 4px;
}
.empty-note .btnrow {
  margin-top: 16px;
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}
.btn-outline2 {
  padding: 9px 18px;
  border-radius: 8px;
  border: 1px solid #5a55e0;
  background: var(--surface);
  color: #5a55e0;
  font-size: 12.5px;
  font-weight: 700;
  cursor: pointer;
}
.plan-head {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 0;
}
.plan-toggle {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--ink-soft);
}
.subbar {
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 10px 16px;
  font-weight: 600;
  font-size: 13.5px;
  margin: 14px 0 0;
}
.progress-box {
  background: #e7e5fb;
  border-radius: 10px;
  padding: 22px 24px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-top: 1px;
  flex-wrap: wrap;
  gap: 16px;
}
.progress-box .pv {
  font-size: 22px;
  font-weight: 700;
  font-family: "Sora", sans-serif;
  color: var(--ink);
  margin: 4px 0 2px;
}
.progress-box .pl {
  font-size: 13px;
  font-weight: 600;
  color: #4a4670;
}
.progress-box .ppct {
  font-size: 11.5px;
  color: var(--ink-soft);
}
.plan-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 4px 0;
  font-size: 12.5px;
  color: var(--ink-soft);
  flex-wrap: wrap;
  gap: 8px;
}
.plan-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-top: 16px;
}
.plan-card {
  border-radius: 12px;
  padding: 18px;
  color: #fff;
  position: relative;
}
.plan-card .pc-l {
  font-size: 13.5px;
  font-weight: 600;
  opacity: 0.95;
}
.plan-card .pc-v {
  font-size: 19px;
  font-weight: 700;
  font-family: "Sora", sans-serif;
  margin-top: 20px;
}
.plan-card .pc-ic {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 26px;
  height: 26px;
  border-radius: 7px;
  background: rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
}
.bonus-card {
  border: 1px solid var(--line);
  border-radius: var(--radius);
  padding: 20px;
  text-align: center;
  background: var(--surface);
}
.bonus-card .bl {
  color: var(--ink-soft);
  font-size: 13px;
}
.bonus-card .bv {
  font-size: 20px;
  font-weight: 700;
  font-family: "Sora", sans-serif;
  margin-top: 6px;
}
.calc-bar {
  display: flex;
  gap: 26px;
  flex-wrap: wrap;
  background: var(--bg);
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 10px 16px;
  font-size: 12.5px;
  color: var(--ink-soft);
  margin: 14px 0;
}
.calc-bar b {
  color: var(--ink);
  font-weight: 600;
}
.nav-item.has-dd {
  position: relative;
}
.chev {
  margin-left: 2px;
  font-size: 9px;
  transition: transform 0.15s;
  display: inline-block;
}
.nav-item.open .chev {
  transform: rotate(180deg);
}
.dropdown-menu {
  position: fixed;
  background: #1b2440;
  border: 1px solid #2a3350;
  border-radius: 12px;
  padding: 6px 0;
  min-width: 230px;
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.4);
  z-index: 999;
  display: none;
}
.dropdown-menu.show {
  display: block;
}
.dropdown-menu ul {
  margin: 0;
  padding: 0;
}
.dropdown-menu li {
  list-style: none;
  padding: 11px 18px;
  font-size: 13px;
  color: #d7dbea;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 500;
  white-space: nowrap;
  justify-content: flex-start;
}
.dropdown-menu li .li-l {
  display: flex;
  align-items: center;
  gap: 10px;
}
.dropdown-menu li .arrow {
  color: #8890b5;
  font-size: 12px;
  margin-left: auto;
  padding-left: 16px;
}
.dropdown-menu li:hover {
  background: rgba(255, 255, 255, 0.07);
  color: #fff;
}
.dropdown-menu li:before {
  content: "";
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: #8890b5;
  flex: 0 0 auto;
}
.dropdown-menu li.has-sub {
  display: block;
  padding: 0;
}
.dropdown-menu li.has-sub:before {
  display: none;
}
.dropdown-menu .sub-head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 11px 18px;
  justify-content: flex-start;
}
.dropdown-menu .sub-head:before {
  content: "";
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: #8890b5;
  flex: 0 0 auto;
}
.dropdown-menu .sub-arrow {
  margin-left: auto;
  padding-left: 16px;
  transition: transform 0.15s;
}
.dropdown-menu li.has-sub.open .sub-arrow {
  transform: rotate(180deg);
}
.dropdown-menu .submenu {
  list-style: none;
  margin: 0;
  padding: 0;
  max-height: 0;
  overflow: hidden;
  background: rgba(255, 255, 255, 0.04);
}
.dropdown-menu li.has-sub.open .submenu {
  max-height: 300px;
  padding: 2px 0 6px;
}
.dropdown-menu .submenu li {
  padding: 9px 18px 9px 20px;
  font-size: 12.5px;
  color: #b9c0d6;
}
.dropdown-menu .submenu li:before {
  width: 4px;
  height: 4px;
  background: #6b7399;
}
.dropdown-menu .submenu li:hover {
  background: rgba(255, 255, 255, 0.06);
}
.dropdown-menu .submenu li {
  justify-content: flex-start;
}
.dropdown-menu .badge-pill {
  margin-left: auto;
  background: #e8b75e;
  color: #3a2a08;
  font-size: 11px;
  font-weight: 700;
  padding: 3px 10px;
  border-radius: 20px;
}
.settings-card {
  padding: 16px;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--surface);
  margin-bottom: 12px;
}
.settings-card h3 {
  margin: 0 0 4px;
  font-size: 14px;
}
.settings-card p {
  margin: 0 0 10px;
  color: var(--ink-soft);
  font-size: 12.5px;
}
.field-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 10px;
}
.pill.green {
  color: #1db854;
  border-color: #1db854;
}
.ceo-row {
  display: flex;
  align-items: center;
  gap: 12px;
}
.ceo-row.top {
  align-items: flex-start;
}
.ceo-label {
  width: 150px;
  flex: 0 0 auto;
  color: var(--ink-soft);
  font-size: 13px;
  padding-top: 8px;
}
.ceo-row input[type="text"] {
  flex: 1;
}
.ceo-stack {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.ceo-input-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.ceo-input-row input {
  flex: 1;
}
.logo-chip {
  background: var(--navy);
  color: #fff;
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}
.radio-row {
  display: flex;
  align-items: center;
  gap: 9px;
  font-size: 13px;
  color: var(--ink);
  margin-bottom: 10px;
}
.radio-row:last-child {
  margin-bottom: 0;
}
.radio-row input[type="radio"] {
  width: 16px;
  height: 16px;
  accent-color: #5a55e0;
}
.toggle.lg {
  width: 44px;
  height: 24px;
}
.toggle.lg i {
  width: 20px;
  height: 20px;
}
.toggle.lg.on i {
  left: 22px;
}
.toggle-row {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid var(--line);
}
.toggle-row:last-child {
  border-bottom: none;
}
.toggle-row .toggle {
  margin-top: 2px;
}
.tr-title {
  font-weight: 600;
  color: var(--ink);
  font-size: 14px;
}
.tr-desc {
  color: var(--ink-soft);
  font-size: 12.5px;
  margin-top: 5px;
  line-height: 1.6;
}
.drawer-overlay {
  position: fixed;
  inset: 0;
  background: rgba(20, 20, 30, 0.4);
  z-index: 1000;
  display: none;
}
.drawer-overlay.show {
  display: block;
}
.drawer {
  position: fixed;
  top: 0;
  right: 0;
  height: 100%;
  width: 420px;
  max-width: 92vw;
  background: var(--surface);
  box-shadow: -10px 0 30px rgba(0, 0, 0, 0.2);
  z-index: 1001;
  display: flex;
  flex-direction: column;
  transform: translateX(100%);
  transition: transform 0.25s ease;
}
.drawer.room-mode {
  width: 800px;
  max-width: 100vw;
}
.drawer.room-mode .drawer-head {
  padding-top: 17px;
  border-top: 3px solid var(--gold);
}
.drawer.room-mode .drawer-body {
  flex: 0 0 auto;
  gap: 0;
  overflow: visible;
  padding: 24px 20px 0;
}
.drawer.room-mode .drawer-foot {
  padding: 10px 20px;
  border-top: 0;
}
.drawer.room-mode .drawer-foot button {
  min-height: 38px;
  padding: 10px;
}
.drawer.show {
  transform: translateX(0);
}
.drawer-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 20px 22px;
  border-bottom: 1px solid var(--line);
}
.drawer-head h3 {
  margin: 0;
  font-size: 18px;
  color: var(--ink);
}
.drawer-head .dsub {
  font-size: 12px;
  color: var(--ink-soft);
  margin-top: 2px;
}
.drawer-head .dmem {
  text-align: right;
  font-size: 10.5px;
  color: var(--ink-soft);
  font-weight: 700;
  letter-spacing: 0.5px;
}
.drawer-head .dmem b {
  display: block;
  font-size: 12.5px;
  color: var(--ink);
  font-weight: 700;
  margin-top: 2px;
  letter-spacing: 0;
}
.drawer-close {
  cursor: pointer;
  font-size: 19px;
  color: var(--ink-soft);
  margin-left: 14px;
  line-height: 1;
}
.drawer-body {
  flex: 1;
  overflow-y: auto;
  padding: 22px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.field-float {
  position: relative;
}
.field-float label {
  position: absolute;
  top: -8px;
  left: 11px;
  background: var(--surface);
  padding: 0 5px;
  font-size: 11px;
  color: var(--ink-soft);
}
.field-float input,
.field-float textarea,
.field-float select {
  width: 100%;
  box-sizing: border-box;
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 14px 12px 9px;
  font-size: 13px;
  font-family: inherit;
  color: var(--ink);
  background: var(--surface);
  appearance: none;
}
.field-float textarea {
  min-height: 110px;
  resize: vertical;
}
.field-expand {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 13px 14px;
  font-size: 13px;
  color: var(--ink-soft);
  cursor: pointer;
}
.student-extra-toggle {
  width: 100%;
  border: 0;
  border-radius: 0;
  background: transparent;
  text-align: left;
  font-family: inherit;
}
.student-extra-toggle:hover {
  filter: none;
  background: var(--bg);
}
.student-extra-content {
  flex-direction: column;
  gap: 10px;
  padding: 0 12px 12px;
}
.student-extra-content input,
.student-extra-content select {
  width: 100%;
  box-sizing: border-box;
  padding: 11px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  color: var(--ink);
  font: inherit;
}
.student-group-option {
  display: flex;
  align-items: center;
  gap: 9px;
  color: var(--ink);
  font-size: 13px;
  cursor: pointer;
}
.student-group-option input {
  width: 16px;
  height: 16px;
  accent-color: #5a55e0;
}
.assessment-scale {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 4px;
  color: var(--ink-soft);
  font-size: 12px;
}
.assessment-scale b {
  min-width: 30px;
  padding: 5px 8px;
  border: 1px solid var(--line);
  border-radius: 7px;
  background: var(--surface);
  color: var(--ink);
  text-align: center;
  font-variant-numeric: tabular-nums;
}
.field-plain {
  position: relative;
}
.field-plain input,
.field-plain textarea {
  width: 100%;
  box-sizing: border-box;
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 14px;
  font-size: 13px;
  font-family: inherit;
  color: var(--ink);
  background: var(--surface);
}
.field-plain input {
  padding-right: 38px;
}
.field-plain textarea {
  min-height: 150px;
  resize: vertical;
}
.field-plain .cal-ic {
  position: absolute;
  right: 14px;
  top: 16px;
  color: var(--ink-soft);
  pointer-events: none;
}
.field-err input {
  border-color: #e15c5c !important;
}
.field-err input::placeholder {
  color: #e15c5c;
  opacity: 1;
}
.field-err-msg {
  color: #e15c5c;
  font-size: 12px;
  margin-left: 2px;
}
.drawer-check {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: var(--ink-soft);
  cursor: pointer;
}
.drawer-check input {
  width: 16px;
  height: 16px;
}
.empty-state {
  text-align: center;
  padding: 40px 0 20px;
  color: var(--ink-soft);
  font-size: 14px;
}
.pill-green {
  background: #e4f7ea;
  color: #1db854;
  font-size: 12px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 14px;
}
.drawer-foot {
  padding: 16px 22px;
  border-top: 1px solid var(--line);
}
.drawer-foot button {
  width: 100%;
  padding: 14px;
  border: none;
  border-radius: 8px;
  background: #5a55e0;
  color: #fff;
  font-weight: 700;
  font-size: 13px;
  cursor: pointer;
  letter-spacing: 0.5px;
}
.action-menu {
  position: fixed;
  background: var(--surface);
  border: 1px solid var(--line);
  border-radius: 10px;
  padding: 6px;
  box-shadow: 0 10px 26px rgba(0, 0, 0, 0.18);
  z-index: 1002;
  display: none;
  min-width: 175px;
}
.action-menu.show {
  display: block;
}
.action-menu .ai {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 9px 10px;
  border-radius: 8px;
  font-size: 13px;
  color: var(--ink);
  cursor: pointer;
  white-space: nowrap;
}
.action-menu .ai:hover {
  background: var(--bg);
}
.record-editor-overlay {
  position: fixed;
  inset: 0;
  z-index: 1600;
  display: grid;
  place-items: center;
  padding: 18px;
  background: rgba(20, 20, 30, 0.48);
}
.record-editor {
  width: min(560px, 100%);
  max-height: min(82vh, 760px);
  overflow: auto;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: var(--surface);
  color: var(--ink);
  box-shadow: 0 18px 55px rgba(0, 0, 0, 0.24);
}
.record-editor > header {
  position: sticky;
  top: 0;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid var(--line);
  background: var(--surface);
}
.record-editor h2 {
  margin: 0;
  font-size: 17px;
}
.record-editor-close {
  width: 32px;
  height: 32px;
  padding: 0;
  border: 0;
  background: transparent;
  color: var(--ink-soft);
  font-size: 20px;
}
.record-editor-fields {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
  padding: 18px 20px;
}
.record-editor-fields label {
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: var(--ink-soft);
  font-size: 12px;
}
.record-editor-fields input,
.record-editor-fields select,
.record-editor-fields textarea {
  width: 100%;
  min-width: 0;
  box-sizing: border-box;
  padding: 10px 11px;
  border: 1px solid var(--line);
  border-radius: 7px;
  background: var(--bg);
  color: var(--ink);
  font: inherit;
}
.record-editor-fields textarea {
  min-height: 88px;
  resize: vertical;
}
.record-editor form > footer {
  display: flex;
  justify-content: flex-end;
  gap: 9px;
  padding: 13px 20px 18px;
  border-top: 1px solid var(--line);
}
@media (max-width: 520px) {
  .record-editor-fields {
    grid-template-columns: 1fr;
  }
}
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(20, 20, 30, 0.45);
  z-index: 1500;
  display: none;
}
.modal-overlay.show {
  display: block;
}
.modal-box {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: var(--surface);
  border-radius: 14px;
  padding: 28px 30px;
  width: 480px;
  max-width: 92vw;
  max-height: 86vh;
  overflow-y: auto;
  z-index: 1501;
  display: none;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
}
.modal-box.show {
  display: block;
}
.tpl-check {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 9px 0;
  font-size: 14px;
  color: var(--ink);
  cursor: pointer;
}
.tpl-check input {
  width: 19px;
  height: 19px;
  accent-color: #5a55e0;
  flex: 0 0 auto;
}
.chip-row {
  display: flex;
  gap: 8px;
  overflow-x: auto;
}
.chip {
  padding: 8px 16px;
  border-radius: 20px;
  border: 1px solid #5a55e0;
  font-size: 12px;
  font-weight: 700;
  color: #5a55e0;
  white-space: nowrap;
  cursor: pointer;
  background: var(--surface);
  flex: 0 0 auto;
}
.chip.active {
  background: #5a55e0;
  color: #fff;
}
.df-box {
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 14px 12px;
  font-size: 13px;
  color: var(--ink);
  background: var(--surface);
  width: 100%;
  box-sizing: border-box;
  position: relative;
}
.df-box input,
.df-box select {
  border: none;
  outline: none;
  background: transparent;
  width: 100%;
  font-size: 13px;
  color: var(--ink);
  font-family: inherit;
  padding: 0;
}
.df-box input.phone-input {
  width: 100%;
  min-width: 0;
  box-sizing: border-box;
}
.df-box input:focus-visible,
.df-box select:focus-visible,
.field-float input:focus-visible,
.field-float textarea:focus-visible,
.field-float select:focus-visible,
.field-plain input:focus-visible,
.field-plain textarea:focus-visible {
  outline: 2px solid var(--gold);
  outline-offset: 2px;
}
.df-box.labeled {
  padding-top: 16px;
  padding-bottom: 8px;
}
.df-box .df-label {
  position: absolute;
  top: -8px;
  left: 10px;
  background: var(--surface);
  padding: 0 5px;
  font-size: 11px;
  color: var(--ink-soft);
}
.df-box .df-icon {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--ink-soft);
  pointer-events: none;
}
.df-placeholder {
  color: var(--ink-soft);
}
@media (max-width: 480px) {
  .panel .grid[style*="repeat(4,1fr)"],
  .panel .grid[style*="repeat(6,1fr)"],
  .plan-cards {
    grid-template-columns: minmax(0, 1fr) !important;
  }
  .students-panel > .row:first-child {
    align-items: stretch !important;
  }
  .students-panel > .row:first-child > .spacer {
    display: none;
  }
  .students-panel > .row:first-child > div:first-child,
  .students-panel > .row:first-child > div:last-child {
    width: 100%;
  }
  .students-panel > .row:first-child > div:last-child {
    align-items: stretch !important;
  }
  .students-panel > .row:first-child > div:last-child > div {
    width: 100%;
    flex-wrap: wrap;
  }
  .students-panel > .row:first-child > div:last-child button {
    flex: 1 1 44%;
    min-width: 0;
    padding: 8px 6px;
    font-size: 10px;
    white-space: normal;
  }
}
</style>
