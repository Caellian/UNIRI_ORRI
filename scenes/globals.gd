extends Node
class_name GameGlobals

@onready
var game: Node = get_node("/root/Game")
@onready
var player: Player = game.get_node("%Player")
@onready
var time: GameTime = game.get_node("%Time")
@onready
var scene_manager: SceneManager = game.get_node("%SceneManager")

var game_save: GameSave = null
