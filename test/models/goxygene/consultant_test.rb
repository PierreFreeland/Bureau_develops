require 'test_helper'

describe Goxygene::Consultant do
  let(:consultant) { Goxygene::Consultant.find 8786 }
  let(:consultant_8388) { Goxygene::Consultant.find 8388 }
  let(:consultant_18068) { Goxygene::Consultant.find 18068 }
  let(:boulet_182) { Goxygene::Consultant.find 182 }
  let(:correspondant_aveline) { Goxygene::Employee.find 177}
  let(:conseiller_sheron) { Goxygene::Employee.find 304}
  let(:balances)   { OpenStruct.new id: 8786, cash: -19073.42, activity: -8738.56, invoicing: 3135.0 }
  let(:cdd_in_200912) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'RD', starting_date: '2009-12-22T00:00:00.000Z', ending_reason: 'FD', ending_date: '2010-02-28T00:00:00.000Z')}
  let(:cdd_in_201404) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'RD', starting_date: '2013-04-13T00:00:00.000Z', ending_reason: 'FD', ending_date: '2013-04-13T00:00:00.000Z')}
  let(:cdd_in_201403) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'RD', starting_date: '2014-03-15T00:00:00.000Z', ending_reason: 'FD', ending_date: '2014-03-15T00:00:00.000Z')}
  let(:cdd_in_201409) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'RD', starting_date: '2014-09-24T00:00:00.000Z', ending_reason: 'FD', ending_date: '2014-09-24T00:00:00.000Z')}
  let(:cdd_in_201508) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'RD', starting_date: '2015-08-02T00:00:00.000Z', ending_reason: 'FD', ending_date: '2015-08-28T00:00:00.000Z')}
  let(:cdi_in_201509) {OpenStruct.new(contract_type: 'CDI', employee_id: '08388', company_code: 'ITG', starting_reason: 'RI', starting_date: '2015-09-01T00:00:00.000Z', ending_reason: nil, ending_date: nil)}

  let(:payroll_contracts_naima) {[cdd_in_200912, cdd_in_201403, cdd_in_201404, cdd_in_201409, cdd_in_201508, cdi_in_201509]}

  let(:trial_for_201304) {OpenStruct.new(employee_id: '08388', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2013-04-13T00:00:00.000Z', ending_date: '2013-04-13T00:00:00.000Z')}
  let(:trial_for_201403) {OpenStruct.new(employee_id: '08388', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2014-03-15T00:00:00.000Z', ending_date: '2014-03-15T00:00:00.000Z')}
  let(:trial_for_201409) {OpenStruct.new(employee_id: '08388', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2014-09-24T00:00:00.000Z', ending_date: '2014-09-24T00:00:00.000Z')}
  let(:trial_for_201508) {OpenStruct.new(employee_id: '08388', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2015-08-02T00:00:00.000Z', ending_date: '2015-08-05T00:00:00.000Z')}
  let(:trial_for_201509) {OpenStruct.new(employee_id: '08388', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2015-09-01T00:00:00.000Z', ending_date: '2015-09-01T00:00:00.000Z')}


  let(:cdd_in_200912) {OpenStruct.new(contract_type: 'CDD', employee_id: '08388', company_code: 'ITG', starting_reason: 'Contrat durée déterminée', starting_date: '2009-12-22T00:00:00.000Z', ending_reason: 'FD', ending_date: '2010-02-28T00:00:00.000Z')}

  let(:trial_periods_naima) {[trial_for_201304, trial_for_201403, trial_for_201409, trial_for_201508, trial_for_201509] }
  let(:trial_periods) {OpenStruct.new employee_id: "08786", company_code: "ITG_S", trial_type: "ESSA", starting_date: "2010-10-04T00:00:00.000Z", ending_date: "2011-02-03T00:00:00.000Z"}
  let(:trials_boulet) {}

  let(:payroll_contracts) {[OpenStruct.new(contract_type: "CDI", employee_id: "08786", company_code: "ITG_S", starting_reason: "RI", starting_date: "2010-10-04T00:00:00.000Z", ending_reason: "", ending_date: nil)]}

  let(:payroll_contractsfor_18068) {[OpenStruct.new(contract_type: "CDI", employee_id: "18068", company_code: "ITG", starting_reason: "RI", starting_date: "2020-04-01T00:00:00.000Z", ending_reason: "", ending_date: nil)]}

  let(:trial_for_18068_1) {OpenStruct.new(employee_id: '18068', company_code: 'ITG', trial_type: 'ESSA', starting_date: '2020-04-01T00:00:00.000Z', ending_date: '2020-07-29T00:00:00.000Z')}
  let(:trial_for_18068_2) {OpenStruct.new(employee_id: '18068', company_code: 'ITG', trial_type: 'RENO', starting_date: '2020-07-30T00:00:00.000Z', ending_date: '2020-11-26T00:00:00.000Z')}
  let(:trial_periods_for_18068) {[trial_for_18068_1, trial_for_18068_2] }
  let(:first_trial) {Goxygene::EmploymentTrialPeriod.find 18777}
  let(:extend_trial) {Goxygene::EmploymentTrialPeriod.find 18778}

  let(:payroll_contracts_boulet) {[OpenStruct.new(contract_type: "DIC", employee_id: '00182', company_code: 'ITG_S', starting_reason: 'RD', starting_date: '2021-01-01T00:00:00.000Z', ending_reason: 'FD', ending_date: '2021-11-30T00:00:00.000Z', imprecise_term: 11, imprecise_term_periodicity: 'M')]}

  let(:employe) {OpenStruct.new id: "08786", company_code: "ITG_S", establishment_code: "09", name: "Gutkowski", marital_name: "Gutkowski", usual_name: "Gutkowski", firstname: "Drew",
      birthdate: "1977-07-18", birthplace: "Sedan", birth_department: "08", birth_country: "FR", family_state: "K", children_count: 0, nationality: "FR", social_security_number: "1770708409052",
      social_security_key: "47", job_id: "COIN", category_id: "CADR", position: "2.2", coefficient: "130", worker_authorization_id: "", active: "A", hourly_rate: "16.4", is_retired: false,
      is_exempt_of_majoration: false, insee_job_code: "372A", worker_authorization: {number: nil, starting_date: nil, ending_date: nil}, company_healthcare: true, has_not_holidays_bonus: false,
      kind: "H"}

  let(:employe_naima) {OpenStruct.new id: "08388", company_code: "ITG", establishment_code: "01", name: "Beier", marital_name: "Beier", usual_name: "Beier", firstname: "Carey", birthdate: "1983-03-16",
      birthplace: "Chatenay Malabry", birth_department: "92", birth_country: "FR", family_state: "C", children_count: 0, nationality: "FR", social_security_number: "2830392019073", social_security_key: "29",
      job_id: "COGP", category_id: "CADR", position: "3.1", coefficient: "170", worker_authorization_id: "", active: "A", hourly_rate: "27.07", is_retired: false,
      is_exempt_of_majoration: false, insee_job_code: "372A", worker_authorization: {number: nil, starting_date: nil, ending_date: nil}, company_healthcare: true, has_not_holidays_bonus: false,
      kind: "MME"}

  let(:employe_boulet) {OpenStruct.new id: "00182", company_code: "ITG_S", establishment_code: "09", name: "Boulet", marital_name: "Boulet", usual_name: "Boulet", firstname: "Xavier",
      birthdate: "1974-07-18", birthplace: "Paris", birth_department: "75", birth_country: "FR", family_state: "K", children_count: 0, nationality: "FR", social_security_number: "1740775409052",
      social_security_key: "47", job_id: "COIN", category_id: "CADR", position: "2.2", coefficient: "130", worker_authorization_id: "", active: "A", hourly_rate: "16.4", is_retired: false,
      is_exempt_of_majoration: false, insee_job_code: "372A", worker_authorization: {number: nil, starting_date: nil, ending_date: nil}, company_healthcare: true, has_not_holidays_bonus: false,
      kind: "H"}

  let(:data_contact) {OpenStruct.new id: "08786", employee_id: "08786", company_code: "ITG_S", address_line1: "68454 Floretta Light", address_line2: "Apt. 727", address_line3: nil,
      zipcode: "75019", city: "Paris", country: "FR", phone_number_1: "306.869.2345   ", phone_number_2: "306.869.2345   "}

  let(:contact_naima) {OpenStruct.new id: "08388", employee_id: "08388", company_code: "ITG", address_line1: "76394 Nienow Circles", address_line2: "Apt. 776", address_line3: nil,
      zipcode: "31500", city: "Toulouse", country: "FR", phone_number_1: "110.921.2328   ", phone_number_2: "110.921.2328   "}

  let(:contact_boulet) {OpenStruct.new id: "00182", employee_id: "00182", company_code: "ITG_S", address_line1: "6845 Floretta Light", address_line2: "Apt. 72", address_line3: nil,
      zipcode: "75018", city: "Paris", country: "FR", phone_number_1: "306.869.2345   ", phone_number_2: "306.869.2345   "}

  let(:payroll_bank_accounts) {[OpenStruct.new(employee_id: "08786", company_code: "ITG_S", payment_mode: "V", bank: "30002", counter: "00689", account_number: "0000054686N",
      key: "48", iban: "FR5630002006890000054686N48", bic: "CRLYFRPP", domiciliation: "LCL", beneficiary: "Drew Gutkowski", rank: 1)]}

  let(:payroll_bank_naima) {[OpenStruct.new(employee_id: "08388", company_code: "ITG", payment_mode: "V", bank: "30002", counter: "00689", account_number: "0000054686N",
      key: "48", iban: "FR5630002006890000054686N48", bic: "CRLYFRPP", domiciliation: "LCL", beneficiary: "Drew Gutkowski", rank: 1)]}

  let(:payroll_bank_boulet) {[OpenStruct.new(employee_id: "00182", company_code: "ITG_S", payment_mode: "V", bank: "30002", counter: "00689", account_number: "0000054686N",
      key: "48", iban: "FR5630002006890000054686N48", bic: "CRLYFRPP", domiciliation: "LCL", beneficiary: "Xavier BOULET", rank: 1)]}

  describe 'Test of Cumuls calculation' do

    before do
      Rails.cache.clear

	    Accountancy = Minitest::Mock.new

	    Accountancy.expect(:consultant_account_balances, balances, [8786, environment: "FREELAND", clear_cache: true])
	  end

    after { assert_mock Accountancy }

    describe 'disbursements_in_payment' do
    	it 'must been sum of disbursements in process (not in a slip) ' do
    		assert_equal consultant.cumuls.disbursements_in_payment, 5000.00
    	end
    end

    describe 'max_salary' do
    	it 'must been equal to activity balance - all operations expenses and wages (to validate + in processing) / salary multiplier of type of employment contract ' do
    		assert_equal consultant.cumuls.max_salary, -7815.36
    	end
    end

    describe 'estimate_max_salary' do
    	it 'must been equal to activity balance - all operations expenses and wages (to validate + in processing + to process)  / salary multiplier of type of employment contract' do
    		assert_equal consultant.cumuls.estimate_max_salary, -7973.29
    	end
    end

	  describe 'max_advance' do
    	it 'must been equal to activity balance - expenses processing/2 + cash balance - advances in payment' do
    		assert_equal consultant.cumuls.max_advance, -50013.09
    	end
    end

    describe 'estimate_max_advance' do
    	it 'must been equal to activity balance - expenses processing and in process/2 + cash balance - advances in payment' do
    		assert_equal consultant.cumuls.estimate_max_advance, -50133.12
    	end
    end

    describe 'max_expenses' do
    	it 'must been equal to activity balance - expenses processing ' do
    		assert_equal consultant.cumuls.max_expenses, -8738.56
    	end
    end

    describe 'estimate_max_expenses' do
    	it 'must been equal to activity balance - all expenses and wages  ' do
    		assert_equal consultant.cumuls.estimate_max_expenses, -12119.4
    	end
    end

   describe 'expenses_in_payment' do
    	it 'must been equal to sum of total of expenses in payment ' do
    		assert_equal consultant.cumuls.expenses_in_payment, 1570.39
    	end
    end

   describe 'expenses_awaiting' do
    	it 'must been equal to sum of total of expenses in processing and to process' do
    		assert_equal consultant.cumuls.expenses_awaiting, 1810.45
    	end
    end

  end

  describe 'Test of consultant Payroll synchronisation' do
    before do
      Rails.cache.clear

      Payroll = Minitest::Mock.new
      Payroll.expect(:employment_contracts,  payroll_contracts, [employee_id: '08786', company_code: 'ITG_S', clear_cache: true])

      Payroll.expect(:trial_periods,  trial_periods, [employee_id: '08786', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:employee,  employe, ['08786', company_code: 'ITG_S', clear_cache: true])

      Payroll.expect(:personal_coordinates, data_contact, [employee_id: '08786', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:bank_accounts,  payroll_bank_accounts, [employee_id: '08786', company_code: 'ITG_S', clear_cache: true])

      sign_in cas_authentications(:administrator)

      #CasAuthentication.current_cas_authentication.cas_user.employee
      consultant.update_from_payroll
    end

    it 'calls the Payroll API' do
      assert_mock Payroll
    end

    describe 'synchronisation payroll_contracts : begin of the last contract' do
      it  'must been equal to starting_date of last employment_contract ' do
        assert_equal consultant.employment_contracts.last.starting_date.strftime('%Y-%m-%d'), "2010-10-04"
      end
    end

    describe 'synchronisation of consultant data' do
      describe 'Consultant birthdate ' do
        it 'must been equal to the employee birth_date' do
          assert_equal consultant.individual.birth_date.strftime('%Y-%m-%d'), "1977-07-18"
        end
      end
      describe 'contact data of consultant' do
        it 'must been equal to employe address_line2' do
          assert_equal consultant.contact_datum.address_2, data_contact.address_line2
        end
      end
      describe 'Bank account iban' do
        it 'must been equal to payroll_bank_accounts.iban' do
          assert_equal consultant.bank_account.iban, payroll_bank_accounts.first.iban
        end
      end
      describe 'Payment mode' do
        it 'must been equal to transfert(1)' do
          assert_equal consultant.payment_type_id, 2
        end
      end
      describe 'Civility' do
        it 'must been equal to 1 (Monsieur)' do
          assert_equal consultant.civility_id, 1
        end
      end
    end
  end

  describe 'Test of consultant Payroll synchronisation for trial periods' do
    before do
      Rails.cache.clear
      Payroll = Minitest::Mock.new
      Payroll.expect(:employment_contracts,  payroll_contractsfor_18068, [employee_id: '18068', company_code: 'ITG', clear_cache: true])

      Payroll.expect(:trial_periods,  trial_periods_for_18068, [employee_id: '18068', company_code: 'ITG', clear_cache: true])
      sign_in cas_authentications(:administrator)

      consultant_18068.employment_contracts.last.update_from_payroll(payroll_contract: payroll_contractsfor_18068.first, payroll_trial: trial_periods_for_18068)
    end

    describe 'sync first trial period ' do
      it 'the trial date_begin must been equal to trials.starting_date' do
        assert_equal first_trial.starting_date.to_date, trial_for_18068_1.starting_date.to_date
      end
    end
    describe 'sync extention trial period ' do
      it 'the trial end_date must been equal to trials.ending_date' do
        assert_equal extend_trial.ending_date.to_date, trial_for_18068_2.ending_date.to_date
      end
    end

  end

  describe 'Test of consultant Payroll Sage synchronisation' do
    before do
      Rails.cache.clear

      Payroll = Minitest::Mock.new
      Payroll.expect(:employment_contracts, payroll_contracts_naima, [employee_id: '08388', company_code: 'ITG', clear_cache: true])

      Payroll.expect(:employee, employe_naima, ['08388', company_code: 'ITG', clear_cache: true])

      Payroll.expect(:personal_coordinates, contact_naima, [employee_id: '08388', company_code: 'ITG', clear_cache: true])

      Payroll.expect(:trial_periods, trial_periods_naima, [employee_id: '08388', company_code: 'ITG', clear_cache: true])

      Payroll.expect(:bank_accounts, payroll_bank_naima, [employee_id: '08388', company_code: 'ITG', clear_cache: true])


      sign_in cas_authentications(:administrator)

      consultant_8388.update_from_payroll
    end

    it 'calls the Payroll API' do
      assert_mock Payroll
    end

    describe 'synchronisation of consultant data' do
      describe 'Civility' do
        it 'must been equal to 2 (Madame)' do
          assert_equal consultant_8388.civility_id, 2
        end
      end
      describe 'Address line 3' do
        it 'must been equal to Complément adresse' do
          assert_equal consultant_8388.contact_datum.address_3, "Complément adresse"
        end
      end
    end
  end

  describe 'Test of consultant Imprecise Term Contrat synchronisation' do
    before do
      Rails.cache.clear
      Payroll = Minitest::Mock.new
      Payroll.expect(:employment_contracts, payroll_contracts_boulet,[employee_id: '00182', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:employee, employe_boulet, ['00182', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:personal_coordinates, contact_boulet, [employee_id: '00182', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:trial_periods, trials_boulet, [employee_id: '00182', company_code: 'ITG_S', clear_cache: true])
      Payroll.expect(:bank_accounts, payroll_bank_boulet, [employee_id: '00182', company_code: 'ITG_S', clear_cache: true])

      sign_in cas_authentications(:administrator)

      boulet_182.update_from_payroll
    end

    it 'calls the Payroll API' do
      assert_mock Payroll
    end

    describe 'Synchronisation of contrat data' do
      describe 'Imprecise Term duration' do
        it 'must been equal to 11 ' do
          assert_equal boulet_182.employment_contracts.order(:starting_date).last.last_version.imprecise_term_duration, 11
        end
      end
      describe 'Imprecise Term duration' do
        it 'must been equal to 3 ' do
          assert_equal boulet_182.employment_contracts.order(:starting_date).last.last_version.payroll_time_unit_id, 3
        end
      end
      describe 'Imprecise Term duration' do
        it 'must been equal to 2021-11-30 ' do
          assert_equal boulet_182.employment_contracts.order(:starting_date).last.last_version.ending_date.to_date, "2021-11-30".to_date
        end
      end
    end
  end

  describe 'Test consultant manual requests' do
    describe 'query_ca_billings_on_v2' do 
      describe 'For Correspondant' do 
        it 'must been equal to 0' do 
          assert_equal Goxygene::Consultant.query_ca_billings_on_v2(2020, correspondant_aveline), 0
        end 
      end 

      describe 'For Conseiller' do 
        it 'must been equal to 0' do 
          assert_equal Goxygene::Consultant.query_ca_billings_on_v2(2020, conseiller_sheron), 400
        end 
      end 
    end 
  end 
end

