import { Controller } from 'stimulus'

import 'select2/dist/js/select2'
import 'select2/dist/js/i18n/ja'

export default class extends Controller {
  static targets = ['template']

  connect () {
    this._initializeSelect2()
  }

  addPlay (event) {
    const playForm = this.templateTarget.innerHTML.replace(/TEMPLATE_INDEX/g, new Date().getTime())
    event.target.insertAdjacentHTML('beforebegin', playForm)
    this._initializeSelect2()
  }

  removePlay (event) {
    const playForm = event.target.closest('.play-form')
    playForm.querySelector('input[name*="_destroy"]').value = 1
    playForm.querySelector('.play-form-visible-fields').remove()
  }

  _initializeSelect2 () {
    $('.member-select').select2({ theme: 'bootstrap4' })
  }
}
