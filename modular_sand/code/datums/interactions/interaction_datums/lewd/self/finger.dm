/datum/interaction/lewd/fingerass_self
	description = "Пальчики. Поиграться со своей задницей."
	interaction_sound = null
	require_user_hands = TRUE
	require_user_anus = REQUIRE_EXPOSED
	user_is_target = TRUE
	max_distance = 0
	write_log_user = "fingered self"
	write_log_target = null

/datum/interaction/lewd/fingerass_self/display_interaction(mob/living/user)

	user.visible_message(span_lewd("<b>\The [user]</b> [pick(
		"погружает палец в свой сфинктер.",
		"суёт палец в своё анальное колечко.",
		"разрабатывает своё анальное кольцо собственного пальца.")]"), ignored_mobs = user.get_unconsenting())
	playlewdinteractionsound(get_turf(user), 'modular_sand/sound/interactions/champ_fingering.ogg', 50, 1, -1)
	user.handle_post_sex(NORMAL_LUST, CUM_TARGET_HAND, user, CUM_TARGET_ANUS) //SPLURT edit

/datum/interaction/lewd/finger_self
	description = "Пальчики. Поиграться со своей вагиной."
	require_user_hands = TRUE
	require_user_vagina = REQUIRE_EXPOSED
	interaction_sound = null
	user_is_target = TRUE
	max_distance = 0
	write_log_user = "fingered own pussy"
	write_log_target = null

	additional_details = list(
		list(
			"info" = "You can fill a container if you hold it in your hand or pull it",
			"icon" = "flask",
			"color" = "transparent"
			)
	)

/datum/interaction/lewd/finger_self/display_interaction(mob/living/user)

	var/obj/item/reagent_containers/liquid_container

	var/obj/item/cached_item = user.get_active_held_item()
	if(istype(cached_item, /obj/item/reagent_containers))
		liquid_container = cached_item
	else
		cached_item = user.pulling
		if(istype(cached_item, /obj/item/reagent_containers))
			liquid_container = cached_item

	var/message = pick(
		"погружает палец в свою киску",
		"тихо выдыхает и всовывает палец в своё влагалище",
		"играется со своей киской",
		"разрабатывает своё влагалище своим пальчиком")
	if(!user.is_fucking(user, CUM_TARGET_HAND, user.getorganslot(ORGAN_SLOT_VAGINA)))
		user.set_is_fucking(user, CUM_TARGET_HAND, user.getorganslot(ORGAN_SLOT_VAGINA))

	if(liquid_container)
		message += " прямо в [liquid_container]"

	user.visible_message(span_lewd("<b>\The [user]</b> [message]."), ignored_mobs = user.get_unconsenting())
	playlewdinteractionsound(get_turf(user), 'modular_sand/sound/interactions/champ_fingering.ogg', 50, 1, -1)
	user.handle_post_sex(NORMAL_LUST, CUM_TARGET_HAND, liquid_container ? liquid_container : user, ORGAN_SLOT_VAGINA)
