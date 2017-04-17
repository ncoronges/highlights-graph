require 'bundler/setup'
require 'kindle_highlights'


kindle = KindleHighlights::Client.new(email_address: ENV['login'], password: ENV['password'])
puts "loaded #{kindle.books.length}"

