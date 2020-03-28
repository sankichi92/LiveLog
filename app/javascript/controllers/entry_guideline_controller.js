import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['deadline', 'notes'];

  fetchAndReplaceGuideline(event) {
    fetch(`/lives/${event.target.value}/entry_guideline`)
      .then((response) => response.json())
      .then((entryGuideline) => {
        this._replaceGuideline(entryGuideline);
      });
  }

  _replaceGuideline(entryGuideline) {
    this.deadlineTarget.textContent = entryGuideline.deadline;
    this.notesTarget.innerHTML = entryGuideline.notes;
  }
}
