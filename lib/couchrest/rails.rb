module CouchRest
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

Rails.module_eval do
  include CouchRest::Rails
end
