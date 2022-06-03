require "application_system_test_case"
require "goxygene_set_up"

class ParametersDevisesSubTabTest < GoxygeneSetUp

  setup do
    visit goxygene.devises_path
  end

  test "Filter on devise index" do
    click_on "Filtres"
    sleep 2
    fill_in "q_name_cont", with: "US"
    click_on "Rechercher"
    page.all('tr').count > 1
  end

  test "Should open create new devise modal" do
    click_on "Ajouter une devise"
    assert_selector "h4", "Ajouter une devise"
  end

  test "Should have validate error Devise field empty" do
    click_on "Ajouter une devise"
    click_on "Enregistrer"
    assert_text "Devise doit être rempli(e)"
  end

  test "Should have validate error Code ISO field empty" do
    click_on "Ajouter une devise"
    click_on "Enregistrer"
    assert_text "Code ISO doit être rempli(e)"
  end

  test "Should have validate error Symbole field empty" do
    click_on "Ajouter une devise"
    click_on "Enregistrer"
    assert_text "Symbole doit être rempli(e)"
  end

  test "Should have validate error Code ISO format" do
    click_on "Ajouter une devise"
    fill_in "currency_short_name", with: "TEST"
    click_on "Enregistrer"
    assert_text "Le code ISO est trop long (pas plus de 3 caractères)"
  end

  test "Should create new devise" do
    click_on "Ajouter une devise"
    fill_in "currency_name", with: "Thai baht"
    fill_in "currency_short_name", with: "THB"
    fill_in "currency_symbol", with: "฿"
    click_on "Enregistrer"
    assert_text "Thai baht"
  end

  test "Should open edit devise modal" do
    execute_script("$('i.fa-pencil')[1].click()")
    assert_selector "h4", "Éditer la devise"
  end

  test "Should update devise name" do
    execute_script("$('i.fa-pencil')[1].click()")
    fill_in "currency_name", with: "Dollar US new"
    click_on "Enregistrer"
    assert_text "Dollar US new"
  end

  test "Should update devise short name" do
    execute_script("$('i.fa-pencil')[1].click()")
    fill_in "currency_short_name", with: "NEW"
    click_on "Enregistrer"
    assert_text "NEW"
  end

  test "Should update devise symbol" do
    execute_script("$('i.fa-pencil')[1].click()")
    fill_in "currency_symbol", with: "USnew"
    click_on "Enregistrer"
    assert_text "USnew"
  end

  test "Should update devise active" do
    execute_script("$('i.fa-pencil')[1].click()")
    sleep 1
    execute_script("$('#currency_active_0').click()")
    click_on "Enregistrer"
    sleep 1
    assert_equal false, Goxygene::Currency.find(2).active
  end
end
