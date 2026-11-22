import { Controller } from "@hotwired/stimulus"
import Rails from "@rails/ujs"
import Sortable from "sortablejs"

// Drag-and-drop reordering that's saved on the server.
// Children with data-sortable-id are draggable; the order of ids is PATCHed to urlValue.
export default class extends Controller {
  static values = { url: String, handle: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      draggable: "[data-sortable-id]",
      handle: this.handleValue || null,
      animation: 150,
      ghostClass: "ghost",
      chosenClass: "sortable-chosen",
      onEnd: (event) => { if (event.oldIndex !== event.newIndex) this.save() }
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  save() {
    const ids = [...this.element.querySelectorAll("[data-sortable-id]")].map((el) => el.dataset.sortableId)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": Rails.csrfToken() },
      body: JSON.stringify({ ids })
    }).then((response) => {
      if (!response.ok) throw new Error(`Saving the order failed (${response.status})`)
    }).catch((error) => {
      console.error(error)
      window.location.reload() // show the order that's actually saved
    })
  }
}
