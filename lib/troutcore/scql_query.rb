module Troutcore
  class SCQLQuery

    def initialize(trout, hash)
      @trout = trout
      @hash = hash
    end

    def execute
      initial_results = {@trout => fetch_with_query_conditions(@hash)}
      raise initial_results.inspect
      recursively_include_fields(initial_results)
    end

    private

    # results :: {recordtype => [recordset], ...}
    def recursively_include_fields(results, previous_count = records_in_result_set(results))
      results.keys.each do |recordtype|
        recordtype.default_include_attributes.each do |attr|
          # desctructive operation on `results`.
          include_association_in_result_set!(results, attr, results[recordtype])
        end
      end
      if previous_count == (count = records_in_result_set(results))
        results
      else
        recursively_include_fields(results, count)
      end
    end

    def records_in_result_set(results)
      results.inject(0) { |a, (_, v)|
        a + v.size
      }
    end

    def include_association_in_result_set!(results, attr, recordset)
      guids_to_include = recordset.map { |rec|
        rec[attr.name]
      }.flatten
      type = Troutcore::Trout.type_from_guid(guids_to_include.first)
      results[type] ||= []
      results[type] |= guids_to_include
    end

    def fetch_with_query_conditions(query_hash)
      case query_hash[:conditions]
      when "(date >= {startDate}) AND (date <= {endDate})"
        hardcoded_date_query(query_hash)
      when "workspace = true"
        hardcoded_workspace_query(query_hash)
      else
        raise "UNSUPPORTED QUERY. ADD IT TO TROUTCORE OR IMPLEMENT A REAL SCQL PARSER: #{@hash[:conditions]}"
      end
    end

    def hardcoded_date_query(query_hash)
      start_date = Time.at(query_hash[:parameters][:startDate][:ms].to_i/1000).utc.beginning_of_day
      end_date   = Time.at(query_hash[:parameters][:endDate][:ms].to_i/1000).utc.beginning_of_day

      dates = []
      curr = start_date
      until curr > end_date
        dates << curr
        curr += 1.day
      end
      dates.map { |a| @trout.new(a) }
    end

    def hardcoded_workspace_query(query_hash)
      @trout.get_rails_model.where(workspace: true).map { |a| @trout.new(a) }
    end

  end
end
