DB_PID=`cat db.pid`
kill $DB_PID
SRV_PID=`cat server.pid`
kill $SRV_PID

