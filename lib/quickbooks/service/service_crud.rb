module Quickbooks
  module Service
    module ServiceCrud

      def query(object_query = nil, options = {})
        fetch_collection(object_query, model, options)
      end

      def query_all(object_query = nil)
        per_page = 250
        max_pages = 101 # drop out after 25000 results as a fail safe

        page_count = 1
        start_position = 0
        query_complete = false

        results = []

        while (!query_complete && (page_count < max_pages))
          query_response = query(object_query, {:per_page => per_page, :page => page_count})
          results.concat(query_response.entries)
          puts "Page #{page_count}: #{query_response.count}"

          # See if this is the final page
          if (query_response.count < per_page)
            query_complete = true
          end

          # Bump the page count as a fail safe for truly mega sets
          page_count += 1
        end

        return results
      end

      def fetch_by_id(id, options = {})
        url = "#{url_for_resource(model.resource_for_singular)}/#{id}"
        fetch_object(model, url, options)
      end

      def create(entity, options = {})
        raise Quickbooks::InvalidModelException.new(entity.errors.full_messages.join(',')) unless entity.valid?
        xml = entity.to_xml_ns(options)
        response = do_http_post(url_for_resource(model.resource_for_singular), valid_xml_document(xml))
        if response.code.to_i == 200
          model.from_xml(parse_singular_entity_response(model, response.plain_body))
        else
          nil
        end
      end
      alias :update :create

      def delete(entity)
        raise "Not implemented for this Entity"
      end

      def delete_by_query_string(entity, options = {})
        url = "#{url_for_resource(model::REST_RESOURCE)}?operation=delete"

        xml = entity.to_xml_ns(options)
        response = do_http_post(url, valid_xml_document(xml))
        if response.code.to_i == 200
          parse_singular_entity_response_for_delete(model, response.plain_body)
        else
          false
        end
      end
    end
  end
end
