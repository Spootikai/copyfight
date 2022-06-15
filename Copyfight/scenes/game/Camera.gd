extends Camera2D

onready var home_position : Vector2 = get_viewport().size / 2
onready var intensity : float = 10
onready var shake : bool = false

func _ready():
	self.global_position = home_position
	
func _physics_process(delta):
	self.global_position = lerp(self.global_position, home_position, delta*10)
	
	if shake:
		self.global_position += Vector2(rand_range(-intensity, intensity), rand_range(-intensity, intensity))

func startShake(duration : float, _intensity : float = 10.0):
	for i in get_children():
		i.queue_free()
	
	var timer = Timer.new()
	self.add_child(timer)
	timer.set_wait_time(duration)
	timer.connect("timeout", self, "stopShake")
	timer.start()

	shake = true
	intensity = _intensity

func stopShake():
	shake = false
