ENV["AMBER_ENV"] ||= "test"

# Prevents running tests in production
if Amber.env.production?
  raise "The Amber environment is running in production mode!"
end

require "spec"
require "garnet_spec"
require "../config/*"

module Spec
  DRIVER = :chrome
  PATH   = "/usr/local/bin/chromedriver"

  capabilities = {
    browserName:              "chrome",
    version:                  "",
    platform:                 "ANY",
    javascriptEnabled:        true,
    takesScreenshot:          true,
    handlesAlerts:            true,
    databaseEnabled:          true,
    locationContextEnabled:   true,
    applicationCacheEnabled:  true,
    browserConnectionEnabled: true,
    cssSelectorsEnabled:      true,
    webStorageEnabled:        true,
    rotatable:                true,
    acceptSslCerts:           true,
    nativeEvents:             true,
    args:                     "--headless",
  }
end
