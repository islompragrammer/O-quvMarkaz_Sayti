import { defineConfig } from 'vite'
import { randomUUID, timingSafeEqual } from 'node:crypto'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { loadEnv } from 'vite'

const projectRoot = fileURLToPath(new URL('.', import.meta.url))

function localDemoAuthPlugin(credentials) {
  return {
    name: 'local-demo-auth',
    apply: 'serve',
    configureServer(server) {
      server.middlewares.use((request, response, next) => {
        const pathname = new URL(request.url ?? '/', 'http://localhost').pathname
        if (!['/__local-demo-status', '/__local-demo-login'].includes(pathname)) return next()

        const respond = (status, payload) => {
          response.statusCode = status
          response.setHeader('Content-Type', 'application/json; charset=utf-8')
          response.end(JSON.stringify(payload))
        }
        const enabled = Boolean(credentials.DEV_LOGIN_PHONE && credentials.DEV_LOGIN_PASSWORD)

        if (pathname === '/__local-demo-status' && request.method === 'GET') {
          return respond(200, { enabled })
        }
        if (pathname !== '/__local-demo-login' || request.method !== 'POST') {
          return respond(405, { error: 'Method not allowed.' })
        }
        if (!enabled) return respond(503, { error: 'Local demo credentials are not configured.' })

        let body = ''
        request.setEncoding('utf8')
        request.on('data', (chunk) => {
          body += chunk
          if (body.length > 8192) request.destroy()
        })
        request.on('end', () => {
          let submitted
          try {
            submitted = JSON.parse(body || '{}')
          } catch {
            return respond(400, { error: 'Invalid request.' })
          }

          const expectedPassword = Buffer.from(credentials.DEV_LOGIN_PASSWORD)
          const submittedPassword = Buffer.from(String(submitted.password ?? ''))
          const passwordMatches = expectedPassword.length === submittedPassword.length
            && timingSafeEqual(expectedPassword, submittedPassword)
          const normalizePhone = (value) => String(value ?? '').replace(/\D/g, '').replace(/^998/, '')
          const phoneMatches = normalizePhone(submitted.phone) === normalizePhone(credentials.DEV_LOGIN_PHONE)
          if (!phoneMatches || !passwordMatches) return respond(401, { error: 'Telefon yoki parol noto‘g‘ri.' })

          const profile = {
            id: randomUUID(),
            full_name: 'Lokal o‘qituvchi',
            phone: `+998${normalizePhone(credentials.DEV_LOGIN_PHONE)}`,
            role: 'teacher',
            branch_name: 'Lokal demo',
            registered_at: new Date().toISOString().slice(0, 10),
          }
          return respond(200, { authMode: 'local-demo', user: { id: profile.id }, profile })
        })
      })
    },
  }
}

export default defineConfig(({ mode }) => ({
  plugins: [vue(), localDemoAuthPlugin(loadEnv(mode, projectRoot, ''))],
  server: {
    host: '127.0.0.1',
    port: 4173,
    strictPort: true,
  },
  preview: {
    host: '127.0.0.1',
    port: 4173,
    strictPort: true,
  },
  build: {
    target: 'es2020',
    sourcemap: false,
    cssCodeSplit: true,
    chunkSizeWarningLimit: 1000,
    rollupOptions: {
      input: {
        main: resolve(projectRoot, 'index.html'),
        teacher: resolve(projectRoot, 'teacher.html'),
      },
      output: {
        manualChunks: {
          vue: ['vue'],
          supabase: ['@supabase/supabase-js'],
          qr: ['qrcode'],
          icons: ['lucide-vue-next'],
        },
      },
    },
  },
}))
