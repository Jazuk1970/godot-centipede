# godot-centipede
A centipede remake in Godot.

My second little project with Godot after attempting a space invader clone.
I've had several attempts at creating a centipede movement routine which can move in sub grid sized elements which proved a little more difficult than I thought. It was easy to get
all "centipods" to check their own paths, but in the event of collisions etc all pods wouldn't necessarily stick together.  If using pure grid co-ordinates interating the movement
from the head backwards was an easy solution but resulted in only grid sized movements. In the end I have settled for a system where the head does all the checking, and at each
direction change the grid location and new direction is sent to the neighbour pod.
Each pod (when not being a head) receives signals from the previous neighbour which sends position and direction data. The pod simply heads in its current direction until the
grid location is reached and then changes direction to the direction sent in the neighbour update. At the point of direction change it too sends an update to its neighbour and this#
iterates through all pods.
Each pod includes: a reference to its previous neighbour, next neighbour. When a pod is hit by a bullet its simply a case of telling the hit pod that its next neighbour should be
converted to a head, and disconnecting the previous neighbours - "next neighbour" reference.

Currently the project uses several Grid Arrays to track the location of muchrooms, and centipods for collision checking rather than using the in built collision checks. This seemed
a little easier to check positions which would be moved to rather than moving, checking and moving back (my inexperience with GODot i guess).

I plan on implementing as best I can most if not all elements that can be percieved in the original, but all coding, design etc is done purely by looking at the arcade original and
videos on youtube etc. so its highly likely i'll miss something.

This is intended purely as a bit of fun, and excerise in using Godot but by all means let me know any thoughts/ideas etc.. of give some advice on better/alternate ways of doing
things.

I'll edit this as and when things get added.

Enjoy!

Jason

