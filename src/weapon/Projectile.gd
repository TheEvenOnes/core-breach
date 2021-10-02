extends RigidBody

var damage := 5.0
var speed := 40.0
var lifetime := 5.0


func _ready() -> void:
  yield(get_tree().create_timer(lifetime), 'timeout')
  queue_free()
