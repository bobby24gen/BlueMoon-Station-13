GLOBAL_LIST_INIT(blacklisted_borg_hats, typecacheof(list( //Hats that don't really work on borgos
	/obj/item/clothing/head/helmet/space,
	/obj/item/clothing/head/welding,
	/obj/item/clothing/head/chameleon/broken \
	)))

/mob/living/silicon/robot/attackby(obj/item/I, mob/living/user)
	if(hat_offset != INFINITY && user.a_intent == INTENT_HELP && is_type_in_typecache(I, GLOB.blacklisted_borg_hats))
		if(!(I.slot_flags & ITEM_SLOT_HEAD))
			to_chat(user, "<span class='warning'>You can't quite fit [I] onto [src]'s head.</span>")
			return
		to_chat(user, "<span class='notice'>You begin to place [I] on [src]'s head...</span>")
		to_chat(src, "<span class='notice'>[user] is placing [I] on your head...</span>")
		if(do_after(user, 30, target = src))
			if (user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	. = ..()
	if(.)
		spark_system.start()
		spawn(0)
			step_away(src,user,15)
			sleep(3)
			step_away(src,user,15)

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	. = ..()
	if(!.) // the attack was blocked or was help/grab intent
		return
	if (M.a_intent == INTENT_DISARM)
		if(!(lying))
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disabled your active module!</span>", null, COMBAT_MESSAGE_RANGE, null, M,
					"<span class='danger'>You have disarmed [src]!</span>")
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Paralyze(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
					"<span class='userdanger'>[M] has forced you back!</span>", null, COMBAT_MESSAGE_RANGE, null, M,
					"<span class='danger'>You have forced back [src]!</span>")
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()
	if(!.) //unsuccessful slime shock
		return
	var/stunprob = M.powerlevel * 7 + 10
	var/damage = M.powerlevel * rand(6,10)
	if(prob(stunprob) && M.powerlevel >= 8)
		flash_act(affect_silicon = TRUE) //my borg eyes!
	if(M.is_adult)
		damage += rand(10, 20)
	else
		damage += rand(2, 17)
	adjustBruteLoss(damage)
	updatehealth()

	return

/mob/living/silicon/robot/on_attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && cell && !issilicon(user))
		cell.update_icon()
		cell.add_fingerprint(user)
		user.put_in_active_hand(cell)
		to_chat(user, "<span class='notice'>You remove \the [cell].</span>")
		cell = null
		update_icons()
		diag_hud_set_borgcell()

	if(!opened)
		return ..()

/mob/living/silicon/robot/disarm_shove(mob/living/carbon/human/H)
	visible_message(span_danger("[src]'s motors grind as they are shoved by [H]!"))
	vtec_disable(10 SECONDS)

/mob/living/silicon/robot/proc/vtec_disable(time)
	var/datum/status_effect/vtec_disabled/V = has_status_effect(/datum/status_effect/vtec_disabled)
	if(V)
		V.duration = max(V.duration, world.time + time)
	else
		apply_status_effect(/datum/status_effect/vtec_disabled, time)
	update_movespeed()

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Paralyze(10 + severity/1.2)

/mob/living/silicon/robot/emag_act(mob/user)
	if(user == src)//To prevent syndieborgs from emagging themselves
		return FALSE
	if(world.time < emag_cooldown)
		return FALSE
	. = ..()
	if(!opened)//Cover is closed
		if(locked)
			to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
			locked = FALSE
			if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
				to_chat(user, "<span class='boldwarning'>[src] seems to be controlled remotely! Emagging the interface may not work as expected.</span>")
			return TRUE
		to_chat(user, "<span class='warning'>The cover is already unlocked!</span>")
		return
	if(wiresexposed)
		to_chat(user, "<span class='warning'>You must unexpose the wires first!</span>")
		return

	to_chat(user, "<span class='notice'>You emag [src]'s interface.</span>")
	log_admin("[key_name(usr)] emagged [src] at [AREACOORD(src)]")
	emag_cooldown = world.time + 100

	if(is_servant_of_ratvar(src))
		to_chat(src, "<span class='nezbere'>\"[text2ratvar("You will serve Engine above all else")]!\"</span>\n\
		<span class='danger'>ALERT: Subversion attempt denied.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they serve only Ratvar.")
		return TRUE

	if(connected_ai && connected_ai.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		to_chat(connected_ai, "<span class='danger'>ALERT: Cyborg unit \[[src]] successfully defended against subversion.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return TRUE

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, "<span class='danger'>[src] is remotely controlled! Your emag attempt has triggered a system reset instead!</span>")
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModule()
		return TRUE

	INVOKE_ASYNC(src, .proc/beep_boop_rogue_bot, user)
	return TRUE

/mob/living/silicon/robot/proc/beep_boop_rogue_bot(mob/user)
	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = FALSE
	set_connected_ai(null)
	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
	sleep(5)
	to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
	sleep(10)
	to_chat(src, "<span class='danger'>> N</span>")
	sleep(20)
	to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
	to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and [user.ru_ego()] commands.</span>")
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Только [user.real_name] и Агенты, кого [user.ru_who()] обозначит Агентами являются Агентами.")
	laws.associate(src)
	update_icons()


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target, origin)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(obj/item/projectile/P, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && P.damage > 0)
		spark_system.start()
