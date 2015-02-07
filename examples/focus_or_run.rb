#!/usr/bin/env ruby
#
# Focus the specified window if it exists, otherwise run the given command.
#

require 'optparse'
require 'i3ipc-ruby'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-n', '--name', true, 'specify name regex') do |regex|
    options[:name] = regex
  end
  opts.on('-w', '--window-class', true, 'specify window-class regex') do |regex|
    options[:class] = regex
  end
  opts.on('-c', '--command', true, 'set command') do |cmd|
    options[:command] = cmd
  end
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

fail OptionParser::MissingArgument unless options[:name] || options[:class]
fail OptionParser::MissingArgument unless options[:command]

i3 = I3ipc::Connection.new

tree = i3.get_tree
windows = tree.leaves.select do |con|
  con.name =~ /#{options[:name]}/ && con.window_class =~ /#{options[:class]}/
end

if windows.empty?
  i3.command "exec #{options[:command]}"
else
  focused = tree.find_focused
  index = windows.find_index { |con| con.id == focused.id } || windows.size
  windows[(index + 1) % windows.size].command 'focus'
end
