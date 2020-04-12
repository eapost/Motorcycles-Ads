#_______oBBBBB8o______oBBBBBBB 
#_____o8BBBBBBBBBBB__BBBBBBBBB8________o88o, 
#___o8BBBBBB**8BBBB__BBBBBBBBBB_____oBBBBBBBo, 
#__oBBBBBBB*___***___BBBBBBBBBB_____BBBBBBBBBBo, 
#_8BBBBBBBBBBooooo___*BBBBBBB8______*BB*_8BBBBBBo, 
#_8BBBBBBBBBBBBBBBB8ooBBBBBBB8___________8BBBBBBB8, 
#__*BBBBBBBBBBBBBBBBBBBBBBBBBB8_o88BB88BBBBBBBBBBBB, 
#____*BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB8, 
#______**8BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB*, 
#___________*BBBBB WELCOME TO REDIS BBBBBBBBBB8*, 
#____________*BBBBBBBBBBBBBBBBBBBBBBBB8888**, 
#_____________BBBBBBBBBBBBBBBBBBBBBBB*, 
#_____________*BBBBBBBBBBBBBBBBBBBBB*, 
#______________*BBBBBBBBBBBBBBBBBB8, 
#_______________*BBBBBBBBBBBBBBBB*, 
#________________8BBBBBBBBBBBBBBB8, 
#_________________8BBBBBBBBBBBBBBBo, 
#__________________BBBBBBBBBBBBBBB8, 
#__________________BBBBBBBBBBBBBBBB,

install.packages("redux")
library("redux")

# Remote Connection
r <- redux::hiredis(
  redux::redis_config(
    host = "redis-18081.c13.us-east-1-3.ec2.cloud.redislabs.com", 
    port = "18081", 
    password = "super_safe_password"))

#Local Connection
r <- redux::hiredis(
  redux::redis_config(
    host = "127.0.0.1", 
    port = "6379"))

# "SET" = Set a simple Key
r$SET("demo","value")

# "GET" = Get a simple Key
r$GET("demo")

# "DEL" = Delete a simple Key
r$DEL("demo")
r$GET("demo") # Check the returned value
typeof(r$GET("demo"))
is.null(r$GET("demo"))

# "SETNX" = Set if key does not exist
r$SET("demo","value1")
r$GET("demo")
r$SET("demo","value2")
r$GET("demo")
r$SETNX("demo","value3")
r$GET("demo")
r$DEL("demo")
r$SETNX("demo","value3")
r$GET("demo")

# "INCR" = Increase Value +1 (New Key)
r$GET("demo_incr")
r$INCR("demo_incr")
r$GET("demo_incr")
r$INCR("demo_incr")
r$GET("demo_incr")

r$SET("demo_incr","-500") # (Pre-set Key)
r$GET("demo_incr")
r$INCR("demo_incr")
r$GET("demo_incr")
r$INCR("demo_incr")
r$GET("demo_incr")

# Conventions! 
# Colon sign (:) is a convention when naming keys. Try to stick with a schema. 
# For instance "object-type:id:field" can be a nice idea, like in "user:1000:password". 
# Some people like to use dots for multi-words fields, like in "comment:1234:reply.to".
# Others like to use a colon (:) as namespace separator and a hash (#) for id-parts of keys, 
# e.g.: logistics:building#23

r$SET("user:1000:username","RedisFan")
r$SET("user:1000:password","Yey!Password!")
r$SET("user:1001:username","MscBAStudent")
r$SET("user:1001:password","Yey!AnotherPassword!")
r$SET("user:1002:username","NumberLover33")
r$SET("user:1002:password","YetAnotherPassword!")

# Could we run a command that will return all the users?
# Using string search on keys is available through the "keys" command. This command should be
# however used only for debugging purpose since it's O(N).

r$KEYS("*")
r$KEYS("user*")
r$KEYS("user:1000*")
r$KEYS("user:*:username")
r$KEYS("user:*:use*")

# "EXPIRE" = Key will be deleted in X seconds
r$SET("unfortunate_key","lived_a_happy_life")
r$GET("unfortunate_key")
r$EXPIRE("unfortunate_key",2)
r$GET("unfortunate_key")
r$GET("random_string") # Non-existing values return null. Check the cli! -> (nil)

# Set and Expire at the same time?

# "TTL" = How much time remaining before expiring?
r$SET("blah_key","blah_value")
r$GET("blah_key")
r$TTL("blah_key") # -1 : will never expire
r$EXPIRE("blah_key",1)
r$TTL("blah_key") # -2 : has expired

r$SET("blah_key","blah_value") # I set my key again
r$GET("blah_key")
r$TTL("blah_key") # -1 : TTL has been reset
r$EXPIRE("blah_key",120)
r$TTL("blah_key") # Positive numbers are the Time-to-Live in Seconds


#########
# LISTS #
#########

r$GET("my_list") # Yes, obviously it's blank
r$RPUSH("my_list","value on the right") # Right Push
r$RPUSH("my_list","value on the right x2") # Right Push
r$RPUSH("my_list","value on the right x3") # Right Push
r$GET("my_list") # Doesn't work!
r$LRANGE("my_list",0,1) # (start / end positions)
r$LRANGE("my_list",0,0)
r$LRANGE("my_list",0,-1) # return everithing

r$LPUSH("my_list","value on the left") # Left Push
r$LRANGE("my_list",0,0)
r$LRANGE("my_list",0,-1)

n <- 3
r$LRANGE("my_list",n,(n+1)) # Return the nth value of the list

# RPUSH -> Put at the end (in terms of LRANGE)
# LPUSH -> Put at the beginning (in terms of LRANGE)

r$LLEN("my_list") # Return the length of the list

r$RPOP("my_list") # Remove AND return the last element (right side)
r$LLEN("my_list")

r$LPOP("my_list") # Remove AND return the last element (left side)
r$LLEN("my_list")
r$LRANGE("my_list",0,-1)

# BRPOP -> Blocks program execution and waits for a message.
r$BRPOP("blocking_list",60)
# BLPOP -> Blocks program execution and waits for a message.
r$BLPOP("blocking_list",60)


########
# SETS #
########

# SETS -> Unordered. Each element only once.

# "SADD" = Add an element to the SET
r$SADD("my_set", "elem1")
# "SMEMBERS" = Returns the elements of the SET
r$SMEMBERS("my_set")
r$SADD("my_set", "elem2")
r$SADD("my_set", "elem3")
r$SADD("my_set", "elem4")
r$SMEMBERS("my_set")
r$SADD("my_set", "elem4") # Cannot add the same thing twice. Check response.
r$SMEMBERS("my_set")

# "SREM" = Removes an element from a SET
r$SREM("my_set","elem4")
r$SMEMBERS("my_set")

# "SISMEMBER" = Checks if member exists in SET. Check Response.
r$SISMEMBER("my_set","elem3")
r$SISMEMBER("my_set","elem4")

# "SRANDMEMBER" = Get a random member from the SET
r$SRANDMEMBER("my_set")

r$SADD("my_other_set", "elem3")
r$SADD("my_other_set", "elem4")
r$SADD("my_other_set", "elem5")
r$SADD("my_other_set", "elem6")
r$SMEMBERS("my_other_set")

# "SUNION" = Union of two sets
r$SUNION(c("my_set", "my_other_set"))

# "SUNIONSTORE" = Union of two sets stored in a new KEY
r$SUNIONSTORE("union_set", c("my_set", "my_other_set"))
r$SMEMBERS("union_set")

# "SINTER" = Intersection of two sets
r$SINTER(c("my_set", "my_other_set"))

# "SINTERSTORE" = Intersection of two sets stored in a new KEY
r$SINTERSTORE("intersection_set", c("my_set", "my_other_set"))
r$SMEMBERS("intersection_set")


###############
# SORTED SETS #
###############

# Sorted Sets are like Sets but with associated scores.

# "ZADD" = Like SADD but with score
r$ZADD("my_sorted_set", "100", "elem1")
r$ZADD("my_sorted_set", "200", "elem2")
r$ZADD("my_sorted_set", "400", "elem4")
r$ZADD("my_sorted_set", "300", "elem3")

# "ZRANGE" = Return all elements from X to Y position sorted ASC 
r$ZRANGE("my_sorted_set", "0", "2")
r$ZRANGE("my_sorted_set", "0", "-1") # Add -1 to get everything back

# "ZREM" = Remove an element from the sorted set. 
r$ZREM("my_sorted_set", "elem3")
r$ZRANGE("my_sorted_set", "0", "-1")


##########
# HASHES #
##########

# HASHES -> Maps between string fields and string values

# "HSET" = Set the value of a key's field
r$HSET("user:1000", "name", "Spiros")
r$HSET("user:1000", "surname", "Safras")
r$HSET("user:1000", "pageviews", "0")

# "HGET" = Get the value of a key's field
r$HGET("user:1000", "surname")

# "HINCRBY" = increase by a "step"
r$HGET("user:1000", "pageviews")
r$HINCRBY("user:1000", "pageviews", 5)
r$HGET("user:1000", "pageviews")

# "HGETALL" = Get all hash values
r$HGETALL("user:1000")

# "HMSET" = Multi-set values. Good for performance. Check all the "M" variations of REDIS functions.
r$HMSET("user:1000", c("city", "country"), c("Nea Makri", "Greece"))
r$HGETALL("user:1000")

# "HDEL" = Delete a field
r$HDEL("user:1000", "country")
r$HGETALL("user:1000")


################
# TRANSACTIONS #
################

r$MULTI()
r$SET("keyA", "v1")
r$SET("keyB", "v2")
r$SET("keyC", "v3")
r$EXEC()


###############################
# System Status / Maintenance #
###############################

# Clear Memory. Everything will be deleted.
r$FLUSHALL()

# Check memory consumption. Consider Optimizing.
r$INFO("memory")

# Function that returns total connected clients
print( active_connections() )

# Function that kills all the connected clients
kill_connections(skip_me="no")

active_connections <- function(){
  tryCatch(
    {
      cl <- r$CLIENT_LIST()
      (nchar(cl) - nchar(gsub("addr","",cl)))/4
    },
    error=function(cond) {
      # Choose a return value in case of error
      0
    }
  )
}

kill_connections <- function(skip_me="yes"){
  tryCatch(
    {
      r$CLIENT_KILL(TYPE="slave",SKIPME=skip_me)
      r$CLIENT_KILL(TYPE="pubsub",SKIPME=skip_me)
      r$CLIENT_KILL(TYPE="normal",SKIPME=skip_me)
    },
    error=function(cond) {
      # Choose a return value in case of error
      0
    }
  )
}