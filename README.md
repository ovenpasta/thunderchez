# thunderchez
Libraries for [Chez Scheme](https://github.com/cisco/ChezScheme) productivity

Be sure to put thunderchez path on your library path,

By example:


	(library-directories "/path/to/thunderchez")

or set the CHEZSCHEMELIBDIRS environment variable:
	
	CHEZSCHEMELIBDIRS=/path/to/thunderchez

## SRFI
	
Based on [surfage](https://github.com/dharmatech/surfage/) with minor changes

	(import (srfi s1 lists))
	(import (srfi s13 strings))
	(import (srfi s14 char-sets))
	etc...
	
## Fmt
[Original site](http://synthcode.com/scheme/fmt/)

	(import (fmt fmt)) 
	(import (fmt fmt-c)) 
	(import (fmt fmt-js)) 
	

## Matchable
Based on [matchable egg](http://wiki.call-cc.org/eggref/4/matchable)

	(import (matchable))
  
## Sqlite3
Based partially on chicken [sqlite3 egg](http://wiki.call-cc.org/eggref/4/sqlite3) but slightly different. Needs some testing.

	(import (sqlite3))

## USB
[Library website](http://libusb.info)

	(import (usb))
  
## SDL2

[Library website](http://www.libsdl.org)
  
	(import (sdl2))	

## Cairo
[Library website](http://www.cairographics.org)
  
	(import (cairo))
	
See [test.ss](./cairo/test.ss) for examples

## Json parser
Uses [lalr](./lalr/lalr.ss)

	(import (json))

	(string->json "{ \"name\" : \"my-name\" , \"age\" : 120 , \"children\" : [{ \"name\" : \"my-son\", \"age\" : 1 }, { \"name\" : \"my-son2\", \"age\" : 2 }] }" )
	=> ((name . "my-name")
	    (age . 120)
	    (children .
                    #(((name . "my-son") (age . 1))
                      ((name . "my-son2") (age . 2)))))


## NanoMsg
[Library website](http://www.nanomsg.org)

	(import (nanomsg))

### Some tests from [nanomsg-examples](https://github.com/dysinger/nanomsg-examples)
  * [pipeline](./nanomsg/pipeline)
  * [reqrep](./nanomsg/reqrep)
  * [pair](./nanomsg/pair)
  * [pubsub](./nanomsg/pubsub)
  * [bus](./nanomsg/bus)
  * [survey](./nanomsg/survey)

