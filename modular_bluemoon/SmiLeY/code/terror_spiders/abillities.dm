//TERROR SPIDERS ABILLITIES

//TIER 1 SPIDERS

//LURKER//

//STEALTH AKA INVISIBILLITY
/obj/effect/proc_holder/spell/aoe_turf/terror_stealth
	name = "Stealth"
	desc = "Become completely invisible for a short time."
	action_icon_state = "stealth"
	action_background_icon_state = "bg_terror"
	cooldown_min = 25 SECONDS
	clothes_req = FALSE
	sound = 'sound/creatures/terrorspiders/stealth.ogg'
	var/duration = 8 SECONDS

/obj/effect/proc_holder/spell/aoe_turf/terror_stealth/choose_targets()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/aoe_turf/terror_stealth/cast(list/targets, mob/user = usr)
	user.alpha = 0
	user.visible_message("<span class='warning'>[user] suddenly disappears!</span>", "<span class='purple'>You are invisible now!</span>")
	addtimer(CALLBACK(src, PROC_REF(reveal), user), duration)


/obj/effect/proc_holder/spell/aoe_turf/terror_stealth/proc/reveal(mob/user)
	if(QDELETED(user))
		return

	user.alpha = initial(user.alpha)
	user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='purple'>You are visible again!</span>")
	playsound(user.loc, 'sound/creatures/terrorspiders/stealth_out.ogg', 150, TRUE)


//HEALER//

//LESSER HEALING
/obj/effect/proc_holder/spell/aoe_turf/terror_healing
	name = "Heal"
	desc = "Exude feromones to heal your allies"
	action_icon_state = "heal"
	action_background_icon_state = "bg_terror"
	cooldown_min = 30 SECONDS
	clothes_req = FALSE
	inner_radius = 6
	sound = 'sound/creatures/terrorspiders/heal.ogg'
	var/heal_amount = 20
	var/apply_heal_buff = FALSE


/obj/effect/proc_holder/spell/aoe_turf/terror_healing/choose_targets()
	var/datum/spell_targeting/aoe/T = new()
	T.range = inner_radius
	T.allowed_type = /mob/living/simple_animal/hostile/poison/terror_spider
	return T


/obj/effect/proc_holder/spell/aoe_turf/terror_healing/cast(list/targets, mob/user = usr)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/spider in targets)
		visible_message("<span class='green'>[user] exudes feromones and heals spiders around!</span>")
		spider.adjustBruteLoss(-heal_amount)
		if(apply_heal_buff)
			spider.apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
		new /obj/effect/temp_visual/heal(get_turf(spider), "#00ff0d")
		new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")
		new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")


//TIER 2 SPIDERS

//WIDOW//

//VENOM SPIT
/obj/effect/proc_holder/spell/aimed/fireball/venom_spit
	name = "Venom spit"
	desc = "Spit an acid that creates smoke filled with drugs and venom on impact."
	invocation_type = "none"
	action_icon_state = "fake_death"
	action_background_icon_state = "bg_terror"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	cooldown_min = 25 SECONDS
	projectile_type = /obj/item/projectile/terrorspider/widow/venom

/obj/effect/proc_holder/spell/aimed/fireball/venom_spit/update_icon()
	return

/obj/item/projectile/terrorspider/widow/venom
	name = "venom acid"
	damage = 5

/obj/item/projectile/terrorspider/widow/venom/on_hit(var/target)
	. = ..()
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/T = get_turf(target)
	create_reagents(1250)
	reagents.add_reagent("thc", 250)
	reagents.add_reagent("psilocybin", 250)
	reagents.add_reagent("lsd", 250)
	reagents.add_reagent("space_drugs", 250)
	reagents.add_reagent("terror_black_toxin", 250)
	S.set_up(reagents, T, TRUE)
	S.start()

	return ..()

//SMOKE SPIT
/obj/effect/proc_holder/spell/aimed/fireball/smoke_spit
	name = "Smoke spit"
	desc = "Spit an acid that creates smoke on impact."
	invocation_type = "none"
	action_icon_state = "smoke"
	action_background_icon_state = "bg_terror"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	cooldown_min = 10 SECONDS
	projectile_type = /obj/item/projectile/terrorspider/widow/smoke


/obj/effect/proc_holder/spell/aimed/fireball/smoke_spit/update_icon()
	return


/obj/item/projectile/terrorspider/widow/smoke
	name = "smoke acid"
	damage = 5


/obj/item/projectile/terrorspider/widow/smoke/on_hit(var/target)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new
	var/turf/T = get_turf(target)
	smoke.set_up(15, 0, T)
	smoke.start()

	return ..()


//DESTROYER//

//EMP

/obj/effect/proc_holder/spell/targeted/emplosion/terror_emp
	name = "EMP shriek"
	desc = "Emits a shriek that causes EMP pulse."
	action_icon_state = "emp_new"
	action_background_icon_state = "bg_terror"
	cooldown_min = 40 SECONDS
	clothes_req = FALSE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	emp_range = 4


/obj/effect/proc_holder/spell/targeted/emplosion/terror_emp/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//EXPLOSION
/obj/effect/proc_holder/spell/aoe_turf/terror_burn
	name = "Burn!"
	desc = "Release your energy to create a massive fire ring."
	action_icon_state = "explosion"
	action_background_icon_state = "bg_terror"
	cooldown_min = 60 SECONDS
	clothes_req = FALSE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	range = 5


/obj/effect/proc_holder/spell/aoe_turf/explosion/terror_burn/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//GUARD//

//SHIELD
/obj/effect/proc_holder/spell/aoe_turf/conjure/terror_shield
	name = "Guardian shield"
	desc = "Create a temporary organic shield to protect your hive."
	action_icon_state = "terror_shield"
	action_background_icon_state = "bg_terror"
	cooldown_min = 8 SECONDS
	clothes_req = FALSE
	charge_max = 0 SECONDS
	cast_sound = 'sound/creatures/terrorspiders/mod_defence.ogg'
	summon_type = list(/obj/effect/forcefield/terror)


/obj/effect/forcefield/terror
	desc = "Thick protective membrane produced by Guardians of Terror."
	name = "Guardian shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "terror_shield"

	timeleft = 16.5 SECONDS                       //max 2 shields existing at one time
	light_color = LIGHT_COLOR_PURPLE


/obj/effect/forcefield/terror/CanPass(atom/movable/mover, turf/target, mob/living/carbon/human/H)
	. = ..()
	if(isterrorspider(mover))

		return TRUE
	else if(isliving(mover))
		if(isterrorspider(mover.pulledby))

			return TRUE
		if(prob(75))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			H.Paralyze(10 SECONDS)
			return FALSE


//DEFILER//

//SMOKE
/obj/effect/proc_holder/spell/aoe_turf/terror_smoke
	name = "Smoke"
	desc = "Erupt a smoke to confuse your enemies."
	action_icon_state = "smoke"
	action_background_icon_state = "bg_terror"
	cooldown_min = 8 SECONDS
	clothes_req = FALSE
	sound = 'sound/creatures/terrorspiders/attack2.ogg'

	school = "conjuration"
	smoke_amt = 15

/**
 * A spell targeting system which will return the caster as target
 */
/datum/spell_targeting/self

/datum/spell_targeting/self/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom)
	return list(user) // That's how simple it is


/obj/effect/proc_holder/spell/aoe_turf/terror_smoke/choose_targets()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe_turf/terror_smoke/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//PARALYSING SMOKE
/obj/effect/proc_holder/spell/aoe_turf/terror_parasmoke
	name = "Paralyzing Smoke"
	desc = "Erupt a smoke to paralyze your enemies."
	action_icon_state = "biohazard2"
	action_background_icon_state = "bg_terror"
	cooldown_min = 60 SECONDS
	clothes_req = FALSE
	sound = 'sound/creatures/terrorspiders/attack2.ogg'


/obj/effect/proc_holder/spell/aoe_turf/terror_parasmoke/choose_targets()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe_turf/terror_parasmoke/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/aoe_turf/terror_parasmoke/cast(list/targets, mob/user = usr)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	create_reagents(2000)
	reagents.add_reagent("neurotoxin", 1000)
	reagents.add_reagent("capulettium_plus", 1000)
	smoke.set_up(reagents, user, TRUE)
	smoke.start()


//TERRIFYING SHRIEK
/obj/effect/proc_holder/spell/aoe_turf/terror_shriek
	name = "Terrify"
	desc = "Emit a loud shriek to terrify your enemies."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	cooldown_min = 60 SECONDS
	clothes_req = FALSE
	inner_radius = 7
	sound = 'sound/creatures/terrorspiders/white_shriek.ogg'


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek/choose_targets()
	var/datum/spell_targeting/aoe/T = new()
	T.range = inner_radius
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(iscarbon(target))
			to_chat(target, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
			target.AdjustConfused(20 SECONDS, 10, 20)
			target.Slowed(2 SECONDS)
			target.Jitter(600 SECONDS)

		if(issilicon(target))
			to_chat(target, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
			target << 'sound/misc/interference.ogg'
			playsound(target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			do_sparks(5, 1, target)

//TIER 3

//PRINCESS//

//SHRIEK
/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_princess
	name = "Princess Shriek"
	desc = "Emits a loud shriek that weakens your enemies."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	cooldown_min = 30 SECONDS
	clothes_req = FALSE
	inner_radius = 6
	sound = 'sound/creatures/terrorspiders/princess_shriek.ogg'


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_princess/choose_targets()
	var/datum/spell_targeting/aoe/T = new()
	T.range = inner_radius
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_princess/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(iscarbon(target))
			to_chat(target, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
			target.adjustStaminaLoss(30)
			target.Slowed(10 SECONDS)
			target.Jitter(300 SECONDS)

		if(issilicon(target))
			to_chat(target, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
			target << 'sound/misc/interference.ogg'
			playsound(target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			do_sparks(5, 1, target)

//PRINCE//

//SLAM
/obj/effect/proc_holder/spell/aoe_turf/terror_slam
	name = "Slam"
	desc = "Slam the ground with your body."
	action_icon_state = "slam"
	action_background_icon_state = "bg_terror"

	charge_max = 35 SECONDS
	clothes_req = FALSE
	inner_radius = 2
	sound = 'sound/creatures/terrorspiders/prince_attack.ogg'


/obj/effect/proc_holder/spell/aoe_turf/terror_slam/choose_targets()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = inner_radius
	return T


/obj/effect/proc_holder/spell/aoe_turf/terror_slam/cast(list/targets, mob/user = usr)
	for(var/turf/target_turf in targets)
		for(var/mob/living/carbon/target in target_turf.contents)
			target.adjustBruteLoss(20)
			target.Slowed(8 SECONDS)

		if(istype(target_turf, /turf/open/floor/holofloor))
			var/turf/open/floor/holofloor/floor_tile = target_turf
			floor_tile.break_tile()


//MOTHER//

//JELLY PRODUCTION
/obj/effect/proc_holder/spell/aoe_turf/conjure/terror_jelly
	name = "Produce jelly"
	desc = "Produce an organic jelly that heals spiders."
	action_icon_state = "spiderjelly"
	action_background_icon_state = "bg_terror"
	cooldown_min = 30 SECONDS
	clothes_req = FALSE
	charge_max = 3.3 SECONDS
	cast_sound = 'sound/creatures/terrorspiders/jelly.ogg'
	summon_type = list(/obj/structure/spider/royaljelly)


//MASS HEAL
/obj/effect/proc_holder/spell/aoe_turf/terror_healing/greater
	name = "Massive healing"
	cooldown_min = 40 SECONDS
	inner_radius = 7
	heal_amount = 30
	apply_heal_buff = TRUE


//TIER 4

//ALL HAIL THE QUEEN//

//SHRIEK
/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_queen
	name = "Queen Shriek"
	desc = "Emit a loud shriek that weakens your enemies."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	cooldown_min = 45 SECONDS
	clothes_req = FALSE
	inner_radius = 7
	sound = 'sound/creatures/terrorspiders/queen_shriek.ogg'


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_queen/choose_targets()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = inner_radius
	return T


/obj/effect/proc_holder/spell/aoe_turf/terror_shriek_queen/cast(list/targets, mob/user = usr)
	for(var/turf/target_turf in targets)
		for(var/mob/living/target in target_turf.contents)
			if(iscarbon(target))
				to_chat(target, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				target.adjustStaminaLoss(50)
				target.Jitter(1000 SECONDS)
				target.Slowed(14 SECONDS)

			if(issilicon(target))
				to_chat(target, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				target << 'sound/misc/interference.ogg'
				playsound(target, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, target)

		for(var/obj/machinery/light/lamp in target_turf.contents)
			INVOKE_ASYNC(lamp, TYPE_PROC_REF(/obj/machinery/light, break_light_tube))

//KING??// one day..
