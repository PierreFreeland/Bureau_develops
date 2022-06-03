require "application_system_test_case"
require "goxygene_set_up"

class ConsultantCompetencesTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_competence_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test "Should be show a consultant competence" do
    assert_selector "h4", text: "COMPETENCES DU CONSULTANT"
    assert_selector "li.active", text: "Compétences"
  end

  test "Should upload a document" do
    if has_no_css? 'input[type="file"].consultant-competences-simulation-file'
      find('a[data-target="#income-simulation-items"] i[data-original-title=Ajouter]').click
    end

    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('input[type="file"].consultant-competences-simulation-file').set(file_path)
    click_on "Enregister"
    assert_selector "#income-simulation-items tr.fields:first-child td:first-child", text: "sample_document.pdf"
  end

  test "Should edit and save" do
    select "Expert", from: "consultant[prospecting_data_attributes][0][potential_skill]"
    select "Bonne", from: "consultant[prospecting_data_attributes][0][potential_relevance]"
    select "Signée", from: "consultant[prospecting_data_attributes][0][potential_nearness]"
    find('#consultant_competences').set('Testing')
    select "Développement commercial", from: "consultant[consultant_activity_id]"
    click_on "Enregister"

    assert_selector "#consultant_prospecting_data_attributes_0_potential_skill option[selected='selected']", text: "Expert"
    assert_selector "#consultant_prospecting_data_attributes_0_potential_relevance option[selected='selected']", text: "Bonne"
    assert_selector "#consultant_prospecting_data_attributes_0_potential_nearness option[selected='selected']", text: "Signée"
    assert_input "#consultant_competences", "Testing"
    assert_selector "#consultant_consultant_activity_id option[selected='selected']", text: "Développement commercial"
  end

  test "Should add a Tags of expertise form" do
    consultant_skill = Goxygene::ConsultantSkill.active.last

    page.all('a[href*="#add-resume-item"] i')[0].click
    page.all('select[id*="consultant_skill_id"]').last.find(:option, text: consultant_skill.label).select_option
    click_on "Enregister"
    assert_equal consultant_skill.label, page.all('select[id*="consultant_skill_id"]').last.find("option[value='#{consultant_skill.id}']").text
  end

  test "Should add a Langues parlées of expertise form" do
    language = Goxygene::Language.first
    language_level = Goxygene::LanguageLevel.first

    page.all('a[href*="#add-resume-item"] i')[1].click
    page.all('select[id*="language_id"]').last.find(:option, text: language.label).select_option
    page.all('select[id*="language_level_id"]').last.find(:option, text: language_level.label).select_option
    click_on "Enregister"
    assert_equal language.label, page.all('select[id*="language_id"]').last.find("option[value='#{language.id}']").text
    assert_equal language_level.label, page.all('select[id*="language_level_id"]').last.find("option[value='#{language_level.id}']").text
  end

  test "Should add a experience form" do
    page.all('a[href*="#add-resume-item"] i')[3].click
    find("input[id*='begin_date']").set((Date.today + 15).strftime("%d/%m/%Y"))
    click_on "Enregister"
    assert_equal((Date.today + 15).strftime("%d/%m/%Y"), find("input[id*='begin_date']").value)
  end

  test "Should add a formations form" do
    study_level = Goxygene::StudyLevel.first

    page.all('a[href*="#add-study-item"] i')[0].click
    page.all('select[id*="study_level_id"]').last.find(:option, text: study_level.label).select_option
    click_on "Enregister"
    assert_equal study_level.label, page.all('select[id*="study_level_id"]').last.find("option[value='#{study_level.id}']").text
  end

  test "Should add a mission form" do
    payroll_job_type = Goxygene::PayrollJobType.first
    line_of_business = Goxygene::LineOfBusiness.first

    page.all('a[href*="#add-mission-item"] i')[0].click
    page.all('select[id*="payroll_job_type_id"]').last.find(:option, text: payroll_job_type.label).select_option
    page.all('select[id*="line_of_business_id"]').last.find(:option, text: line_of_business.label).select_option
    click_on "Enregister"
    assert_equal payroll_job_type.label, page.all('select[id*="payroll_job_type_id"]').last.find("option[value='#{payroll_job_type.id}']").text
    assert_equal line_of_business.label, page.all('select[id*="line_of_business_id"]').last.find("option[value='#{line_of_business.id}']").text
  end
end
