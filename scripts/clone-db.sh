#!/bin/sh

# cf. https://devcenter.heroku.com/articles/heroku-postgres-import-export#export

heroku pg:backups:capture
rm -vf latest.dump
heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d LiveLog2_development latest.dump
rails runner "User.find(1).update(admin: true)"
