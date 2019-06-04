// TODO - most of this ripped from fortressone/huetf - should rewrite it at some point so it's more logical

// quadmode
float rounds;
float team1score;
float team2score;
float quad_winner;

void () MatchThink =
{
    local string tmp;

    if (self.cnt == -1) {
        return;
    }

    self.cnt2 = (self.cnt2 - 1);

    if (self.cnt2 == 1) {
        localcmd("serverinfo status \"");
        tmp = ftos(self.cnt);
        localcmd(tmp);
        localcmd(" min left\"\n");
    }

    if (self.cnt2 == -1) {
        self.cnt2 = 59;
        self.cnt = (self.cnt - 1);
    }
    if (!self.cnt2) {
        if (self.cnt == 1 || self.cnt == 5)         {
            tmp = ftos (self.cnt);
            bprint(PRINT_HIGH, Q"\s[\s", tmp, "\s]\s minute");
            if (self.cnt != 1) {
                bprint(PRINT_HIGH, "s");
            }
            bprint(PRINT_HIGH, " remaining\n");
        }
        if (!self.cnt) {
            self.think = SUB_Remove;
            self.nextthink = (time + 0.1);
            NextLevel();
            return;
        }
    }
    if (!self.cnt && (((self.cnt2 == 30) || (self.cnt2 == 15)) || (self.cnt2 <= 10))) {
        tmp = ftos(self.cnt2);
        bprint(PRINT_HIGH, Q"\s[\s", tmp, "\s]\s second");
        if (self.cnt2 != 1) {
            bprint(PRINT_HIGH, "s");
        }
        bprint(PRINT_HIGH, " remaining\n");
    }
    self.nextthink = (time + 1);
};

void () PlayerNotReady = {
    if (self.ready) {
        bprint(PRINT_HIGH, self.netname, " is NOT ready anymore\n ");
        self.ready = 0;
    }
}

//=-=-=-=-=

float () CheckWinningTeam = {
	local float win_score = 0;
	local float winning_team = 0;

	if (team1score > win_score) {
		win_score = team1score;
		winning_team = 1;
	}

	if (team2score > win_score) {
		win_score = team2score;
		winning_team = 2;
	}
	else if (team2score == win_score) {
		winning_team = 0;
	}

	return winning_team;
};

void StartQuadRound();

void () QuadRoundOver = {
	self.think = StartQuadRound;
	self.nextthink = (time + 0.5);
};

void () QuadRoundThink = {

    // respawn players
    entity p;
    p = find(world, classname, "player");
    while (p)
    {
        if (p.deadflag == DEAD_DEAD)
        {
            p.respawntime = p.respawntime - 1;
            if (p.respawntime <= 0)
            {
                oldself = self;
                self = p;
                PutClientInServer();
                self = oldself;
            }
        }

        p = find(p, classname, "player");
    }

	local string tmp;
	local float fl;

	if (rounds < 2) {
		if (CheckWinningTeam() != 0) {
			if (quad_winner != CheckWinningTeam()) {
				quad_winner = CheckWinningTeam();
				self.think = QuadRoundOver;
				self.nextthink = (time + 0.1);
				return;
			}
		}
	}

	if (self.cnt == -1)
		return;

	if ( self.cnt == stof(infokey(world, "round_time")) - 1 && self.cnt2 == 59 ) {
		localcmd("serverinfo status \"");
		tmp = ftos (self.cnt + 1);
		localcmd(tmp);
		localcmd(" min left\"\n");
	}

	if (self.cnt2 == 1) {
		localcmd("serverinfo status \"");
		tmp = ftos (self.cnt);
		localcmd(tmp);
		localcmd(" min left\"\n");
	}

	if (self.cnt2 == -1) {
		self.cnt2 = 59;
		self.cnt = (self.cnt - 1);
	}

	if (!self.cnt2)	{
		if ((self.cnt == 1) || (self.cnt == 5)) {
			tmp = ftos (self.cnt);
			bprint(PRINT_HIGH, "\s[\s", tmp, "\s]\s minute");
			if (self.cnt != 1)
				bprint(PRINT_HIGH, "s");
			bprint(PRINT_HIGH, " remaining\n");
		}
		if (!self.cnt) {
			if (rounds > 0)
            {
                local string st;
                st = infokey(world, "round_delay_time");
                bprint(PRINT_HIGH, "ROUND TIME OVER\nNext round begins in ", st, " seconds\n");
            }

			self.think = QuadRoundOver;
			self.nextthink = (time + 0.1);
			return;
		}
	}

	if (!self.cnt && (((self.cnt2 == 30) || (self.cnt2 == 15)) || (self.cnt2 <= 10))) {
		fl = ceil (self.cnt2);
		if (!(fl - self.cnt2)) {
			tmp = ftos(self.cnt2);
			bprint(PRINT_HIGH, "\s[\s", tmp, "\s]\s second");
			if ((self.cnt2 != 1))
				bprint(PRINT_HIGH, "s");
			bprint(PRINT_HIGH, " remaining\n");
		}
	}
	self.nextthink = (time + 1);
};

void () QuadRoundBegin = {

	local entity te;
	local float counter;
	localcmd(strcat(strcat("timelimit ", ftos(stof(infokey(world, "round_time")))), "\n"));
	te = find(world, classname, "func_breakable");
	while (te) {
		setmodel(te, te.mdl);
		te.solid = SOLID_BSP;
		te = find(te, classname, "func_breakable");
	}

	te = find(world, classname, "player");
	while (te != world) {
		oldself = self;
		self = te;
		self.takedamage = DAMAGE_AIM;
		self.solid = SOLID_SLIDEBOX;
		self.movetype = MOVETYPE_WALK;
		setspawnparms(self);
		PutClientInServer();
		self = oldself;
		te = find (te, classname, "player");
	}

	bprint(2, "ROUND BEGINS NOW\n");
	if (!self.cnt) {
		self.cnt = stof(infokey (world, "round_time")) - 1;
		self.cnt2 = 60;
	}
	else {
		counter = floor(self.cnt);
		if (counter < self.cnt)
			self.cnt2 = ((self.cnt - counter) * 60);
		else
			self.cnt2 = 60;
		if (self.cnt2 == 60)
			self.cnt = (self.cnt - 1);
		else
			self.cnt = counter;
	}
	self.cnt2 = self.cnt2 + 1;
	localcmd("serverinfo status \"");
	local string tmp = ftos (self.cnt + 1);
	localcmd(tmp);
	localcmd(" min left\"\n");
	self.think = QuadRoundThink;
	self.nextthink = (time + 0.001);
};

void () QuadRoundInit = {
	local string num;
	local entity p;

	self.cnt2 = (self.cnt2 - 1);
    if (!self.cnt2)	{
        localcmd("serverinfo status \"0 min left\"\n");
        self.nextthink = (time + 0.1);
        self.think = QuadRoundBegin;
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                p.takedamage = DAMAGE_AIM;
                p.solid = SOLID_SLIDEBOX;
                p.movetype = MOVETYPE_WALK;
            }
            p = find(p, classname, "player");
        }
        return;
    }

    num = ftos(self.cnt2);
    p = find (world, classname, "player");
    while (p) {
        if (p.netname != "") {
            centerprint(p, "Round begins in: ", num, " second(s).\nEnsure correct class is chosen!\n");

            if (self.cnt2 <= 5)
            {
                stuffcmd(p, "play buttons/switch04.wav\n");
            }
        }
        p = find(p, classname, "player");
    }
	self.nextthink = (time + 1);
};

void () StartQuadRound =
{
    rounds = (rounds - 1);

	local entity te, te2, p;

	lightstyle(0, "m");

	p = find(world, classname, "player");
	while (p != world) {
		if (p.netname != "") {
			p.takedamage = DAMAGE_NO;
			p.solid = SOLID_NOT;
			p.movetype = MOVETYPE_NONE;
			p.modelindex = 0;
			p.model = string_null;
		}
		p = find(p, classname, "player");
	}

// game is over with no rounds left
	if (rounds == -1) {
		quad_winner = CheckWinningTeam();
		if (quad_winner == TEAM_NONE)
			bprint (PRINT_HIGH, "Round Drawn!\n");
		else if (quad_winner == TEAM_BLUE)
			bprint(PRINT_HIGH, "Blue Team Wins!\n");
		else if (quad_winner == TEAM_RED)
			bprint(PRINT_HIGH, "Red Team Wins!\n");

		p = find (world, classname, "player");
		while (p != world) {
			if (p.netname != "") {
				p.takedamage = DAMAGE_NO;
				p.solid = SOLID_NOT;
				p.movetype = MOVETYPE_NONE;
				p.modelindex = 0;
				p.model = string_null;
			}
			p = find(p, classname, "player");
		}
		bprint(2, "Rounds Over! Use \"cmd map <mapname>\" to go to the nextmap\n");
		localcmd("stop\n");
		return;
	}

	if (intermission_running)
		return;

	te = find(world, classname, "door");
	while (te != world) {
		te2 = self;
		self = te;
		door_go_down_silent();
		self.think = LinkDoors;
		self = te2;
		te = find(te, classname, "door");
	}

	te = find(world, classname, "round");
    if (!te)
    {
        te = spawn();
        te.owner = world;
        te.classname = "round";
    }
    te.cnt2 = GetSetting(world, "round_delay_time", QUAD_DELAY_TIME);
	te.cnt = GetSetting(world, "round_time", QUAD_ROUND_TIME);
    te.roundnum = GetSetting(world, "rounds", QUAD_ROUNDS);

	localcmd("serverinfo status Standby\n");

    if (te.roundnum == (rounds+1))
    {
        // first round
        te.think = QuadRoundBegin;
		te.nextthink = (time + 0.01);
    }
    else
    {
        te.think = QuadRoundInit;
		te.nextthink = (time + 1);
    }
};

void () EndQuadRound = {
	if (infokey(world, "quadmode") == "on") {
		if (infokey(world,"status") != "Countdown" && infokey(world,"status") != "Standby") {
			if (rounds > 1) {
                local string st;
                st = infokey(world, "round_delay_time");
                bprint(2, "ROUND TIME OVER\nNext round begins in ", st, " seconds\n");
				lightstyle (0, "e");
				self.think = QuadRoundOver;
				self.nextthink = (time + 0.1);
			}
			else if (rounds == 1) {
				StartQuadRound();
			}
		}
	}
};

void GameThink()
{
    self.nextthink = time + 1;
    self.cnt2 = self.cnt2 + 1;
    if (self.cnt2 >= 60)
    {
        self.cnt = self.cnt + 1;
        self.cnt2 = self.cnt2 - 60;
    }
}


void () LobbyThink = {
    // check all players selected champs
    entity p;
    p = find(world, classname, "player");
    if (p)
    {
        while (p)
        {
            // not everyone has a champ yet
            if (!p.champ_id)
            {
                self.nextthink = time + 1;
                return;
            }
            // not everyone is ready
            if (!p.ready)
            {
                self.nextthink = time + 1;
                return;
            }
            p = find(p, classname, "player");
        }
    }
    else // there are no players
    {
        self.nextthink = time + 1;
        return;
    }
    
    // champs are selected, everyone is /ready
    // countdown start of game
    self.cnt2 = (self.cnt2 - 1);
    if (self.cnt2 == 1) {
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                p.respawn_time = (time + 2);
                p.takedamage = DAMAGE_NO;
                p.solid = SOLID_NOT;
                p.movetype = MOVETYPE_NONE;
                p.modelindex = 0;
                p.model = string_null;
            }
            p = find(p, classname, "player");
        }
    }
    else if (!self.cnt2) {
        self.cnt = 0;
        self.cnt2 = 0;
        self.nextthink = time + 1;
        self.think = GameThink;
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                p.takedamage = DAMAGE_AIM;
                p.solid = SOLID_SLIDEBOX;
                p.movetype = MOVETYPE_WALK;
            }
            p = find(p, classname, "player");
        }
        StartQuadRound();
        return;
    }

    string num, tmp;
    float fl;
    fl = (self.cnt2 / 60);
    if (fl == 1 || fl == 2 || fl == 3 || fl == 4 || fl == 5 || fl == 6 || fl == 7 || fl == 8 || fl == 9 || fl == 10) {
        num = ftos(fl);
        bprint(PRINT_HIGH, "Match will begin in ", num, " minute(s).\n");
    }
    if (self.cnt2 == 30)    {
        num = ftos(self.cnt2 / 60);
        bprint(PRINT_HIGH, "Match will begin in 30 seconds.\n");
    }
    if (self.cnt2 <= 10) {
        if (self.cnt2 == 10) {
            lightstyle(0, "e");

            if (stof(infokey(world, "demo_auto_left")) > 0) {
                if (infokey(world, "serverdemo") == "on") {
                    calltimeofday();

                    localcmd("record \"");
                    localcmd(ftos (tod_day)); // day
                    localcmd("-");
                    localcmd(ftos (tod_mon)); // month
                    localcmd("-");
                    localcmd(ftos (tod_year)); // year
                    localcmd("_");
                    localcmd(ftos (tod_hour)); // hour
                    localcmd("-");
                    localcmd(ftos (tod_min)); // minute
                    localcmd("-");
                    localcmd(ftos (tod_sec)); // second

                    localcmd("_[");
                    localcmd(mapname);
                    localcmd("]");
                    localcmd("\"\n");
                }
            }
        }
        num = strzone(ftos(self.cnt2));
        p = find(world, classname, "player");
        tmp = strcat(num ,"\n\n\b:[\b");
        tmp = strcat(tmp, mapname);
        tmp = strcat(tmp, "\b]:\b");
        strcat(tmp, "\n");

        while (p != world) {
            if (p.netname != "") {
                centerprint (p, "Countdown ", tmp, "\n");
                if (self.cnt2 < 6) {
                    stuffcmd (p, "play buttons/switch04.wav\n");
                }
            }
            p = find(p, classname, "player");
        }

        if (self.cnt2 > 1) {
            bprint(PRINT_HIGH, num, " seconds \n");
        }
        else {
            bprint(PRINT_HIGH, "1 second \n");
        }
        strunzone(num);
    }

    self.nextthink = (time + 1);
}

void GameSpawn()
{
    entity te;
	te = find(world, classname, "gametimer");
	te = spawn();
	te.owner = world;
	te.classname = "gametimer";
	te.think = LobbyThink;
	te.nextthink = time + 1;
	te.cnt2 = 31;
    rounds = GetSetting(world, "rounds", QUAD_ROUNDS);
}