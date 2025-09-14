import { createConsumer } from "@rails/actioncable"

document.addEventListener('DOMContentLoaded', function() {
  const consumer = createConsumer()

  consumer.subscriptions.create("MenuChannel", {
    connected() {
      console.log("Connected to MenuChannel")
    },

    disconnected() {
      console.log("Disconnected from MenuChannel")
    },

    received(data) {
      if (data.type === 'menu_updated') {
        updateMenuDisplay(data.menu_items)
      }
    }
  })

  function updateMenuDisplay(menuItems) {
    const menuGrid = document.getElementById('menu-grid')
    if (!menuGrid) return

    // Clear current menu items
    menuGrid.innerHTML = ''

    // Add updated menu items
    menuItems.slice(0, 12).forEach(item => {
      const menuItemElement = createMenuItemElement(item)
      menuGrid.appendChild(menuItemElement)
    })

    // Add fade-in animation
    menuGrid.classList.add('updating')
    setTimeout(() => {
      menuGrid.classList.remove('updating')
    }, 300)
  }

  function createMenuItemElement(item) {
    const div = document.createElement('div')
    div.className = 'menu-item'
    div.setAttribute('data-menu-item-id', item.id)

    const headerDiv = document.createElement('div')
    headerDiv.className = 'menu-item-header'

    const nameH3 = document.createElement('h3')
    nameH3.className = 'menu-item-name'
    nameH3.textContent = item.name

    const priceSpan = document.createElement('span')
    priceSpan.className = 'menu-item-price'
    priceSpan.textContent = formatPrice(item.price)

    headerDiv.appendChild(nameH3)
    headerDiv.appendChild(priceSpan)
    div.appendChild(headerDiv)

    if (item.description) {
      const descriptionP = document.createElement('p')
      descriptionP.className = 'menu-item-description'
      descriptionP.innerHTML = item.description.replace(/\n/g, '<br>')
      div.appendChild(descriptionP)
    }

    if (item.comment) {
      const commentP = document.createElement('p')
      commentP.className = 'menu-item-comment'
      commentP.innerHTML = item.comment.replace(/\n/g, '<br>')
      div.appendChild(commentP)
    }

    return div
  }

  function formatPrice(price) {
    return new Intl.NumberFormat('fr-FR', {
      style: 'currency',
      currency: 'EUR',
      minimumFractionDigits: 2
    }).format(price)
  }
})