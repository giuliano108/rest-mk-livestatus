$LOAD_PATH.unshift File.dirname(__FILE__)
require 'livestatus/web'

run LiveStatus::Web::App
