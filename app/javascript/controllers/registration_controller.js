import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  padNumber(event) {
    event.target.value = `${event.target.value.toString().padStart(2, '0')}`
  }
}
