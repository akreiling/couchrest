# This file contains various hacks for Rails compatibility.
# To use, just require in environment.rb, like so:
#
#   require 'couchrest/support/rails'

class Hash
  # Hack so that CouchRest::Document, which descends from Hash,
  # doesn't appear to Rails routing as a Hash of options
  def self.===(other)
    return false if self == Hash && other.is_a?(CouchRest::Document)
    super
  end
end


CouchRest::Document.class_eval do
  # Hack so that CouchRest::Document, which descends from Hash,
  # doesn't appear to Rails routing as a Hash of options
  def is_a?(o)
    return false if o == Hash
    super
  end
  alias_method :kind_of?, :is_a?
end


require Pathname.new(File.dirname(__FILE__)).join('..', 'validation', 'validation_errors')

CouchRest::Validation::ValidationErrors.class_eval do
  # Returns the total number of errors added. Two errors added to the same attribute will be counted as such.
  # This method is called by error_messages_for
  def count
    errors.values.inject(0) { |error_count, errors_for_attribute| error_count + errors_for_attribute.size }
  end
end

module CouchRest
  module Support
    module Rails
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def couchdb
          @@couchdb ||= initialize_couchdb
        end

        def initialize_couchdb
          returning CouchRest.new do |server|
            config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'couchdb.yml'))[env].with_indifferent_access
            server.uri = config[:uri]
            server.default_database = config[:database]
          end
        end
      end
    end
  end
end

Rails.module_eval do
  include CouchRest::Support::Rails
end
