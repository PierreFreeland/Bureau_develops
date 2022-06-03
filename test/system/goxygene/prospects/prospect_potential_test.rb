require "application_system_test_case"
require "goxygene_set_up"

class ProspectPotentialTest < GoxygeneSetUp

  setup do
    Rails.cache.clear
    visit goxygene.prospect_potential_path(Goxygene::ProspectingDatum.find(5030))
    assert_selector "li.active", text: "POTENTIEL PROSPECT"
  end

  test "Should be show a prospect potential" do
    assert_selector "h4", text: "POTENTIEL PROSPECT"
  end

  test "Should modified a prospect status" do
    page.all('a[href*="statuses/new"]').last.click
    sleep 2
    select "Nouveau", from: "prospecting_datum[prospect_status]"
    find('#modal input[value="Enregistrer"]').click
    sleep 2
    assert_selector 'div.col-xs-7 a[href*="statuses/new"] span', text: "ACTIF - Nouveau"
  end

  test "Should upload a document" do
    if has_no_css? 'input[type="file"][name*="income_simulations"]'
      find('a[href*="#add-resume-item"] i[data-original-title=Ajouter]').click
    end

    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('input[type="file"][name*="income_simulations"]').set(file_path)
    find('input[name*="label"][id*="income_simulations"]').set('sample_document.pdf')
    page.all('input[value="Enregister"]').first.click
    assert_selector "#income-simulation-items tr.fields:first-child td:first-child", text: "sample_document.pdf"
  end

  test "Should Should edit and save" do
    find('#prospecting_datum_consultant_attributes_competences').set('Testing')
    select "Développement commercial", from: "prospecting_datum[consultant_attributes][consultant_activity_id]"
    page.all('input[value="Enregister"]').first.click

    assert_input "#prospecting_datum_consultant_attributes_competences", "Testing"
    assert_selector "#prospecting_datum_consultant_attributes_consultant_activity_id option[selected='selected']", text: "Développement commercial"
  end

  test "Should add a experience form" do
    page.all('a[href*="#add-resume-item"] i')[4].click
    find("input[id*='begin_date']").set((Date.today + 15).strftime("%d/%m/%Y"))
    page.all('input[value="Enregister"]').first.click
    assert_equal((Date.today + 15).strftime("%d/%m/%Y"), find("input[id*='begin_date']").value)
  end

  test "Should add a formations form" do
    study_level = Goxygene::StudyLevel.first
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')

    page.all('a[href*="#add-study-item"] i')[0].click
    page.all('select[id*="study_level_id"]').last.find(:option, text: study_level.label).select_option
    find('input[type="text"][id*="diploma"]').set('sample_document')
    find('input[type="file"][name*="diploma_document"]').set(file_path)
    page.all('input[value="Enregister"]').first.click

    assert_input 'input[type="text"][id*="diploma"]', 'sample_document'
    assert_equal study_level.label, page.all('select[id*="study_level_id"]').last.find("option[value='#{study_level.id}']").text
  end

  test "Should add a mission form" do
    page.all('a[href*="#add-mission-item"] i')[0].click
    find('input[id*="skills"]').set('testing')
    page.all('input[value="Enregister"]').first.click
    assert_input 'input[id*="skills"]', 'testing'
  end
end
