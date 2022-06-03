require "application_system_test_case"
require "goxygene_set_up"

class ParametersDocumentationsTest < GoxygeneSetUp

  setup do
    visit goxygene.documentations_path
  end

  test "Should create new documentation" do
    page.find(".fa-plus-circle").click
    execute_script("$('#documentation_state').click()")
    fill_in "documentation_title", with: "Test title"
    click_on "Enregistrer cette documentation"
    if has_css?("a", text: "Fin »")
      click_on "Fin"
      sleep 1
    end

    assert_selector "td", "Test title"
  end

  test "Should redirect to documentation detail page" do
    title = all(".title a").first.text
    all(".title a").first.click
    assert_selector "h4", title
  end

  test "Should update documentation data" do
    all(".title a").first.click
    fill_in "documentation_title", with: "Test update title"
    click_on "Enregistrer cette documentation"

    if has_css?("a", text: "Fin »")
      click_on "Fin"
      sleep 1
    end

    assert_selector "td", "Test update title"
  end

  test "Should update documentation's category" do
    all(".title a").first.click
    category = all('option')[0].text
    select category, from: "documentation_category_ids"
    click_on "Enregistrer cette documentation"

    if has_css?("a", text: "Fin »")
      click_on "Fin"
      sleep 1
    end

    assert_selector "td", category
  end

  test "Should success to upload documentation's file" do
    file_path = File.absolute_path('./test/fixtures/files/sample_image.jpg')
    all(".title a").first.click
    attach_file('documentation[file]', file_path)
    click_on "Enregistrer cette documentation"
    assert_no_selector ".alert-danger"
  end

  test "Should have validate error file format when upload documentation's image" do
    file_path = File.absolute_path('./test/fixtures/files/sample1.pdf')
    all(".title a").first.click
    attach_file('documentation[file]', file_path)
    click_on "Enregistrer cette documentation"
    assert_selector ".alert-danger", "Le fichier doit avoir pour extension jpg, jpeg, gif, png"
  end

  test "Should delete documentation" do
    before = Goxygene::Documentation.count
    all('.destroy').first.click
    assert_equal before-1, Goxygene::Documentation.count
  end


end
