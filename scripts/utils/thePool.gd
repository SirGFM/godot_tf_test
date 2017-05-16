
# So, GDScript says it doesn't like global because of thread safety and yada,
# yada, yada...
#
# I say screw that! Give me my globals!
#
# Seriously, wouldn't a static member variable be much cleaner than this ugly
# mess to make a stupid cache?
#
# Godot could "simply" parse all scripts and add references of static variables
# to an internal list, which map everything to a single instance in memory...
# And magically, the problems with thread safety would disappear!
#
# Yes, I was pissed while I wrote this.

# Required by Godot
extends Node

# Cache of loaded animations. Indexed by the animation's name.
var AnimationCache = {}

