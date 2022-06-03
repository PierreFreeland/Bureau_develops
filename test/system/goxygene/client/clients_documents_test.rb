require "application_system_test_case"
require "goxygene_set_up"

class ClientsDocumentsTest < GoxygeneSetUp

  setup do
    visit goxygene.client_documents_path(Goxygene::Customer.first)
  end

  test "Should can upload a file to Accord-cadre" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:first-child td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should can upload a file to Devis" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:nth-child(2) td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should can upload a file to Commande" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:nth-child(3) td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should can upload a file to Avenant" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:nth-child(4) td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should can upload a file to Autre" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:nth-child(5) td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end

  test "Should can upload a file to Autre document client" do
    file_path = File.absolute_path('./test/fixtures/files/sample_document.pdf')
    find('tbody tr:last-child td:last-child input[type="file"]', visible: false).set(file_path)
    sleep 2
    assert_text "sample_document.pdf"
  end
end
