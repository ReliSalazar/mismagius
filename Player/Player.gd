extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 150
const FRICTION = 700

var velocity = Vector2.ZERO

# we are calling the child nodes.
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
# this will let us manipualte the machine state directly.
onready var animationState = animationTree.get("parameters/playback")

func _physics_process(delta):
  var input_vector = Vector2.ZERO
  input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
  input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
  # Vector2.normalized() help us to make diagonal speed don't sum the horizontal and vertical
  # speed and be faster than normal. This is trigonometry
  # C will always be longer than B and A, so, we need to normalize these values to be equal.
  # normalized creates a radius of a determined radius and cut the values so the Vector was stable.
  #   _______-Y_______ (1, -1)
  #   |       |      /|
  #   |       |  C /  | A
  #   |       |  /    |
  # -X|_______|/______|+X
  #   |       |    B  |
  #   |       |       |
  #   |_______|_______|
  #          +Y
  input_vector = input_vector.normalized()
  
  if input_vector != Vector2.ZERO:
    # we set the blend position so it could change the animations.
    animationTree.set("parameters/Idle/blend_position", input_vector)
    animationTree.set("parameters/Walk/blend_position", input_vector)
    # and finally we set which blendspace2d we're going to use.
    animationState.travel("Walk")
    # delta has the time that the last frame took to process.
    # so, basically we're changing how it moves from pixels per
    # frame to some amount (delta) per second.
    velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
  else:
    animationState.travel("Idle")
    # Vector2.move_toward() makes stop smoother.
    velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
  
  velocity = move_and_slide(velocity)
