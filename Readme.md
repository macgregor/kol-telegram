# telegram
Automate LT&T Telegram Office item of the month

## Installation
Run this command in the graphical CLI:

```
svn checkout https://github.com/macgregor/kol-telegram/trunk/Release/
```

## Usage

**gcli**

```
> telegram -h

usage: telegram [--help|-h] [-n|--no-prep] difficulty

help, h - display this usage message and exit
-n, --no-prep - by default telegram will optimize equipment and buffs before
the boss fight (which could be expensive and overly cautious), with this flag set,
the script assumes you have already set up an appropriate moodoutfit to complete the fight.
difficulty - desired quest difficulty. Case insensitive. Can be one of:
    * easy, 1 - do easy quest
    * medium, 2 - do medium quest
    * hard, 3 - do hard quest

> telegram easy -n
> telegram HARD
> telegram 2 --no-prep
```

**ASH**

```
import <telegram.ash>;

// see whats available
print_available_ltt_office_quests();

// do easy quest, first of the day so its free
// easy quest bosses are easy! not necessarily true, but for demonstration purposes
// theres no need to waste meat on buffs and combat items
boolean should_prep_for_boss = false;
do_ltt_office_quest_easy(should_prep_for_boss);

// if you are using inflatables you cant do any more, otherwise you need to accept overtime
// first one costs 1,000
accept_overtime();
do_ltt_office_quest_medium(should_prep_for_boss);

// the do_ltt_office_quest_* methods will also auto accept overtime for you if needed.
// second costs 10,000. Bosses are tough, lets the script prepare for them
should_prep_for_boss = true
do_ltt_office_quest_hard(should_prep_for_boss);

// third costs 100,000
// after after the 10,000 meat overtime, the script will start prompting you to confirm
// you want to do overtime since it gets expensive very quickly
do_ltt_office_quest_hard(should_prep_for_boss)

// lets buy an inflatable office to sell or use later
buy_one_inflatable_ltt_office();

// heck, lets buy them all
buy_all_inflatable_ltt_office();
```
