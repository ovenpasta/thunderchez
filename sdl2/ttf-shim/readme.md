Shim to allow ttf functions to load.

Chez can't pass structures through ffi at the moment, but work is being done on it tenatively (https://github.com/cisco/ChezScheme/pull/213).  This shim is quite simple, all it does is define wrapper functions for each of the RENDER functions that SDL_TTF has.  We have to do this because unlike most of the other SDL code I've been going through, these particular functions take the structure as an argument, rather than a pointer to the structure.  All the wrapper functions do is take a pointer through the ffi, and call the function it wraps with the pointer dereferenced.

I have chosen at the moment to name and export these functions with a suffix "STTF_" which stands for "Shimmed TTF".  Operations are the exact same in as you would expect, all you have to do is append the render functions you use in scheme with an "sttf-" instead of "ttf-".  For all non-render functions "ttf-" is still used. (Loading, init).

Currently, there are two library init functions exported so scheme can load the .so, but since I'm linking the shim .so to the sdl_ttf .so it may not be necessary to have both.  Work will be done on this.

To compile the shared library:


gcc -c ttf-shim.c -I/usr/include/SDL2 -D_GNU_SOURCE=1 -D_REENTRANT


gcc ttf-shim.o -shared -o ttfshim.so -L/usr/lib -lSDL2 -lpthread -lSDL2_ttf


I have tested it with some simple cases and it seems to work absolutely fine so far.


One final note on this,  it makes it slightly more complicated to generate new binding using the c2ffi method.  You will have to manually go into the "ttf-functions.ss" file and change all instances of (sdl-color-t) to something harmless like an int.  Work also being done on filtering these out so automatic generation can resume.