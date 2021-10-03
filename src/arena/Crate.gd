extends RigidBody

const CrateExplodeFX := preload('res://src/objects/CrateExplodeFX.tscn')

const MAX_HEALTH := 5.0
var health := MAX_HEALTH

func _ready() -> void:
  contact_monitor = true
  contacts_reported = true

func _physics_process(delta: float) -> void:
  var pos = get_viewport().get_camera().unproject_position(global_transform.origin)
  var rect = get_viewport().size
  var player = get_parent().get_node('Spaceship')
  var dist_to_player = global_transform.origin.distance_to(player.global_transform.origin)

  $Control/ColorRect.rect_position = pos + Vector2(-32, - 32 + 16 * clamp(2.0 / dist_to_player, 0.0, 1.0))
  var direction = -player.global_transform.basis.z

  var to_player = global_transform.origin - player.global_transform.origin
  $Control.visible = to_player.dot(direction) > 0

  update_gui()

  for body in get_colliding_bodies():
    if body.is_in_group('projectile'):
      damage(1)


func update_gui() -> void:
  $Control/ColorRect.rect_scale.x = max(0.1, health / MAX_HEALTH)

func damage(amount: float) -> void:
  health -= amount
  if health < 0.0:
    var fx = CrateExplodeFX.instance()
    fx.global_transform.origin = global_transform.origin
    get_parent().add_child(fx)
    queue_free()
