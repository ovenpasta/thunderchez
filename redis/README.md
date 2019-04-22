# Si, Redis!

This library depends on thunderchez's socket implementation at [thunderchez](https://github.com/ovenpasta/thunderchez)

The version of the library at [Si, Redis!](https://github.com/Silverbeard00/Siredis) is exactly the same but I want to keep them seperate.

Mostly because I think it's cleaner to work on this way, and because I don't feel the name "Si, Redis!" goes with the naming scheme that thunderchez uses.  Although it'd probably be better to do some git magic and just attach thunderchez to the project.

The current library is:  V-0.0.1

Si, Redis! is an extremely simple library.  Only making up about 117 lines of code at the moment.

But I like this, because I find databases interfaces are too opinionated at times.  So why shouldn't we make it simpler?  Well actually there are alot of good reasons but we simply won't think about that right now.  This library should not be viewed as batteries attached,  it is a framework (hopefully a better one in the future) for customizing how you want to deal with redis through a simple interface.

Si, Redis! is extremely easy to use because it's literally just one function.  Si, Redis! is pipelined too.


## Starting up

All you need to start using Si, Redis! is to start up your redis server, and load the library.

In thunderchez you would make sure your path is set

	(library-directories "/path/to/thunderchez")
	(import (redis))
	(redis-init)

And you're all set.  Si, Redis! is based entirely around closures and abusing them to no good end.

Here's the only function.  The typical use of it is in the second line.

	(return-redis-closure ip port)
	(define redis (return-redis-closure ip port))
	
	(define other-redis (return-redis-closure ip-2 port-2)) 
	; To make a closure to a different
	; Redis server

Here are some example uses:

	(redis '(ping)) ;or
	(redis 'ping)

A simple grammar for the redis closure is also very simple:

	(redis cmd) where
	cmd -> Redis Command
	cmd -> '(cmd)0 '(cmd)1 .. '(cmd)n

	(redis 'ping) 		; OK!
	(redis 'ping 'ping) 	; NOT OK!
	(redis '(ping) '(ping)) ; OK!

For instance we can also do:

	(redis '(multi) '(incr foo) '(incr bar) '(exec))

To perform a transaction that increments foo and bar.  Literally all one need do is wrap the redis closure around how they would normally use redis commands.  Si, Redis! will currently return everything as lists, nestled properly according to the way the command was called.

Si, Redis of course is brand new and has lots of work that needs to be done on it.  Namely the parser should probably be rewritten.  Typechecking might lead to performance hits at the amount I'm doing it too.

## GOALS

Si, Redis hopes to support the following features eventually!

+ Proper support of transactions.  (There is almost no error handling at the moment!)
+ Add support for lexicons!  Lexicons would need to be aimed at the two parsing functions.  Essentially what if we want to use our host language functions and by simply wrapping them in the redis closure we are allowed to do things like (make-hashtable) or (hash-map) and have it parsed into proper redis commands.  We could program normally and by simply wrapping or not wrapping the closure around the code blocks we would enable or disable using redis as a backend for our operations.  The challange would be making this easy so we didn't have to make a pseudo interpreter for each lexicon.
+ Add support for automatically returning data in different formats (vectors, lists, hashtables)
+ Add syntactical sugar so we don't have to throw the old '() and ' up everywhere.
+ Fully comment the code as it expands.
