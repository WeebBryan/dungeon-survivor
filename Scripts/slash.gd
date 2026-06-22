extends Node2D

# ============================================================
# CONFIGURAÇÕES DA ANIMAÇÃO
# ============================================================

@export var grow_duration = 0.05
@export var visible_duration = 0.1
@export var fade_duration = 0.1

@export var start_scale = Vector2.ZERO
@export var end_scale = Vector2.ONE


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	play_slash_animation()


# ============================================================
# ANIMAÇÃO
# ============================================================

func play_slash_animation():

	scale = start_scale
	modulate.a = 1.0

	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		end_scale,
		grow_duration
	)

	tween.tween_interval(visible_duration)

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_duration
	)

	await tween.finished

	queue_free()
