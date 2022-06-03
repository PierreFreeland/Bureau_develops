module BureauConsultant
  module StatementOfActivitiesHelper
    def vehicle_check
      if current_consultant.vehicle
        "Puissance fiscal : #{current_consultant.vehicle&.vehicle_taxe_weight&.taxe_weigth}. Pour déclarer ou modifier la puissance fiscale de votre véhicule,
         merci d'en adresser la demande à votre correspondant, en joignant la copie du
         certificat d'immatriculation de votre nouveau véhicule."
      else
        "Rappel : Vous ne pourrez déclarer des frais que sur vos jours d'activité"
      end
    end

    def mission_expense_form_action(options)
      if options[:expense_id] && options[:activity_id]
        update_expense_statement_of_activities_path(activity_id: options[:activity_id], expense_id: options[:expense_id])
      else
        update_expense_statement_of_activities_path(activity_id: options[:activity_id])
      end
    end

  end
end
