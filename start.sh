/usr/bin/env ruby ./db.rb &
echo "$!" > db.pid
/usr/bin/env ruby ./server.rb -p 4568 &
echo "$!" > server.pid

