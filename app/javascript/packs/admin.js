import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import * as Sentry from '@sentry/browser';
import 'bootstrap';
import 'admin-lte';
import '../controllers/admin';

Sentry.init({ dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621' });

Rails.start();

ActiveStorage.start();
