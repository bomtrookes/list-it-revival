import { Controller } from "@hotwired/stimulus"

// Toggles a list between edit mode and how other people will see it.
// Published lists open in preview mode; the button switches back to editing.
export default class extends Controller {
  static targets = ["button"]
  static values = { published: Boolean }

  connect() {
    if (this.publishedValue && this.hasButtonTarget) this.show(true)
  }

  toggle(event) {
    event.preventDefault()
    this.show(!this.element.classList.contains("is-previewing"))
  }

  show(previewing) {
    this.element.classList.toggle("is-previewing", previewing)
    if (this.hasButtonTarget) {
      this.buttonTarget.textContent = previewing ? "Edit list" : "Preview"
    }
  }
}
