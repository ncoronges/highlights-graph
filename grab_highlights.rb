require 'bundler/setup'
require 'kindle_highlights'
require 'mongo'
require 'yaml'
require 'optparse'

options = YAML.load_file('./opts.yaml')

cmd_opts = {}
OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [cmd_opts]"
    opts.on('-r', '--rebuild', 'Rebuild') do |v| 
      cmd_opts[:rebuild] = v 
    end
end.parse!

p cmd_opts


# script

puts "logging in #{options["amzn_email"]}.."

kindle = KindleHighlights::Client.new(email_address: options["amzn_email"], password: options["amzn_password"])
puts "loaded #{kindle.books.length}"

client = Mongo::Client.new(options["mongo_url"])
puts "connected to mongo"

if (cmd_opts[:rebuild])
    puts "rebuild: clearing collections"
    client[:books].drop
end

collection = client[:books]
collection.indexes.create_one({"asin": 1}, {unique: true})

kindle.books.each do |key, value|
    puts "asin #{key} title #{value}"
    doc = {"asin":key, "title":value, "highlights":kindle.highlights_for(key) }
    result = collection.insert_one(doc)
    result.n
end






