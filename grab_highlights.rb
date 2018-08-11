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

kindle = KindleHighlights::Client.new(
    email_address: options["amzn_email"], 
    password: options["amzn_password"]
)
puts "loaded #{kindle.books.length}"
if (kindle.books.length==0)
    puts "no books to load"
    exit
end

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

kindle.books.each { |book|
    puts "asin #{book.asin} title #{book.title} author #{book.author}"
    unless (cmd_opts[:test])
        doc = {"asin":book.asin, "title":book.title, "author":book.author }
        result = books_collection.insert_one(doc)
        result.n
        highlights = kindle.highlights_for(book.asin)
        highlights.each { |highlight|
            doc = {"asin":book.asin, "title":book.title, "author":book.author, "highlight":highlight.text, "location":highlight.location}
            puts "insert highlight for #{book.title} location #{highlight.location}"
            result = highlights_collection.insert_one(doc)
            result.n
        }
    end
}






