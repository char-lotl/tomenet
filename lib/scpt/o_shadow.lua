-- handle the occultism school ('shadow magic')

OFEAR_I = add_spell {
	["name"] = 	"Cause Fear I",
	["name2"] = 	"Fear I",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	1,
	["mana"] = 	2,
	["mana_max"] = 	2,
	["fail"] = 	0,
	["stat"] = 	A_WIS,
	["direction"] = FALSE,
	["spell"] = 	function(args)
		fire_ball(Ind, GF_TURN_ALL, 0, 5 + get_level(Ind, OFEAR_I, 65), 1, "hisses")
	end,
	["info"] = 	function()
		return "power "..(5 + get_level(Ind, OFEAR_I, 65))
	end,
	["desc"] = { "Temporarily scares all adjacent creatures.", }
}
__lua_OFEAR = OFEAR_I
OFEAR_II = add_spell {
	["name"] = 	"Cause Fear II",
	["name2"] = 	"Fear II",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	14,
	["mana"] = 	12,
	["mana_max"] = 	12,
	["fail"] = 	-30,
	["stat"] = 	A_WIS,
	["direction"] = FALSE,
	["spell"] = 	function()
		project_los(Ind, GF_TURN_ALL, 5 + get_level(Ind, OFEAR_I, 65), "hisses")
	end,
	["info"] = 	function()
		return "power "..(5 + get_level(Ind, OFEAR_I, 65))
	end,
	["desc"] = { "Temporarily scares all creatures in sight.", }
}

OBLIND_I = add_spell {
	["name"] = 	"Blindness",
	["name2"] = 	"Blind",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	3,
	["mana"] = 	2,
	["mana_max"] = 	2,
	["fail"] = 	0,
	["direction"] = TRUE,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_BLIND, args.dir, 5 + get_level(Ind, OBLIND_I, 80), "hisses")
	end,
	["info"] = 	function()
		return "power "..(5 + get_level(Ind, OBLIND_I, 80))
	end,
	["desc"] = { "Temporarily blinds a target.", }
}
OBLIND_II = add_spell {
	["name"] = 	"Darkness",
	["name2"] = 	"Dark",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	16,
	["mana"] = 	13,
	["mana_max"] = 	13,
	["fail"] = 	-30,
	["direction"] = FALSE,
	["spell"] = 	function()
		--1..gl(7) starting at rad 2, or just gl(9) starting at rad 1
		msg_print(Ind, "You are surrounded by darkness.")
		fire_ball(Ind, GF_DARK_WEAK, 0, 8192 + 10 + get_level(Ind, OBLIND_I, 80), 1 + get_level(Ind, OBLIND_II, 7), " calls darkness for")
	end,
	["info"] = 	function()
		return "power "..(10 + get_level(Ind, OBLIND_I, 80)).." rad "..(1 + get_level(Ind, OBLIND_II, 7))
	end,
	["desc"] = { "Causes a burst of darkness around you, blinding nearby foes.", }
}

DETECTINVIS = add_spell {
	["name"] = 	"Detect Invisible",
	["name2"] = 	"DetInv",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	8,
	["mana"] = 	3,
	["mana_max"] = 	3,
	["fail"] = 	10,
	["spell"] = 	function()
		detect_invisible(Ind)
	end,
	["info"] = 	function()
		--return "rad "..(10 + get_level(Ind, DETECTMONSTERS, 40))
		return ""
	end,
	["desc"] = 	{ "Detects all nearby invisible creatures.", }
}

OSLEEP_I = add_spell {
	["name"] = 	"Veil of Night I",
	["name2"] = 	"VoN I",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	5,
	["mana"] = 	3,
	["mana_max"] = 	3,
	["fail"] = 	0,
	["direction"] = TRUE,
	["stat"] = 	A_WIS,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_OLD_SLEEP, args.dir, 5 + get_level(Ind, OSLEEP_I, 80), "mumbles softly")
	end,
	["info"] = 	function()
		return "power "..(5 + get_level(Ind, OSLEEP_I, 80))
	end,
	["desc"] = { "Causes the target to fall asleep instantly.", }
}
OSLEEP_II = add_spell {
	["name"] = 	"Veil of Night II",
	["name2"] = 	"VoN II",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	20,--22
	["mana"] = 	19,
	["mana_max"] = 	19,
	["fail"] = 	-30,
	["direction"] = FALSE,
	["stat"] = 	A_WIS,
	["spell"] = 	function()
		fire_wave(Ind, GF_OLD_SLEEP, 0, 5 + get_level(Ind, OSLEEP_I, 80), 1, 10, 3, EFF_WAVE, "mumbles softly")
	end,
	["info"] = 	function()
		return "power "..(5 + get_level(Ind, OSLEEP_I, 80)).." rad 10"
	end,
	["desc"] = { "Expanding veil that lets monsters fall asleep.", }
}

function get_darkbolt_dam(Ind, limit_lev)
	local lev

	lev = get_level(Ind, DARKBOLT_I, 50)
	if limit_lev ~= 0 and lev > limit_lev then lev = limit_lev + (lev - limit_lev) / 3 end

	return 5 + ((lev * 3) / 5), 7 + ((lev * 2) / 3)
end
DARKBOLT_I = add_spell {
	["name"] = 	"Shadow Bolt I",
	["name2"] = 	"SBolt I",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	6,
	["mana"] = 	3,
	["mana_max"] = 	3,
	["fail"] = 	-6,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_DARK, args.dir, damroll(get_darkbolt_dam(Ind, 1)), " casts a shadow bolt for")
	end,
	["info"] = 	function()
		local x, y

		x, y = get_darkbolt_dam(Ind, 1)
		return "dam "..x.."d"..y
	end,
	["desc"] = 	{ "Conjures up darkness into a powerful bolt.", }
}
DARKBOLT_II = add_spell {
	["name"] = 	"Shadow Bolt II",
	["name2"] = 	"SBolt II",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	25,
	["mana"] = 	6,
	["mana_max"] = 	6,
	["fail"] = 	-40,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_DARK, args.dir, damroll(get_darkbolt_dam(Ind, 15)), " casts a shadow bolt for")
	end,
	["info"] = 	function()
		local x, y

		x, y = get_darkbolt_dam(Ind, 15)
		return "dam "..x.."d"..y
	end,
	["desc"] = 	{ "Conjures up darkness into a powerful bolt.", }
}
DARKBOLT_III = add_spell {
	["name"] = 	"Shadow Bolt III",
	["name2"] = 	"SBolt III",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	40,
	["mana"] = 	12,
	["mana_max"] = 	12,
	["fail"] = 	-80,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_DARK, args.dir, damroll(get_darkbolt_dam(Ind, 0)), " casts a shadow bolt for")
	end,
	["info"] = 	function()
		local x, y

		x, y = get_darkbolt_dam(Ind, 0)
		return "dam "..x.."d"..y
	end,
	["desc"] = 	{ "Conjures up darkness into a powerful bolt.", }
}

POISONRES = add_spell {
	["name"] = 	"Aspect of Peril",
	["name2"] = 	"AoP",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	10,
	["mana"] = 	15,
	["mana_max"] = 	15,
	["fail"] = 	-10,
	["spell"] = 	function()
		local dur

		dur = randint(15) + 20 + get_level(Ind, POISONRES, 25)
		set_melee_brand(Ind, dur, TBRAND_POIS, 0, TRUE, TRUE)
		fire_ball(Ind, GF_TBRAND_POIS, 0, dur, 2, " calls perilous shadows imbuing you.")
		if get_level(Ind, POISONRES, 50) >= 10 then
			set_oppose_pois(Ind, dur)
			fire_ball(Ind, GF_RESPOIS_PLAYER, 0, dur, 2, "")
		end
	end,
	["info"] = 	function()
		return "dur "..(20 + get_level(Ind, POISONRES, 25)).."+d15"
	end,
	["desc"] = 	{
		"It temporarily bestows the touch of poison on your melee weapons.",
		"At level 10 it grants temporary poison resistance.",
		"***Automatically projecting***",
	}
}

OBLINK = add_spell {
	["name"] = 	"Retreat",
	["name2"] = 	"Retr",
	["school"] = 	{SCHOOL_OSHADOW},
	["level"] = 	8,
	["extrareq"] = 	SKILL_CONVEYANCE,
	["extralev"] = 	5000,
	["mana"] = 	5,
	["mana_max"] = 	5,
	["fail"] = 	-7,
	["spell"] = 	function()
		local dist = 3 + get_level(Ind, OBLINK, 69) / 17

		retreat_player(Ind, dist)
	end,
	["info"] = 	function()
		if players(Ind).s_info[SKILL_CONVEYANCE + 1].value < 5000 then
			return "REQ: Conveyance 5.000"
		else
			return "distance "..(3 + get_level(Ind, OBLINK, 69) / 17)
		end
	end,
	["desc"] = 	{ "Fade away from your current target, if any.", },
}

SHADOWGATE = add_spell {
	["name"] = 	"Shadow Gate",
	["name2"] = 	"SGate",
	["school"] = 	{SCHOOL_OSHADOW, SCHOOL_CONVEYANCE},
	["level"] = 	23,
	["extrareq"] = 	SKILL_CONVEYANCE,
	["extralev"] = 	10000,
	["am"] = 	75,
	["spell_power"] = 0,
	["mana"] = 	6,
	["mana_max"] = 	6,
	["fail"] = 	-50,
	["spell"] = 	function()
		--begin at ANNOY_DISTANCE as a minimum, to overcome
		do_shadow_gate(Ind, 4 + get_level(Ind, SHADOWGATE, 12))
		end,
	["info"] = 	function()
		if players(Ind).s_info[SKILL_CONVEYANCE + 1].value < 10000 then
			return "REQ: Conveyance 10.000"
		else
			return "range "..(4 + get_level(Ind, SHADOWGATE, 12))
		end
	end,
	["desc"] = 	{
		"Teleports you to the nearest opponent in line of sight",
		"within a maximum range that increases with skill.",
		"Your next immediate strike hits that target critically",
		"(provided you don't miss) and dually (if you dual-wield)."
	}
}

OLEVITATION = add_spell {
	["name"] = 	"Shadow Stream",
	["name2"] = 	"Stream",
	["school"] = 	{SCHOOL_OSHADOW},
	["level"] = 	18,
	["mana"] = 	14,
	["mana_max"] = 	14,
	["fail"] = 	-20,
	["spell"] = 	function()
		if get_level(Ind, OLEVITATION, 50) >= 10 then set_tim_lev(Ind, randint(10) + 10 + get_level(Ind, OLEVITATION, 25))
		else set_tim_ffall(Ind, randint(10) + 10 + get_level(Ind, OLEVITATION, 25))
		end
	end,
	["info"] = 	function()
		return "dur "..(10 + get_level(Ind, OLEVITATION, 25)).."+d10"
	end,
	["desc"] = 	{
		"Grants you feather falling.",
		"At level 10 it grants you levitation on a stream of shadows."
	}
}

function get_darkbeam_dam(Ind, limit_lev)
	local lev

	lev = get_level(Ind, DARKBEAM_I, 50)
	if limit_lev ~= 0 and lev > limit_lev then lev = limit_lev + (lev - limit_lev) / 3 end

	return 6 + ((lev * 3) / 6), 8 + ((lev * 3) / 3) + 1
end

DARKBEAM_I = add_spell {
	["name"] = 	"Darkness Rift I",
	["name2"] = 	"DRift I",
	["school"] = 	SCHOOL_OSHADOW,
	["spell_power"] = 0,
	["level"] = 	21,
	["mana"] = 	9,
	["mana_max"] = 	9,
	["fail"] = 	-10,
	["stat"] = 	A_WIS,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
			fire_beam(Ind, GF_DARK, args.dir, damroll(get_darkbeam_dam(Ind, 10)), " casts a rift of darkness for")
	end,
	["info"] = 	function()
			local xx, yy

			xx, yy = get_darkbeam_dam(Ind, 10)
			return "dam "..xx.."d"..yy
	end,
	["desc"] = 	{
			"Forms a long rift of unbearable darkness.",
		}
}
DARKBEAM_II = add_spell {
	["name"] = 	"Darkness Rift II",
	["name2"] = 	"DRift II",
	["school"] = 	SCHOOL_OSHADOW,
	["spell_power"] = 0,
	["level"] = 	39,
	["mana"] = 	18,
	["mana_max"] = 	18,
	["fail"] = 	-100,
	["stat"] = 	A_WIS,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
			fire_beam(Ind, GF_DARK, args.dir, damroll(get_darkbeam_dam(Ind, 0)), " casts a rift of darkness for")
	end,
	["info"] = 	function()
			local xx, yy

			xx, yy = get_darkbeam_dam(Ind, 0)
			return "dam "..xx.."d"..yy
	end,
	["desc"] = 	{
			"Forms a long rift of unbearable darkness.",
		}
}

-- Grants invisibility (and the 'Shrouded' effect on unlit grids, currently disabled)
OINVIS = add_spell {
	["name"] = 	"Shadow Shroud",
	["name2"] = 	"Shroud",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	30,
	["mana"] = 	30,
	["mana_max"] = 	30,
	["fail"] = 	-40,
	["spell"] = 	function()
		local dur = randint(20) + 15 + get_level(Ind, OINVIS, 50)

		set_invis(Ind, dur, 20 + get_level(Ind, OINVIS, 50))
		--set_shroud(Ind, dur, 10 + get_level(Ind, OINVIS, 50) / 2)
	end,
	["info"] = 	function()
		return "dur "..(15 + get_level(Ind, OINVIS, 50)).."+d20 power "..(20 + get_level(Ind, OINVIS, 50))
		--.."/"..(10 + get_level(Ind, OINVIS, 50) / 2)
	end,
	["desc"] = 	{
		"Grants invisibility.",
		--"If you are standing on a non-lit grid (and not using any light source)",
		--"it will make it especially hard for monsters to hit you in melee.",
	}
}

function get_chaosbolt_dam(Ind)
	local lev

	lev = get_level(Ind, CHAOSBOLT, 50) + 21
	return 0 + (lev * 3) / 5, 1 + lev
end
CHAOSBOLT = add_spell {
	["name"] = 	"Chaos Bolt",
	["name2"] = 	"CBolt",
	["school"] = 	{SCHOOL_OSHADOW, SCHOOL_HOFFENSE},
	["spell_power"] = 0,
	["level"] = 	30,
	["mana"] = 	16,
	["mana_max"] = 	20,
	["fail"] = 	-55,
	["stat"] = 	A_WIS,
	["direction"] = TRUE,
	["ftk"] = 	1,
	["spell"] = 	function(args)
		fire_bolt(Ind, GF_CHAOS, args.dir, damroll(get_chaosbolt_dam(Ind)), " casts a chaos bolt for")
	end,
	["info"] = 	function()
		local x, y

		x, y = get_chaosbolt_dam(Ind)
		return "dam "..x.."d"..y
	end,
	["desc"] = 	{ "Channels the powers of chaos into a bolt.", }
}

DISPERSION = add_spell {
	["name"] = 	"Dispersion",
	["name2"] = 	"Disp",
	["school"] = 	{SCHOOL_OSHADOW},
	["level"] = 	33,
	["mana"] = 	40,
	["mana_max"] = 	40,
	["fail"] = 	-65,
	["stat"] = 	A_INT,
	["spell"] = 	function()
		set_dispersion(Ind, 50 - get_level(Ind, DISPERSION, 72), 35 + get_level(Ind, DISPERSION, 30));
	end,
	["info"] = 	function()
		return "dur "..(35 + get_level(Ind, DISPERSION, 30))..", 1 ST cost: "..(50 - get_level(Ind, DISPERSION, 72)).."%"
	end,
	["desc"] = 	{
		"Evade melee and bolt attacks by dispersing into shadow form",
		"at a certain chance per evaded attack to deplete 1 point of stamina.",
		"The spell will automatically end if your stamina is depleted.",
		"Stamina will not regenerate while Dispersion is active.",
	}
}
STOPDISPERSION = add_spell {
	["name"] = 	"Stop Dispersion",
	["name2"] = 	"SDisp",
	["school"] = 	{SCHOOL_OSHADOW},
	["level"] = 	33,
	["mana"] = 	0,
	["mana_max"] = 	0,
	["fail"] = 	101,
	["stat"] = 	A_INT,
	["spell"] = 	function()
		set_dispersion(Ind, 0, 0);
	end,
	["info"] = 	function()
		return ""
	end,
	["desc"] = 	{ "Stop dispersion into shadow form.", }
}

ODRAINLIFE = add_spell {
	["name"] = 	"Drain Life",
	["name2"] = 	"Drain",
	["school"] = 	{SCHOOL_OSHADOW, SCHOOL_NECROMANCY},
	["spell_power"] = 0,
	["am"] = 	75,
	["level"] = 	37,
	["mana"] = 	40,
	["mana_max"] = 	40,
	["fail"] = 	-60,
	["stat"] = 	A_WIS,
	["direction"] = TRUE,
	["spell"] = 	function(args)
		drain_life(Ind, args.dir, 14 + get_level(Ind, ODRAINLIFE, 22))
		hp_player(Ind, player.ret_dam / 4, FALSE, FALSE)
	end,
	["info"] = 	function()
		return (14 + get_level(Ind, ODRAINLIFE, 22)).."% (max 900), 25% heal"
	end,
	["desc"] = 	{ "Drains life from a target, which must not be non-living or undead.", }
}

DARKBALL = add_spell {
	["name"] = 	"Darkness Storm",
	["name2"] = 	"DStorm",
	["school"] = 	{SCHOOL_OSHADOW},
	["spell_power"] = 0,
	["level"] = 	42,
	["mana"] = 	27,
	["mana_max"] = 	27,
	["fail"] = 	-90,
	["direction"] = TRUE,
	["ftk"] = 	2,
	["spell"] = 	function(args)
			fire_ball(Ind, GF_DARK, args.dir, rand_int(100) + 390 + get_level(Ind, DARKBALL, 1500), 3, " conjures up a darkness storm for")
	end,
	["info"] = 	function()
		return "dam d100+"..(390 + get_level(Ind, DARKBALL, 1500)).." rad 3"
	end,
	["desc"] = 	{ "Conjures up a storm of darkness.", }
}
