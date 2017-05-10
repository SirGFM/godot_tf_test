extends KinematicBody2D

# Slight hack to import another script...
const Physics = preload("res://scripts/physics.gd")

#===============================================================================
# Public variables (visible on the editor)
#-------------------------------------------------------------------------------

# Horizontal speed, in tiles per second
export(float) var speed = 8
# Time, in frames, to reach the jump's appeax
export(int) var jump_time = 20
# Time, in frames, to fall from the jump's appeax
export(int) var fall_time = 15
# Jump height, in tiles
export(float) var jump_height = 4.5

#===============================================================================
# Private variables (hidden)
#-------------------------------------------------------------------------------

# Actual move speed, in pixels per second
var _speed = 0.0
# Actual jump speed, in pixels per second
var _jump_speed = 0.0
# Actual jump acceleration, in pixels per seconds squared
var _jump_acceleration = 0.0
# Actual fall acceleration, in pixels per seconds squared
var _fall_acceleration = 0.0

var attr = Physics.PhysicsAttributes.new()

var _was_jump_pressed = false

# Called every time the node is added to the scene.
func _ready():
    # Enable per-frame update
    self.set_fixed_process(true)
    # Calculate physics constants
    self._speed = Physics.tiles_to_pixels(self.speed)
    self._jump_speed = Physics.get_jump_speed(self.jump_time, self.jump_height)
    self._jump_acceleration = Physics.get_jump_acc(self.jump_time, self.jump_height)
    self._fall_acceleration = Physics.get_jump_acc(self.fall_time, self.jump_height)
    # Set initial state to falling
    self.attr.acc.y = _fall_acceleration

# Called every frame
func _fixed_process(delta):
    # Update horizontal movement
    if Input.is_action_pressed("move_right"):
        self.attr.vel.x = self._speed
    elif Input.is_action_pressed("move_left"):
        self.attr.vel.x = -self._speed
    else:
        self.attr.vel.x = 0.0

    # Integrate the position. It had to be done separately for each axis so
    # getting stuck on a axis don't mess with movement on the other
    self.attr.integrate(self.get_pos(), delta)
    self.move_to(Vector2(self.attr.pos.x, self.get_pos().y))
    var rem = self.move_to(Vector2(self.get_pos().x, self.attr.pos.y))

    if rem.y > 0:
        # If there was a positive vertical remainder, we touched a floor
        if self._was_jump_pressed && Input.is_action_pressed("jump"):
            self.attr.vel.y = self._jump_speed
            self.attr.acc.y = self._jump_acceleration
        else:
            self.attr.vel.y = 0.0
            self.attr.acc.y = self._fall_acceleration
    elif rem.y < 0:
        # If there was a negative vertical remainder, we touched a ceiling
        self.attr.vel.y = 0.0
        self.attr.acc.y = self._fall_acceleration
    else:
        # Simply falling
        self.attr.acc.y = self._fall_acceleration

    _was_jump_pressed = Input.is_action_pressed("jump")
