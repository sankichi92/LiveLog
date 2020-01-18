import { Controller } from 'stimulus';
import $ from 'jquery';
import 'datatables.net/js/jquery.dataTables';
import 'datatables.net-bs4/js/dataTables.bootstrap4';

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
