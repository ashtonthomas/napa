module Napa
  class Logger
    class Output
      class Stdout
        def initialize
          return unless enable?
          Logging.appenders.stdout('stdout', options)
          Napa::Logger.logger.add_appenders 'stdout'
        end

        def options
          {}.tap do |o|
            # binding.pry
            # Logging::Layouts.pattern()

            o[:layout] = Logging.layouts.pattern(
              :pattern => '[%d] %-5l %c: %m\n',
              :color_scheme => 'bright'
            )

            # o[:layout] = Logging.layouts.json if Napa::Logger.config.format == :json
            # o[:layout] = Logging.layouts.yaml if Napa::Logger.config.format == :yaml
          end
        end

        def enable?
          Napa::Logger.config.output.include?(:stdout)
        end
      end
    end
  end
end
