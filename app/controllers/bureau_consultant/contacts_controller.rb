module BureauConsultant
  class ContactsController < BureauConsultant::ApplicationController
    before_action :require_consultant!

    def create
      UserMailer.contact(
        current_consultant.user,
        current_consultant.send(:__getobj__),
        contacts_params[:message]
      ).deliver_later

      head :ok
    end

    private
    def contacts_params
      params.require(:contact).permit(:message)
    end


  end
end
