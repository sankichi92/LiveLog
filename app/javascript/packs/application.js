import Rails from '@rails/ujs'
import * as ActiveStorage from '@rails/activestorage'
import Turbolinks from 'turbolinks'

import * as Sentry from '@sentry/browser'

import 'bootstrap/dist/js/bootstrap.bundle'

import 'select2/dist/js/select2'
import 'select2/dist/js/i18n/ja'

import '../legacy/close_alert_donation'
import '../legacy/facebook_sdk'
import '../legacy/facebook_share'
import '../legacy/google_adsense'
import '../legacy/google_analytics'
import '../legacy/itunes_search'
import '../legacy/log_audio'
import '../legacy/log_twitter'
import '../legacy/log_youtube'
import '../legacy/manual_link'
import '../legacy/playlist'
import '../legacy/song_form'
import '../legacy/tooltip'

Rails.start()
ActiveStorage.start()
Turbolinks.start()

Sentry.init({
  dsn: 'https://a73e1519070f4bbab6079e78a5801590@sentry.io/1821621',
  release: process.env.HEROKU_SLUG_COMMIT,
  environment: process.env.NODE_ENV,
  debug: process.env.NODE_ENV !== 'production',
})
