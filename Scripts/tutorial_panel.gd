extends Panel

# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = true

	get_tree().paused = true


# ============================================================
# FECHAR TUTORIAL
# ============================================================

func close_tutorial():

	visible = false

	get_tree().paused = false


# ============================================================
# BOTÃO COMEÇAR
# ============================================================

func _on_start_button_pressed():

	close_tutorial()
