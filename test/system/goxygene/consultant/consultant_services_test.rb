require "application_system_test_case"
require "goxygene_set_up"

class ConsultantServicesTest < GoxygeneSetUp
  setup do
    visit goxygene.consultant_services_path(Goxygene::Consultant.find(8786))
    assert_selector "h4", "PARCOURS & SERVICES"
  end

  test "Should show templete email in table violet" do
    length = find(".table-violet tbody").all("tr").count

    for i in 1..length
      label = find(".table-violet tbody").all("tr")[i - 1].all("td")[0].text
      # fill_in "consultant[comment]", with: label
      within ".table-violet" do
        all(".fa-envelope")[i].click
      end

      assert_selector ".modal h4", "Envoyer un email"
      assert_selector "p", "Vous trouverez ci-joint la fiche service #{label}."

      fill_in "personal_message", with: "test"
      sleep 2
      click_on "Annuler"
    end
  end

  test "Should show templete email in table dark red" do
    length = find(".table-dark-red tbody").all("tr").count

    for i in 1..length
      label = find(".table-dark-red tbody").all("tr")[i - 1].all("td")[0].text
      # fill_in "consultant[comment]", with: label
      within ".table-dark-red" do
        all(".fa-envelope")[i].click
      end

      assert_selector ".modal h4", "Envoyer un email"
      assert_selector "p", "Vous trouverez ci-joint la fiche service #{label}."

      fill_in "personal_message", with: "test"
      sleep 2
      click_on "Annuler"
    end
  end

  test "Should show templete email in table dark orange" do
    length = find(".table-dark-orange tbody").all("tr").count

    for i in 1..length
      label = find(".table-dark-orange tbody").all("tr")[i - 1].all("td")[0].text
      # fill_in "consultant[comment]", with: label
      within ".table-dark-orange" do
        all(".fa-envelope")[i].click
      end

      assert_selector ".modal h4", "Envoyer un email"
      assert_selector "p", "Vous trouverez ci-joint la fiche service #{label}."

      fill_in "personal_message", with: "test"
      sleep 2
      click_on "Annuler"
    end
  end

  test "Should show templete email in table orange" do
    length = find(".table-orange tbody").all("tr").count

    for i in 1..length
      label = find(".table-orange tbody").all("tr")[i - 1].all("td")[0].text
      # fill_in "consultant[comment]", with: label
      within ".table-orange" do
        all(".fa-envelope")[i].click
      end

      assert_selector ".modal h4", "Envoyer un email"
      assert_selector "p", "Vous trouverez ci-joint la fiche service #{label}."

      fill_in "personal_message", with: "test"
      sleep 2
      click_on "Annuler"
    end
  end
end