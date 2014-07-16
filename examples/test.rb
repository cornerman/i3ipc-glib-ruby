#!/usr/bin/ruby

require_relative '../lib/i3ipc-ruby.rb'

i3 = I3ipc::Connection.new

puts i3.get_marks.inspect

puts i3.get_tree.get_nodes.inspect
