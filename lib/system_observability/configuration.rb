class SystemObservability::Configuration
  def config_bugsnag(api_key:, app_version:, enabled_release_stages:)
    Bugsnag.configure do |config|
      config.api_key               = api_key
      config.app_version           = app_version
      config.enabled_release_stages = enabled_release_stages
    end
  end
end
