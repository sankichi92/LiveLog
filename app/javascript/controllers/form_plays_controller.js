import { Controller } from '@hotwired/stimulus';
import $ from 'jquery';
import 'select2';
import 'select2/dist/js/i18n/ja';

export default class extends Controller {
  static targets = ['template', 'container'];

  connect() {
    this._initializeSelect2();
  }

  addPlay() {
    const playForm = this.templateTarget.innerHTML.replace(/TEMPLATE_INDEX/g, new Date().getTime());
    this.containerTarget.insertAdjacentHTML('beforeend', playForm);
    this._initializeSelect2();
  }

  removePlay(event) {
    const playForm = event.target.closest('.play-form');
    playForm.querySelector('input[name*="_destroy"]').value = 1;
    playForm.querySelector('.play-form-visible-fields').remove();
  }

  _initializeSelect2() {
    $('.member-select').select2({ theme: 'bootstrap4', width: '100%' });
  }
}
