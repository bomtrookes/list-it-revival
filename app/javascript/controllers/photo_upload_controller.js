import { Controller } from "@hotwired/stimulus"

// Shrinks big photos in the browser before they're uploaded, so uploads are quick and
// pages stay light. Works with phone photo libraries and cameras (incl. iPhone HEIC photos).
const MAX_DIMENSION = 2000
const MAX_BYTES = 10 * 1024 * 1024
const RESIZE_ABOVE_BYTES = 1.5 * 1024 * 1024
const KEEP_TYPES = ["image/jpeg", "image/png", "image/webp", "image/gif"]

export default class extends Controller {
  async resize() {
    const input = this.element
    const file = input.files[0]
    this.clearMessage()
    if (!file) return

    if (!file.type.startsWith("image/") && file.type !== "") {
      return this.reject("Please choose a photo.")
    }

    const needsWork = file.size > RESIZE_ABOVE_BYTES || !KEEP_TYPES.includes(file.type)
    if (file.type === "image/gif" || !needsWork) return this.check(file)

    this.setBusy(true)
    try {
      const smaller = await this.shrink(file)
      if (smaller) {
        const transfer = new DataTransfer()
        transfer.items.add(smaller)
        input.files = transfer.files
      }
      this.check(input.files[0])
    } catch (error) {
      console.warn("Couldn't resize photo, uploading the original", error)
      this.check(file)
    } finally {
      this.setBusy(false)
    }
  }

  async shrink(file) {
    const bitmap = await this.load(file)
    const scale = Math.min(1, MAX_DIMENSION / Math.max(bitmap.width, bitmap.height))
    const canvas = document.createElement("canvas")
    canvas.width = Math.round(bitmap.width * scale)
    canvas.height = Math.round(bitmap.height * scale)
    canvas.getContext("2d").drawImage(bitmap, 0, 0, canvas.width, canvas.height)
    const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/jpeg", 0.85))
    if (!blob || (blob.size >= file.size && KEEP_TYPES.includes(file.type))) return null
    const name = file.name.replace(/\.[^.]+$/, "") + ".jpg"
    return new File([blob], name, { type: "image/jpeg", lastModified: Date.now() })
  }

  load(file) {
    if (window.createImageBitmap) {
      return createImageBitmap(file, { imageOrientation: "from-image" }).catch(() => this.loadWithImg(file))
    }
    return this.loadWithImg(file)
  }

  loadWithImg(file) {
    return new Promise((resolve, reject) => {
      const img = new Image()
      img.onload = () => { URL.revokeObjectURL(img.src); resolve(img) }
      img.onerror = reject
      img.src = URL.createObjectURL(file)
    })
  }

  check(file) {
    if (file && file.size > MAX_BYTES) this.reject("That photo is over 10 MB. Please pick a smaller one.")
  }

  reject(message) {
    this.element.value = ""
    this.showMessage(message)
  }

  showMessage(message) {
    this.message = document.createElement("div")
    this.message.className = "photo-upload-error"
    this.message.textContent = message
    this.element.insertAdjacentElement("afterend", this.message)
  }

  clearMessage() {
    this.message?.remove()
    this.message = null
  }

  setBusy(busy) {
    const form = this.element.form
    if (!form) return
    form.querySelectorAll("[type=submit]").forEach((button) => { button.disabled = busy })
  }
}
