import <__telegram_data.ash>;

/* Passive Damage dealing stuff, used in Granny Hackleton boss fight */
static boolean[item] PASSIVE_DMG_COMBAT_ITEMS = $items[gas can, old school beer pull tab, cold mashed potatoes, paint bomb, crazy hobo notebook, bag of gross foreign snacks, possessed tomato, hand grenegg, Colon Annihilation Hot Sauce, jagged scrap metal, jigsaw blade, throwing fork, dinner roll, whole turkey leg, skull with a fuse in it, nastygeist];
static boolean[item] PASSIVE_DMG_EFFECT_ITEMS = $items[monkey barf, half-digested coal, beard incense, spooky sound effects record, glowing syringe];
static boolean[skill] PASSIVE_DMG_EFFECT_BUFFS = $skills[Jalape&ntilde;o Saucesphere, The Psalm of Pointiness, Scarysauce];
static boolean[item] PASSIVE_DMG_EQUIPMENT = $items[double-ice cap, cup of infinite pencils, dubious loincloth, ironic oversized sunglasses, MagiMechTech NanoMechaMech, cannonball charrrm bracelet, ant pick, tiny bowler];

static boolean[item] HOT_RES_EFFECT_ITEMS = $items[SPF 451 lip balm, drop of water-37, cocoa chondrule, lotion of sleaziness, lotion of stench, hot powder, magenta seashell];
static boolean[item] SPOOKY_RES_EFFECT_ITEMS = $items[black eyedrops, lotion of stench, spooky sap, lotion of hotness, ectoplasmic orbs, marzipan skull, spooky powder];
static boolean[skill] ELEM_RES_EFFECT_BUFFS = $skills[Elemental Saucesphere, Astral Shell];

static boolean[item] STAT_BUFF_ITEMS = $items[tomato juice of powerful power, potion of temporary gr8ness, Ferrigno's Elixir of Power, philter of phorce, Trivial Avocations Card: What?, Trivial Avocations Card: When?, Trivial Avocations Card: Where?, Trivial Avocations Card: Who?];

static item[string] UNUSUAL_CONSTRUCT_DISC_MAP = {
  "BE": $item[strange disc (green)],
  "JADE": $item[strange disc (green)],
  "BELA" : $item[strange disc (blue)],
  "COBALT" : $item[strange disc (blue)],
  "BU" : $item[strange disc (blue)],
  "BULAZAK"	: $item[strange disc (blue)],
  "SAPPHIRE" : $item[strange disc (blue)],
  "BUPABU" : $item[strange disc (black)],
  "OBSIDIAN" : $item[strange disc (black)],
  "CHAKRO" : $item[strange disc (red)],
  "CRIMSON" : $item[strange disc (red)],
  "CHO" : $item[strange disc (yellow)],
  "GOLD" : $item[strange disc (yellow)],
  "FUFUGAKRO" : $item[strange disc (blue)],
  "ULTRAMARINE" : $item[strange disc (blue)],
  "FUNI" : $item[strange disc (yellow)],
  "CITRINE" : $item[strange disc (yellow)],
  "NIPA" : $item[strange disc (white)],
  "IVORY" : $item[strange disc (white)],
  "PACHA" : $item[strange disc (white)],
  "PEARL" : $item[strange disc (white)],
  "PATA" : $item[strange disc (black)],
  "EBONY" : $item[strange disc (black)],
  "SOM" : $item[strange disc (black)],
  "JET" : $item[strange disc (black)],
  "SOMPAPA" : $item[strange disc (white)],
  "ALABASTER" : $item[strange disc (white)],
  "TAZAK" : $item[strange disc (yellow)],
  "CANARY" : $item[strange disc (yellow)],
  "ZAKSOM" : $item[strange disc (green)],
  "EMERALD" : $item[strange disc (green)],
  "ZEVE" : $item[strange disc (red)],
  "RUBY" : $item[strange disc (red)],
  "ZEVEBENI" : $item[strange disc (green)],
  "VERDIGRIS" : $item[strange disc (green)],
  "ZEVESTANO" : $item[strange disc (red)],
  "VERMILLION" : $item[strange disc (red)],
};

static boolean[item] BLUNT_WEAPONS;
static{
  if(!file_to_map("telegram_blunt_weapons.txt", BLUNT_WEAPONS)){
    print("telegram was unable to load the blunt weapons file. Continuing.");
  }
}

 /*
  * Boss Fight Combat Filter.
  *
  * Mafia calls for each round of combat once the fight has started, custom logic
  * to deal with boss quirks should go here. These filters seem to require top
  * level scope.
  *
  * adventure(1, $location[Investigating a Plaintive Telegram], "__ltt_boss_fight_filter");
  */
string __ltt_boss_fight_filter(int round, monster opp, string text){
  static int[item] combat_items_used;
  static int die_1;
  static int die_2;
  boolean funksling = have_skill($skill[Ambidextrous Funkslinging]);

  if(round == 1){
    clear(combat_items_used);
    die_1 = 0;
    die_2 = 0;
  }
  if(opp == $monster[Granny Hackleton]){
    string use_item = "";
    boolean second = false;
    foreach i in PASSIVE_DMG_COMBAT_ITEMS {
      if(!(combat_items_used contains i)){
        combat_items_used[i] = 1;
        if(!second){
          use_item = "item " + i;
          second = true;
        } else if(funksling){
          use_item += ", " + i;
        } else{

        }
      }
    }
    return use_item;
  }
  if(opp == $monster[Unusual construct]){
    matcher word = create_matcher("LANO (.*?) NIZEVE", text);
    matcher translation = create_matcher("ROUTING (.*?) PHASE", text);
    string color = "";
    if(word.find()){
      color = word.group(1);
    } else if(translation.find()){
      color = translation.group(1);
    }

    if (color == "" || !(UNUSUAL_CONSTRUCT_DISC_MAP contains color)){
      print("Wasnt able to extract a knowns color from combat.");
      print("Extracted color: " + color);
      print(text);
      abort("Unable to determine which disc to use, see: https://kol.coldfront.net/thekolwiki/index.php/Unusual_construct");
    }

    string to_use = "item " + UNUSUAL_CONSTRUCT_DISC_MAP[color];
    if(funksling && item_amount($item[New Age hurting crystal]) > 0){
      to_use += ', ' + $item[New Age hurting crystal];
    }
    return to_use;
  }

  if(opp == $monster[Snake-Eyes Glenn]){
    print("I need the html from a round of combat from Snake-Eyes Glenn to implement smarter combat against him.");
    print("If possible please post the html source for a round of combat with a dice roll (not round 1) to: https://github.com/macgregor/kol-telegram/issues", "red");
  }

  if(opp == $monster[Pecos Dave]){
    matcher hit_round = create_matcher("He shoots a bunch of holes into you", text);
    matcher reload_round = create_matcher("His pistol jams", text);

    if(hit_round.find() || (my_hp() / my_maxhp()) < 0.9){
      string to_use = "";
      if(item_amount($item[New Age healing crystal]) > 0){
        to_use = "item " + $item[New Age healing crystal];
      } else{
        print("Uhh, I'm not very smart about healing right now. You might die. Good luck!", "red");
        return "";
      }
      if(funksling && item_amount($item[New Age hurting crystal]) > 0){
        to_use += ", " + $item[New Age hurting crystal];
      }
      return to_use;
    } else {
      return "attack";
    }
  }

  //nothing to special combat strategy for:
  //  * $monster[Former Sheriff Dan Driscoll]
  //  * $monster[Pharaoh Amoon-Ra Cowtep]
  //  * $monster[Daisy the Unclean]
  //  * $monster[Jeff the Fancy Skeleton]

  print("telegram boss fight filter out of actions, deferring to default CCS", "blue");
  return "";
}

monster __determine_boss(){
  monster boss = $monster[none];
  int difficulty = get_property("lttQuestDifficulty").to_int();

  if(difficulty == ACCEPT_EASY_QUEST){
    boss = EASY_QUESTS[get_property("lttQuestName")];
  } else if(difficulty == ACCEPT_MEDIUM_QUEST){
    boss = MEDIUM_QUESTS[get_property("lttQuestName")];
  } else if(difficulty == ACCEPT_HARD_QUEST){
    boss = HARD_QUESTS[get_property("lttQuestName")];
  }

  return boss;
}

void __print_boss_hint(monster boss){
  if(boss == $monster[Granny Hackleton]){
    print(boss + " - blocks attacks, skills, familiar actions and can only use combat items once each. Use buffs, equipment and items that deal passive damage over time.");
  }

  if(boss == $monster[Clara]){
    print(boss + " - damage softcapped at 500, cannot be staggers, blocks combat items, deals spooky and hot damage each round. Buff hot and spooky res to survive, fight with regular attacks or skills.");
  }

  if(boss == $monster[Unusual construct]){
    print(boss + " - deals hot damage each round, construct says something each round, the second word indicates what disc you need to use to survive the round. Without funkslinging you have to rely on passive damage to kill it.");
  }

  if(boss == $monster[Former Sheriff Dan Driscoll]){
    print(boss + " - most actions in combat will fail, passive damage sources and chefstaff jiggle's will work though.");
  }

  if(boss == $monster[Pharaoh Amoon-Ra Cowtep]){
    print(boss + " - gives large debuff at start of combat, attacks twice per turn, deals spooky damage each turn, reflects spells, immune to staggers and stuns. Buff up stats before fight or funksling healing/hurting crystals.");
  }

  if(boss == $monster[Snake-Eyes Glenn]){
    print(boss + " - has a variety of atributes each round based on two dice rolled the previous round. adjust combat tactics accordingly. See https://kol.coldfront.net/thekolwiki/index.php/Snake-Eyes_Glenn");
  }

  if(boss == $monster[Daisy the Unclean]){
    print(boss + " - immune to staggers and stuns, each time she hits you gain 1 adventure of a buff that gets stronger each time. Luckily she is weak. Just smack her a few times.");
  }

  if(boss == $monster[Pecos Dave]){
    print(boss + " - immune to staggers and stuns, damage softcapped at 50, alternates between shooting you for most hp and spending a round reloading. Funksling new age healing/hurting crystals, use Shell Up on shooting rounds, cast Beanscreen.");
  }

  if(boss == $monster[Jeff the Fancy Skeleton]){
    print(boss + " - immune to staggers, has 50% physical and 70% elemental resistance, skills will fail 90% of the time, blocks combat items, immune to physical damage from non-blunt weapons. Equip blunt weapons, passive damage, lower ML.");
  }
}

/*
 * Internal method. Prepares for and fights the LT&T Office quest boss
 * assumes the next adventure in Investigating a Plaintive Telegram will be the boss.
 */
boolean __fight_boss(boolean should_prepare){

  void acquire_and_use(boolean[item] item_array){
    foreach i in item_array{
      effect e = to_effect(string_modifier(i, "Effect"));
      if(have_effect(e) == 0){
        if(item_amount(i) > 0 || buy(1, i)){
          use(1, i);
        }
      }
    }
  }

  void acquire_items(boolean[item] item_array){
    foreach i in item_array{
      if(item_amount(i) == 0){
        buy(1, i);
      }
    }
  }

  void acquire_buffs(boolean[skill] skill_array){
    foreach s in skill_array{
      effect e = to_effect(s);
      if(have_skill(s) && have_effect(e) == 0){
        use_skill(1, s);
      }
    }
  }

  void equip_items_maybe(boolean[item] equip_array){
    foreach i in equip_array{
      slot s = to_slot(i);
      if(can_equip(i) && equipped_amount(i) == 0 && item_amount(i) > 0){
        equip(to_slot(i), i);
      }
    }
  }

  void prepare_for_trouble(monster boss){
    print("Preparing to fight LT&T quest boss: " + boss, "blue");
    if(boss == $monster[Granny Hackleton]){
      acquire_items(PASSIVE_DMG_COMBAT_ITEMS);
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
    }

    if(boss == $monster[Clara]){
      acquire_and_use(HOT_RES_EFFECT_ITEMS);
      acquire_and_use(SPOOKY_RES_EFFECT_ITEMS);
      acquire_buffs(ELEM_RES_EFFECT_BUFFS);
    }

    if(boss == $monster[Unusual construct]){
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
      if(!have_skill($skill[Ambidextrous Funkslinging])){
        print("May have troble beating boss without Ambidextrous Funkslinging, if so boost passive damage as much as possible and try again.");
      } else{
        if(item_amount($item[New Age hurting crystal]) < 30){
          buy(30-item_amount($item[New Age hurting crystal]), $item[New Age hurting crystal]);
        }
      }
    }

    if(boss == $monster[Former Sheriff Dan Driscoll]){
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
    }

    if(boss == $monster[Pharaoh Amoon-Ra Cowtep]){
      acquire_and_use(SPOOKY_RES_EFFECT_ITEMS);
      acquire_buffs(ELEM_RES_EFFECT_BUFFS);
      acquire_and_use(STAT_BUFF_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
    }

    if(boss == $monster[Snake-Eyes Glenn]){
      print("Boy this guy is difficult to script a battle for, I am just going to buff us way the hell up and hope for the best.");
      acquire_and_use(STAT_BUFF_ITEMS);
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
    }

    if(boss == $monster[Daisy the Unclean]){
      // no prep for now
    }

    if(boss == $monster[Pecos Dave]){
      if(item_amount($item[New Age healing crystal]) < 5){
        buy(5 - item_amount($item[New Age healing crystal]), $item[New Age healing crystal]);
      }
    }

    /*
     * TODO:
     *   - improve logic determining which blunt weapon is better
     */
    if(boss == $monster[Jeff the Fancy Skeleton]){
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
      item best = $item[none];
      foreach i in BLUNT_WEAPONS{
        if(item_amount(i) > 0 && can_equip(i) && get_power(i) > get_power(best)){
          best = i;
        }
      }
      if(best != $item[none]){
        equip(to_slot(best), best);
      } else if(!(BLUNT_WEAPONS contains equipped_item($slot[weapon]))){
        print("You might not have a blunt weapon equipped, this fight might not go well.");
      }
    }

    if(item_amount($item[Space Trip safety headphones]) > 0){
      print("Equipping Space Trip safety headphones to make the fit a bit easier.");
      equip($slot[acc3], $item[Space Trip safety headphones]);
    } else{
      print("Equipping Space Trip safety headphones will give you better chances of winning.");
    }
  }

  monster boss = __determine_boss();
  if(boss == $monster[none]){
    print("Not sure who the boss is, you're on your own partner.", "red");
    return false;
  }

  __print_boss_hint(boss);
  if(should_prepare){
    prepare_for_trouble(boss);
  } else{
    print("Trusting that you have already prepared yourself for this battle");
  }
  adventure(1, $location[Investigating a Plaintive Telegram], "__ltt_boss_fight_filter");
  return true;
}
