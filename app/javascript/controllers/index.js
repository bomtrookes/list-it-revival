import { Application } from "@hotwired/stimulus"

import AddItemController from "./add_item_controller"
import ChangeViewController from "./change_view_controller"
import EditItemController from "./edit_item_controller"
import FilterSearchController from "./filter_search_controller"
import PhotoUploadController from "./photo_upload_controller"
import PreviewController from "./preview_controller"
import SortableController from "./sortable_controller"

const application = Application.start()
application.debug = false
window.Stimulus = application

application.register("add-item", AddItemController)
application.register("change-view", ChangeViewController)
application.register("edit-item", EditItemController)
application.register("filter-search", FilterSearchController)
application.register("photo-upload", PhotoUploadController)
application.register("preview", PreviewController)
application.register("sortable", SortableController)
