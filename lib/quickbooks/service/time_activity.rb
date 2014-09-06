module Quickbooks
  module Service
    class TimeActivity < BaseService
      include ServiceCrud

      def create(time_activity, options = {})
        if (!time_activity)
          return nil
        end

        stringify_date_time(time_activity, 'start_time')
        stringify_date_time(time_activity, 'end_time')

        ServiceCrud.instance_method(:create).bind(self).call(time_activity, options)
      end
      alias :update :create

      def delete(time_activity, options = {})
        delete_by_query_string(time_activity)
      end

      private

        def model
          Quickbooks::Model::TimeActivity
        end
    end
  end
end
