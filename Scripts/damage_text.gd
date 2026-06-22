extends Node2D

# ============================================================
# CONFIGURAÇÕES DA ANIMAÇÃO
# ============================================================

@export var move_distance = 60.0
@export var animation_duration = 1.0
@export var pop_duration = 0.2

@export var start_scale = Vector2(0.5, 0.5)
@export var end_scale = Vector2.ONE


# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var label = $Label


# ============================================================
# CONFIGURAÇÃO DO TEXTO
# ============================================================

func setup(text_value):

	if label == null:
		return

	label.text = str(text_value)

	play_animation()


# ============================================================
# ANIMAÇÃO
# ============================================================

func play_animation():

	label.scale = start_scale

	var tween = create_tween()

	tween.parallel().tween_property(
		label,
		"scale",
		end_scale,
		pop_duration
	)

	tween.parallel().tween_property(
		self,
		"position:y",
		position.y - move_distance,
		animation_duration
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		animation_duration
	)

	await tween.finished

	queue_free()
