require 'presenters/system_env_presenter'

module VCAP::CloudController
  module Diego
    class Environment
      EXCLUDE = [:users]

      def initialize(app, initial_env={})
        @app         = app
        @initial_env = initial_env || {}
      end

      def as_json(_={})
        diego_env =
          @initial_env.
            merge(VCAP_APPLICATION: vcap_application, MEMORY_LIMIT: "#{app.memory}m").
            merge(SystemEnvPresenter.new(app.all_service_bindings).system_env).
            merge(app.environment_json || {})

        diego_env = diego_env.merge(DATABASE_URL: app.database_uri) if app.database_uri

        NormalEnvHashToDiegoEnvArrayPhilosopher.muse(diego_env)
      end

      private

      attr_reader :app

      def vcap_application
        env = app.vcap_application
        EXCLUDE.each { |k| env.delete(k) }
        env
      end
    end
  end
end
