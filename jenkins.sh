#!/bin/bash -x
export FACTER_govuk_platform=test
export RAILS_ENV=test
export DISPLAY=":99"

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake stats
bundle exec rake ci:setup:rspec default
RESULT=$?
exit $RESULT
