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
static int ACCEPT_OVERTIME = 4; // ?? not sure what choice is


boolean __page_contains(string url, string text){
  return contains_text(visit_url(url), text);
}

string __available_quest(string ltt_office_page, monster[string] possible_quests){
  foreach q in possible_quests {
    matcher m = create_matcher(q, ltt_office_page);
    if(m.find()){
      return q;
    }
  }
  return "";
}

boolean __ltt_office_available(){
  return __page_contains("place.php?whichplace=town_right", "lttoffice.gif");
}

boolean __ltt_quests_available(string ltt_office_page){
  return __available_quest(ltt_office_page, EASY_QUESTS) != "" && __available_quest(ltt_office_page, MEDIUM_QUESTS) != "" && __available_quest(ltt_office_page, HARD_QUESTS) != "";
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

boolean __overtime_available(string ltt_office_page){
  matcher m = create_matcher("Pay overtime", ltt_office_page);
  return m.find();
}

int __overtime_cost(string ltt_office_page){
  if(__overtime_available(ltt_office_page)){
    matcher m = create_matcher("(Pay overtime \(.*?\))", ltt_office_page);
    if(m.find()){
      return extract_meat(m.group(1));
    }
  }
  return -1;
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
  adventure(1, $location[Investigating a Plaintive Telegram], "ltt_boss_fight");
  return true;
}

/*
 * Internal method, checks if the LT&T office is accessible, accepts a quest of
 * the choosen difficulty, adventures until the boss is up next then delegates to
 * __fight_boss() to finish the quest.
 *
 * returns true if it was able to complete an LT&T quest, false otherwise
 */
boolean __do_ltt_office_quest(int difficulty){
  if(__ltt_office_available()){
    if(!__have_telegram() || get_property("questLTTQuestByWire") == "unstarted"){
      if(__overtime_available(__visit_ltt_office()) && !accept_overtime()){
        print("Wasnt able to take on overtime quest", "red");
        return false;
      }
      __visit_ltt_office();
      run_choice(difficulty);
    }
    if(!__have_telegram()){
      print("We should have a plaintive telegram by now, something is wrong.", "red");
      return false;
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

    print("LT&T boss is up next.");
    __fight_boss();
    stage_count = get_property("lttQuestStageCount").to_int();
    current_stage = get_property("questLTTQuestByWire");

    if(stage_count == "step3"){
      print("I dont think we won that fight, sorry!", "red");
      return false;
    } else{
      print("Completed LT&T office quest.", "green");
      return true;
    }
  } else{
    print("LT&T Office inaccessible?", "red");
    return false;
  }
}

/*
 * Accept overtime if one is available. Will prompt for user confirmation
 * if the overtime cost is above 10,000 meat (defaulting to not accept overtime
 * after 10 seconds).
 *
 * returns true if overtime was available, accepted and there are now quests available
 * for selection in the LT&T office. There could be available quests to choose
 * from even if this method returns false (if you havent done the free quest yet for example)
 */
boolean accept_overtime(){
  string page = __visit_ltt_office();
  if(__overtime_available(page)){
    int cost = __overtime_cost(page);
    if(cost > 10000 && !user_confirm("Overtime will cost " + cost + " are you sure you want to spend this much?", 10000, false)){
      print(cost + " is way too much to spend, sheesh.", false);
      return false;
    }
    if(my_meat() < cost){
      print("You cant afford " + cost + " for overtime.", "red");
      return false;
    }
    run_choice(ACCEPT_OVERTIME);
    boolean can_accept_quest = __ltt_quests_available(__visit_ltt_office());
    __leave_ltt_office();
    return can_accept_quest;
  }
  return false;
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
 * Do Hard LT&T Office quest. Should be able to pick it up in any state of completion.
 *
 * returns true if the quest was completed successfully, false otherwise.
 */
boolean do_ltt_office_quest_hard(){
  return __do_ltt_office_quest(ACCEPT_HARD_QUEST);
}

/*
 * Do Medium LT&T Office quest. Should be able to pick it up in any state of completion.
 *
 * returns true if the quest was completed successfully, false otherwise.
 */
boolean do_ltt_office_quest_medium(){
  return __do_ltt_office_quest(ACCEPT_MEDIUM_QUEST);
}

/*
 * Do Easy LT&T Office quest. Should be able to pick it up in any state of completion.
 *
 * returns true if the quest was completed successfully, false otherwise.
 */
boolean do_ltt_office_quest_easy(){
  return __do_ltt_office_quest(ACCEPT_EASY_QUEST);
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
