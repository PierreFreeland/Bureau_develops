require "application_system_test_case"
require "goxygene_set_up"
require 'api_accountancy'

class ParametersManagementRightGroupConsultantsTest < GoxygeneSetUp

  setup do
    visit goxygene.group_consultants_path
  end

  test "Should show error message when not fill data in create form of group consultant" do
    click_on "Creation d'un groupe de consultants"
    click_on "Enregistrer"

    assert_text "Groupe doit être rempli(e)"
  end

  test "Should create a new group consultant" do
    click_on "Creation d'un groupe de consultants"

    fill_in "accountancy_consultant_group[label]", with: "A Testing Group"

    click_on "Enregistrer"

    sleep 2
    assert_text "A Testing Group"
  end

  test "Should redirect to group consultant page" do
    click_on "Creation d'un groupe de consultants"
    assert_selector "h4", text: "Creation d'un groupe de consultants"
  end

  test "Should sort asc Conseiller de transition prof. when click Conseiller de transition prof." do
    click_on "Conseiller de transition prof."
    assert_selector ".sort_link.asc", text: "CONSEILLER DE TRANSITION PROF. ▲"
  end

  test "Should show filter section" do
    click_on "Filtres"
    assert_selector "label", text: "Que les actifs"
  end

  test "Should show result when filter with A" do
    click_on "Filtres"
    fill_in 'q[label_cont]', with: 'A'
    find('#q_active_eq', visible: false).set(true)

    assert_selector '.inscription-menus li.active', text: 'Groupe de gestion'
  end

  test "Should show edit when click" do
    page.all('.rounded-icons')[0].click
    assert_selector "h4", text: "Éditer le groupe de consultants"
  end

  test "excel export" do
    page.execute_script('$.find(".text-green")[0].click()')
    sleep 2
    full_path = DOWNLOAD_PATH+"/export_users.xlsx"
    assert File.exist?(full_path)
  end
end
