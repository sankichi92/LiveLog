import { Controller } from 'stimulus'

export default class extends Controller {
  clickRow () {
    location.href = this.data.get('location')
  }
}
