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
