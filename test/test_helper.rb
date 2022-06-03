ENV['RAILS_ENV']   ||= 'test'
ENV['MANAGEO_KEY'] ||= 'meh'

require_relative '../config/environment'
require 'rails/test_help'
require 'ffaker'
require "minitest/rails"
require "minitest/reporters"
require "minitest/bang"
require 'active_support/testing/assertions'
include ActiveSupport::Testing::Assertions

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
# Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

# https://github.com/rails/rails/issues/31324
if ActionPack::VERSION::STRING >= "5.2.0"
  Minitest::Rails::TestUnit ||= Rails::TestUnit
end

class Float
  def self.parse_formated_currency(number)
    number.gsub('&nbsp;', ' ').gsub(' ', '').gsub(',', '.').to_f
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers

  def sign_in(user)
    CasAuthentication.current_cas_authentication = user
    super
  end

  def assert_ransack_filter(field, value)
    assert_select "input#q_#{field}" do
      assert_equal value, css_select("input#q_#{field}").first['value']
    end
  end

  def assert_tabledata_value(selector:, field:, &block)
    assert_select selector

    css_select("#{selector} td.#{field}").each do |entry|
      assert block.call(entry)
    end
  end

  def assert_tabledata_order(selector:, field:, &block)
    assert_select selector

    previous = nil

    css_select("#{selector} td.#{field}").each do |entry|
      if previous.nil?
        previous = entry
        next
      end

      assert block.call(entry, previous)

      previous = entry
    end
  end

  def assert_input(field, value)
    assert_selector field do
      assert_selector "[value='#{value}']"
    end
  end
end
