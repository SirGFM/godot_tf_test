extends Sprite

# Path to the animation's JSON file
export(String) var animationData
# Animation that plays whenever one finishes
export(String) var defaultAnimation

# Animation are JSON objects which SHALL contain the following fields:
#   * frames -- Array of frames indexes, in the order they should be played
#   * fps -- Animation speed in frames-per-second
#   * loop -- Whether the animation should loop or not
var _animations

# The current animation
var _curAnimation
# Time until the next frame
var _delay
# Accumulated time until the next frame
var _accDelay
# Index of the current frame
var _curFrame
# Object of the current animation
var _animObject

# Play an animation. Whenever a new animation is played (or force is set), the
# animation is reset to its initial state.
func playAnimation(anim, force):
    if self._curAnimation == anim && !force:
        # Does nothing since the animation isn't going to change
        return
    elif !anim in self._animations:
        printerr("Invalid animation")
        return

    # Retrieve the animation and cache the relevant info
    self._animObject = self._animations[anim]
    if self._animObject.fps > 0:
        self._curAnimation = anim
        self._delay = 1.0 / self._animObject.fps
        self._curFrame = 0
        # Make it ~animated~
        self.set_process(true)
    else:
        self.set_process(false)
    self._accDelay = 0

    # Update the graphic to the animation's first frame
    self.set_frame(self._animObject.frames[0])

func _ready():
    # Something along this:
    #   1. Check if cached
    #   2. Load file to string
    #   3. Decode string's JSON (`parse_json(str)`)
    #   4. Store into cache tagged by file's MD5

    # TODO Wrap this within a mutex or something (it shouldn't be required,
    # but Godot complains about globals and thread safety, so...)
    var cache = get_node("/root/thePool").AnimationCache

    if animationData == null:
        printerr("AnimationData can't be null")
        return
    elif animationData.empty():
        printerr("AnimationData can't be empty!")
        return

    # Check if cached and load if necessary
    if animationData in cache:
        self._animations = cache[animationData]
    else:
        var fp = File.new()
        if !fp.file_exists(animationData):
            printerr("Failed to find AnimationData")
            return
        fp.open(animationData, File.READ)
        var json = fp.get_as_text()
        fp.close()

        self._animations = {}
        if self._animations.parse_json(json) != OK:
            printerr("Failed to parse animation")
            return

    if !defaultAnimation.empty():
        self.playAnimation(defaultAnimation, true)

# Called every frame, sync'ed to draw(?). Should only ever be called if an
# animation is being played.
func _process(delta):
    # This may actually bug animations slightly, in case of lag
    self._accDelay += delta
    if self._accDelay > self._delay:
        # Just switched frames
        self._accDelay -= self._delay
        self._curFrame += 1
        # Check if animation ended
        if self._curFrame >= self._animObject.frames.size():
            if self._animObject.loop:
                # Animation ended but it loops, go back to the first frame
                # TODO Increase finish count!
                # TODO Send 'just_finished' signal
                self._curFrame = 0
            else:
                # Animation ended. Go back to default, if any
                if self.defaultAnimation:
                    self.playAnimation(self.defaultAnimation, true)
                else:
                    self.set_process(false)
                return
        self.set_frame(self._animObject.frames[self._curFrame])

