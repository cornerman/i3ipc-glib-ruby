#!/usr/bin/env ruby
#
# Open a fresh workspace
#

require 'optparse'
require 'i3ipc-ruby'

high = false
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-r', '--reverse', 'prefer a high workspace number') do
    high = true
  end
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

i3 = I3ipc::Connection.new

nums = i3.get_workspaces.map { |ws| ws.num }.sort
free_nums = (1..10).reject { |i| nums.include? i }
target = high ? free_nums.last : free_nums.first
i3.command "workspace number #{target}" if target
