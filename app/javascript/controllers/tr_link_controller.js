import { Controller } from 'stimulus'
import Turbolinks from 'turbolinks'

export default class extends Controller {
  clickRow () {
    const location = this.data.get('location')
    Turbolinks.visit(location)
  }
}
