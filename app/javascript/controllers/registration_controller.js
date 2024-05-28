import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="registration"
export default class extends Controller {
  connect() {
    // Targets
    static targets = ["elementToHide"]

    // ---
    // Values
    static values = { visible: Boolean }

    // ---
    // Classes
    static classes = ["hidden"]

    // ---
    // Actions
    hi() {
      alert("hi mom")
    }
    toggle() {
      // Update the state - Stimulus creates a property <valueName>Value 
      // for each value that can be used as a getter and as a setter
      this.visibleValue = !this.visibleValue
    }

    visibleValueChanged() {
      // Stimulus callback <value name>Changed which is automatically 
      // called when the value is changed 
      this.elementToHideTarget.classList.toggle(this.hiddenClass, !this.visibleValue)
    }
  }
}
