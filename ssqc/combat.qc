/*
	combat.qc

	damage, obit, etc related functions

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/

void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_RadiusDamage;

/*SERVER
void() monster_death_use;
*/

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/

void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	
	if (self.health < -99)
		self.health = -99;              // don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{       // doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

    if (targ.classname == "player" || targ.classname == "item_qwmgoal")
    {
        if (attacker.classname != "player")
        {
            // if enemy wasn't a player, find last person to hit them and make them the killer
            attacker = targ.enemy;
        }
    }

	if (attacker && attacker.classname != "player")
	{
		attacker.enemy = world;
	}

	self.enemy = attacker;

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;
	self.effects = 0;

	self.th_die ();
	
	self = oself;
};


void () AssistTrackerThink = {
	self.health = self.health - 1;
	if (self.health <= 0)
	{
		if (self.classname == "lasthit_tracker")
		{
			self.owner.enemy = world;
            self.owner.assist_count = self.owner.assist_count - 1;
            if (self.owner.assist_count < 0)
                self.owner.assist_count = 0;
		}
		remove(self);
	}
	else
	{
		self.nextthink = time + 1;
	}
}

void(entity targ, entity inflictor, entity attacker, float damage) T_Damage =
{
	local   vector  dir;
	local   float  attackerteam, targteam;

	if (!targ.takedamage)
		return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;
	damage_inflictor = inflictor;        

// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);

		// Read: only if it's not yourself doing the damage
		if ( (damage < 60) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname != targ.netname)) 
			targ.velocity = targ.velocity + dir * damage * 11;
		else                        
		// Otherwise, these rules apply to rockets and grenades                        
		// for blast velocity
			targ.velocity = targ.velocity + dir * damage * 8;
		
		// Rocket Jump modifiers
		if ( (rj > 1) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname == targ.netname)) 
			targ.velocity = targ.velocity + dir * damage * rj;
	}

	// team play damage avoidance
	attackerteam = attacker.team_no;
	targteam = targ.team_no;

	if ((targteam == attackerteam) &&
		(attacker.classname == "player") && 
		inflictor.classname !="door")
		return;

	// check for damage reduction
	entity buff;
	buff = find(world, classname, "buff");
	while (buff)
	{
		switch (buff.buffcategory)
		{
			case BUFF_DMGRD_ALL:
				damage = damage * (buff.buffvalue / 100);
				break;
		}
		buff = find(buff, classname, "buff");
	}

	// do the damage
	targ.health = targ.health - damage;

	// if champ being attacked by another champ
	if (targ.classname == "player" && attacker.classname == "player")
	{
		// last hit by
		targ.enemy = attacker;
		entity lht;
		float tracked;
		tracked = 0;

		lht = find(world, classname, "lasthit_tracker");
		while (lht)
		{
			if (lht.owner == targ)
			{
				lht.enemy = attacker;
				tracked = 1;
				lht.health = 13;
				lht.nextthink = time + 1;
			}
			lht = find(lht, classname, "lasthit_tracker");
		}
		if (!tracked)
		{
			lht = spawn();
			lht.classname = "lasthit_tracker";
			lht.owner = targ;
			lht.enemy = attacker;
			lht.health = 13;
			lht.think = AssistTrackerThink;
			lht.nextthink = time + 1;
		}

		// track attacker in assist entity
		entity at;
		tracked = 0;

		at = find(world, classname, "assist_tracker");
		while (at)
		{
			if (at.enemy == attacker && at.owner == targ)
			{
				tracked = 1;
				at.health = 10;
				at.nextthink = time + 1;
			}
			at = find(at, classname, "assist_tracker");
		}

		if (!tracked)
		{
			at = spawn();
			at.classname = "assist_tracker";
			at.owner = targ;
			at.enemy = attacker;
			at.think = AssistTrackerThink;
			at.nextthink = time + 1;
			at.health = 10;
            at.owner.assist_count = at.owner.assist_count + 1;
		}

		entity creep;
		float dist;
		creep = find (world, classname, "creep");

		while (creep)
		{
			if (creep.team_no == targ.team_no)
			{
				// if minions are near
				dist = vlen(targ.origin - creep.origin);

				if (dist <= CREEP_AGRO_RANGE)
				{
					// if minions don't have a champ target, target the attacker
					if (!creep.enemy || creep.enemy.classname != "player")
					{
						creep.enemy = attacker;
					}
				}
			}
			creep = find(creep, classname, "creep");
		}

        // do same for tower
        float dist2;
        dist2 = 0;
        entity tower;
        tower = find(world, classname, "item_qwmgoal");
        while (tower)
        {
            if (tower.team_no != attacker.team_no)
            {
                if (tower.enemy)
                {
                    if (tower.enemy.classname == "player")
                    {
                        return;
                    }
                }

                dist = vlen(attacker.origin - tower.origin);
                if (dist <= STRUCTURE_TOWER_RANGE)
                {
                    dist2 = vlen(targ.origin - tower.origin);
                    if (dist2 <= STRUCTURE_TOWER_RANGE)
                    {
                        tower.enemy = attacker;
                    }
                }
            }
            tower = find(tower, classname, "item_qwmgoal");
        }
	}

	if (targ.health <= 0)
	{
		Killed (targ, attacker);
		return;
	}

	// react to the damage
	oldself = self;
	self = targ;

	if (self.th_pain)
	{
		self.th_pain (attacker, damage);
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_RadiusDamage =
{
	local   float   points;
	local   entity  head;
	local   vector  org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
						head.deathtype = dtype;
						T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
	local   float   points;
	local   entity  head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
					T_Damage (head, attacker, attacker, points);
			}
		}
		head = head.chain;
	}
};