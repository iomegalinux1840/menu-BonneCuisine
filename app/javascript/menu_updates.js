import { createConsumer } from "@rails/actioncable"

const MIN_REFRESH_INTERVAL_MS = 15_000

let menuUpdatesInitialized = false

function initializeMenuUpdates() {
  if (menuUpdatesInitialized) return
  menuUpdatesInitialized = true

  const body = document.body
  if (!body) return

  const restaurantId = body.dataset.restaurantId
  const refreshUrl = body.dataset.menuRefreshUrl

  if (!restaurantId || !refreshUrl) {
    return
  }

  const container = document.getElementById('menu-content')
  const initialSignature = container?.dataset.menuSignature || body.dataset.menuSignature
  const refreshIntervalSeconds = parseInt(body.dataset.menuRefreshInterval, 10)
  const refreshIntervalMs = Math.max(
    Number.isFinite(refreshIntervalSeconds) ? refreshIntervalSeconds * 1000 : 60_000,
    MIN_REFRESH_INTERVAL_MS
  )

  const consumer = createConsumer()
  let refreshing = false
  let currentSignature = initialSignature || null
  let recoveryTimerId = null

  const fallbackTimerId = window.setInterval(() => {
    if (document.hidden) return
    refreshMenu({ reason: 'interval' })
  }, refreshIntervalMs)

  const subscription = consumer.subscriptions.create(
    { channel: "MenuChannel", restaurant_id: restaurantId },
    {
      connected() {
        console.log("Connected to MenuChannel", restaurantId)
        stopRecoveryPolling()
      },

      disconnected() {
        console.log("Disconnected from MenuChannel", restaurantId)
        startRecoveryPolling()
      },

      received(data) {
        if (data && data.action === 'refresh') {
          refreshMenu({ reason: 'broadcast' })
        }
      }
    }
  )

  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
      refreshMenu({ reason: 'visibility' })
    }
  })

  window.addEventListener('focus', () => {
    refreshMenu({ reason: 'focus' })
  })

  window.addEventListener('beforeunload', () => {
    clearInterval(fallbackTimerId)
    stopRecoveryPolling()
    subscription?.unsubscribe()
  })

  function startRecoveryPolling() {
    if (recoveryTimerId) return
    refreshMenu({ reason: 'disconnect' })
    recoveryTimerId = window.setInterval(() => {
      refreshMenu({ reason: 'recovery' })
    }, MIN_REFRESH_INTERVAL_MS)
  }

  function stopRecoveryPolling() {
    if (!recoveryTimerId) return
    clearInterval(recoveryTimerId)
    recoveryTimerId = null
  }

  function refreshMenu({ reason } = {}) {
    if (refreshing) return
    refreshing = true

    fetch(refreshUrl, {
      headers: {
        'Accept': 'application/json'
      },
      credentials: 'same-origin',
      cache: 'no-store'
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(payload => {
        if (!payload) return

        const nextSignature = payload.signature || null
        if (nextSignature && currentSignature && nextSignature === currentSignature) {
          return
        }

        const target = container || document.getElementById('menu-content')
        if (!target || !payload.html) return

        target.innerHTML = payload.html

        if (nextSignature) {
          currentSignature = nextSignature
          target.dataset.menuSignature = nextSignature
          body.dataset.menuSignature = nextSignature
        }

        const grid = target.querySelector('.menu-grid, .showcase-layout__grid')
        if (grid) {
          grid.classList.add('updating')
          setTimeout(() => grid.classList.remove('updating'), 300)
        }
      })
      .catch(error => {
        console.warn('Unable to refresh menu content', error)
      })
      .finally(() => {
        refreshing = false
      })
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeMenuUpdates)
} else {
  initializeMenuUpdates()
}

document.addEventListener('turbo:load', initializeMenuUpdates)
