require "application_system_test_case"
require "goxygene_set_up"

class ParametersArticleTopicsTest < GoxygeneSetUp

  setup do
    visit goxygene.article_topics_path
  end

  test "Should create new article topic" do
    page.find(".fa-plus-circle").click
    fill_in "article_topic_name", with: "Test Topic"
    click_on "Enregistrer cette rubrique"

    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", "Test Topic"
  end

  test "Should redirect to article detail page" do
    title = all(".name a").first.text
    all(".name a").first.click
    assert_selector "h4", title
  end

  test "Should update article topic data" do
    all(".name a").first.click
    fill_in "article_topic_name", with: "Test update topic"
    click_on "Enregistrer cette rubrique"

    if has_css?("a", text: "Fin »")
      sleep 1
      click_on "Fin"
    end

    assert_selector "td", "Test update topic"
  end

  test "Should delete article topic" do
    before = Goxygene::ArticleTopic.count
    all('.destroy').first.click
    assert_equal before-1, Goxygene::ArticleTopic.count
  end
end

