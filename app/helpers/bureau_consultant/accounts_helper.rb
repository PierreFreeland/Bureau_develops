module BureauConsultant
  module AccountsHelper
    def sort_link_for_accounts(column, text, q_params)
      current_order   = params[:q][:s].to_s.split.last
      current_order ||= 'asc'
      reverse_order   = current_order == 'asc' ? 'desc' : 'asc'

      text_order_hint = case current_order
                        when 'asc'  then '▲'
                        when 'desc' then '▼'
                        end

      link_to(
        params[:q][:s].to_s.split.first == column.to_s ? "#{text} #{text_order_hint}" : text,
        q: q_params.to_unsafe_h.merge(s: "#{column} #{reverse_order}")
      )
    end
  end
end
