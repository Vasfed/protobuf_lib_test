# encoding: utf-8

require 'rubygems'

require 'protocol_buffers'
require 'beefcake'
# require 'protobuf'

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

endTimeRPB = Time.now - startTime
puts "--------------------------------------------------------------"
puts "ruby-protocol-buffers, 1000 serialize iterations: #{endTimeRPB} sec"

#####################################################################
##
## => beefcake
##
#####################################################################

class VarietyBeef
  include Beefcake::Message

  required :x, :int32, 1
  required :y, :int32, 2
  optional :tag, :string, 3

  module Foonum
    A = 1
    B = 2
  end

end

x2 = VarietyBeef.new :x => 1, :y => 2
s = ""

startTime = Time.now

(0...1000).each do |i|
  x2.encode(s)
end

endTimeBeef = Time.now - startTime
puts "beefcake, 1000 serialize iterations: : #{endTimeBeef} sec"


#####################################################################
##
## => protobuf
##
#####################################################################

# class VarietyProto < Protobuf::Message

#   required ::Protobuf::Field::Int32Field, :x, 1
#   required ::Protobuf::Field::Int32Field, :y, 2
#   optional ::Protobuf::Field::StringField, :tag, 3

#   module Foonum
#     A = 1
#     B = 2
#   end

# end

# x3 = VarietyProto.new :x => 1, :y => 2
# s = ""

# startTime = Time.now

# (0...1000).each do |i|
#   x3.serialize_to_string
# end

# endTimeProto = Time.now - startTime
# puts "protobuf, 1000 serialize iterations: : #{endTimeProto} sec"


#####################################################################
##
## => java protobuf jar
##
#####################################################################

require 'java'
require_relative './protobuf-java-2.5.0.jar'
$CLASSPATH << File.join(Dir.pwd,"target")
require 'hash_to_proto_converter'

startTime = Time.now

(0...1000).each do |i|
  proto = Minecart::HashProtoBuilder.hash_to_proto(
    com.liquidm.test::variety,x: 1,y: 2
  )
end

endTimeProto = Time.now - startTime
puts "java protobuf, 1000 serialize iterations: : #{endTimeProto} sec"


#####################################################################
##
## => overall comparison
##
#####################################################################

puts "--------------------------------------------------------------\n"

puts "protobuf - ruby-protocol-buffers: #{((1 - (endTimeProto / endTimeRPB)) * 100).round(3)}% faster"
puts "protobuf - beefcake #{((1 - (endTimeProto / endTimeBeef)) * 100).round(3)}% faster"

puts "--------------------------------------------------------------\n"



