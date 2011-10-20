module Troutcore
  module Controller

    def fetch
      render json: Troutcore::SCQLQuery.
        new(params[:data]).
        execute.
        inject({}) { |a, (k,v)|
          a[k] = v.map(&:to_json)
          a
        }
    end

    def retrieveRecords
      ids = Array.wrap(params[:data])
      trout = ids.map { |id|
        Troutcore::Trout.find_by_guid(id)
      }.group_by { |rec|
        rec.class.sc_type_name
      }.inject({}) { |a, (k,v)|
        a[k] = v.map(&:to_json)
        a
      }
      render json: trout
    end

    def commitRecords
      render json: params[:data]
    end

  end
end
