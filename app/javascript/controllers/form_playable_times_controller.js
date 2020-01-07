import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['template']

  addPlayableTime (event) {
    const playableTimeForm = this.templateTarget.innerHTML.replace(/TEMPLATE_INDEX/g, new Date().getTime())
    event.target.insertAdjacentHTML('beforebegin', playableTimeForm)
  }

  removePlayableTime (event) {
    const playableTimeForm = event.target.closest('.playable-time-form')
    playableTimeForm.querySelector('input[name*="_destroy"]').value = 1
    playableTimeForm.querySelector('.playable-time-form-visible-fields').remove()
  }
}
