require 'timeout'

module LiveStatus::Client
    # Mind that LiveStatus::Client::UnixSocket and UNIXSocket are two different things... :(
    class UnixSocket
        def initialize socket_path
            @socket_path = socket_path
        end

        def query query_string
            header   = []
            response = []
            timeout(5) do
                client = UNIXSocket.new @socket_path
                client.print query_string
                raise "Cannot connect to socket" if client.eof?
                client.each_line do |line|
                    fields = line.chomp.split ';'
                    if header.empty? 
                        header = fields
                    else
                        response << Hash[*header.zip(fields).flatten]
                    end
                end
            end
            response
        end
    end
end
