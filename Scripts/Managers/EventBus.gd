extends Node

# Existing core signals
signal character_switched(new_active_character: CharacterBody2D)
signal character_state_changed(character: CharacterBody2D, new_state: int)
signal interaction_target_changed(character: CharacterBody2D, target: Area2D)
signal rift_closed(rift_id: String)

# New Sprint 3 modular signals
signal gameplay_state_changed(new_state: int)
signal ability_state_changed(character_type: int, ability_id: String, state: int)
signal objective_updated(objective_id: String, status: int)
signal puzzle_completed(puzzle_id: String)
signal rift_state_changed(rift_id: String, new_state: int)
signal dialogue_started(speaker_name: String, text_lines: Array)
signal dialogue_finished()
signal cutscene_started(cutscene_name: String)
signal cutscene_finished(cutscene_name: String)
signal event_triggered(event_id: String) # For generic narrative/world triggers
