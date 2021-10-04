extends RigidBody

const Projectile := preload('res://src/weapon/Projectile.tscn')
const Boom := preload('res://src/objects/CrateExplodeFX.tscn')
const Menu := preload('res://src/menu/Menu.tscn')
# const SkyboxRes := preload('res://assets/simple_skybox/Skybox.tscn')

export (float) var acceleration = 10.0

export (float) var max_health := 100.0
export (float) var current_health := 100.0
export (float) var health_regen := 0.0
export (float) var max_ammo := 100.0
export (float) var current_ammo := 100.0
export (float) var ammo_regen := 20.0
export (float) var core_meltdown_timer := 30.0
export (Color) var energy_color := Color.purple

onready var health := current_health
onready var ammo := current_ammo

var coins := 0

var mouse_captured = true

var mouse_deltas := Vector2.ZERO
var skyboxI: Spatial
const skybox_scale = Vector3(100, 100, 100)  # 100 * (-4.4 -> 4.4)

var elapsed := 0.0

func update_state(delta: float) -> void:
  health = min(health + health_regen * delta, max_health)
  ammo = min(ammo + ammo_regen * delta, max_ammo)
  core_meltdown_timer = max(0.0, core_meltdown_timer - delta)

func update_gui() -> void:
  var target = $Camera/GUI/CrossTarget

  var center = get_viewport().size * 0.5
  target.position = target.position.linear_interpolate(center + mouse_deltas * 32.0, 0.025)

  var distance = target.position.distance_to(center)
  var away_from_center = target.position - center

  target.rotation = away_from_center.angle() + deg2rad(90.0)

  if distance < 64:
    target.modulate.a = smoothstep(0.0, 1.0, distance / 64.0)
  else:
    target.modulate.a = 1.0

  $Camera/GUI/Health.rect_scale.y = min(1.0, health / max_health)
  $Camera/GUI/HealthLabel.text = str(int($Camera/GUI/Health.rect_scale.y * 100)) + "%"
  $Camera/GUI/Ammo.rect_scale.y = min(1.0, ammo / max_ammo)
  $Camera/GUI/AmmoLabel.text = str(int($Camera/GUI/Ammo.rect_scale.y * 100)) + "%"
  $Camera/GUI/CoinsLabel.text = "Coins: " + str(coins)

  $Camera/GUI/CoreMeltdown/In.text = str(int(core_meltdown_timer)) + " seconds"

  if core_meltdown_timer < 10.0:
    $Camera/GUI/CoreMeltdown.modulate.a = 0.5 + 0.25 * sin(elapsed * 6)
    $Camera/GUI/CoreMeltdown.modulate.r = 1
    $Camera/GUI/CoreMeltdown.modulate.g = 0
    $Camera/GUI/CoreMeltdown.modulate.b = 0
  else:
    $Camera/GUI/CoreMeltdown.modulate = Color(1, 1, 1)
    if core_meltdown_timer < 30.0:
      $Camera/GUI/CoreMeltdown.modulate.a = 0.4 + 0.2 * sin(elapsed * 4)

func process_shoot() -> void:
  var AMMO_COST = 10.0
  if Input.is_action_just_pressed('fire_primary') && ammo > AMMO_COST:
    ammo = max(0.0, ammo - AMMO_COST)
    var projectile = Projectile.instance()
    projectile.global_transform = $Camera/ProjectileShooter.global_transform
    projectile.apply_central_impulse(projectile.transform.basis.z * -projectile.speed)
    projectile.energy_color = energy_color
    ProjectileManager.add_projectile(projectile)
    add_collision_exception_with(projectile)
    $AudioStreamPlayer3D.play()

func _ready() -> void:
  contact_monitor = true
  contacts_reported = true
  linear_damp = 1.5
  angular_damp = 3.0
  var target = $Camera/GUI/CrossTarget
  var center = get_viewport().size * 0.5
  target.position = center
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

  #var skybox := SkyboxRes.instance()
  #skybox.TextureFront = load('res://assets/skybox1/front.png')
  #skybox.TextureBack = load('res://assets/skybox1/back.png')
  #skybox.TextureUp = load('res://assets/skybox1/top.png')
  #skybox.TextureBottom = load('res://assets/skybox1/bottom.png')
  #skybox.TextureLeft = load('res://assets/skybox1/right.png')  # sic
  #skybox.TextureRight = load('res://assets/skybox1/left.png')  # sic
  #skybox.name = 'Skybox'
  #get_parent().get_node('InterpolatedCamera2').add_child(skybox)
  #skyboxI = skybox
  #skybox.global_scale(skybox_scale)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseMotion:
    if mouse_captured:
      mouse_deltas += event.relative * 150.0 * 1.0 / get_viewport().size

func play_sfx_core():
  if !$CoreSFX.playing:
    $CoreSFX.play()

func _physics_process(delta: float) -> void:
  elapsed += delta

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
    add_force(transform.basis.y * -acceleration, Vector3.ZERO)
  if Input.is_action_pressed('throttle_left'):
    add_force(transform.basis.x * -acceleration, Vector3.ZERO)
  if Input.is_action_pressed('throttle_right'):
    add_force(transform.basis.x * acceleration, Vector3.ZERO)
  if Input.is_action_pressed('roll_left'):
    add_torque(transform.basis.z * acceleration * 0.2)
  if Input.is_action_pressed('roll_right'):
    add_torque(transform.basis.z * -acceleration * 0.2)

  var yaw = mouse_deltas.x
  var pitch = mouse_deltas.y

  add_torque(transform.basis.y * (-yaw))
  add_torque(transform.basis.x * (-pitch))

  process_shoot()

  update_state(delta)
  update_gui()

  mouse_deltas *= 0.5

  play_sfx_core()
  $CoreSFX.pitch_scale = 1.0 + linear_velocity.length() / 5.0

  #var skybox = skyboxI
  #var origin: Vector3
  #origin = skybox.global_transform.origin
  #skybox.global_transform = Transform.IDENTITY
  #skybox.global_transform.origin = origin
  #skybox.global_scale(skybox_scale)

func heal(amount: float) -> void:
  health = min(max_health, health + amount)

func add_core_time(amount: float) -> void:
  core_meltdown_timer += amount

func add_coins(amount: int) -> void:
  coins += amount

func damage(amount: float) -> void:
  health = max(0.0, health - amount)
  if health <= 0.0:
    var fx = Boom.instance()
    FxManager.add_fx(fx)
    fx.global_transform = global_transform
    yield(get_tree().create_timer(0.5), 'timeout')
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    ArenaManager.set_arena(Menu.instance())
