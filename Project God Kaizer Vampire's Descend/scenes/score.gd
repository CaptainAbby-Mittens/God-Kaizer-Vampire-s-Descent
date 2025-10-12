extends Label

var score: int = GameManager.score

func _ready():
	text = "Score :" + str(score)  # Convert to string
