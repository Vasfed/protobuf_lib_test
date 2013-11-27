# encoding: utf-8

require 'rubygems'

require 'protocol_buffers'
require 'beefcake'
require 'protobuf'

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

def x1
  x1 = Variety.new :x => 1, :y => 2
  s = ""

  startTime = Time.now

  (0...1000).each do |i|
    x1.serialize(s)
  end

  endTimeRPB = Time.now - startTime
  puts "--------------------------------------------------------------"
  puts "ruby-protocol-buffers, 1000 serialize iterations: #{endTimeRPB} sec"
  endTimeRPB
end

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

def x2
  x2 = VarietyBeef.new :x => 1, :y => 2
  s = ""

  startTime = Time.now

  (0...1000).each do |i|
    x2.encode(s)
  end

  endTimeBeef = Time.now - startTime
  puts "beefcake, 1000 serialize iterations: : #{endTimeBeef} sec"
  endTimeBeef
end

#####################################################################
##
## => protobuf
##
#####################################################################

class VarietyProto < Protobuf::Message

  required ::Protobuf::Field::Int32Field, :x, 1
  required ::Protobuf::Field::Int32Field, :y, 2
  optional ::Protobuf::Field::StringField, :tag, 3

  module Foonum
    A = 1
    B = 2
  end

end

def x3
  x3 = VarietyProto.new :x => 1, :y => 2
  s = ""

  startTime = Time.now

  (0...1000).each do |i|
    x3.serialize_to_string
  end

  endTimeProto = Time.now - startTime
  puts "protobuf, 1000 serialize iterations: : #{endTimeProto} sec"
  endTimeProto
end

#####################################################################
##
## => java protobuf jar
##
#####################################################################

require 'java'
require_relative './protobuf-java-2.5.0.jar'
$CLASSPATH << File.join(Dir.pwd,"target")
require 'hash_to_proto_converter'

def x4
  startTime = Time.now

  (0...1000).each do |i|
    proto = Minecart::HashProtoBuilder.hash_to_proto(
      com.liquidm.Test::Variety,x: 1,y: 2
    )
  end

  endTimeJavaProto = Time.now - startTime
  puts "java protobuf, 1000 serialize iterations: : #{endTimeJavaProto} sec"
  endTimeJavaProto
end

#####################################################################
##
## => raw java protobuf jar
##
#####################################################################

# variety_builder = com.liquidm.test::variety.newBuilder
# variety_builder.setX(1)
# variety_builder.setY(2)
# variety = variety_builder.build

#####################################################################
##
## => overall comparison
##
#####################################################################

def results x1, x2, x3, x4
  puts "--------------------------------------------------------------\n"

  puts "protobuf - ruby-protocol-buffers: #{((1 - (x3 / x1)) * 100).round(3)}% faster"
  puts "protobuf - beefcake #{((1 - (x3 / x2)) * 100).round(3)}% faster"
  puts "ruby protobuf - java protobuf #{((1 - (x3 / x4)) * 100).round(3)}% faster"

  puts "--------------------------------------------------------------\n"
end

x1 = x2 = x3 = x4 = 0

ITERATIONS = 1000
(0...ITERATIONS).each do |i|  
  x1 += x1(); x2 += x2(); x3 += x3(); x4 += x4();
end 

x1 /= ITERATIONS; x2 /= ITERATIONS; x3 /= ITERATIONS; x4 /= ITERATIONS;

puts "===============================================================\n"
puts "Performance compared to fastest solution"
puts "===============================================================\n"

puts "protobuf - ruby-protocol-buffers: #{((1 - (x3 / x1)) * 100).round(3)}% faster"
puts "protobuf - beefcake #{((1 - (x3 / x2)) * 100).round(3)}% faster"
puts "ruby protobuf - java protobuf #{((1 - (x3 / x4)) * 100).round(3)}% faster"

puts "===============================================================\n"