import <__telegram_data.ash>;

/* Passive Damage dealing stuff, used in Granny Hackleton boss fight */
static boolean[item] PASSIVE_DMG_COMBAT_ITEMS = $items[gas can, old school beer pull tab, cold mashed potatoes, paint bomb, crazy hobo notebook, bag of gross foreign snacks, possessed tomato, hand grenegg, Colon Annihilation Hot Sauce, jagged scrap metal, jigsaw blade, throwing fork, dinner roll, whole turkey leg, skull with a fuse in it, nastygeist];
static boolean[item] PASSIVE_DMG_EFFECT_ITEMS = $items[monkey barf, half-digested coal, beard incense, spooky sound effects record, glowing syringe];
static boolean[skill] PASSIVE_DMG_EFFECT_BUFFS = $skills[Jalape&ntilde;o Saucesphere, The Psalm of Pointiness, Scarysauce];
static boolean[item] PASSIVE_DMG_EQUIPMENT = $items[double-ice cap, cup of infinite pencils, dubious loincloth, ironic oversized sunglasses, MagiMechTech NanoMechaMech, cannonball charrrm bracelet, ant pick, tiny bowler];

static boolean[item] HOT_RES_EFFECT_ITEMS = $items[SPF 451 lip balm, drop of water-37, cocoa chondrule, lotion of sleaziness, lotion of stench, hot powder, magenta seashell];
static boolean[item] SPOOKY_RES_EFFECT_ITEMS = $items[black eyedrops, lotion of stench, spooky sap, lotion of hotness, ectoplasmic orbs, marzipan skull, spooky powder];
static boolean[skill] ELEM_RES_EFFECT_BUFFS = $skills[Elemental Saucesphere, Astral Shell];

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
  boolean funksling = have_skill($skill[Ambidextrous Funkslinging]);

  if(round == 1){
    clear(combat_items_used);
  }
  if(opp == $monster[Granny Hackleton]){
    string use_item = "";
    boolean second = false;
    foreach i in PASSIVE_DMG_COMBAT_ITEMS {
      if(!(combat_items_used contains i)){
        combat_items_used[i] = 1;
        if(!second){
          use_item = "item i";
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

    if (color = "" || !(UNUSUAL_CONSTRUCT_DISC_MAP contains color)){
      print("Wasnt able to extract a knowns color from combat.");
      print("Extracted color: " + color);
      print(text);
      abort("Unable to determine which disc to use, see: https://kol.coldfront.net/thekolwiki/index.php/Unusual_construct");
    }

    return "item " + UNUSUAL_CONSTRUCT_DISC_MAP[color];
  }

  print("telegram boss fight filter out of actions, deferring to default CCS", "blue");
  return "";
}

/*
 * Internal method. Prepares for and fights the LT&T Office quest boss
 * assumes the next adventure in Investigating a Plaintive Telegram will be the boss.
 */
boolean __fight_boss(){

  monster determine_boss(){
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
      print(boss + " - blocks attacks, skills, familiar actions and can only use combat items once each. Use buffs, equipment and items that deal passive damage over time.");
      acquire_items(PASSIVE_DMG_COMBAT_ITEMS);
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
    }

    if(boss == $monster[Clara]){
      print(boss + " - damage softcapped at 500, cannot be staggers, blocks combat items, deals spooky and hot damage each round. Buff hot and spooky res to survive, fight with regular attacks or skills.");
      acquire_and_use(HOT_RES_EFFECT_ITEMS);
      acquire_and_use(SPOOKY_RES_EFFECT_ITEMS);
      acquire_buffs(ELEM_RES_EFFECT_BUFFS);
    }

    if(boss == $monster[Unusual construct]){
      print(boss + " - deals hot damage each round, construct says something each round, the second word indicates what disc you need to use to survive the round. Without funkslinging you have to rely on passive damage to kill it.");
      acquire_and_use(PASSIVE_DMG_EFFECT_ITEMS);
      acquire_buffs(PASSIVE_DMG_EFFECT_BUFFS);
      equip_items_maybe(PASSIVE_DMG_EQUIPMENT);
    }

    if(item_amount($item[Space Trip safety headphones]) > 0){
      print("Equipping Space Trip safety headphones to make the fit a bit easier.");
      equip($slot[acc3], $item[Space Trip safety headphones]);
    }
  }

  monster boss = determine_boss();
  if(boss == $monster[none]){
    print("Not sure who the boss is, you're on your own partner.", "red");
    return false;
  }

  prepare_for_trouble(boss);
  adventure(1, $location[Investigating a Plaintive Telegram], "__ltt_boss_fight_filter");
  return true;
}
