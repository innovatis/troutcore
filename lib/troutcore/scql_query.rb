module Troutcore
  class SCQLQuery

    attr_reader :record_type, :conditions, :parameters
    def initialize(query)
      @record_type = query.delete(:recordType)
      @conditions  = query.delete(:conditions)
      @parameters  = query.delete(:parameters)
    end

    def trout
      Troutcore::Trout.find_type(record_type)
    end

    def execute
      results = initial_result_set
      additional = []
      trout.default_include_attributes.each do |attr|
        guids = results.map do |rec|
          rec.generate_attribute(attr.name)
        end.flatten.compact
        additional.concat Troutcore::Trout.find_all_by_guids(*guids)
      end

      (results + additional).group_by { |rec| rec.class.sc_type_name }
    end

    private

    def initial_result_set
      case conditions
      when "(date >= {startDate}) AND (date <= {endDate})"
        hardcoded_date_query
      when "workspace = true"
        hardcoded_workspace_query
      else
        raise "UNSUPPORTED QUERY"
      end
    end

    def hardcoded_date_query
      start_date = Time.at(parameters[:startDate][:ms].to_i/1000).utc.beginning_of_day
      end_date   = Time.at(parameters[:endDate][:ms].to_i/1000).utc.beginning_of_day

      dates = []
      curr = start_date
      until curr > end_date
        dates << curr
        curr += 1.day
      end
      dates.map { |a| trout.new(a) }
    end

    def hardcoded_workspace_query
      trout.get_rails_model.where(workspace: true).map { |a| trout.new(a) }
    end

  end
end
