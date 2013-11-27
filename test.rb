# encoding: utf-8

require 'rubygems'
require 'protocol_buffers'
require 'beefcake'

#####################################################################
##
## => ruby-protocol-buffer
##
#####################################################################

class Variety < ProtocolBuffers::Message

  required :int32, :x, 1
  required :int32, :y, 2
  optional :string, :tag, 3

  module Foonum
    A = 1
    B = 2
  end

end

x1 = Variety.new :x => 1, :y => 2
s = ""

startTime = Time.now

(0...1000).each do |i|
  x1.serialize(s)
end

endTime = Time.now - startTime
puts "ruby-prptocol-buffers: #{endTime}"

#####################################################################
##
## => beefcake
##
#####################################################################

class Variety
  include Beefcake::Message

  required :x, :int32, 1
  required :y, :int32, 2
  optional :tag, :string, 3

  module Foonum
    A = 1
    B = 2
  end

end

x2 = Variety.new :x => 1, :y => 2
s = ""

startTime = Time.now

(0...1000).each do |i|
  x2.encode(s)
end

endTime = Time.now - startTime
puts "beefcake: #{endTime}"



