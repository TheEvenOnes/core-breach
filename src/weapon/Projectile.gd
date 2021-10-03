extends RigidBody

const ProjectileExplodeEffect := preload('res://src/weapon/ProjectileExplodeEffect.tscn')

var damage := 5.0
var speed := 80.0
var lifetime := 5.0


func _ready() -> void:
  contact_monitor = true
  contacts_reported = true
  yield(get_tree().create_timer(lifetime), 'timeout')
  queue_free()

func _physics_process(delta: float) -> void:
  var colliding_bodies = get_colliding_bodies()
  if colliding_bodies.size() > 0:
    var effect = ProjectileExplodeEffect.instance()
    effect.global_transform.origin = global_transform.origin
    get_parent().add_child(effect)
    queue_free()
