import Rails from '@rails/ujs'
import * as ActiveStorage from '@rails/activestorage'
import Turbolinks from 'turbolinks'

import * as Sentry from '@sentry/browser'
import $ from 'jquery'
import 'bootstrap/dist/js/bootstrap.bundle'

import '../controllers'

Rails.start()
ActiveStorage.start()
Turbolinks.start()

Sentry.init({
  dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621',
  release: process.env.HEROKU_SLUG_COMMIT,
  environment: process.env.NODE_ENV,
  debug: process.env.NODE_ENV !== 'production',
})

$(document).on('turbolinks:load', () => {
  $('[data-toggle="tooltip"]').tooltip()
})
