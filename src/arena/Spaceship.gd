extends RigidBody

const Projectile := preload('res://src/weapon/Projectile.tscn')

export (float) var acceleration = 10.0

var mouse_captured = true

var mouse_deltas := Vector2.ZERO

func _ready() -> void:
  linear_damp = 1.5
  angular_damp = 3.0
  var target = $InterpolatedCamera/GUI/CrossTarget
  var center = get_viewport().size * 0.5
  target.position = center
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    if mouse_captured:
      mouse_deltas += event.relative * 250.0 * 1.0 / get_viewport().size

func play_sfx_core():
  if !$CoreSFX.playing:
    $CoreSFX.play()

func update_crosshair_target() -> void:
  var target = $InterpolatedCamera/GUI/CrossTarget

  var center = get_viewport().size * 0.5
  target.position = target.position.linear_interpolate(center + mouse_deltas * 16.0, 0.025)

  var distance = target.position.distance_to(center)
  var away_from_center = target.position - center

  target.rotation = away_from_center.angle() + deg2rad(90.0)

  if distance < 64:
    target.modulate.a = smoothstep(0.0, 1.0, distance / 64.0)
  else:
    target.modulate.a = 1.0

func _physics_process(delta: float) -> void:
  if Input.is_action_just_released('ui_cancel'):
    get_tree().quit()

  if Input.is_action_just_pressed('debug_toggle_mouse_capture'):
    mouse_captured = !mouse_captured
    if mouse_captured:
      Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
      Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

  var overdrive = 1.0
  if Input.is_action_pressed('throttle_overdrive'):
    overdrive = 4.0
  if Input.is_action_pressed('throttle_forward'):
    add_force(transform.basis.z * -acceleration * overdrive, Vector3.ZERO)
  if Input.is_action_pressed('throttle_backward'):
    add_force(transform.basis.z * acceleration * overdrive, Vector3.ZERO)
  if Input.is_action_pressed('throttle_up'):
    add_force(transform.basis.y * acceleration, Vector3.ZERO)
  if Input.is_action_pressed('throttle_down'):
    add_force(transform.basis.y * (-acceleration), Vector3.ZERO)
  if Input.is_action_pressed('throttle_left'):
    add_force(transform.basis.x * (-acceleration), Vector3.ZERO)
  if Input.is_action_pressed('throttle_right'):
    add_force(transform.basis.x * acceleration, Vector3.ZERO)
  if Input.is_action_pressed('roll_left'):
    add_torque(transform.basis.z * acceleration)
  if Input.is_action_pressed('roll_right'):
    add_torque(transform.basis.z * (-acceleration))
  if Input.is_action_just_pressed('fire_primary'):
    var projectile = Projectile.instance()
    projectile.global_transform = $InterpolatedCamera/ProjectileShooter.global_transform
    projectile.apply_central_impulse(projectile.transform.basis.z * -projectile.speed)
    get_parent().add_child(projectile)
    $AudioStreamPlayer3D.play()

  var yaw = mouse_deltas.x
  var pitch = mouse_deltas.y

  add_torque(transform.basis.y * (-yaw))
  add_torque(transform.basis.x * (-pitch))

  update_crosshair_target()

  mouse_deltas *= 0.5

  play_sfx_core()
  $CoreSFX.pitch_scale = 1.0 + linear_velocity.length() / 5.0
