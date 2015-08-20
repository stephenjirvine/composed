#!/bin/bash
# ------------------------------------------------------------------
# [Steve Irvine] Simple Idempotent Rails deploy Script
# Script to be called by Vagrant to provision a basic rails app
# ------------------------------------------------------------------

# VARS
POSTGRES_VERSION="9.3+154ubuntu1"
RAILS_APP_NAME="rails-demo"
RUBY_VERSION="ruby-2.2.2"
NODEJS_VERSION="0.10.25~dfsg2-2ubuntu1"
RAILS_VERSION="4.2.3"

# Functions
log()  { printf "%b\n" "$*"; }
fail() { log "\nERROR: $*\n" ; exit 1 ; }

# --- Body --------------------------------------------------------
log "Updating apt cache"
sudo apt-get update 1>/dev/null

# Deploy Postgres DB
# Adding the version number means that future runs won't force an upgrade
# until we're ready, this makes us a bit more idempotent
sudo apt-get install -y postgresql=$POSTGRES_VERSION 1>/dev/null
if [[ $? > 0 ]]
then
  fail "Postgres install failed - exiting"
else
  log "Postgres version $POSTGRES_VERSION installed"
fi

# Idempotency check for database
if [[ `sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -w $RAILS_APP_NAME` ]]
then
  log "$RAILS_APP_NAME database already exists"
else
  log "creating rails db"
  sudo -u postgres createuser vagrant
  sudo -u postgres createdb $RAILS_APP_NAME --owner=vagrant
  log "db created"
fi

# Deploy ruby via RVM if it is not already the version we want
if [[ -f /home/vagrant/.rvm/bin/rvm ]]
then
  log "rvm already installed"
else
  log "installing RVM"
  command curl -sSL https://rvm.io/mpapis.asc | gpg --import - 1>/dev/null
  \curl -sSL https://get.rvm.io | bash -s stable
  source /home/vagrant/.rvm/scripts/rvm
fi

if [[ `rvm current` == $RUBY_VERSION ]]
then
  log "ruby version $RUBY_VERSION already installed"
else
  rvm install $RUBY_VERSION 1>/dev/null
  rvm --default use $RUBY_VERSION
fi

# deploy nodejs
log "checking node.js is version $NODEJS_VERSION"
sudo apt-get -y install nodejs=$NODEJS_VERSION 1>/dev/null
if [[ $? > 0 ]]
then
  fail "NodeJS install failed - exiting"
else
  log "NodeJS version $NODEJS_VERSION installed"
fi

# Deploy rails
if [[ `rails -v | cut -d ' ' -f2` == $RAILS_VERSION ]]
then
  log "rails version $RAILS_VERSION already installed"
else
  log "installing rails $RAILS_VERSION"
  gem install bundler passenger rails --no-ri --no-rdoc -f
fi

# Create rails app
if [[ -e /home/vagrant/$RAILS_APP_NAME/ ]]
then
  log "Rails app $RAILS_APP_NAME already created"
else
  rails new $RAILS_APP_NAME
fi

# Start rails server if it isn't already running
if [[ -e /home/vagrant/$RAILS_APP_NAME/tmp/pids/server.pid ]]
then
  log "Rails app $RAILS_APP_NAME already running, or stale pid found"
else
  log "starting $RAILS_APP_NAME"
  cd $RAILS_APP_NAME
  bin/rails server -b 0.0.0.0 -d
fi

exit 0
