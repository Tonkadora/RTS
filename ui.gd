extends CanvasLayer

@onready var label_wood: Label = $ResourceText/LabelWood
@onready var label_food: Label = $ResourceText/LabelFood
@onready var label_gold: Label = $ResourceText/LabelGold

@onready var label_population: Label = $ResourceText/LabelPopulation
@onready var worker_build_options: Node2D = $WorkerBuildOptions


func _process(delta: float) -> void:
	label_wood.text = "wood" +  str(Global.wood_count)
	label_food.text = "food" +  str(Global.food_count)
	label_gold.text = "gold" +  str(Global.gold_count)
	label_population.text = "Population" +  str(Global.population_count) + "/" + str(Global.max_population_count)
	
	if Global.workers_selected == true:
		worker_build_options.visible = true
	else:
		worker_build_options.visible = false
