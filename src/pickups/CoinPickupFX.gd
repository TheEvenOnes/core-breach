extends CPUParticles


func _ready() -> void:
  emitting = true
  $AudioStreamPlayer3D.play()
  yield(get_tree().create_timer(2.0), 'timeout')
  queue_free()
