module Troutcore
  module Controller

    def fetch
      type_name = params[:data].delete(:recordType)
      type = Troutcore::Model.find_type(type_name)

      scql = Troutcore::SCQLQuery.new(type, params[:data])
      trout = type.find_by_scql(scql)

      render json: trout
    end

    def retrieveRecords
      render json: params[:data]
    end

    def commitRecords
      render json: params[:data]
    end

  end
end
