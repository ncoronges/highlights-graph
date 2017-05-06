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
    opts.on('-t', '--test', 'Test only') do |v| 
      cmd_opts[:test] = v 
    end
end.parse!

p cmd_opts


# script

puts "logging in #{options["amzn_email"]}.."

kindle = KindleHighlights::Client.new(email_address: options["amzn_email"], password: options["amzn_password"])
puts "loaded #{kindle.book_items.length}"

client = Mongo::Client.new(options["mongo_url"])
puts "connected to mongo"

if (cmd_opts[:rebuild])
    puts "rebuild: clearing collections"
    client[:books].drop
    client[:highlights].drop
end

books_collection = client[:books]
books_collection.indexes.create_one({"asin": 1}, {unique: true})
highlights_collection = client[:highlights]

kindle.book_items.each do |key, book|
    puts "asin #{key} title #{book[:title]} author #{book[:author]}"
    unless (cmd_opts[:test])
        doc = {"asin":key, "title":book[:title], "author":book[:author] }
        result = books_collection.insert_one(doc)
        result.n
        highlights = kindle.highlights_for(key)
        for highlight in highlights 
            highlight["title"]=book[:title]
            highlight["author"]=book[:author]
            result = highlights_collection.insert_one(highlight)
            result.n
        end
    end
end






