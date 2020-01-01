import { Controller } from 'stimulus'

import 'select2/dist/js/select2'
import 'select2/dist/js/i18n/ja'

export default class extends Controller {
  static targets = ['template']

  connect () {
    this._initializeSelect2()
  }

  addPlaying (event) {
    const playingForm = this.templateTarget.innerHTML.replace(/TEMPLATE_INDEX/g, new Date().getTime())
    event.target.insertAdjacentHTML('beforebegin', playingForm)
    this._initializeSelect2()
  }

  removePlaying (event) {
    const playingForm = event.target.closest('.playing-form')
    playingForm.querySelector('input[name*="_destroy"]').value = 1
    playingForm.querySelector('.form-row').remove()
  }

  _initializeSelect2 () {
    $('.member-select').select2({ theme: 'bootstrap4' })
  }
}
