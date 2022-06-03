class GoxygeneSetUp < ApplicationSystemTestCase
  setup do
    sign_in cas_authentications(:administrator)
  end
end