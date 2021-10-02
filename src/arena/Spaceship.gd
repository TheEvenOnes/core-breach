extends RigidBody

export (float) var acceleration = 10.0

var mouse_captured = false

var mouse_deltas := Vector2.ZERO

func _ready() -> void:
  linear_damp = 2.0
  angular_damp = 3.0


func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    if mouse_captured:
      mouse_deltas += event.relative * 0.2

func _physics_process(delta: float) -> void:
  if Input.is_action_just_pressed('debug_toggle_mouse_capture'):
    mouse_captured = !mouse_captured
    if mouse_captured:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

  if Input.is_action_pressed('throttle_up'):
    add_force(transform.basis.z * (-acceleration), Vector3.ZERO)
  if Input.is_action_pressed('throttle_down'):
    add_force(transform.basis.z * acceleration, Vector3.ZERO)
  if Input.is_action_pressed('throttle_left'):
    add_force(transform.basis.x * (-acceleration), Vector3.ZERO)
  if Input.is_action_pressed('throttle_right'):
    add_force(transform.basis.x * acceleration, Vector3.ZERO)
  if Input.is_action_pressed('roll_left'):
    add_torque(transform.basis.z * acceleration)
  if Input.is_action_pressed('roll_right'):
    add_torque(transform.basis.z * (-acceleration))

  var yaw = mouse_deltas.x
  var pitch = mouse_deltas.y

  add_torque(transform.basis.y * (-yaw))
  add_torque(transform.basis.x * (-pitch))

  mouse_deltas *= 0.5
