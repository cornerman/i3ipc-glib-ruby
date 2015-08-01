#!/usr/bin/env ruby
#
# Activate Scroll-Lock LED whenever there is an urgent window
#

require 'i3ipc-glib-ruby'

i3 = I3ipc::Connection.new

i3.on 'workspace::urgent' do |i3, _|
  if i3.get_tree.descendents.find { |con| con.urgent }
    `xset led named "Scroll Lock"`
  else
    `xset -led named "Scroll Lock"`
  end
end

i3.main
