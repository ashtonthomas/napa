module Napa
  class Logger
    class Configuration
      def initialize(options = {})
        @options = {}.tap do |o|
          o[:format] = :basic if Napa.env.development? || Napa.heroku?
          o[:output] = [:stdout] if Napa.heroku?
          # o[:log_tags] = [ Napa::RequestId ]
        end

        @options.merge!(options)
      end

      def format
        # Allowed options: :basic, :yaml, :json
        @options[:format] || :json
      end

      def output
        # Allowed options: :stdout, :file
        @options[:output] ? Array.wrap(@options[:output]) : [:stdout, :file]
      end

      def request_level
        # :info, :debug, :warning, etc.
        @options[:request_level] || :info
      end

      def response_level
        # :info, :debug, :warning, etc.
        @options[:response_level] || :debug
      end

      def log_tags
        # need to make this an attr_writer/or able to be modified somehow
        # probably with << (which ignores duplicates)
        # remember the symbol is the method that is calle don the request
        # but default to something with a proc
        # that can pull or generate the request_id
        # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/request_id.rb

        # This is to workaround NOT wrapping Rack::Request to generate the appropriate request_id method
        # @options[:log_tags] || [ Napa::RequestId ]
      end
    end
  end
end
