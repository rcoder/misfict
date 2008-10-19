require 'uri'
require 'drb'

require 'rubygems'
require 'test/spec'
require 'json'

require 'post'

def get(uri)
  Net::HTTP.get(URI.parse(uri))
end

def post(uri, params)
  Net::HTTP.post_form(URI.parse(uri), params).body
end

DB_URI = "druby://localhost:8777"
SERVER_URI = "http://localhost:4567/ajax/"

context "db server" do
  setup do
    DRb.start_service
    @db = DRbObject.new(nil, DB_URI)
  end

  specify "should support array methods" do
    (@db << "foo").last.should.equal "foo"
    @db.empty?.should.be false
    @db.pop
  end
end

context "http server" do
  specify "/last should return a post" do
    res = get(SERVER_URI + 'last')
    entry = JSON.parse(res)
    entry.should.be.an.instance_of(Hash)
    entry["text"].should.not.be.nil
  end

  specify "should accept new posts under /next" do
    res = post(SERVER_URI + "next", { 
      "text" => "It was a dark and stormy night.", 
      "user" => "lennon" 
    })
    entry = JSON.parse(res)
    entry.should.be.an.instance_of(Hash)
    entry["text"].should.not.be.nil
  end

  specify "should return an array of posts from /story" do
    res = JSON.parse(get(SERVER_URI + 'story'))
    res.should.be.an.instance_of(Array)
    res.each do |entry| 
      entry.should.be.an.instance_of(Hash)
      entry["text"].should.not.be.nil
    end
  end
end
