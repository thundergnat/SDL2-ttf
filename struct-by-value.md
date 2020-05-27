There are a few corners of the Raku NativeCall interface that are not completely
functional.

One which I keep running up against is the inability to pass CStructs by value.

It is rare to pass large CStructs by value; in general, the more common method
is to pass them by reference, which avoids a lot of copying and code
duplication. And indeed, pass CStruct by reference is implemented and works
pretty well in NativeCall. I have been stymied several times though while
looking into implementing library interfaces because it isn't particularly rare
to use pass-by-value for small, static CStructs.

I really want to avoid needing to write C wrappers for the libraries if
possible, for several reasons:

1. My C code sucks. I am not  a programmer by profession, and while I have written C, the people who then needed to use that C code got (justifiably) sad. (And it has been over 15 years since I wrote any serious C code.)

2. I don't want to create more maintenance headaches for myself than strictly
necessary. If I wrap a library, it is now on me to release updated code for
updated libraries. (Also, see above note about the quality of my C code.)

3. It should be possible to do this using libraries Moar (and, one would suspect, Raku) already include.

At one point [User: scovit](http://github.com/scovit) had put in a [pull
request](https://github.com/rakudo/rakudo/pull/2648) for Rakudo to fix this
exact problem. The pull request never got much attention and has subsequently
been closed. Mostly, (it seems,) due to the author being unsatisfied with it than anything else.

And even more of a downer, it only proposed to implement CStruct call-by-value
for libffi. Which, don't get me wrong, is awesome, but is the secondary foreign
function interface used by Moar. The primary interface: dynCall would not use the
same code. (mostly?)

That isn't the end of the world though, the different interface libraries would
almost definitely need to be implemented separately at a low level and have the
calling interface abstracted out.

It appears the dynCall DOES have [a similar CStruct call-by-value routine](https://github.com/MoarVM/dyncall/blob/463573e7aa6ef3a9c361106463fad07c41861af3/dyncall/dyncall_api.c#L150).

So it seems like it should be possible. Documentation is pretty thin so it may
be fiddly to get working. I'm not even sure if it should be implemented at the
Rakudo level, or implemented in Moar (NQP?) and expose the API.

[Here's an example ( SDL2-ttf )](https://github.com/thundergnat/SDL2-ttf) of a library hung up
waiting on this. Pretty much everything works except color handling. In the test script,
I ask for red and green text but end up with pretty much random colors because it
expects pass-by-value but gets a memory location (reference) and incorrectly treats it as
values.

  * * * *

So what's the point of all of this? Yeah I'm whining about stuff that I theoretically
could do myself, but my skill level is suspect at best. What I <em>can</em> do is offer <strike>bribes</strike>, umm...  compensation to a more skilled programmer to make it happen.

So... any parties that are interested in contributing to Raku but wouldn't mind
a little sweetener? I would be willing to put up $200US as a small incentive to
make it a little more palatable.

Yes, I am aware that that is a pitiful amount compared to the time and effort
it will probably take, but it is better than an poke in the eye with a sharp
stick, and is slightly better than nothing at all. And hey, if you were looking
for a way to contribute that someone would appreciate, this isn't a bad place to
look IMO.

What would the "finished" status be? Code in Raku exposing CStruct call-by-value
for NativeCall, accepted by the project leader (jnthn effectively), through the
dynCall interface, that would at a minimum let the above mentioned SDL2-ttf
library pass color CStructs the way the library wants them (by value).

Any takers?
