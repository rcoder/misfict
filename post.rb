class Post
  attr_accessor :num, :text, :user, :ts
  def to_json
    {'num' => @num, 'text' => @text, 'user' => @user, 'ts' => @ts}.to_json
  end
end

