import $ from '../../global_jquery';

import { Controller } from '@hotwired/stimulus';
import 'datatables.net-bs4/js/dataTables.bootstrap4';
import 'datatables.net/js/jquery.dataTables';

export default class extends Controller {
  initialize() {
    $(this.element).DataTable({
      info: false,
      order: [],
      paging: false,
      searching: false,
    });
  }
}
