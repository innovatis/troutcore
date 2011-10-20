module Troutcore
  module Controller

    def fetch
      type_name = params[:data].delete(:recordType)
      type = Troutcore::Trout.find_type(type_name)

      scql = Troutcore::SCQLQuery.new(type, params[:data])

      trout = scql.
        execute.
        inject({}) { |a, (k,v)|
          a[k] = v.map(&:to_json)
          a
        }

      render json: trout
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
