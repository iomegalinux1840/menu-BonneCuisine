import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  static targets = ["button", "error"]

  connect() {
    const publishableKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content

    if (!publishableKey) {
      console.warn('[Stripe] Publishable key meta tag is missing; subscription button disabled.')
      this.disableButton(true)
      return
    }

    if (typeof Stripe === 'undefined') {
      console.error('[Stripe] Stripe.js failed to load.')
      this.disableButton(true)
      this.showError('Stripe ne se charge pas correctement. Merci de réessayer plus tard.')
      return
    }

    this.stripe = Stripe(publishableKey)
  }

  subscribe(event) {
    event.preventDefault()

    if (!this.stripe) {
      this.showError('Le paiement n\'est pas disponible pour le moment.')
      return
    }

    this.showError(null)
    this.disableButton(true)

    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': this.csrfToken
      },
      body: JSON.stringify({})
    })
      .then(async response => {
        const data = await response.json().catch(() => ({}))

        if (!response.ok) {
          const errorMessage = data.error || 'Une erreur est survenue pendant la création du paiement.'
          throw new Error(errorMessage)
        }

        return data
      })
      .then(data => this.stripe.redirectToCheckout({ sessionId: data.id }))
      .then(result => {
        if (result.error) {
          throw new Error(result.error.message)
        }
      })
      .catch(error => {
        console.error('[Stripe] Checkout error', error)
        this.showError(error.message)
      })
      .finally(() => this.disableButton(false))
  }

  disableButton(state) {
    if (!this.hasButtonTarget) return

    this.buttonTarget.disabled = state
    this.buttonTarget.classList.toggle('is-loading', state)
  }

  showError(message) {
    if (!this.hasErrorTarget) return

    if (!message) {
      this.errorTarget.hidden = true
      this.errorTarget.textContent = ''
      return
    }

    this.errorTarget.hidden = false
    this.errorTarget.textContent = message
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
