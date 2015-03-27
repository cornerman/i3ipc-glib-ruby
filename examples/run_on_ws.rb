#!/usr/bin/env ruby
#
# Execute the given command whenever the specified workspace is initialized.
#

require 'optparse'
require 'i3ipc-ruby'

settings = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-s', '--set', true, 'set workspace::command action') do |setting|
    split = setting.split(/::/)
    raise 'please provide workspace::command pairs with --set' if (split.size != 2)
    ws = split[0]
    cmd = split[1]
    settings[ws] = cmd
  end
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

i3 = I3ipc::Connection.new

i3.on('workspace::focus') do |i3, ev|
  if settings[ev.current.name] && ev.current.nodes.empty?
    i3.command "exec #{settings[ev.current.name]}"
  end
end

i3.main
