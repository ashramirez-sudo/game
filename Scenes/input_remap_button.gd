extends Button
class_name InputRemapButton

@export var action: String = ""
@export var action_event_index: int = 0

func _ready():
	toggle_mode = true
	update_text()

func _toggled(_toggled_on: bool):
	update_text()

func update_text():
	if button_pressed:
		text = "Press Key..."
		return

	if action.is_empty() or not InputMap.has_action(action):
		text = "Unassigned"
		return

	var events = InputMap.action_get_events(action)
	if action_event_index >= events.size():
		text = "Unassigned"
		return

	var input = events[action_event_index]
	if input is InputEventKey:
		if input.physical_keycode != Key.KEY_NONE:
			text = OS.get_keycode_string(input.physical_keycode)
		elif input.keycode != Key.KEY_NONE:
			text = OS.get_keycode_string(input.keycode)
		else:
			text = "Unassigned"
	else:
		text = input.as_text()

func _unhandled_input(event: InputEvent):
	if not button_pressed or action.is_empty() or not InputMap.has_action(action):
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			button_pressed = false
			release_focus()
			update_text()
			get_viewport().set_input_as_handled()
			return

		var action_events = InputMap.action_get_events(action)
		if action_event_index < action_events.size():
			InputMap.action_erase_event(action, action_events[action_event_index])

		InputMap.action_add_event(action, event)
		button_pressed = false
		release_focus()
		update_text()
		get_viewport().set_input_as_handled()

	
