import { Controller } from "@hotwired/stimulus"

// An item card: tap the name to edit it inline, (i) shows the description and photo.
export default class extends Controller {
  static targets = ["infos", "form", "card", "article"]

  connect() {
    this.articleTarget.classList.add("d-none")
  }

  displayForm() {
    if (!this.hasFormTarget) return
    this.infosTarget.classList.add("d-none")
    this.articleTarget.classList.add("d-none")
    this.formTarget.classList.remove("d-none")
    this.formTarget.querySelector("input[type=text], textarea")?.focus()
  }

  descBtn() {
    this.articleTarget.classList.toggle("d-none")
  }

  update(event) {
    event.preventDefault()
    const submit = this.formTarget.querySelector("[type=submit]")
    if (submit) submit.disabled = true
    fetch(this.formTarget.action, {
      method: "PATCH",
      headers: { "Accept": "text/plain" },
      body: new FormData(this.formTarget)
    })
      .then(async (response) => {
        const body = await response.text()
        if (!response.ok) throw new Error(body || "Couldn't save that item.")
        this.cardTarget.outerHTML = body
      })
      .catch((error) => {
        if (submit) submit.disabled = false
        let note = this.formTarget.querySelector(".photo-upload-error.from-server")
        if (!note) {
          note = document.createElement("div")
          note.className = "photo-upload-error from-server"
          this.formTarget.prepend(note)
        }
        note.textContent = error.message
      })
  }
}
