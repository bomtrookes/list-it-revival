import { Controller } from "@hotwired/stimulus"

// Shows the "+ List Item" link and reveals the new item form when it's clicked.
// Lists you don't own have neither, so every step checks the targets exist.
export default class extends Controller {
  static targets = ["addItem", "newForm"]

  connect() {
    if (this.hasNewFormTarget) this.newFormTarget.classList.add("d-none")
    if (this.hasAddItemTarget) this.addItemTarget.classList.remove("d-none")
  }

  nextItem() {
    if (!this.hasNewFormTarget) return
    this.newFormTarget.classList.remove("d-none")
    if (this.hasAddItemTarget) this.addItemTarget.classList.add("d-none")
    const field = this.newFormTarget.querySelector("input[type=text], textarea")
    if (field) field.focus()
  }
}
