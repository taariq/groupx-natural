#!/usr/bin/env ruby

require 'mongo'
require 'ferret'

stopwords = IO.read('stopwords.txt').chomp.split(/\n/)
analyzer = Ferret::Analysis::StandardAnalyzer.new(stopwords)

@users = {}
@keywords = {}
@keyword_id = 1

def process(keyword)
  keyword.sub!(/\/.*/, '') # strip the location off uris
  keyword.sub!(/^(.+\.)?(.+)\..+$/, '\2') # extract the domain
  return if keyword.length == 1 # reject single digits
  return if keyword =~ /[@\d]/ # reject numbers or email
  unless @keywords[keyword]
    @keywords[keyword] = @keyword_id
    @keyword_id += 1
  end
  @keywords[keyword]
end

connection = Mongo::Connection.new
db = connection.db('groupx')
coll = db.collection('posts')
coll.find().each do |post|
  next unless post['message']
  @users[post['from']['id']] = post['from']['name']

  ts = analyzer.token_stream(:post, post['message'])
  while( token = ts.next ) do
    if id = process(token.text)
      puts "#{post['from']['id']},#{id}"
    end
  end
  post['comments']['data'] ||= []
  post['comments']['data'].each do |comment|
    @users[comment['from']['id']] = comment['from']['name']

    ts = analyzer.token_stream(:comment, comment['message'])
    while( token = ts.next ) do
      if id = process(token.text)
        puts "#{comment['from']['id']},#{id}"
      end
    end
  end
end

File.open('keywords.csv', 'w') do |file|
  @keywords.each do |key, value|
    file.puts "#{value},#{key}"
  end
end

File.open('users.csv', 'w') do |file|
  @users.each do |key, value|
    file.puts "#{value},#{key}"
  end
end
