module BureauConsultant
  module MenuHelper
    def add_active_class(controller, action = nil)
      action ||= action_name
      if controller == controller_name && action == action_name
        'active'
      end
    end
  end
end
