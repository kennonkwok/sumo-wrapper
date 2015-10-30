require 'serverspec'
require 'pathname'

if ENV['OS'] == 'Windows_NT'
  set :backend, :cmd
  # On Windows, set the target host's OS explicitely
  set :os, :family => 'windows'
else
  set :backend, :exec
  set :path, '/sbin:/usr/local/sbin:/usr/sbin:$PATH'
end

def load_properties(properties_filename)
  properties = {}
  File.open(properties_filename, 'r') do |properties_file|
    properties_file.read.each_line do |line|
      line.strip!
      if (line[0] != ?# && line[0] != ?=)
        i = line.index('=')
        if i
          properties[line[0..i - 1].strip] = line[i + 1..-1].strip
        else
          properties[line] = ''
        end
      end
    end
  end
  properties
end
