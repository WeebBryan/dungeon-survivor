extends Panel

# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false


# ============================================================
# BOTÃO REINICIAR
# ============================================================

func _on_restart_button_pressed():

	print("RESTART FUNCIONOU")

	get_tree().paused = false

	get_tree().reload_current_scene()


# ============================================================
# BOTÃO MENU
# ============================================================

func _on_menu_button_pressed():

	print("MENU FUNCIONOU")

	get_tree().paused = false

	get_tree().change_scene_to_file("res://Cenas/main_menu.tscn")
