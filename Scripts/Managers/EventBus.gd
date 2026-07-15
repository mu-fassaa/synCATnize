extends Node

signal character_switched(new_active_character: CharacterBody2D)
signal character_state_changed(character: CharacterBody2D, new_state: int)
signal interaction_target_changed(character: CharacterBody2D, target: Area2D)
signal rift_closed(rift_id: String)
