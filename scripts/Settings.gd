extends Node

const SETTINGS_FILE = "user://settings.cfg"

var _settings = {
    "controls": {
        "touch_screen": false
    }
}

func _ready():
#    save_settings()
    load_settings()

func get_setting(section: String, setting: String) -> String:
    if _settings.has(section) and _settings[section].has(setting):
        return _settings[section][setting]
    
    return ""

func load_settings():
    var file = ConfigFile.new()
    var error = file.load(SETTINGS_FILE)
    
    if error == OK:
        var sections = file.get_sections()
        for section in sections:
            if not _settings.has(section):
                _settings[section] = {}
                
            for section_setting in file.get_section_keys(section):
                _settings[section][section_setting] = file.get_value(section, section_setting)
            

#    print(_settings)

func save_single_setting(section: String, settting: String, value):
    var config_file = ConfigFile.new()
    config_file.set_value(section, settting, value)
    config_file.save(SETTINGS_FILE)
    
    load_settings()

#func save_settings():
#    ConfigFile.new()
#
#    var config_file = ConfigFile.new()
##    config_file.set("autolock", settings["autolock"])
#    config_file.set_value("combat", "autolock", _settings["autolock"])
#    config_file.save(SETTINGS_FILE)
