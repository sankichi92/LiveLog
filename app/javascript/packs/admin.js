import Rails from '@rails/ujs'
import Turbolinks from 'turbolinks'

import * as Sentry from '@sentry/browser'

import 'bootstrap/dist/js/bootstrap.bundle'
import 'admin-lte/dist/js/adminlte'

Rails.start()
Turbolinks.start()

Sentry.init({
  dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621',
  release: process.env.HEROKU_SLUG_COMMIT,
  environment: process.env.NODE_ENV,
  debug: process.env.NODE_ENV !== 'production',
})
