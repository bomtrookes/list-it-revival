// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import * as bootstrap from "bootstrap"
import "@fortawesome/fontawesome-free/js/all"

Rails.start()
ActiveStorage.start()
window.bootstrap = bootstrap

import "./controllers"

// Fade flash messages out after a few seconds
document.querySelectorAll(".alert-dismissible").forEach((el) => {
  setTimeout(() => bootstrap.Alert.getOrCreateInstance(el).close(), 5000)
})

// Article lists: the (i) button toggles its active colour
document.addEventListener("click", (event) => {
  const btn = event.target.closest(".infoBtn")
  if (btn) btn.classList.toggle("info-active")
})
