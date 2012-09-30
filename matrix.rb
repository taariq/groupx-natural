#!/usr/bin/env ruby

keywords = []
uniques = {}

IO.foreach('ferret.csv') do |line|
  fields = line.chomp.split(/,/)
  uniques[fields[0]] = true
  users = keywords[fields[1].to_i] ||= {}
  users[fields[0]] = users[fields[0]].to_i + 1
end

keys = uniques.keys
puts "KeywordID,#{keys.join(',')}"

keywords.each_with_index do |keyword, i|
  next unless keyword
  print "#{i}"
  keys.each do |key|
    print ",#{keyword[key] || 0}"
  end
  puts
end
