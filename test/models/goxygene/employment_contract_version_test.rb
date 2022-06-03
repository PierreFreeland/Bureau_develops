require 'test_helper'

describe Goxygene::EmploymentContractVersion do
	#t(:consultant) {OpenStruct.new id: "159", establishment_code: "SIEGE", name: "ARNOULD", firstname: "Franck",
  #  email: "mguerin.7@itg.fr", phone: "0033628645440"}

  # = rand(99999).to_s
  #va_matricule = 'test_' + id

  #ntract_id = rand(1..200) + id.to_i

  #ntrat_id_for_cancelation = 0

  #t(:salarie) {OpenStruct.new id: nova_matricule, establishment_code: "SIEGE", name: "TEST_#{id}", firstname: "Prenom_#{id}",
  #email: "livith.taty_#{id}@iprodap.fr", phone: "0033618711327"}

  #gnature_fields_cdi = {
  #                      employee:  { page: 3, llx: 50,  lly: 75,  urx: 292, ury: 99 },
  #                      manager:   { page: 3, llx: 307, lly: 75,  urx: 556, ury: 99 }
  #                    }

  #gnature_fields_cdd_original =   {
  #                                  employee:  { page: 3, llx: 50,  lly: 120, urx: 292, ury: 75 },
  #                                  manager:   { page: 3, llx: 307, lly: 120, urx: 557, ury: 75 }
  #                                }

  #i_pdf_file = "./test/fixtures/files/cdi_without_appendix.pdf"
  #d_original_pdf_file = "./test/fixtures/files/ccd_without_appendix.pdf"

  #scribe 'Test of gem  Novapost integration' do

  #before do
	#  Novapost::Novapost = Minitest::Mock.new
	#end

  #after { assert_mock Novapost::Novapost }

  #describe 'get employee' do
  #  it 'return the employee data' do
  #    Novapost::Novapost.expect(:get_employee,  balances, ['consultant_159'])

  #    response = peopledoc.get_employee 'consultant_159'
  #    cons159 = OpenStruct.new JSON.parse(response)
  #    assert_equal cons159.lastname, consultant.name
  #  end
  #end

  #describe 'create employee  ' do
  #  it 'If OK : return technical_id' do
  #    id = rand(99999).to_s
  #    nova_matricule = 'test_' + id

  #    salarie = OpenStruct.new( id: nova_matricule, establishment_code: "SIEGE", name: "TEST_#{id}", firstname: "Prenom_#{id}",
  #    email: "livith.taty_#{id}@iprodap.fr", phone: "0033618711327")

  #    response = peopledoc.create_or_update_employee(lastname: salarie.name, firstname: salarie.firstname,
  #      email: salarie.email, mobile_phone: salarie.phone, employee_payroll_id: nova_matricule)

  #    employee = OpenStruct.new JSON.parse(response)
  #    assert_equal employee.technical_id, 'consultant_' + nova_matricule
  #  end
  #end

    #describe 'Send CDI contract ' do
    #  it  'The CDI is accepted : return contract_tracking_id' do
    #    id = rand(99999).to_s
    #    nova_matricule = 'test_' + id
#
    #    contract_id = rand(1..200) + id.to_i
#
    #    salarie = OpenStruct.new( id: nova_matricule, establishment_code: "SIEGE", name: "TEST_#{id}", firstname: "Prenom_#{id}",
    #      email: "livith.taty_#{id}@iprodap.fr", phone: "0033618711327")
#
    #    response = peopledoc.create_or_update_employee(lastname: salarie.name, firstname: salarie.firstname,
    #      email: salarie.email, mobile_phone: salarie.phone, employee_payroll_id: nova_matricule)
#
    #    employee = OpenStruct.new JSON.parse(response)
#
    #    response = peopledoc.push_contract_to_signature(contract_version_id: contract_id, employee_payroll_id: nova_matricule, employee_email: salarie.email,
    #      employee_mobile_phone: salarie.phone, pdf_file: cdi_pdf_file, signature_fields: signature_fields_cdi)
#
    #    contrat_to_signe = OpenStruct.new JSON.parse(response)
    #    assert_equal contrat_to_signe.external_id, "contract_tracking_" + contract_id.to_s
    #  end
    #end
#
    #describe 'Send CDD contract ' do
    #  it  'The CDD is accepted : return contract_tracking_id' do
#
    #    id = rand(99999).to_s
    #    nova_matricule = 'test_' + id
#
    #    contract_id = rand(1..200) + id.to_i
#
    #    salarie = OpenStruct.new( id: nova_matricule, establishment_code: "SIEGE", name: "TEST_#{id}", firstname: "Prenom_#{id}",
    #      email: "livith.taty_#{id}@iprodap.fr", phone: "0033618711327")
#
    #    response = peopledoc.create_or_update_employee(lastname: salarie.name, firstname: salarie.firstname,
    #      email: salarie.email, mobile_phone: salarie.phone, employee_payroll_id: nova_matricule)
#
    #    employee = OpenStruct.new JSON.parse(response)
#
    #    response = peopledoc.push_contract_to_signature(contract_version_id: contract_id + 1, employee_payroll_id: nova_matricule, employee_email: salarie.email,
    #      employee_mobile_phone: salarie.phone, pdf_file: cdd_original_pdf_file, signature_fields: signature_fields_cdd_original)
#
    #    contrat_to_signe = OpenStruct.new JSON.parse(response)
    #    assert_equal contrat_to_signe.external_id, "contract_tracking_" + (contract_id + 1).to_s
    #  end
    #end
#
    #describe 'Cancel contract' do
    #  it 'Contrat canceled a contract : return contrat_id ' do
    #    id = rand(99999).to_s
    #    nova_matricule = 'test_' + id
#
    #    contract_id = rand(1..200) + id.to_i
#
    #    salarie = OpenStruct.new( id: nova_matricule, establishment_code: "SIEGE", name: "TEST_#{id}", firstname: "Prenom_#{id}",
    #      email: "livith.taty_#{id}@iprodap.fr", phone: "0033618711327")
#
    #    response = peopledoc.create_or_update_employee(lastname: salarie.name, firstname: salarie.firstname,
    #      email: salarie.email, mobile_phone: salarie.phone, employee_payroll_id: nova_matricule)
#
    #    employee = OpenStruct.new JSON.parse(response)
#
    #    response = peopledoc.push_contract_to_signature(contract_version_id: contract_id + 1, employee_payroll_id: nova_matricule, employee_email: salarie.email,
    #      employee_mobile_phone: salarie.phone, pdf_file: cdd_original_pdf_file, signature_fields: signature_fields_cdd_original)
#
    #    contrat_to_signe = OpenStruct.new JSON.parse(response)
#
    #    response = peopledoc.cancel_signature(contrat_to_signe.id)
    #    canceled_contrat = OpenStruct.new JSON.parse(response)
    #    assert_equal canceled_contrat.id, contrat_to_signe.id
    #  end
    #end
	#end

end
