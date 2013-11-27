# encoding: utf-8
require 'java'

require 'protobuf-java-2.4.1'
$CLASSPATH << File.join(Dir.pwd, "pizza")

require 'hash_to_proto_converter'

proto = Minecart::HashProtoBuilder.hash_to_proto(
    com.pizza.Pizza::Person,
    name: 'Fred',
    email: 'fred@example.com',
    phone: '555 1234'
  )

Minecart::HashProtoBuilder.hash_from_proto(proto)
