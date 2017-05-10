# Helper functions to control the game's physics

#===============================================================================
# Physics constants
#-------------------------------------------------------------------------------
# These are used to defined a logical space, in a hopefully easier way to think
# about the game's world.
#===============================================================================

# Define the size of a single (virtual) tile, in pixels
const _tile_size = 8.0
# Define the (logical) fps of the game
const _fps = 60.0

#===============================================================================
# Helper functions
#-------------------------------------------------------------------------------
#===============================================================================

# Convert a distance in tiles to pixels
static func tiles_to_pixels(val):
    return val * _tile_size

# Convert a time in frames to seconds (as float)
static func frames_to_sec(frames):
    return frames / _fps

# Return the jump speed in pixels per second, given the time to the appex in
# frames and the jump height in tiles
static func get_jump_speed(timeToAppex, jumpHeight):
    return -2.0 * tiles_to_pixels(jumpHeight) / frames_to_sec(timeToAppex)

# Return the acceleration (i.e., "gravity") of a jump, given the time to the
# appex in frames and the jump height in tiles
static func get_jump_acc(timeToAppex, jumpHeight):
    var t = frames_to_sec(timeToAppex)
    return 2.0 * tiles_to_pixels(jumpHeight) / (t * t)

# Integration function
#
# It's currently implemented using verlet integration:
#    x1 = x0 + v0*dt + 0.5*a0*t*t
#
# It returns the new position and speed as a Vector2
static func integrate(pos, vel, acc, delta):
    pos += vel * delta
    if acc != 0:
        pos += 0.5 * acc * delta * delta
        vel += acc * delta
    return Vector2(pos, vel)

#===============================================================================
# Basic physic class
#-------------------------------------------------------------------------------
# Deals with integrating and storing all the boring/fun stuff
#===============================================================================

class PhysicsAttributes:
    var pos = Vector2(0, 0)
    var vel = Vector2(0, 0)
    var acc = Vector2(0, 0)

    func _init():
        self.pos = Vector2(0, 0)
        self.vel = Vector2(0, 0)
        self.acc = Vector2(0, 0)

    func integrate(cur_pos, delta):
        self.pos = cur_pos + self.vel * delta
        if self.acc.x != 0:
            self.pos.x += 0.5 * self.acc.x * delta * delta
            self.vel.x += self.acc.x * delta
        if self.acc.y != 0:
            self.pos.y += 0.5 * self.acc.y * delta * delta
            self.vel.y += self.acc.y * delta

