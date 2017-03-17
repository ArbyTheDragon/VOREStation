/mob/living/simple_animal

	var/vore_active = 0					// If vore behavior is enabled for this mob

	var/list/prey_exclusions = list()	// List of targets excluded (for now) from being eaten by this mob.

	var/vore_capacity = 1				// The capacity (in people) this person can hold
	var/vore_max_size = RESIZE_TINY		// The max size this mob will consider eating
	var/vore_min_size = RESIZE_TINY 	// The min size this mob will consider eating
	var/vore_pounce_chance = 0			// Chance of this mob knocking down an opponent
	var/vore_standing_too = 0			// Can also eat non-stunned mobs
	var/vore_ignores_prefs = 0			// Ignores the toggle digestion pref

	var/vore_default_mode = DM_DIGEST	// Default bellymode (DM_DIGEST, DM_HOLD, DM_ABSORB)
	var/vore_digest_chance = 0			// Chance to switch to digest mode if resisted
	var/vore_absorb_chance = 0			// Chance to switch to absorb mode if resisted
	var/vore_escape_chance = 0			// Chance of resisting out of mob

	var/vore_stomach_name				// The name for the first belly if not "stomach"
	var/vore_stomach_flavor				// The flavortext for the first belly if not the default
