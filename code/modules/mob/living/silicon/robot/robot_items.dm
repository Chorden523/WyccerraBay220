//A portable analyzer, for research borgs.  This is better then giving them a gripper which can hold anything and letting them use the normal analyzer.
/obj/item/portable_destructive_analyzer
	name = "Portable Destructive Analyzer"
	icon = 'icons/obj/tools/portable_analyzer.dmi'
	icon_state = "portable_analyzer"
	desc = "Similar to the stationary version, this rather unwieldy device allows you to break down objects in the name of science."

	var/min_reliability = 90 //Can't upgrade, call it laziness or a drawback

	var/datum/research/techonly/files 	//The device uses the same datum structure as the R&D computer/server.
										//This analyzer can only store tech levels, however.

	var/obj/item/loaded_item	//What is currently inside the analyzer.

/obj/item/portable_destructive_analyzer/New()
	..()
	files = new /datum/research/techonly(src) //Setup the research data holder.

/obj/item/portable_destructive_analyzer/attack_self(user as mob)
	var/response = alert(user, 	"Analyzing the item inside will *DESTROY* the item for good.\n\
							Syncing to the research server will send the data that is stored inside to research.\n\
							Ejecting will place the loaded item onto the floor.",
							"What would you like to do?", "Analyze", "Sync", "Eject")
	if(response == "Analyze")
		if(loaded_item)
			var/confirm = alert(user, "This will destroy the item inside forever.  Are you sure?","Confirm Analyze","Yes","No")
			if(confirm == "Yes" && !QDELETED(loaded_item)) //This is pretty copypasta-y
				to_chat(user, "You activate the analyzer's microlaser, analyzing \the [loaded_item] and breaking it down.")
				flick("portable_analyzer_scan", src)
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				for(var/T in loaded_item.origin_tech)
					files.update_tech(T, loaded_item.origin_tech[T])
					to_chat(user, "\The [loaded_item] had level [loaded_item.origin_tech[T]] in [GLOB.tech_id_to_name[T]].")
				loaded_item = null
				for(var/obj/I in contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I,/obj/item/stack/material))//Only deconstructs one sheet at a time instead of the entire stack
						var/obj/item/stack/material/S = I
						if(S.use(1))
							loaded_item = S
						else
							qdel(S)
							desc = initial(desc)
							icon_state = initial(icon_state)
					else
						qdel(I)
						desc = initial(desc)
						icon_state = initial(icon_state)
			else
				return
		else
			to_chat(user, "The [src] is empty.  Put something inside it first.")
	if(response == "Sync")
		var/success = 0
		for(var/obj/machinery/r_n_d/server/S as anything in SSmachines.get_machinery_of_type(/obj/machinery/r_n_d/server))

			for(var/datum/tech/known_tech as anything in files.known_tech) //Uploading
				S.files.add_tech_to_known(known_tech)

			for(var/datum/tech/known_tech as anything in S.files.known_tech) //Downloading
				files.add_tech_to_known(known_tech)

			success = 1
			files.refresh_research()
		if(success)
			to_chat(user, "You connect to the research server, push your data upstream to it, then pull the resulting merged data from the master branch.")
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 1)
		else
			to_chat(user, "Reserch server ping response timed out.  Unable to connect.  Please contact the system administrator.")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 1)
	if(response == "Eject")
		if(loaded_item)
			loaded_item.dropInto(loc)
			desc = initial(desc)
			icon_state = initial(icon_state)
			loaded_item = null
		else
			to_chat(user, "The [src] is already empty.")


/obj/item/portable_destructive_analyzer/use_after(atom/target, mob/living/user, click_parameters)
	if(!isitem(target))
		return FALSE
	if(!isturf(target.loc)) // Don't load up stuff if it's inside a container or mob!
		return FALSE
	if(loaded_item)
		to_chat(user, SPAN_WARNING("\The [src] already has something inside.  Analyze or eject it first."))
		return TRUE

	var/obj/item/I = target
	I.forceMove(src)
	loaded_item = I
	for(var/mob/M in viewers())
		M.show_message(text(SPAN_NOTICE("[user] adds the [I] to the [src].")), 1)
	desc = initial(desc) + "<br>It is holding \the [loaded_item]."
	flick("portable_analyzer_load", src)
	icon_state = "portable_analyzer_full"
	return TRUE

/obj/item/party_light
	name = "party light"
	desc = "An array of LEDs in tons of colors."
	icon = 'icons/obj/structures/lighting.dmi'
	icon_state = "partylight-off"
	item_state = "partylight-off"
	var/activated = 0
	var/strobe_effect = null

/obj/item/party_light/attack_self()
	if (activated)
		deactivate_strobe()
	else
		activate_strobe()

/obj/item/party_light/on_update_icon()
	if (activated)
		icon_state = "partylight-on"
		set_light(7, 1)
	else
		icon_state = "partylight_off"
		set_light(0)

/obj/item/party_light/proc/activate_strobe()
	activated = 1

	// Create the party light effect and place it on the turf of who/whatever has it.
	var/turf/T = get_turf(src)
	var/obj/party_light/L = new(T)
	strobe_effect = L

	// Make the light effect follow this party light object.
	GLOB.moved_event.register(src, L, TYPE_PROC_REF(/atom/movable, move_to_turf_or_null))

	update_icon()

/obj/item/party_light/proc/deactivate_strobe()
	activated = 0

	// Cause the party light effect to stop following this object, and then delete it.
	GLOB.moved_event.unregister(src, strobe_effect, TYPE_PROC_REF(/atom/movable, move_to_turf_or_null))
	QDEL_NULL(strobe_effect)

	update_icon()

/obj/item/party_light/Destroy()
	deactivate_strobe()
	. = .. ()

/obj/party_light
	name = "party light"
	desc = "This is probably bad for your eyes."
	icon = 'icons/effects/lens_flare.dmi'
	icon_state = "party_strobe"
	simulated = FALSE
	anchored = TRUE
	pixel_x = -30
	pixel_y = -4

/obj/party_light/Initialize()
	update_icon()
	. = ..()

//This is used to unlock other borg covers.
/obj/item/card/robot //This is not a child of id cards, as to avoid dumb typechecks on computers.
	name = "access code transmission device"
	icon_state = "robot_base"
	desc = "A circuit grafted onto the bottom of an ID card.  It is used to transmit access codes into other robot chassis, \
	allowing you to lock and unlock other robots' panels."

//A harvest item for serviceborgs.
/obj/item/robot_harvester
	name = "auto harvester"
	desc = "A hand-held harvest tool that resembles a sickle.  It uses energy to cut plant matter very efficently."
	icon = 'icons/obj/weapons/other.dmi'
	icon_state = "autoharvester"

/obj/item/robot_harvester/use_after(atom/target, mob/living/user, click_parameters)
	if(!istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		to_chat(user, SPAN_WARNING("Harvesting \a [target] is not the purpose of this tool. \The [src] is for plants being grown."))
		return TRUE

	var/obj/machinery/portable_atmospherics/hydroponics/T = target
	if(T.harvest) //Try to harvest, assuming it's alive.
		T.harvest(user)
	else if(T.dead) //It's probably dead otherwise.
		T.remove_dead(user)
	return TRUE

// A special tray for the service droid. Allow droid to pick up and drop items as if they were using the tray normally
// Click on table to unload, click on item to load. Otherwise works identically to a tray.
// Unlike the base item "tray", robotrays ONLY pick up food, drinks and condiments.

/obj/item/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

/obj/item/tray/robotray/can_add_item(obj/item/I)
	return ..() && istype(I, /obj/item/reagent_containers)




// A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/pen/robopen/attack_self(mob/user as mob)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)

	switch(choice)

		if("Colour")
			var/newcolour = input("Which colour would you like to use?") as null|anything in list("black","blue","red","green","yellow")
			if(newcolour) colour = newcolour

		if("Mode")
			if (mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")

	return

// Copied over from paper's rename verb
// see code/modules/paperwork/paper.dm line 62

/obj/item/pen/robopen/proc/RenamePaper(mob/user, obj/item/paper/paper)
	if ( !user || !paper )
		return
	var/n_name = sanitizeSafe(input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text, 32)
	if ( !user || !paper )
		return

	//n_name = copytext(n_name, 1, 32)
	if(( get_dist(user,paper) <= 1  && user.stat == 0))
		paper.SetName("paper[(n_name ? text("- '[n_name]'") : null)]")
		paper.last_modified_ckey = user.ckey
	add_fingerprint(user)
	return

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/form_printer/use_after(atom/target, mob/living/user, click_parameters)
	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))
		return TRUE

/obj/item/form_printer/attack_self(mob/user as mob)
	deploy_paper(get_turf(src))

/obj/item/form_printer/proc/deploy_paper(turf/T)
	T.visible_message(SPAN_NOTICE("\The [src.loc] dispenses a sheet of crisp white paper."))
	new /obj/item/paper(T)


//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/structures/decals.dmi'
	icon_state = "shock"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/structures/decals.dmi'
	icon_state = "shock"

/obj/item/inflatable_dispenser
	name = "inflatables dispenser"
	desc = "Hand-held device which allows rapid deployment and removal of inflatables."
	icon = 'icons/obj/tools/inflatable_dispenser.dmi'
	icon_state = "inf_deployer"
	item_state = "RPED"
	w_class = ITEM_SIZE_LARGE

	var/stored_walls = 5
	var/stored_doors = 2
	var/max_walls = 5
	var/max_doors = 2
	var/mode = 0 // 0 - Walls   1 - Doors

/obj/item/inflatable_dispenser/robot
	w_class = ITEM_SIZE_HUGE
	stored_walls = 10
	stored_doors = 5
	max_walls = 10
	max_doors = 5

/obj/item/inflatable_dispenser/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It has [stored_walls] wall segment\s and [stored_doors] door segment\s stored.")
	. += SPAN_NOTICE("It is set to deploy [mode ? "doors" : "walls"]")

/obj/item/inflatable_dispenser/attack_self()
	mode = !mode
	to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

/obj/item/inflatable_dispenser/use_after(atom/target, mob/living/user, click_parameters)
	if (loc != user)
		return
	var/turf/T = get_turf(target)
	if (!user.TurfAdjacent(T))
		return

	if (istype(target, /obj/structure/inflatable))
		if (!do_after(user, 0.5 SECONDS, target, DO_PUBLIC_UNIQUE))
			return TRUE
		playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
		var/obj/item/inflatable/I
		if (istype(target, /obj/structure/inflatable/door))
			if (stored_doors < max_doors)
				++stored_doors
			else
				I = new /obj/item/inflatable/door(T)
		else
			if (stored_walls < max_walls)
				++stored_walls
			else
				I = new /obj/item/inflatable/wall(T)
		user.visible_message(
			SPAN_ITALIC("\The [user] picks up \an [target] with \an [src]."),
			SPAN_NOTICE("You deflate \the [target] with \the [src]."),
			SPAN_ITALIC("You can hear rushing air."),
			range = 5
		)
		if (I)
			var/obj/structure/inflatable/S = target
			copy_health(S, I)
		qdel(target)
		return TRUE

	else if (istype(target, /obj/item/inflatable))
		var/collected = FALSE
		if (istype(target, /obj/item/inflatable/door))
			if (stored_doors < max_doors)
				++stored_doors
				collected = TRUE
		else
			if (stored_walls < max_walls)
				++stored_walls
				collected = TRUE
		if (collected)
			user.visible_message(
				SPAN_ITALIC("\The [user] picks up \an [target] with \an [src]."),
				SPAN_ITALIC("You pick up \the [target] with \the [src]."),
				range = 3
			)
			qdel(target)
		else
			to_chat(user, SPAN_WARNING("\The [src] is already full of those."))
		return TRUE

	else
		var/active_mode = mode
		if (active_mode ? (!stored_doors) : (!stored_walls))
			to_chat(user, SPAN_WARNING("\The [src] is out of [active_mode ? "doors" : "walls"]."))
			return TRUE
		var/obstruction = T.get_obstruction()
		if (obstruction)
			to_chat(user, SPAN_WARNING("\The [english_list(obstruction)] is blocking that spot."))
			return TRUE
		if (!do_after(user, 0.5 SECONDS, T, DO_PUBLIC_UNIQUE))
			return TRUE
		obstruction = T.get_obstruction()
		if (obstruction)
			to_chat(user, SPAN_WARNING("\The [english_list(obstruction)] is blocking that spot."))
			return TRUE
		var/placed
		if (active_mode)
			placed = new /obj/structure/inflatable/door(T)
			--stored_doors
		else
			placed = new /obj/structure/inflatable/wall(T)
			--stored_walls
		user.visible_message(
			SPAN_ITALIC("\The [user] inflates \an [placed]."),
			SPAN_NOTICE("You inflate \an [placed]."),
			range = 5
		)
		playsound(loc, 'sound/items/zip.ogg', 75, 1)
		return TRUE
/obj/item/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 150

/obj/item/robot_rack
	name = "a generic robot rack"
	desc = "A rack for carrying large items as a robot."
	var/object_type                    //The types of object the rack holds (subtypes are allowed).
	var/interact_type                  //Things of this type will trigger attack_hand when attacked by this.
	var/capacity = 1                   //How many objects can be held.
	/// Whether to attack_self on objects as they're deployed
	var/attack_self_on_deploy = TRUE
	var/list/obj/item/held = list()    //What is being held.

/obj/item/robot_rack/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It can hold up to [capacity] item[capacity == 1 ? "" : "s"].")

/obj/item/robot_rack/Initialize(mapload, starting_objects = 0)
	. = ..()
	for(var/i = 1, i <= min(starting_objects, capacity), i++)
		held += new object_type(src)

/obj/item/robot_rack/attack_self(mob/user)
	if(!length(held))
		to_chat(user, SPAN_WARNING("\The [src] is empty."))
		return
	var/obj/item/R = held[length(held)]
	R.dropInto(loc)
	held -= R
	if (attack_self_on_deploy)
		R.attack_self(user) // deploy it
	to_chat(user, SPAN_NOTICE("You deploy \a [R]."))
	R.add_fingerprint(user)

/obj/item/robot_rack/resolve_attackby(obj/O, mob/user, click_params)
	if(istype(O, object_type))
		if(length(held) < capacity)
			to_chat(user, SPAN_NOTICE("You collect \the [O]."))
			O.forceMove(src)
			held += O
			return
		to_chat(user, SPAN_WARNING("\The [src] is full and can't store any more items."))
		return
	if(istype(O, interact_type))
		O.attack_hand(user)
		return
	. = ..()

/obj/item/robot_rack/verb/empty_rack()
	set name = "Empty Rack"
	set desc = "Empty all items from the rack."
	set category = "Silicon Commands"
	if(!length(held))
		to_chat(usr, SPAN_WARNING("\The [src] is empty."))
		return
	while(length(held))
		attack_self(usr)

/obj/item/bioreactor
	name = "bioreactor"
	desc = "An integrated power generator that runs on most kinds of biomass."
	icon = 'icons/obj/structures/portgen.dmi'
	icon_state = "portgen0"

	var/base_power_generation = 75 KILOWATTS
	var/max_fuel_items = 5
	var/list/fuel_types = list(
		/obj/item/reagent_containers/food/snacks/meat = 2,
		/obj/item/reagent_containers/food/snacks/fish = 1.5
	)

/obj/item/bioreactor/attack_self(mob/user)
	if(length(contents) >= 1)
		var/obj/item/removing = contents[1]
		user.put_in_hands(removing)
		to_chat(user, SPAN_NOTICE("You remove \the [removing] from \the [src]."))
	else
		to_chat(user, SPAN_WARNING("There is nothing loaded into \the [src]."))

/obj/item/bioreactor/use_after(atom/movable/target, mob/living/user, click_parameters)
	if(!istype(target))
		return FALSE

	var/is_fuel = istype(target, /obj/item/reagent_containers/food/snacks/grown)
	is_fuel = is_fuel || is_type_in_list(target, fuel_types)

	if(!is_fuel)
		to_chat(user, SPAN_WARNING("\The [target] cannot be used as fuel by \the [src]."))
		return TRUE
	if(length(contents) >= max_fuel_items)
		to_chat(user, SPAN_WARNING("\The [src] can fit no more fuel inside."))
		return TRUE

	target.forceMove(src)
	to_chat(user, SPAN_NOTICE("You load \the [target] into \the [src]."))
	return TRUE

/obj/item/bioreactor/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/bioreactor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/bioreactor/Process()
	var/mob/living/silicon/robot/R = loc
	if(!istype(R) || !R.cell || R.cell.fully_charged() || !length(contents))
		return

	var/generating_power
	var/using_item

	for(var/thing in contents)
		var/atom/A = thing
		if(istype(A, /obj/item/reagent_containers/food/snacks/grown))
			generating_power = base_power_generation
			using_item = A
		else
			for(var/fuel_type in fuel_types)
				if(istype(A, fuel_type))
					generating_power = fuel_types[fuel_type] * base_power_generation
					using_item = A
					break
		if(using_item)
			break

	if(istype(using_item, /obj/item/stack))
		var/obj/item/stack/stack = using_item
		stack.use(1)
	else if(using_item)
		qdel(using_item)

	if(generating_power)
		R.cell.give(generating_power * CELLRATE)
