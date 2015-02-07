#!/usr/bin/env ruby
#
# View multiple workspaces on one screen:
#
# Splits the current workspace into two columns and can move the content of
# another workspace (or more) into the right column. The name of each moved
# workspace is stored as a mark, which is why the original workspaces can be
# restored.
#
# Example:
# -Open a window on workspace 1 and 2, focus workspace 1. Then you can view both
# workspaces on workspace 1 with:
#   split_ws.rb -s 2
# -The operation can be reverted by issuing the same command again or you can
# revert all splits with:
#   split_ws.rb -r
#

require 'optparse'
require 'i3ipc-ruby'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} options"
  opts.on('-r', '--restore', 'restore all workspaces') do
    options[:restore] = true
  end
  opts.on('-s WS', '--split WS',
          'split current workspace, move WS into right column (toggle)') do |ws|
    options[:split] = ws
  end
  opts.on_tail('--help', 'show this message') do
    puts opts
    exit
  end
end.parse!

fail OptionParser::MissingArgument unless options[:restore] || options[:split]

COL_MARK = 'col_'
WS_MARK = 'ws_'

def ws_name(con)
  case con.mark
  when  /^#{WS_MARK}/
    ["(#{con.mark.sub(WS_MARK, '')}", ')']
  when /^#{COL_MARK}/
    ['|', '']
  else
    ['', '']
  end.join(con.nodes.reduce('') { |a, e| a + ws_name(e) })
end

i3 = I3ipc::Connection.new

i3.get_workspaces.each do |con|
  i3.command "rename workspace #{con.name} to #{con.name.split(/\|/).first}"
end

if options[:restore]
  i3.get_marks.select { |m| m =~ /^#{WS_MARK}/ }.each do |m|
    num = m.sub(WS_MARK, '')
    i3.command "[con_mark=#{m}] move workspace number #{num}"
    i3.command "unmark #{m}"
  end
end

if options[:split]
  ws = options[:split]

  tree = i3.get_tree
  focused = tree.find_focused
  focused_ws = focused.workspace || focused

  already_split = tree.find_marked("^#{WS_MARK}#{ws}$").map do |con|
    num = con.mark.sub(WS_MARK, '')
    con.command "move workspace number #{num}"
    i3.command "unmark #{con.mark}"
    focused_ws.name == con.workspace.name
  end.reduce(:or)

  target = i3.get_tree.workspaces.find { |w| ws == w.name }
  if !already_split && target && focused_ws.name != target.name
    visible_ws = i3.get_workspaces.select { |con| con.visible }
    focused.command 'fullscreen' if focused.fullscreen_mode

    target.command 'focus, splith, focus child'
    i3.command "mark #{WS_MARK + target.name}"

    i3.command "workspace number #{focused_ws.name}"
    column_mark = COL_MARK + focused_ws.name
    column_con = focused_ws.find_marked(column_mark).first
    if column_con
      column_con.command 'focus, focus child'
    else
      focused_ws.command 'focus, splith'
    end

    target.command 'move workspace current'
    if column_con
      column_con.command 'focus'
    else
      i3.command "[con_mark=^#{WS_MARK}#{ws}$] focus"
      i3.command "splith, layout tabbed, focus parent, mark #{column_mark}"
    end

    visible_ws.each { |w| i3.command "workspace #{w.name}" }
    focused.command 'focus'
  end

  i3.get_tree.workspaces.each do |con|
    con.command "rename workspace #{con.name} to #{con.name + ws_name(con)}"
  end
end
