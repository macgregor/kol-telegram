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
> telegram h

usage: telegram [help|h] difficulty

help, h - display this usage message and exit
difficulty - desired quest difficulty. Case insensitive. Can be one of:
    * easy, 1 - do easy quest
    * medium, 2 - do medium quest
    * hard, 3 - do hard quest

> telegram easy
> telegram HARD
> telegram 2
```

**ASH**

```
import <telegram.ash>;

// see whats available
print_available_ltt_office_quests();

// do easy quest, first of the day so its free
do_ltt_office_quest_easy();

// if you are using inflatables you cant do any more, otherwise you need to accept overtime
// first one costs 1,000
accept_overtime();
do_ltt_office_quest_medium();

// the do_ltt_office_quest_* methods will also auto accept overtime for you if needed.
// second costs 10,000
do_ltt_office_quest_hard();

// third costs 100,000
// after after the 10,000 meat overtime, the script will start prompting you to confirm
// you want to do overtime since it gets expensive very quickly
do_ltt_office_quest_hard()

// lets buy an inflatable office to sell or use later
buy_one_inflatable_ltt_office();

// heck, lets buy them all
buy_all_inflatable_ltt_office();
```
