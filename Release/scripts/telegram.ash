script "telegram"

import <telegram/__telegram_data.ash>;
import <telegram/__telegram_boss_fight.ash>;

/*
 * Public interface, other ash scripts can safely import and call these methods
 */
boolean accept_overtime();
int buy_all_inflatable_ltt_office();
int buy_one_inflatable_ltt_office();
void do_ltt_office_quest_easy();
void do_ltt_office_quest_hard();
void do_ltt_office_quest_medium();
void print_available_ltt_office_quests();

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

    if(current_stage == "step3"){
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

/*
 * Tries to buy as many Inflatable LT&T telegraph office you can afford with buffalo dimes.
 *
 * returns the number of Inflatable LT&T telegraph office purchased
 */
int buy_all_inflatable_ltt_office(){
  item inflatable = $item[Inflatable LT&T telegraph office];
  int dimes_needed = sell_price(inflatable.seller, inflatable);
  int bought = 0;
  while(__ltt_office_available() && inflatable.seller.available_tokens >= dimes_needed){
    if(!buy(inflatable.seller, 1, inflatable)){
      break;
    }
    bought++;
  }
  return bought;
}

/*
 * Tries to buy one Inflatable LT&T telegraph office with buffalo dimes.
 *
 * returns true if one Inflatable LT&T telegraph office was purchased, false if not
 * (you cant afford one, dont have access to the LT&T office, etc)
 */
boolean buy_one_inflatable_ltt_office(){
  item inflatable = $item[Inflatable LT&T telegraph office];
  int dimes_needed = sell_price(inflatable.seller, inflatable);
  if(__ltt_office_available() && inflatable.seller.available_tokens >= dimes_needed){
    return buy(inflatable.seller, 1, inflatable);
  }
  return false;
}

void __print_help(){
  print_html("<b>usage</b>: telegram [help|h] difficulty\
<p/><b>help</b>, <b>h</b> - display this usage message and exit\
<b>difficulty</b> - desired quest difficulty. Case insensitive. Can be one of:\
<ul><li>easy, 1 - do easy quest</li> \
<li>medium, 2 - do medium quest</li>\
<li>hard, 3 - do hard quest</li></ul>");
}

void main(string args){
  if (args == ""){
		__print_help();
		return;
	}

  foreach key, argument in args.split_string(" "){
		argument = argument.to_lower_case();
    switch(argument){
      case "help":
      case "h":
        __print_help();
        break;
      case "easy":
      case to_string(ACCEPT_EASY_QUEST):
        do_ltt_office_quest_easy();
        break;
      case "medium":
      case to_string(ACCEPT_MEDIUM_QUEST):
        do_ltt_office_quest_medium();
        break;
      case "hard":
      case to_string(ACCEPT_HARD_QUEST):
        do_ltt_office_quest_hard();
        break;
      default:
        print("Unexpected argument: " + argument, "red");
        __print_help();
    }
  }
}
