#!/usr/bin/env ruby

require 'mongo'
require 'semantic'

documents = []

connection = Mongo::Connection.new
db = connection.db('groupx')
coll = db.collection('posts')
coll.find({},{:limit => 1000}).each do |post|
  next unless post['message']
  documents << post['message']
end

search = Semantic::Search.new(documents, :transforms => [:TFIDF, :LSA]) 

0.upto(documents.length - 1) do |i|
  related = search.related(i)
  i.upto(documents.length - 1) do |j|
    if i != j && related[j] > 0.8
      puts related[j]
      puts documents[i].gsub(/\n/, ' ')
      puts documents[j].gsub(/\n/, ' ')
      puts
    end
  end
end
