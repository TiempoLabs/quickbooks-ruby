module Quickbooks
  module Service
    class CDC < BaseService

    	def url_for_cdc(models, start_time)
	        entities = models.map {|model| model::XML_NODE}.join(',')
	        changedSince = start_time.iso8601
 
	        "#{url_for_base}/cdc?entities=#{entities}&changedSince=#{changedSince}"
      	end

      	def fetch_changes(models, start_time)
	        response = {}
        	get_response = do_http_get(url_for_cdc(models, start_time.iso8601))
          change_responses = @last_response_xml.xpath("//xmlns:IntuitResponse/xmlns:CDCResponse")

          models.each_index do |index|
            model = models[index]
            change_response = change_responses[index]

            response[model::XML_NODE] = parse_collection(response, model, change_response)
          end
	      	
          return response
	    end

    end
  end
end
