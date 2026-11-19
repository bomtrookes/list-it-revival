// Entry point for the build script in your package.json
import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/activestorage"
import * as bootstrap from "bootstrap"
import "@fortawesome/fontawesome-free/js/all"

Rails.start()
ActiveStorage.start()
window.bootstrap = bootstrap

import "./controllers"
