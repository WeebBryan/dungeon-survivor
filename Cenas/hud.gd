#extends CanvasLayer
#
#@onready var class_icon: TextureRect = $ClassFrame/ClassIcon
#
#@export var mage_icon: Texture2D
#@export var duelist_icon: Texture2D
#
#
#func _ready():
	#update_class_icon()
#
#
#func update_class_icon():
	#match PlayerData.selected_class:
		#"mage":
			#class_icon.texture = mage_icon
#
		#"duelist":
			#class_icon.texture = duelist_icon
#
		#_:
			#class_icon.texture = duelist_icon
