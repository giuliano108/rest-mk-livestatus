require 'livestatus-init'
require 'livestatus/querystring_builder'
require 'livestatus/client'
require 'sinatra/base'
require 'json'

module LiveStatus::Web
    $0 = self.name

    class App < Sinatra::Base  
        configure :production, :development do
            enable :logging
            set    :root, LiveStatus::SinatraRoot
        end

        configure :development do
            require 'sinatra/reloader'
            require 'pp'
            register Sinatra::Reloader
        end   

        post "/livestatus/v1/:query_name" do
            content_type :json
            query = JSON.parse request.body.read
            querystring_builder = LiveStatus::QuerystringBuilder.new query
            validation_errors = querystring_builder.validation_errors
            if validation_errors.empty?
                socket_path = query.has_key?('socket') ? LiveStatus[:sockets][query['socket'].to_sym] : LiveStatus[:sockets][LiveStatus[:default_socket]]
                raise "Can't obtain a socket path" if socket_path.nil?
                socket = LiveStatus::Client::UnixSocket.new socket_path
                socket.query(querystring_builder.build).to_json
            else
                status 400
                body({'error' => validation_errors}.to_json)
            end
        end
    end
end
