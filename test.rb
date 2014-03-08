#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'benchmark'


class BenchmarkBase

  attr_accessor :serialize_result
  attr_accessor :deserialize_result

  def initialize
    reset_results!
  end

  def name
    self.class.name.gsub(/Benchmark$/, "")
  end

  def reset_results!
    @serialize_result = 0
    @deserialize_result = 0
  end

  def self.inherited cls
    self.benchmarks << cls
  end

  def self.benchmarks
    @@benchmarks ||= []
  end

  def available?
    @available ||= true
  end

  def not_available!
    @available = false
  end

  def prepare!
    raise "Not available" unless available?
  end

  def create_object
    @klass.new :x => 1, :y => 2
  end

  def serialize iterations=1000, obj=create_object
  end

  def deserialize iterations=1000, buffer=serialize(1)
  end
end

#####################################################################
##
## => ruby-protocol-buffer
##
#####################################################################

class ProtocolBuffersBenchmark < BenchmarkBase

  def prepare!
    require 'protocol_buffers'

    @klass = Class.new(ProtocolBuffers::Message) do
      required :int32, :x, 1
      required :int32, :y, 2
      optional :string, :tag, 3
    end
  rescue
    not_available!
    raise
  end

  def serialize iterations=1000, obj=create_object
    res = nil
    iterations.times{
      res = obj.serialize_to_string
    }
    res
  end

  def deserialize iterations=1000, buffer=serialize(1)
    obj = nil
    iterations.times{
      obj = @klass.parse(buffer)
    }
    obj
  end

end

#####################################################################
##
## => beefcake
##
#####################################################################

class BeefcakeBenchmark < BenchmarkBase

  def prepare!
    require 'beefcake'

    @klass = Class.new do
      include Beefcake::Message

      #FIXME: beefcake throws validation error over its own output...

      # required :x, :int32, 1
      # required :y, :int32, 2
      optional :x, :int32, 1
      optional :y, :int32, 2
      optional :tag, :string, 3
    end
  rescue
    not_available!
    raise
  end

  def serialize iterations=1000, obj=create_object
    res = nil
    iterations.times{
      res = obj.encode
    }
    res
  end

  def deserialize iterations=1000, buffer=serialize(1)
    obj = nil
    iterations.times{
      obj = @klass.decode(buffer)
    }
    obj
  end

end


#####################################################################
##
## => protobuf
##
#####################################################################
class ProtobufBenchmark < BenchmarkBase

  def prepare!
    require 'protobuf'

    @klass = Class.new(Protobuf::Message) do
      required ::Protobuf::Field::Int32Field, :x, 1
      required ::Protobuf::Field::Int32Field, :y, 2
      optional ::Protobuf::Field::StringField, :tag, 3
    end
  rescue
    not_available!
    raise
  end

  def serialize iterations=1000, obj=create_object
    res = nil
    iterations.times{
      res = obj.serialize_to_string
    }
    res
  end

  def deserialize iterations=1000, buffer=serialize(1)
    obj = nil
    iterations.times{
      obj = @klass.new.parse_from_string(buffer)
    }
    obj
  end

end


#####################################################################
##
## => java protobuf jar
##
#####################################################################
class JavaProtobufBenchmark < BenchmarkBase

  def prepare!
    require 'java'
    require_relative './protobuf-java-2.5.0.jar'
    $CLASSPATH << File.join(Dir.pwd,"target")
    require 'hash_to_proto_converter'
  rescue
    not_available!
    raise
  end

  def available?
    RUBY_PLATFORM == "java"
  end

  if RUBY_PLATFORM == "java"
    def serialize iterations=1000, obj=create_object
      string = ""
      #FIXME: some sane test for java?
      iterations.times{
        proto = Minecart::HashProtoBuilder.hash_to_proto(
          com.liquidm.Test::Variety,x: 1,y: 2
        )
      }
      string
    end

    def deserialize iterations=1000, buffer=serialize(1)
      obj = nil
      iterations.times{
        raise "NotImplemented"
      }
      obj
    end
  end

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


bms = BenchmarkBase.benchmarks.map{|b| b.new }.select{|b|
  b.available? && b.prepare!
  unless b.available?
    puts "#{b.name} not available"
  else
    true
  end
}


serialize_objs = bms.map &:create_object


iterations = 100
iterations.times do |i|
  bms.each_with_index{|b,i|
    sub_iterations = 1000
    b.serialize_result += Benchmark.realtime{
      b.serialize sub_iterations, serialize_objs[i]
    }
  }
end
serialize_objs = nil


deserialize_objs = bms.map{|b|
  o = b.serialize(1).to_s
  puts "#{b.name}: #{o.inspect}"
  o
}


iterations = 100
iterations.times do |i|
  bms.each_with_index{|b,i|
    sub_iterations = 1000
    b.deserialize_result += Benchmark.realtime{
      b.deserialize sub_iterations, deserialize_objs[i]
    }
  }
end
deserialize_objs = nil


def print_results bms, metric
  res = bms.sort_by{|b|b.send metric}
  first_res = res.first.send(metric)
  res.each{|b|
    comparison = ""
    current_res = b.send(metric)
    unless b == res.first
      comparison = ", #{(current_res/first_res * 100 - 100).round(3)}% slower" unless first_res == 0
    end
    puts "  #{'%15.15s' % b.name}: #{b.send(metric).round(3)} sec#{comparison}"
  }
end

puts "===============================================================\n"
puts "Performance compared to fastest solution, #{iterations} iteration cycles"
puts "===============================================================\n"
puts "Total ellapsed time, serialization: "
print_results bms, :serialize_result
puts
puts "Total ellapsed time, deserialization: "
print_results bms, :deserialize_result

puts "===============================================================\n"
