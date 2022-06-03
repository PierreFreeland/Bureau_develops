module BureauConsultant
  class Engine < ::Rails::Engine
    isolate_namespace BureauConsultant

    initializer "bureau_consultant.assets.precompile" do |app|
      app.config.assets.precompile += ['*.js', '**/*.js', '*.jpg', '*.png', '*.ico', '*.gif', '*.woff2', '*.eot', '*.woff', '*.ttf', '*.svg']
    end

    initializer "bureau_consultant.load_engine_settings", group: :all do |app|
      Settings.add_source!("#{Engine.root}/config/settings.yml")
      Settings.add_source!("#{Engine.root}/config/settings/#{Rails.env}.yml")
      Settings.reload!
    end
  end
end
