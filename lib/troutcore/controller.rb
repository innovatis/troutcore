module Troutcore
  module Controller

    def fetch
      query_result = Troutcore::SCQLQuery.
        new(params[:data]).
        execute

      render json: jsonify(query_result)
    end

    def retrieveRecords
      ids = Array.wrap(params[:data])
      trout = ids.map { |id|
        Troutcore::Trout.find_by_guid(id)
      }.group_by { |rec|
        rec.class.sc_type_name
      }
      render json: jsonify(trout)
    end

    def commitRecords
      create_records( params[:data][:create])
      update_records( params[:data][:update])
      destroy_records(Array.wrap(params[:data][:destroy]))

      render text: "OK"
    end

    private

    def create_records(data)
      return unless data

    end

    def update_records(data)
      return unless data
      data.each do |i, hash|
        guid = hash.delete(:guid)
        Troutcore::Trout.find_by_guid(guid).update(hash)
      end
    end

    def destroy_records(data)
      return unless data
      data.each do |guid|
        Troutcore::Trout.destroy(guid)
      end
    end

    def jsonify(enum)
      enum.inject({}) { |a, (k, v)|
        a[k] = v.map(&:to_json)
        a
      }
    end

  end
end
