import { createConsumer } from "@rails/actioncable"

document.addEventListener('DOMContentLoaded', () => {
  const body = document.body
  if (!body) return

  const restaurantId = body.dataset.restaurantId
  const refreshUrl = body.dataset.menuRefreshUrl

  if (!restaurantId || !refreshUrl) {
    return
  }

  const consumer = createConsumer()
  let refreshing = false

  consumer.subscriptions.create(
    { channel: "MenuChannel", restaurant_id: restaurantId },
    {
      connected() {
        console.log("Connected to MenuChannel", restaurantId)
      },

      disconnected() {
        console.log("Disconnected from MenuChannel", restaurantId)
      },

      received(data) {
        if (data && data.action === 'refresh') {
          refreshMenu()
        }
      }
    }
  )

  function refreshMenu() {
    if (refreshing) return
    refreshing = true

    fetch(refreshUrl, {
      headers: {
        'Accept': 'application/json'
      },
      credentials: 'same-origin'
    })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then(payload => {
        if (!payload || !payload.html) return

        const container = document.getElementById('menu-content')
        if (!container) return

        container.innerHTML = payload.html

        const grid = container.querySelector('.menu-grid')
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
})
