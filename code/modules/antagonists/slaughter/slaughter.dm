//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mob_size = MOB_SIZE_LARGE
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	var/feast_sound = 'sound/magic/demon_consume.ogg'
	death_sound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attack_verb_continuous = "wildly tears into"
	attack_verb_simple = "wildly tear into"
	maxHealth = 500
	health = 500
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 30 // buffed back to 30, the wounds don't do much
	melee_damage_upper = 30
	wound_bonus = 10
	bare_wound_bonus = 15
	sharpness = SHARP_EDGED
	see_in_dark = 8
	blood_volume = 0 //No bleeding on getting shot, for skeddadles
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	bloodcrawl = BLOODCRAWL_EAT
	var/playstyle_string = "<span class='big bold'>You are a slaughter demon,</span><B> a terrible creature from another realm. You have a single desire: To kill.  \
							You may use the \"Blood Crawl\" ability near blood pools to travel through them, appearing and disappearing from the station at will. \
							Pulling a dead or unconscious mob while you enter a pool will pull them in with you, allowing you to feast and regain your health. \
							You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. \
							You gain strength the more attacks you land on live humanoids, though this resets when you return to the blood zone. You can also \
							launch a devastating slam attack, capable of smashing bones in one strike.</B>"

	loot = list(/obj/effect/decal/cleanable/blood, \
				/obj/effect/decal/cleanable/blood/innards, \
				/obj/item/organ/heart/demon)
	del_on_death = 1
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"
	// How many times we have hit humanoid targets since we last bloodcrawled, scaling wounding power
	var/current_hitstreak = 0
	// How much both our wound_bonus and bare_wound_bonus go up per hitstreak hit
	var/wound_bonus_per_hit = 5
	// How much our wound_bonus hitstreak bonus caps at (peak demonry)
	var/wound_bonus_hitstreak_max = 12
	// Keep the people we eat
	var/list/consumed_mobs = list()
	//buffs only happen when hearts are eaten, so this needs to be kept track separately
	var/consumed_buff = 0
	//slam mode for action button
	var/slam_mode = FALSE
	var/datum/action/cooldown/slam

/mob/living/simple_animal/slaughter/Initialize(mapload)
	. = ..()
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	slam = new /datum/action/cooldown/slam
	slam.Grant(src)
	if(istype(loc, /obj/effect/dummy/phased_mob/slaughter))
		bloodspell.phased = TRUE

/datum/action/cooldown/slam
	name = "Slaughter Slam"
	desc = "Launch enemies and break bones in one strike."
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_demon"
	button_icon_state = "slam"
	cooldown_time = 45 SECONDS

/datum/action/cooldown/slam/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/simple_animal/slaughter/user = owner
	user.slam_mode = !user.slam_mode
	to_chat(user, user.slam_mode ? "Ready to slam!" : "Maybe not now.")

/mob/living/simple_animal/slaughter/UnarmedAttack(atom/A, proximity)
	if(iscarbon(A))
		var/mob/living/carbon/target = A
		if(slam_mode)
			if(!isopenturf(loc))
				to_chat(src, "<span class='warning'>You need to be on open flooring to do that!")
				return
			face_atom(A)
			var/mob/living/victim = A
			var/body_pick = pick(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
			var/datum/wound/blunt/critical/wound_major = new
			var/obj/item/bodypart/body_wound = victim.get_bodypart(body_pick)
			wound_major.apply_wound(body_wound)
			visible_message("<span class='danger'>[src] slams into [victim] with monstrous strength!</span>", "<span class='danger'>You slam into [victim] with monstrous strength!</span>", ignored_mobs=victim)
			to_chat(victim, "<span class='userdanger'>[src] slams into you with monstrous strength, sending you flying like a ragdoll!</span>")
			var/turf/yeet_target = get_edge_target_turf(victim, dir)
			victim.throw_at(yeet_target, 10, 14, src)
			slam_mode = FALSE
			slam.StartCooldown()
			log_combat(src, victim, "slaughter slammed")

		if(target.stat != DEAD && target.mind && current_hitstreak < wound_bonus_hitstreak_max)
			current_hitstreak++
			wound_bonus += wound_bonus_per_hit
			bare_wound_bonus += wound_bonus_per_hit

	return ..()

/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	name = "pile of viscera"
	desc = "A repulsive pile of guts and gore."
	gender = NEUTER
	icon_state = "innards"
	random_icon_states = null

/mob/living/simple_animal/slaughter/phasein()
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/slaughter)
	var/slowdown_time = 6 SECONDS + (0.5 * consumed_buff)
	addtimer(CALLBACK(src, .proc/remove_movespeed_modifier, /datum/movespeed_modifier/slaughter), slowdown_time, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/slaughter/Destroy()
	release_victims()
	. = ..()

/mob/living/simple_animal/slaughter/proc/release_victims()
	if(!consumed_mobs)
		return
	var/turf/T = get_turf(src)
	if(!T)
		T = find_safe_turf()
	for(var/mob/living/M in consumed_mobs)
		if(!M)
			continue
		M.forceMove(T)

/mob/living/simple_animal/slaughter/proc/refresh_consumed_buff()
	melee_damage_lower = 22.5 + (0.5 * consumed_buff)
	melee_damage_upper = 22.5 + (1 * consumed_buff)

/mob/living/simple_animal/slaughter/bloodcrawl_swallow(var/mob/living/victim)
	if(consumed_mobs)
		// Keep their corpse so rescue is possible
		consumed_mobs += victim
		victim.reagents?.add_reagent(/datum/reagent/preservahyde,3) // make it so that they don't decay in there
		var/obj/item/organ/heart/heart = victim.getorganslot(ORGAN_SLOT_HEART)
		if(heart)
			qdel(heart)
			consumed_buff++
			refresh_consumed_buff()
	else
		// Be safe and just eject the corpse
		victim.forceMove(get_turf(victim))
		victim.exit_blood_effect()
		victim.visible_message("[victim] falls out of the air, covered in blood, looking highly confused. And dead.")

//The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl
/obj/item/organ/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	decay_factor = 0

/obj/item/organ/heart/demon/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/item/organ/heart/demon/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message("<span class='warning'>[user] raises [src] to [user.ru_ego()] mouth and tears into it with [user.ru_ego()] teeth!</span>", \
						 "<span class='danger'>An unnatural hunger consumes you. You raise [src] your mouth and devour it!</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == /obj/effect/proc_holder/spell/bloodcrawl)
			to_chat(user, "<span class='warning'>...and you don't feel any different.</span>")
			qdel(src)
			return
	user.visible_message("<span class='warning'>[user]'s eyes flare a deep crimson!</span>", \
						 "<span class='userdanger'>You feel a strange power seep into your body... you have absorbed the demon's blood-travelling powers!</span>")
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E

/obj/item/organ/heart/demon/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	..()
	if(M.mind)
		M.mind.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))

/obj/item/organ/heart/demon/Remove(special = FALSE)
	owner?.mind?.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)
	return ..()

/obj/item/organ/heart/demon/Stop()
	return 0 // Always beating.

/mob/living/simple_animal/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	real_name = "laughter demon"
	desc = "A large, adorable creature covered in armor with pink bows."
	speak_emote = list("giggles","titters","chuckles")
	emote_hear = list("guffaws","laughs")
	response_help_continuous = "hugs"
	response_help_simple = "hug"
	attack_verb_continuous = "wildly tickles"
	attack_verb_simple = "wildly tickle"

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	death_sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	deathmessage = "fades out, as all of its friends are released from its \
		prison of hugs."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	playstyle_string = "<span class='big bold'>You are a laughter \
	demon,</span><B> a wonderful creature from another realm. You have a single \
	desire: <span class='clown'>To hug and tickle.</span><BR>\
	You may use the \"Blood Crawl\" ability near blood pools to travel \
	through them, appearing and disappearing from the station at will. \
	Pulling a dead or unconscious mob while you enter a pool will pull \
	them in with you, allowing you to hug them and regain your health.<BR> \
	You move quickly upon leaving a pool of blood, but the material world \
	will soon sap your strength and leave you sluggish.<BR>\
	What makes you a little sad is that people seem to die when you tickle \
	them; but don't worry! When you die, everyone you hugged will be \
	released and fully healed, because in the end it's just a jape, \
	sibling!</B>"

/mob/living/simple_animal/slaughter/laughter/ex_act(severity, target, origin)
	switch(severity)
		if(1)
			death()
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/slaughter/laughter/refresh_consumed_buff()
	melee_damage_lower -= 0.5 // JAPES
	melee_damage_upper += 1

/mob/living/simple_animal/slaughter/laughter/bloodcrawl_swallow(var/mob/living/victim)
	if(consumed_mobs)
		// Keep their corpse so rescue is possible
		consumed_mobs += victim
		refresh_consumed_buff()
	else
		// Be safe and just eject the corpse
		victim.forceMove(get_turf(victim))
		victim.exit_blood_effect()
		victim.visible_message("[victim] falls out of the air, covered in blood, looking highly confused. And dead.")

/mob/living/simple_animal/slaughter/laughter/release_victims()
	if(!consumed_mobs)
		return

	var/turf/T = get_turf(src)
	if(!T)
		T = find_safe_turf()
	for(var/mob/living/M in consumed_mobs)
		if(!M)
			continue
		M.forceMove(T)
		if(M.revive(full_heal = TRUE, admin_revive = TRUE))
			M.grab_ghost(force = TRUE)
			playsound(T, feast_sound, 50, 1, -1)
			to_chat(M, "<span class='clown'>You leave [src]'s warm embrace,	and feel ready to take on the world.</span>")
