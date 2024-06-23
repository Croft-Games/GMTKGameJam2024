extends OptionButton


func _ready():
	select(Settings.numberwang_index)

func _on_item_selected(index: int):
		Settings.numberwang_index = index
