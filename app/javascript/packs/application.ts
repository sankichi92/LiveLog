import Rails from '@rails/ujs';
import * as Sentry from '@sentry/browser';
import 'bootstrap';
import '../controllers';

Sentry.init({ dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621' });

Rails.start();
