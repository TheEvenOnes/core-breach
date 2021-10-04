extends CPUParticles

export (Color) var fx_color := Color.red

func _ready() -> void:
  var mat: SpatialMaterial = mesh.surface_get_material(0)
  mat.emission = fx_color

  emitting = true
  $AudioStreamPlayer3D.play()
  yield(get_tree().create_timer(2.0), 'timeout')
  queue_free()
