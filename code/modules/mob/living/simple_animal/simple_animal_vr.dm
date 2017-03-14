/mob/living/simple_animal
	// List of targets excluded (for now) from being eaten by this mob.
	var/list/prey_exclusions = list()

/mob/living/simple_animal/cat
	isPredator = 1
