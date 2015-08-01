#!/usr/bin/env ruby
#
# Daemon to store the previously focused window
#

require 'socket'
require 'i3ipc-glib-ruby'

Process.daemon true

class History
  attr_reader :last_window

  def current_window=(id)
    @last_window = @current_window
    @current_window = id
  end
end

sock_path = '/tmp/i3_window_back_forth.sock'
i3 = I3ipc::Connection.new

reader, writer = IO.pipe
msg_pid = Process.fork do
  writer.close
  com = History.new

  Thread.new do
    loop do
      id = reader.gets.chomp
      com.current_window = id
    end
  end

  UNIXServer.open(sock_path) do |serv|
    loop do
      s = serv.accept
      id = com.last_window
      begin
        cmd = s.gets.chomp
        case cmd
        when 'focus'
          reply = i3.command "[con_id=#{id}] focus"
          s.puts "focus: #{reply.first.success}"
        else
          s.puts 'error: unknown command'
        end

        s.close
      rescue Errno::EPIPE
        puts 'broken pipe'
      end
    end
  end
end

reader.close
i3.on 'window::focus' do |_, ev|
  writer.puts ev.container.id if ev.change == 'focus'
end

i3.main

Process.kill('HUP', msg_pid)
File.unlink sock_path
