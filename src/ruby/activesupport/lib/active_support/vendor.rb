  
$:.unshift "#{File.dirname(__FILE__)}/vendor/builder-2.1.2"
require 'builder'
$:.unshift "#{File.dirname(__FILE__)}/vendor/memcache-client-1.7.4"
$:.unshift "#{File.dirname(__FILE__)}/vendor/tzinfo-0.3.12"
$:.unshift "#{File.dirname(__FILE__)}/vendor/i18n-0.4.1"
require 'i18n'

module I18n
  if !respond_to?(:normalize_translation_keys) && respond_to?(:normalize_keys)
    def self.normalize_translation_keys(*args)
      normalize_keys(*args)
    end
  end
end
