module BureauConsultant
  module ServiceHelper
    def render_icon_class(solution_number)
      icon = {
        a: 'rocket',
        b: 'arrow-up',
        c: 'meetup',
        d: 'euro',
        e: 'ok-hand'
      }

      "icon-#{icon[solution_number[0].downcase.to_sym]}"
    end

    def render_color_class(solution_number)
      color = {
        a: 'dark-purple',
        b: 'purple',
        c: 'red',
        d: 'orange',
        e: 'yellow',
      }

      color[solution_number[0].downcase.to_sym]
    end
  end
end
