extends Control

# ============================================================
# CAMINHOS DAS CENAS
# ============================================================

const CLASS_SELECT_SCENE = "res://Cenas/class_select.tscn"


# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var menu_music_player = $MenuMusicPlayer


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	get_tree().paused = false

	process_mode = Node.PROCESS_MODE_ALWAYS

	start_menu_music()


func start_menu_music():

	if menu_music_player == null:
		return

	if !menu_music_player.playing:
		menu_music_player.play()


# ============================================================
# BOTÃO PLAY
# ============================================================

func _on_play_button_pressed():

	get_tree().change_scene_to_file(CLASS_SELECT_SCENE)


# ============================================================
# BOTÃO SAIR
# ============================================================

func _on_quit_button_pressed():

	get_tree().quit()
