
echo "remove previous class files..."
rm -rf com
rm -rf target

echo "install necessary gems..."
bundle install

echo "create target/"
mkdir target

echo "compile test.proto..."
protoc --java_out=. test.proto
echo "compile generated java schema to JVM bytecode..."
javac -classpath protobuf-java-2.5.0.jar com/liquidm/Test.java -d target

echo "run benchmark..."
ruby test.rb 