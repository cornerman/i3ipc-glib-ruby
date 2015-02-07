#!/usr/bin/env ruby
#
# Execute the given command whenever the specified workspace is initialized.
#

require 'optparse'
require 'i3ipc-ruby'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-w', '--workspace', true, 'set workspace') do |ws|
    options[:workspace] = ws
  end
  opts.on('-c', '--command', true, 'set command') do |cmd|
    options[:command] = cmd
  end
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

fail OptionParser::MissingArgument unless options[:workspace]
fail OptionParser::MissingArgument unless options[:command]

i3 = I3ipc::Connection.new

i3.on('workspace::focus') do |i3, ev|
  if ev.current.name == options[:workspace] && ev.current.nodes.empty?
    i3.command "exec #{options[:command]}"
  end
end

i3.main
