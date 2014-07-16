#!/usr/bin/env ruby

require_relative '../lib/i3ipc-ruby.rb'

i3 = I3ipc::Connection.new

i3.on('window::focus') do |x, y|
  puts 'hallo'
  puts x.inspect
  puts y.inspect
end

i3.main
