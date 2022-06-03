require "application_system_test_case"
require "goxygene_set_up"

class ParametersArticlesTest < GoxygeneSetUp

  setup do
    visit goxygene.articles_path
  end

  test "Should redirect to article detail page" do
    title = all(".title a").first.text
    all(".title a").first.click
    assert_selector "h4", title
  end

  test "Should update article data" do
    all(".title a").first.click
    fill_in "article_title", with: "Test update title"
    click_on "Enregistrer cet article"

    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", "Test update title"
  end

  test "Should success to upload article's image" do
    file_path = File.absolute_path('./test/fixtures/files/sample_image.jpg')
    all(".title a").first.click
    attach_file('article[image]', file_path)
    click_on "Enregistrer cet article"
    assert_no_selector ".alert-danger"
  end

  test "Should have validate error file format when upload article's image" do
    file_path = File.absolute_path('./test/fixtures/files/sample1.pdf')
    all(".title a").first.click
    attach_file('article[image]', file_path)
    click_on "Enregistrer cet article"
    assert_selector ".alert-danger", "Image doit avoir pour extension jpg, jpeg, gif, png"
  end

  test "Should update topic of article" do
    all(".title a").first.click
    topic = all('option')[0].text
    select topic, from: "article_topic_ids"
    click_on "Enregistrer cet article"

    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", topic
  end

  test "Should create new active article" do
    page.find(".fa-plus-circle").click
    execute_script("$('#article_state').prop('checked', true)")
    fill_in "article_title", with: "Test"
    click_on "Enregistrer cet article"

    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", "Test"
  end

  test "Should delete article" do
    before = Goxygene::Article.count
    all('.destroy').first.click
    assert_equal before-1, Goxygene::Article.count
  end
end
