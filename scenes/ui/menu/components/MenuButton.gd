extends Button

onready var label: Label = $Label

func _ready():
    if disabled:
        var font_color := label.get_color("font_color")
        font_color.a = 0.5
        label.add_color_override("font_color", font_color)
        
        var shadow_color := label.get_color("font_color_shadow")
        shadow_color.a = 0.5
        label.add_color_override("font_color_shadow", shadow_color)
