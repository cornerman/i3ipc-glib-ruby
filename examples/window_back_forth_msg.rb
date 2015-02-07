#!/usr/bin/env ruby
#
# Client to communicate with the window_back_forth daemon
#

require 'socket'

sock_path = '/tmp/i3_window_back_forth.sock'

cmd = ARGV.shift || 'focus'

UNIXSocket.open(sock_path) do |s|
    s.puts cmd
    while (get = s.gets)
        puts get
    end
end
