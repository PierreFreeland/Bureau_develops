require 'test_helper'

describe Goxygene::SynchronizePayrollDataJob do
	let(:consultants_ids) { [8786, 9392, 8388] }
	let(:insee_jobs) {[
    OpenStruct.new(id: "371A", insee_job_code: "371A", label: "Cadre état major grande entreprise"),
    OpenStruct.new(id: "372A", insee_job_code: "372A", label: "Cadres chargés études"),
    OpenStruct.new(id: "372B", insee_job_code: "372B", label: "Cadres organisation ou controle"),
    OpenStruct.new(id: "372C", insee_job_code: "372C", label: "Cadres gestion service personnel"),
    OpenStruct.new(id: "372D", insee_job_code: "372D", label: "Cadres spécialistes de la formation"),
    OpenStruct.new(id: "372E", insee_job_code: "372E", label: "Juristes"),
    OpenStruct.new(id: "372F", insee_job_code: "372F", label: "Cadres document., archivage"),
    OpenStruct.new(id: "373A", insee_job_code: "373A", label: "Cadres serv financ ou compt gde ent"),
    OpenStruct.new(id: "373B", insee_job_code: "373B", label: "Cadres autres services administrat"),
    OpenStruct.new(id: "373C", insee_job_code: "373C", label: "Cadres serv financ ou compt pte ent"),
    OpenStruct.new(id: "373D", insee_job_code: "373D", label: "Cadres autres serv. administratifs"),
    OpenStruct.new(id: "374A", insee_job_code: "374A", label: "Cadres exploit mag vente com détail"),
    OpenStruct.new(id: "374B", insee_job_code: "374B", label: "Chefs prod autres cadres mercatique"),
    OpenStruct.new(id: "374C", insee_job_code: "374C", label: "Cadres comm grde entrp hors détail"),
    OpenStruct.new(id: "374D", insee_job_code: "374D", label: "Cadres comm pte moy entreprises"),
    OpenStruct.new(id: "375A", insee_job_code: "375A", label: "Cadres de la publicité"),
    OpenStruct.new(id: "375B", insee_job_code: "375B", label: "Cadres relat  publiq communication")]}


	describe 'Test of Synchronization with Payroll job' do
		it 'Must been ' do
			skip "Must to be finished"
		end
	end
end
