# Prefer gems to the bundled libs.
require 'rubygems'

$:.unshift "#{File.dirname(__FILE__)}/vendor/builder-2.1.2"
require 'builder'

$:.unshift "#{File.dirname(__FILE__)}/vendor/memcache-client-1.6.5"

$:.unshift "#{File.dirname(__FILE__)}/vendor/tzinfo-0.3.12"

$:.unshift "#{File.dirname(__FILE__)}/vendor/i18n-0.1.3/lib"
require 'i18n'
