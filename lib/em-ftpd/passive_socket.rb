module EM::FTPD

  # An eventmachine module for opening a socket for the client to connect
  # to and send a file
  #
  class PassiveSocket < EventMachine::Connection
    include EM::Deferrable
    include BaseSocket
    

    def self.start(host, control_server, ftp_options)

      if ftp_options.is_a?( Hash ) and range = ftp_options[:passive_range_port] and range.is_a?( Range )
        port = range.detect{ |i| system( "netcat localhost #{i} -w 1 -q 0 </dev/null" ) == false }
      end

      EventMachine.start_server(host, port || 0, self) do |conn|
        control_server.datasocket = conn
      end
    end

    # stop the server with signature "sig"
    def self.stop(sig)
      EventMachine.stop_server(sig)
    end

    # return the port the server with signature "sig" is listening on
    #
    def self.get_port(sig)
      Socket.unpack_sockaddr_in( EM.get_sockname( sig ) ).first
    end

    
  end
end
