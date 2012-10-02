#!/usr/bin/env ruby

require 'mongo'
require 'csv'

posts = CSV.open('posts.csv', 'wb')
comments = CSV.open('comments.csv', 'wb')

posts << [ "PostID", "AuthorID", "AuthorName", "Message" ]
comments << [ "CommentID", "PostID", "AuthorID", "AuthorName", "Message" ]

connection = Mongo::Connection.new
db = connection.db('groupx')
coll = db.collection('posts')
coll.find().each do |post|
  post['message'] ||= ''
  post['message'].gsub!(/\n/, ' ')
  posts << [ post['id'], post['from']['id'], post['from']['name'], post['message'] ]

  post['comments']['data'] ||= []
  post['comments']['data'].each do |comment|
    comment['message'].gsub!(/\n/, ' ')
    comments << [ comment['id'], post['id'], comment['from']['id'], comment['from']['name'], comment['message'] ]
  end
end

comments.close
posts.close

