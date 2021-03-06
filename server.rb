#!/usr/bin/ruby

require 'cgi'
require 'drb'
require 'rss'

require 'rubygems'
require 'json'
require 'sinatra'

require 'post'

$history = DRbObject.new(nil, "druby://localhost:8777")

def is_valid?(text)
  word.size > 2 && !%(test foobar asdf).member?(text) && !text.strip.empty?
end

get '/ajax/last' do
  if $history.empty?
    init_post = Post.new
    seeds = File.read('data/seed.txt').split(/\n+===\n+/)
    init_post.text = seeds[rand(seeds.size)]
    init_post.ts = Time.now
    init_post.num = 0
    $history << init_post
  end

  headers('Content-Type' => 'text/x-json')
  $history.last.to_json
end

post '/ajax/next' do
  curr_sz = $history.size
  seq = params[:num].to_i

  p = Post.new
  text = params[:text]

  if curr_sz == (seq + 1) and is_valid?(text)
    p.text = CGI.escapeHTML(text)
    p.user = params[:user].gsub(/[^-.\w]/, '')
    p.ts = Time.now
    p.num = curr_sz
    $history << p
    $history.save_data
  end
  
  headers('Content-Type' => 'text/x-json')
  p.to_json
end

get '/ajax/story' do
  headers('Content-Type' => 'text/x-json')
  $history.to_a.to_json
end

get '/feed/rss' do
  feed = RSS::Maker.make("2.0") do |rss|
    rss.channel.title = 'misfict'
    rss.channel.link = 'http://rcoder.net/misfict/'
    rss.channel.description = 'micro.serial.fiction'
    recent = $history.recent(10).reverse
    recent.each do |entry|
      item = rss.items.new_item
      item.title = entry.text
      item.date = entry.ts
    end
  end
  headers('Content-Type' => 'application/rss+xml')
  feed.to_s
end

