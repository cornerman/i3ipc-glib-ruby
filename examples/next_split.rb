#!/usr/bin/env ruby
#
# Focus the next visible (horizontally or vertically split) window, this
# ignores tabbed and stacked containers in the parent.
#

require 'optparse'
require 'i3ipc-ruby'

mode = 'horizontal'
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-v', '--vertical', 'focus next vertical split') do
    mode = 'vertical'
  end
  opts.on_tail('-h', '--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

i3 = I3ipc::Connection.new

curr = i3.get_tree.find_focused
while curr.parent
  nodes = curr.parent.nodes
  split = (curr.parent.orientation == mode && curr.parent.layout =~ /^split/)
  if split && curr.workspace && nodes.size > 1
    index = nodes.find_index { |con| con.id == curr.id }
    nodes[(index + 1) % nodes.size].command 'focus, ' + 'focus child,' * 10
    break
  end

  curr = curr.parent
end
