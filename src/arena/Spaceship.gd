extends RigidBody

const Projectile := preload('res://src/weapon/Projectile.tscn')
const SkyboxRes := preload('res://assets/simple_skybox/Skybox.tscn')

export (float) var acceleration = 10.0

export (float) var max_health := 100.0
export (float) var health_regen := 0.0
export (float) var max_ammo := 100.0
export (float) var ammo_regen := 20.0
export (float) var core_meltdown_timer := 60.0

var health := max_health
var ammo := max_ammo

var mouse_captured = true

var mouse_deltas := Vector2.ZERO
var skyboxI: Spatial
const skybox_scale = Vector3(100, 100, 100)  # 100 * (-4.4 -> 4.4)

func update_state(delta: float) -> void:
  health = min(health + health_regen * delta, max_health)
  ammo = min(ammo + ammo_regen * delta, max_ammo)
  core_meltdown_timer = max(0.0, core_meltdown_timer - delta)

func update_gui() -> void:
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

  $InterpolatedCamera/GUI/Health.rect_scale.y = min(1.0, health / max_health)
  $InterpolatedCamera/GUI/HealthLabel.text = str(int($InterpolatedCamera/GUI/Health.rect_scale.y * 100)) + "%"
  $InterpolatedCamera/GUI/Ammo.rect_scale.y = min(1.0, ammo / max_ammo)
  $InterpolatedCamera/GUI/AmmoLabel.text = str(int($InterpolatedCamera/GUI/Ammo.rect_scale.y * 100)) + "%"

  $InterpolatedCamera/GUI/CoreMeltdown/In.text = str(int(core_meltdown_timer)) + " seconds"

  if core_meltdown_timer < 30.0:
    pass

func process_shoot() -> void:
  var AMMO_COST = 10.0
  if Input.is_action_just_pressed('fire_primary') && ammo > AMMO_COST:
    ammo = max(0.0, ammo - AMMO_COST)
    var projectile = Projectile.instance()
    projectile.global_transform = $InterpolatedCamera/ProjectileShooter.global_transform
    projectile.apply_central_impulse(projectile.transform.basis.z * -projectile.speed)
    get_parent().add_child(projectile)
    $AudioStreamPlayer3D.play()

func _ready() -> void:
  linear_damp = 1.5
  angular_damp = 3.0
  var target = $InterpolatedCamera/GUI/CrossTarget
  var center = get_viewport().size * 0.5
  target.position = center
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

  var skybox := SkyboxRes.instance()
  skybox.TextureFront = load('res://assets/skybox1/front.png')
  skybox.TextureBack = load('res://assets/skybox1/back.png')
  skybox.TextureUp = load('res://assets/skybox1/top.png')
  skybox.TextureBottom = load('res://assets/skybox1/bottom.png')
  skybox.TextureLeft = load('res://assets/skybox1/right.png')  # sic
  skybox.TextureRight = load('res://assets/skybox1/left.png')  # sic
  skybox.name = 'Skybox'
  get_parent().get_node('InterpolatedCamera2').add_child(skybox)
  skyboxI = skybox
  skybox.global_scale(skybox_scale)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    if mouse_captured:
      mouse_deltas += event.relative * 150.0 * 1.0 / get_viewport().size

func play_sfx_core():
  if !$CoreSFX.playing:
    $CoreSFX.play()

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

  process_shoot()

  var yaw = mouse_deltas.x
  var pitch = mouse_deltas.y

  add_torque(transform.basis.y * (-yaw))
  add_torque(transform.basis.x * (-pitch))

  update_state(delta)
  update_gui()

  mouse_deltas *= 0.5

  play_sfx_core()
  $CoreSFX.pitch_scale = 1.0 + linear_velocity.length() / 5.0

  var skybox = skyboxI
  var origin: Vector3
  origin = skybox.global_transform.origin
  skybox.global_transform = Transform.IDENTITY
  skybox.global_transform.origin = origin
  skybox.global_scale(skybox_scale)
