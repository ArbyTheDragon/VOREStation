/mob/living/simple_animal/hostile/large/panther
	name = "panther"
	desc = "Runtime's larger, less cuddly cousin."
	icon_state = "panther"
	icon_living = "panther"
	icon_dead = "panther-dead"

	faction = "panther"
	maxHealth = 200
	health = 200
	move_to_delay = 4

	speak_chance = 2
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("rawrs","rumbles","rowls")
	emote_see = list("stares ferociously", "snarls")

	melee_damage_lower = 10
	melee_damage_upper = 30

	old_y = 0
	pixel_y = 0

/mob/living/simple_animal/hostile/large/panther/vore
	vore_active = 1
	vore_capacity = 2
	vore_pounce_chance = 10