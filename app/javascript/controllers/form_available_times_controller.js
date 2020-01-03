import { Controller } from 'stimulus'

import 'select2/dist/js/select2'
import 'select2/dist/js/i18n/ja'

export default class extends Controller {
  static targets = ['template']

  addAvailableTime (event) {
    const availableTimeForm = this.templateTarget.innerHTML.replace(/TEMPLATE_INDEX/g, new Date().getTime())
    event.target.insertAdjacentHTML('beforebegin', availableTimeForm)
  }

  removeAvailableTime (event) {
    const availableTimeForm = event.target.closest('.available-time-form')
    availableTimeForm.querySelector('input[name*="_destroy"]').value = 1
    availableTimeForm.querySelector('.available-time-form-visible-fields').remove()
  }
}
