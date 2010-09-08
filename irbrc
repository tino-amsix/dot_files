#!/usr/bin/env ruby

# Symbolic link to this file from ~/.irbrc
# ln -s ~/bin/dot_files/irbrc ~/.irbrc

ARGV.concat ["--readline", "--prompt-mode", "simple"]

require 'rubygems'
require 'irb/completion'
require 'irb/ext/save-history'
require 'map_by_method'
require 'what_methods'
require 'pp'

IRB.conf[:AUTO_INDENT]=true
IRB.conf[:SAVE_HISTORY] = 500
IRB.conf[:HISTORY_FILE] = File.expand_path('~/.irb_history')

def log_to
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.connection_pool.clear_reloadable_connections!
end

alias q exit

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  # ri 'Array#pop'
  # Array.ri
  # Array.ri :pop
  # arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end