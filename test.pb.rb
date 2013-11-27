##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Message Classes
#
class Variety < ::Protobuf::Message
  class Foonum < ::Protobuf::Enum
    define :A, 1
    define :B, 2
  end

end



##
# Message Fields
#
class Variety
  required ::Protobuf::Field::Int32Field, :x, 1
  required ::Protobuf::Field::Int32Field, :y, 2
  optional ::Protobuf::Field::StringField, :tag, 3
end

