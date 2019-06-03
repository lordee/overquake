#include "../share/defs.h"

.float menu;
.float team_no;
.float champ_id;
.float id;

// champ fields
.float attackdamage;
.float attackspeed;
.float skill_one;
.float skill_two;
.float skill_three;
.float skill_four;
.float skill_selected;
.float mana;
.float max_mana;
.float regentick;
.float healthregen;
.float manaregen;
.float stacks;
.float skill_one_damage;
.float skill_one_cooldown;
.float skill_one_cooldown_time;
.float skill_one_manacost;
.float skill_one_range;
.float skill_one_value;
.float skill_two_damage;
.float skill_two_cooldown;
.float skill_two_cooldown_time;
.float skill_two_manacost;
.float skill_two_range;
.float skill_two_value;
.float skill_three_damage;
.float skill_three_cooldown;
.float skill_three_cooldown_time;
.float skill_three_manacost;
.float skill_three_range;
.float skill_three_value;
.float skill_four_damage;
.float skill_four_cooldown;
.float skill_four_cooldown_time;
.float skill_four_manacost;
.float skill_four_range;
.float skill_four_value;
.float assist_count;
.string team_str;
.float consecutive_deaths;
.float consecutive_kills;
.float kill_tier;
.float respawn_time;

.float respawntime;
.float cnt2;
.float ready;
.float mrvalue;
.float healthlastregen;
.float manalastregen;

// buff fields
.float bufftype;
.float buffcategory;
.float nextthinkinterval;
.float buffvalue;
.float stunned;

entity oldself;
float GameStarted;

// cp defs
.float restrictteamfromwin;
.float scorestyle;
.float switchteamsonwin;
.float timesincelastpointscore;
.float timebetweenpointscore;
.float bluescore;
.float redscore;
.float capnum;
.string caplayout;
.string neutralmodel;
.string bluemodel;
.string redmodel;
.float timetocap;
.float progress;
.float numtocap;
.float bluecancap;
.float redcancap;
.float bluemustown1;
.float bluemustown2;
.float bluemustown3;
.float redmustown1;
.float redmustown2;
.float redmustown3;

// quadmode
float rounds;
float team1score;
float team2score;
float quad_winner;
float number_of_teams;