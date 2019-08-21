script "telegram"

/*
 * Public interface, other ash scripts can safely import and call these methods
 */
void do_ltt_office_quest_hard();
void do_ltt_office_quest_medium();
void do_ltt_office_quest_easy();
void print_available_ltt_office_quests();
string ltt_boss_fight(int round, monster opp, string text);

/*
 * Static data
 */
static monster[string] EASY_QUESTS = {
  "Missing: Fancy Man": $monster[Jeff the Fancy Skeleton],
  "Help! Desperados!": $monster[Pecos Dave],
  "Missing: Pioneer Daughter": $monster[Daisy the Unclean]
};

static monster[string] MEDIUM_QUESTS = {
  "Big Gambling Tournament Announced": $monster[Snake-Eyes Glenn],
  "Haunted Boneyard": $monster[Pharaoh Amoon-Ra Cowtep],
  "Sheriff Wanted": $monster[Former Sheriff Dan Driscoll],
};

static monster[string] HARD_QUESTS = {
  "Madness at the Mine": $monster[unusual construct],
  "Missing: Many Children": $monster[Clara],
  "Wagon Train Escort Wanted": $monster[Granny Hackleton],
};

static int ACCEPT_EASY_QUEST = 1;
static int ACCEPT_MEDIUM_QUEST = 2;
static int ACCEPT_HARD_QUEST = 3;
static int LEAVE_OFFICE = 8;

string __available_quest(string ltt_office_page, monster[string] possible_quests){
  foreach q in possible_quests {
    matcher m = create_matcher(q, ltt_office_page);
    if(m.find()){
      return q;
    }
  }
  return "";
}

boolean __page_contains(string url, string text){
  return contains_text(visit_url(url), text);
}

boolean __ltt_office_available(){
  return __page_contains("place.php?whichplace=town_right", "lttoffice.gif");
}

string __visit_ltt_office(){
  return visit_url("place.php?whichplace=town_right&action=townright_ltt");
}

string __visit_ltt_office(int choice){
  __visit_ltt_office();
  return run_choice(choice);
}

void __leave_ltt_office(){
  run_choice(LEAVE_OFFICE);
}

boolean __have_telegram(){
  return item_amount($item[plaintive telegram]) > 0;
}

boolean __can_do_overtime(){
  matcher m = create_matcher("Pay overtime", __visit_ltt_office());
  __leave_ltt_office();
  return m.find();
}

/*
 * Prints the available quests to the gcli
 */
void print_available_ltt_office_quests(){
  string page = __visit_ltt_office();
  __leave_ltt_office();
  print("[1. Easy] " + __available_quest(page, EASY_QUESTS));
  print("[2. Medium] " + __available_quest(page, MEDIUM_QUESTS));
  print("[3. Hard] " + __available_quest(page, HARD_QUESTS));
}

/*
 * Boss Fight Combat Filter
 */
 static boolean[item] PASSIVE_DMG_COMBAT_ITEMS = $items[gas can, old school beer pull tab, cold mashed potatoes, paint bomb, crazy hobo notebook, bag of gross foreign snacks, possessed tomato, hand grenegg, Colon Annihilation Hot Sauce, jagged scrap metal, jigsaw blade, throwing fork, dinner roll, whole turkey leg, skull with a fuse in it, nastygeist];
 static boolean[item] PASSIVE_DMG_EFFECT_ITEMS = $items[monkey barf, half-digested coal, beard incense, spooky sound effects record, glowing syringe];
 static boolean[skill] PASSIVE_DMG_EFFECT_BUFFS = $skills[Jalape&ntilde;o Saucesphere, Psalm of Pointiness, Scarysauce];
 static boolean[item] PASSIVE_DMG_EQUIPMENT = $items[double-ice cap, cup of infinite pencils, dubious loincloth, ironic oversized sunglasses, MagiMechTech NanoMechaMech, cannonball charrrm bracelet, ant pick, tiny bowler];

string ltt_boss_fight(int round, monster opp, string text){
  print("LT&T Office Boss Fight Combat Filter", "blue");
  static int[item] combat_items_used;
  if(round == 1){
    clear(combat_items_used);
  }
  if(opp == $monster[Granny Hackleton]){
    foreach i in PASSIVE_DMG_COMBAT_ITEMS {
      if(!(combat_items_used contains i)){
        combat_items_used[i] = 1;
        return "use 1 " + i;
      }
    }
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

    if(difficulty == ACCEPT_EASY_QUEST){
      boss = EASY_QUESTS[get_property("lttQuestName")];
    } else if(difficulty == ACCEPT_MEDIUM_QUEST){
      boss = MEDIUM_QUESTS[get_property("lttQuestName")];
    } else if(difficulty == ACCEPT_HARD_QUEST){
      boss = HARD_QUESTS[get_property("lttQuestName")];
    }

    return boss;
  }

  void prepare_for_trouble(monster boss){
    if(boss == $monster[Granny Hackleton]){
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
      equip($slot[acc3], $item[Space Trip safety headphones]);
    }
  }

  monster boss = determine_boss();
  if(boss == $monster[none]){
    abort("Not sure who the boss is, you're on your own partner.");
  }

  prepare_for_trouble(boss);
  adventure(1, $location[Investigating a Plaintive Telegram], "ltt_boss_fight");
  return true;
}

/*
 * Internal method, checks if the LT&T office is accessible, accepts a quest of
 * the choosen difficulty, adventures until the boss is up next then delegates to
 * __fight_boss() to finish the quest.
 */
void __do_ltt_office_quest(int difficulty){
  if(__ltt_office_available()){
    if(!__have_telegram() || get_property("questLTTQuestByWire") == "unstarted"){
      __visit_ltt_office();
      run_choice(difficulty);
    }
    if(!__have_telegram()){
      abort("We should have a plaintive telegram by now, something is wrong.");
    }

    int stage_count = get_property("lttQuestStageCount").to_int();
    string current_stage = get_property("questLTTQuestByWire");

    if($strings[step1, step2, step3] contains current_stage && (current_stage != "step3" || stage_count < 9)){
      repeat{
        adventure(1, $location[Investigating a Plaintive Telegram]);
        stage_count = get_property("lttQuestStageCount").to_int();
        current_stage = get_property("questLTTQuestByWire");
      } until(current_stage == "step3" && stage_count == 9);
    }

    print("boss up");
    __fight_boss();
  } else{
    print("LT&T Office inaccessible?", "red");
  }
}

void do_ltt_office_quest_hard(){
  __do_ltt_office_quest(ACCEPT_HARD_QUEST);
}

void do_ltt_office_quest_medium(){
  __do_ltt_office_quest(ACCEPT_MEDIUM_QUEST);
}

void do_ltt_office_quest_easy(){
  __do_ltt_office_quest(ACCEPT_EASY_QUEST);
}

void main(int difficulty){
  print_available_ltt_office_quests();
  if(difficulty == ACCEPT_EASY_QUEST){
    do_ltt_office_quest_easy();
  } else if(difficulty == ACCEPT_MEDIUM_QUEST){
    do_ltt_office_quest_medium();
  } else if(difficulty == ACCEPT_HARD_QUEST){
    do_ltt_office_quest_hard();
  } else{
    abort("Difficulty should be one of 1 (easy), 2 (medium) or 3 (hard)");
  }
}
