extends Area2D

# ============================================================
# CONFIGURAÇÕES BÁSICAS
# ============================================================

@export var xp_value = 1


# ============================================================
# ESTADO
# ============================================================

var collected = false


# ============================================================
# COLETA
# ============================================================

func _on_body_entered(body):

	if collected:
		return

	if !body.is_in_group("player"):
		return

	collected = true

	play_xp_sound()

	body.gain_xp(xp_value)

	queue_free()


# ============================================================
# ÁUDIO
# ============================================================

func play_xp_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_xp()
