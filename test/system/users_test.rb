require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "visiting the index with guest" do
    skip

    visit bureau_consultant.root_url

    sleep(1)

    assert_selector "input", id: "user_login"
    assert_selector "input", id: "user_pass"
  end

  test "login to User account with wrong password" do
    skip
    visit bureau_consultant.root_url

    sleep(1)

    fill_in "username", with: "hahahahah@hahaha.net"
    fill_in "password", with: "hahahahaha"

    click_on "Se connecter"

    assert_selector "#login_error"
  end

  test "login to User account with right password" do
    skip
    visit bureau_consultant.root_url

    sleep(1)

    fill_in "username", with: "jvau@itg.fr"
    fill_in "password", with: "123456"

    click_on "Se connecter"

    sleep(1)

    assert_selector ".table-responsive"

    click_on "Se déconnecter"
  end

  test "login with User account and pretend to first consultant" do
    skip
    visit bureau_consultant.root_url

    sleep(1)

    fill_in "username", with: "jvau@itg.fr"
    fill_in "password", with: "123456"

    click_on "Se connecter"

    click_link "impersonate"

    assert_selector "a", text: 'Stop impersonating'

    click_on "Stop impersonating"

    click_on "Se déconnecter"
  end


  test "As a Consultant I cannot see the list of other consultants" do
    skip
    visit bureau_consultant.root_url

    sleep(1)

    fill_in "username", with: "jordane.robel_159@consulting-itg.fr"
    fill_in "password", with: "123456"

    click_on "Se connecter"

    visit bureau_consultant.consultants_url

    sleep(1)

    assert_selector "div", id: "greeting", text: "Hello Consultants Jordane Robel"

    click_on "Se déconnecter"
  end

  test "As a Consultant I cannot pretend to be another consultant" do
    skip
    visit bureau_consultant.root_url

    sleep(1)

    fill_in "username", with: "jordane.robel_159@consulting-itg.fr"
    fill_in "password", with: "123456"

    click_on "Se connecter"

    process :post, bureau_consultant.impersonate_user_url(1)

    sleep(1)

    assert_selector "div", id: "greeting", text: "Hello Consultants Jordane Robel"

    click_on "Se déconnecter"
  end

  test "visiting the index with guest in goxygene" do
    skip

    visit goxygene.root_url

    sleep(1)

    assert_selector "input", id: "user_login"
    assert_selector "input", id: "user_pass"
  end

  test "login to User account with wrong password in goxygene" do
    # skip
    visit goxygene.root_url

    sleep(1)

    fill_in "username", with: "hahahahah@hahaha.net"
    fill_in "password", with: "hahahahaha"

    click_on "Connexion"

    assert_selector "span.error",text: "Email ou Mot de Passe incorrect"
  end

  test "login to User account with right password in goxygene" do
    skip
    visit goxygene.root_url

    sleep(1)

    fill_in "username", with: "carolef@itg.fr"
    fill_in "password", with: "123456"

    click_on "Connexion"

    assert_selector "h4", text: 'Bonjour Flak Carole'
  end
end
