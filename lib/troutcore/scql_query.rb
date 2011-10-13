module Troutcore
  class SCQLQuery

    def initialize(trout, hash)
      @trout = trout
      @hash = hash
    end

    def apply_arel(rails_model)
      case @hash[:conditions]
      when "(date >= {startDate}) AND (date <= {endDate})"
        start_date = Time.at(@hash[:parameters][:startDate][:ms].to_i/1000).utc.beginning_of_day
        end_date   = Time.at(@hash[:parameters][:endDate][:ms].to_i/1000).utc.beginning_of_day

        dates = []
        curr = start_date
        until curr > end_date
          dates << curr
          curr += 1.day
        end
        dates
      when "workspace = true"
        @trout.get_rails_model.where(workspace: true)
      else
        raise "UNSUPPORTED QUERY. ADD IT TO TROUTCORE OR IMPLEMENT A REAL SCQL PARSER: #{@hash[:conditions]}"
      end
    end

  end
end
