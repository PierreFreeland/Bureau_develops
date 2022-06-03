require "application_system_test_case"
require "goxygene_set_up"

class ConsultantDocumentsTest < GoxygeneSetUp

  setup do
    visit goxygene.consultant_documents_path(Goxygene::Consultant.find(8786))
    assert_selector "li.active", text: "CONSULTANT"
  end

  test 'Should show a information' do
    assert_selector "h4", text: "DOCUMENTS"
    assert_selector "li.active", text: "Documents"

    assert_selector "th", text: "DOCUMENTS RECRUTEMENT"
    assert_selector "th", text: "PIÈCE D'IDENTITÉ"
    assert_selector "th", text: "DOCUMENT VÉHICULE"
    assert_selector "th", text: "DOCUMENT DE SANTÉ"
    assert_selector "th", text: "DOC ADMIN"
    assert_selector "th", text: "DÉPLACEMENT ÉTRANGER"
    assert_selector "th", text: "CONTRAT DE TRAVAIL"
    assert_selector "th", text: "AUTRES"
  end

  test 'Should upload a document' do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    page.all('.services-table tbody tr:first-child td:last-child input[type="file"]', visible: false)[0].set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should delete a document" do
    find('a[data-method*="delete"]')
    page.all('td a[data-method="delete"]')[0].click
    page.driver.browser.switch_to.alert.accept
    sleep 2
    assert_no_selector 'td a[data-method="delete]'
  end
end
