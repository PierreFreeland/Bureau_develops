require 'test_helper'

describe Goxygene::Country do
	describe '#default_vat' do

		describe 'on France' do
			let(:country) 					{ Goxygene::Country.find 1 }
			let(:default_vat_rate)	{ Goxygene::Vat.find_by default_for_france: true }

			it 'returns the default VAT rate for france' do
				assert_not_nil country.default_vat
				assert_equal default_vat_rate, country.default_vat
			end
		end

		describe 'in an ECC country' do
			let(:default_vat_rate)	{ Goxygene::Vat.find_by default_for_ecc: true }
			let(:country)           { Goxygene::Country.where(european_economic_community: true).where.not(label: 'FRANCE').sample }

			it "returns the right VAT" do
				assert_not_nil country.default_vat
				assert_equal default_vat_rate, country.default_vat
			end

		end

		describe 'in a french overseas country' do
			let(:default_vat_rate)	{ Goxygene::Vat.find_by default_for_french_overseas: true }
			let(:country)           { Goxygene::Country.where(french_overseas: true).sample }

			it "returns the right VAT" do
				assert_not_nil country.default_vat
				assert_equal default_vat_rate, country.default_vat
			end

		end

		describe 'in an ECC partneers country' do
			let(:default_vat_rate)	{ Goxygene::Vat.find_by default_for_ecc: true }
			let(:country)           { Goxygene::Country.where(eec_partner: true).sample }

			it "returns the right VAT" do
				skip # there is no country with this in the database
				assert_not_nil country.default_vat
				assert_equal default_vat_rate, country.default_vat
			end
		end

	end
end
