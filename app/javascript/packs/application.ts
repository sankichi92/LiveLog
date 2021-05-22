import Rails from '@rails/ujs';
import * as Sentry from '@sentry/browser';
import 'bootstrap';
import '../controllers';

Sentry.init({
  enabled: process.env.NODE_ENV === 'production',
  dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621',
  environment: process.env.NODE_ENV,
  release: document.documentElement.dataset.release,
});

Rails.start();

document.addEventListener('DOMContentLoaded', () => {
  $('[data-toggle="tooltip"]').tooltip();
});
