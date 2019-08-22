# telegram
Automate LT&T Telegram Office item of the month

Tested Successfully Against:
* Unusual construct
* Granny Hackleton

## Requirements
For best results you should have:
* Ambidextrous Funkslinging
* Space Trip safety headphones

Written for aftercore (mall access expected), if running in HC or ronin you should
use the `--no-boss` flag, prepare for the boss battle, then re-run with the
`--no-prep` flag to have it fight the boss without extra preparation that requires
the mall.

## Installation
Run this command in the graphical CLI:

```
svn checkout https://github.com/macgregor/kol-telegram/trunk/Release/
```

## Usage

**gcli**

```
telegram v0.1

usage: telegram [-h|--help] [-v|--version] [--no-prep] [--no-boss] [--spend-dimes] [difficulty]

-h, --help - display this usage message and exit
-v, --version - display version and exit
--no-prep - by default telegram will optimize equipment and buffs before
the boss fight (which could be expensive and overly cautious), with this flag set,
the script assumes you have already set up appropriate buffs and equipment to
complete the fight.
--no-boss - by default telegram will try to fight the boss, you can have
the script stop at the boss by setting this flag
--spend-dimes - tries to buy Inflatable LT&T telegraph office with
buffalo dimes
difficulty - desired quest difficulty. Case insensitive. Not required if
a telegram quest has already been started. Can be one of:
  * easy, 1 - do easy quest
  * medium, 2 - do medium quest
  * hard, 3 - do hard quest

> telegram easy
> telegram HARD
> telegram 2 --no-boss
> telegram --no-prep
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
boolean should_fight_boss = true;
do_ltt_office_quest_easy(should_prep_for_boss, should_fight_boss);

// if you are using inflatables you cant do any more, otherwise you need to accept overtime
// first one costs 1,000
accept_overtime();
do_ltt_office_quest_medium(should_prep_for_boss, should_fight_boss);

// the do_ltt_office_quest_* methods will also auto accept overtime for you if needed.
// second costs 10,000. Bosses are tough, lets the script prepare for them
should_prep_for_boss = true
do_ltt_office_quest_hard(should_prep_for_boss, should_fight_boss);

// third costs 100,000
// after after the 10,000 meat overtime, the script will start prompting you to
// confirm you want to do overtime since it gets expensive very quickly
// We are worried about this one so lets stop before fighting the boss so we can
// do our own prep
boolean should_prep_for_boss = false;
boolean should_fight_boss = false;
do_ltt_office_quest_hard(should_prep_for_boss, should_fight_boss);

// do some custom equipment/buff management ...
outfit("badass boss killing outfit");
cli_execute("mood boss-killing-mood");
boolean should_fight_boss = true;
do_ltt_office_quest_hard(should_prep_for_boss, should_fight_boss);

// lets buy an inflatable office to sell or use later
buy_one_inflatable_ltt_office();

// heck, lets buy them all
buy_all_inflatable_ltt_office();
```
