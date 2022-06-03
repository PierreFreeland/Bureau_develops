$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bureau_consultant"
  s.version     = '0.1.0'
  s.authors     = ["Pithak P."]
  s.email       = ["thethak@gmail.com"]
  s.homepage    = "http://www.nuxos.asia"
  s.summary     = "BureauConsultant engine for itg"
  s.description = "BureauConsultant engine for itg"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"

  s.add_dependency "config", "~> 1.7.0"

  s.add_dependency "devise", "~> 4.3"
  s.add_dependency "devise_cas_authenticatable", "~> 1.10"

  s.add_dependency "pg"

  s.add_dependency "jquery-rails", "~> 4.3"
  s.add_dependency "font-awesome-rails", "~> 4.7"

  s.add_dependency "pretender", "~> 0.3"
  s.add_dependency "ransack", "~> 2.1.1"
  s.add_dependency "kaminari", "~> 1.0"

  s.add_dependency "carrierwave", "~> 1.2.1"
  s.add_dependency "rails-i18n", "~> 5.1"
  s.add_dependency "bootstrap-datepicker-rails", "~> 1.6.4.1"
  s.add_dependency "client_side_validations", "~> 12.0.0"
  s.add_dependency "business_time", "~> 0.9.3"

  s.add_dependency "wicked_pdf", "~> 1.1.0"
  s.add_dependency "wkhtmltopdf-binary", "~> 0.12.3.1"

  s.add_dependency "fullcalendar-rails", "~> 3.4.0.0"
  s.add_dependency "momentjs-rails", "~> 2.8"
  s.add_dependency "simple-rss", "~> 1.3.1"

  s.add_dependency "intercom"

  s.add_dependency "manageo"
  s.add_dependency "geocoder"

  s.add_dependency 'rqrcode'

  s.add_dependency "select2-rails", "4.0.2"
end
