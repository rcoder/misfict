require 'drb'
require 'yaml'
require 'forwardable'

require 'post'

class History 
  include DRbUndumped
  include Enumerable 

  extend Forwardable

  def initialize(path)
    @path = path
    @data = load_data
  end

  def load_data
    if File.exists?(@path)
      open(@path) {|fh| YAML.load(fh) }
    else
      []
    end
  end

  def_delegators :@data, :size, :empty?, :each, :append, :<<, :first, :last, :replace, :delete, :pop

  def save_data
    open(@path, 'w') {|fh| YAML.dump(@data, fh) }
  end

  def flush!
    @data.replace([])
  end
end

history = History.new("data/history.yaml")
Thread.new { sleep 300; history.save_data unless history.empty? }

DRb.start_service("druby://localhost:8777", history)

puts "DB server started on #{DRb.uri}"
DRb.thread.join

