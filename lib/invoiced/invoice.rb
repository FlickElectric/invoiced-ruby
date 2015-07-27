module Invoiced
    class Invoice < Object
    	def initialize(client)
    		@client = client
    		@endpoint = '/invoices'
    	end

	    def list(opts={})
	    	@client.request(:get, @endpoint, opts)
	    end

	    def retrieve(id, opts={})
	    	if !id
	    		raise Exception.new("Invalid ID supplied: #{id}")
	    	end

	    	@client.request(:get, @endpoint + "/#{id}", opts)
	    end
	end
end