require 'napa/param_sanitizer'

module Napa
  class Middleware
    class Logger
      include Napa::ParamSanitizer

      # add note in readme
      # https://github.com/rails/rails/blob/master/railties/lib/rails/application/default_middleware_stack.rb#L58
      # how to use ths
      # we could default this to use the request_id or uuid or whatever
      # the tags have to be:
      # - methods the Rack::Request responds_to
      # - objects that respond to to_s
      # - Proc objects that accept an instance of the Rack::Request
      def initialize(app, taggers = nil)
        @app = app
        @taggers = taggers || [ Napa::RequestId.new ]
      end

      def call(env)
        request = Rack::Request.new(env)

        if logger.respond_to?(:tagged)
          logger.tagged(compute_tags(request)) { call_app(request, env) }
        else
          call_app(request, env)
        end
      end

      private

      def compute_tags(request)
        @taggers.collect do |tag|
          case tag
          when Proc
            tag.call(request)
          when Symbol
            request.send(tag)
          else
            tag
          end
        end
      end

      def call_app(request, env)
        # log the request and set the log level from the configuration
        logger.send(config.request_level, format_request(request, env))

        # process the request
        status, headers, body = @app.call(env)

        # log the response and set the log level from the configuration
        logger.send(config.response_level, format_response(status, headers, body))

        # return the results
        [status, headers, body]
      ensure
        # Clear the transaction id after each request
        Napa::LogTransaction.clear
      end

      def format_request(request, env)
        params  = request.params

        begin
          params = JSON.parse(request.body.read) if env['CONTENT_TYPE'] == 'application/json'
        rescue
          # do nothing, params is already set
        end

        request_data = {
          method:           request.request_method,
          path:             request.path_info,
          query:            filtered_query_string(request.query_string),
          host:             Napa::Identity.hostname,
          pid:              Napa::Identity.pid,
          revision:         Napa::Identity.revision,
          params:           filtered_parameters(params),
          remote_ip:        request.ip
        }
        request_data[:user_id] = current_user.try(:id) if defined?(current_user)

        Napa::Logger.request(request_data)
      end

      def format_response(status, headers, body)
        response_body = body.respond_to?(:body) ? body.body : nil
        Napa::Logger.response(status, headers, response_body)
      end

      def config
        Napa::Logger.config
      end

      def logger
        Napa::Logger.logger
      end
    end
  end
end
