import <__telegram_data.ash>;

/* Passive Damage dealing stuff, used in Granny Hackleton boss fight */
static boolean[item] PASSIVE_DMG_COMBAT_ITEMS = $items[gas can, old school beer pull tab, cold mashed potatoes, paint bomb, crazy hobo notebook, bag of gross foreign snacks, possessed tomato, hand grenegg, Colon Annihilation Hot Sauce, jagged scrap metal, jigsaw blade, throwing fork, dinner roll, whole turkey leg, skull with a fuse in it, nastygeist];
static boolean[item] PASSIVE_DMG_EFFECT_ITEMS = $items[monkey barf, half-digested coal, beard incense, spooky sound effects record, glowing syringe];
static boolean[skill] PASSIVE_DMG_EFFECT_BUFFS = $skills[Jalape&ntilde;o Saucesphere, The Psalm of Pointiness, Scarysauce];
static boolean[item] PASSIVE_DMG_EQUIPMENT = $items[double-ice cap, cup of infinite pencils, dubious loincloth, ironic oversized sunglasses, MagiMechTech NanoMechaMech, cannonball charrrm bracelet, ant pick, tiny bowler];

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
  print("LT&T Office Boss Fight Combat Filter", "blue");
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

    if(difficulty == 1){
      boss = EASY_QUESTS[get_property("lttQuestName")];
    } else if(difficulty == 2){
      boss = MEDIUM_QUESTS[get_property("lttQuestName")];
    } else if(difficulty == 3){
      boss = HARD_QUESTS[get_property("lttQuestName")];
    }

    return boss;
  }

  void prepare_for_trouble(monster boss){
    print("Preparing to fight LT&T quest boss: " + boss, "blue");
    if(boss == $monster[Granny Hackleton]){
      print(boss + " - blocks attacks, skills, familiar actions and can only use combat items once each. Use buffs, equipment and items that deal passive damage over time.");
      foreach i in PASSIVE_DMG_COMBAT_ITEMS{
        if(item_amount(i) == 0){
          buy(1, i);
        }
      }

      foreach i in PASSIVE_DMG_EFFECT_ITEMS{
        effect e = to_effect(string_modifier(i, "Effect"));
        if(have_effect(e) == 0){
          if(item_amount(i) > 0 || buy(1, i)){
            use(1, i);
          }
        }
      }

      foreach s in PASSIVE_DMG_EFFECT_BUFFS{
        effect e = to_effect(s);
        if(have_skill(s) && have_effect(e) == 0){
          use_skill(1, s);
        }
      }

      foreach i in PASSIVE_DMG_EQUIPMENT{
        slot s = to_slot(i);
        if(can_equip(i) && equipped_amount(i) == 0 && item_amount(i) > 0){
          equip(to_slot(i), i);
        }
      }
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
