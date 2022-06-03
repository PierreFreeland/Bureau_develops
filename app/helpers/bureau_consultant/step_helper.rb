module BureauConsultant
  module StepHelper
    def add_current_step_class(item_number, current_step)
      'class=is-current' if current_step == item_number
    end

    def add_tooltip(step, current_step)
      if step == current_step
        '<i class="fa fa-question-circle question-icon-size m-l-20 text-violet"></i>'
      end
    end

    def add_tooltip_modal(step, current_step, modal_data_target)
      if step == current_step
        '<i class="fa fa-question-circle question-icon-size p-l-20 text-violet wider-area hidden-xs" data-toggle="modal" data-target="' + modal_data_target + '"></i>'
      end
    end

    def add_text_bold(step, current_step)
      'text-bold' if current_step == step
    end

    def add_active_step_class(step, current_step)
      'active' if current_step == step
    end

    def add_future_step(step, current_step)
      'future_step' if current_step < step
    end
  end
end
