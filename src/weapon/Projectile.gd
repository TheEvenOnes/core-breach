extends RigidBody

const ProjectileExplodeEffect := preload('res://src/weapon/ProjectileExplodeEffect.tscn')

export (Color) var energy_color := Color.red
export (float) var damage := 5.0
export (float) var speed := 80.0
var lifetime := 5.0

func _ready() -> void:
  $MeshInstance.get_surface_material(0).emission = energy_color
  contact_monitor = true
  contacts_reported = true
  yield(get_tree().create_timer(lifetime), 'timeout')
  queue_free()

func _physics_process(delta: float) -> void:
  var colliding_bodies = get_colliding_bodies()
  if colliding_bodies.size() > 0:
    var effect = ProjectileExplodeEffect.instance()
    FxManager.add_fx(effect)
    var mat: SpatialMaterial = effect.mesh.surface_get_material(0)
    mat.emission = energy_color
    effect.global_transform.origin = global_transform.origin
    queue_free()
