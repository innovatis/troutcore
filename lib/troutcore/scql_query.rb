module Troutcore
  class SCQLQuery

    def intitialize(trout, hash)
      @trout = trout
      @hash = hash
    end

    def apply_arel(rails_model)
      case @hash[:conditions]
      when "(date >= {startDate}) AND (date <= {endDate})"
        start_date = Time.at(@hash[:parameters][:startDate][:ms])
        end_date   = Time.at(@hash[:parameters][:endDate][:ms])
        rails_model.where('date >= ? AND date <= ?', start_date, end_date)
      when "workspace = true"
        rails_model.where(workspace: true)
      else
        raise "UNSUPPORTED QUERY. ADD IT TO TROUTCORE OR IMPLEMENT A REAL SCQL PARSER."
      end
    end

  end
end
