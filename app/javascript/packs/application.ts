import Rails from '@rails/ujs';
import * as Sentry from '@sentry/browser';
import 'bootstrap';
import '../controllers';

const rootDataset = document.documentElement.dataset;
Sentry.init({
  enabled: process.env.NODE_ENV === 'production',
  dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621',
  environment: process.env.NODE_ENV,
  release: rootDataset.release,
});
if (rootDataset.userId) {
  Sentry.setUser({ id: rootDataset.userId });
}

Rails.start();

document.addEventListener('DOMContentLoaded', () => {
  $('[data-toggle="tooltip"]').tooltip();

  document.querySelectorAll('tr.clickable').forEach((clickableTableRow) => {
    clickableTableRow.addEventListener('click', () => {
      if (clickableTableRow instanceof HTMLElement && clickableTableRow.dataset.href) {
        location.href = clickableTableRow.dataset.href;
      }
    });
  });
});
