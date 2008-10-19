#!/usr/bin/ruby

require 'cgi'
require 'drb'

require 'rubygems'
require 'json'
require 'sinatra'

require 'post'

$history = DRbObject.new(nil, "druby://localhost:8777")

get '/ajax/last' do
  if $history.empty?
    init_post = Post.new
    seeds = File.read('data/seed.txt').split(/\n+===\n+/)
    init_post.text = seeds[rand(seeds.size)]
    init_post.ts = Time.now
    init_post.num = 0
    $history << init_post
  end

  $history.last.to_json
end

post '/ajax/next' do
  p = Post.new
  p.text = CGI.escapeHTML(params[:text])
  p.user = params[:user].gsub(/[^-.\w]/, '')
  p.ts = Time.now
  p.num = $history.size
  $history << p
  $history.save_data

  p.to_json
end

get '/ajax/story' do
  $history.to_a.to_json
end

