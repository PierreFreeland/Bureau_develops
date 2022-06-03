require "application_system_test_case"
require "goxygene_set_up"

class ConsultantInsriptionsTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_info_pro_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test 'Should show a information' do
    assert_selector "h4", text: "DOSSIER D’INSCRIPTION"
    assert_selector "li.active", text: "Dossier d'inscription"

    if has_text? "Aucun dossier d'inscription électronique pour ce consultant."
      assert_selector "h4", text: "Aucun dossier d'inscription électronique pour ce consultant."
    else
      assert_selector "th", text: "SITUATION PROFESSIONNELLE"
      assert_selector "th", text: "EMPLOYEUR"
      assert_selector "th", text: "RETRAITE"
      assert_selector "th", text: "INVALIDITÉ, RENTES ET PENSIONS"
    end
  end
end
