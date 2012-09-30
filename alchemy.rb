#!/usr/bin/env ruby

require 'mongo'
require 'alchemy_api'

AlchemyApi.api_key = '61186f8ca9427f10fa983cfa70d49568e9ce88f9'

connection = Mongo::Connection.new
db = connection.db('groupx')
coll = db.collection('posts')
coll.find({},{limit:5}).each do |post|
  next unless post['message']
  result = AlchemyApi::TermExtraction.get_ranked_keywords_from_text(post['message'], :max_retrieve => 20)
  keywords = {}
  result.keywords.each { |key| keywords[key.text] = key.relevance }
  puts "#{post['from']['name']} #{keywords.to_json}"
end
