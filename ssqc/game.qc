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
    if (self.cnt2 > 0)
    {
        bprint(PRINT_HIGH, "\s[\s", ftos(self.cnt2), "\s]\s second");
        if (self.cnt2 > 1)
        {
            bprint(PRINT_HIGH, "s");
        }
        bprint(PRINT_HIGH, " remaining\n");

        self.cnt2 = self.cnt2 - 1;
        self.nextthink = time + 1;
        return;
    }
    
    // we got this far, start the game
    StartGame();
}


void () MatchThink =
{
    local string tmp;

    if (self.cnt == -1) {
        return;
    }
    if (cease_fire) {
        self.nextthink = (time + 1);
        return;
    }
    self.cnt2 = (self.cnt2 - 1);
    if (!TeamFortress_GetNoPlayers()) {
        NextLevel();
        return;
    }

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
            bprint3(2, Q"\s[\s", tmp, "\s]\s minute");
            if (self.cnt != 1) {
                bprint(2, "s");
            }
            bprint(2, " remaining\n");
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
        bprint3(2, Q"\s[\s", tmp, "\s]\s second");
        if (self.cnt2 != 1) {
            bprint(2, "s");
        }
        bprint(2, " remaining\n");
    }
    self.nextthink = (time + 1);
};

void () StartMatch =
{
    local string st;
    local float f1;
    local float f2;
    local entity te;
    local entity oldself;
    local entity gren;

    lightstyle(0, "m");
    bprint(2, "MATCH BEGINS NOW\n");

    team4score = 0;
    team3score = 0;
    team2score = 0;
    team1score = 0;
    team4frags = 0;
    team3frags = 0;
    team2frags = 0;
    team1frags = 0;
    te = find(world, classname, "player");

    while (te) {
        oldself = self;
        self = te;

        TeamFortress_RemoveTimers();
        self.frags = 0;
        self.real_frags = 0;
        setspawnparms(self);
        if (!quadmode)
            PutClientInServer();
        self = oldself;
        te = find(te, classname, "player");
    }
    gren = find(world, classname, "grenade");
    while (gren)
    {
        gren.think = GrenadeExplode;
        gren.nextthink = (time + 0.1);
        gren = find(gren, classname, "grenade");
    }
	te = find(world, classname, "detpack");
	while (te){
		if (te.weaponmode == 1) {
			TeamFortress_SetSpeed (te.enemy);
			dremove(te.oldenemy);
			dremove(te.observer_list);
		}
		dremove(te.linked_list);
		dremove(te);
		te = find (te, classname, "detpack");
	}

    cb_prematch = 0;
    cease_fire = 0;

    te = find(world, classname, "prematch");
    te.classname = "match";
    te.cnt = (timelimit / 60);
    te.cnt2 = 60;
    if (te.cnt == 0)
    {
        bprint(2, "Warning no timelimit set!\n");
        localcmd("\nserverinfo status \"0 min left\"\n");
        te.cnt = -1;
        te.cnt2 = -1;
    }
    else
    {
        te.cnt = (te.cnt - 1);
        localcmd("\nserverinfo status \"");
        st = ftos(te.cnt);
        localcmd(st);
        localcmd(" min left\"\n");
        if (!quadmode) {
            te.think = MatchThink;
            te.nextthink = (time + 1);
        }
    }
    st = infokey(world, "spectalk");
    f2 = stof(st);
    if (!f2)
    {
        st = "0";
    }
    localcmd("sv_spectalk ");
    localcmd(st);
    localcmd("\n");
    f1 = stof(infokey(world, "fpd"));
    f1 = (f1 - (f1 & 64)) + (f2 * 64);
    localcmd("serverinfo fpd ");
    st = ftos(f1);
    localcmd(st);
    localcmd("\n");

    if (quadmode) {
        if (rounds) {
            StartQuadRound();
        }
    }
};

void () PreMatch_Think = {
    local entity p;
    local string num, tmp;
    local float fl;

    self.cnt2 = (self.cnt2 - 1);
    if (self.cnt2 == 1) {
        p = find(world, classname, "player");
        while (p != world) {
            if (p.netname != "") {
                p.respawn_time = (time + 2);
                p.takedamage = 0;
                p.solid = 0;
                p.movetype = 0;
                p.modelindex = 0;
                p.model = string_null;
            }
            p = find(p, classname, "player");
        }
    }
    else {
        if (!self.cnt2) {
            is_countdown = 0;
            self.nextthink = (time + 0.1);
            self.think = SUB_Remove;
            p = find(world, classname, "player");
            while (p != world) {
                if (p.netname != "") {
                    p.takedamage = 2;
                    p.solid = 3;
                    p.movetype = 3;
                }
                p = find(p, classname, "player");
            }
            if (!quadmode)
                StartMatch();
            else
                StartQuadRound();
            return;
        }
    }
    fl = (self.cnt2 / 60);
    if (fl == 1 || fl == 2 || fl == 3 || fl == 4 || fl == 5 || fl == 6 || fl == 7 || fl == 8 || fl == 9 || fl == 10) {
        num = ftos(fl);
        bprint3(2, "Match will begin in ", num, " minute(s).\n");
    }
    if (self.cnt2 == 30)    {
        num = ftos(self.cnt2 / 60);
        bprint(2, "Match will begin in 30 seconds.\n");
    }
    if (self.cnt2 <= 10) {
        if (self.cnt2 == 10) {
            is_countdown = 1;
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
                CenterPrint3 (p, "Countdown ", tmp, "\n");
                if (self.cnt2 < 6) {
                    cease_fire = 0;
                    stuffcmd (p, "play buttons/switch04.wav\n");
                }
            }
            p = find(p, classname, "player");
        }
        if (self.cnt2 > 1) {
            bprint2(2, num, " seconds \n");
        }
        else {
            bprint(2, "1 second \n");
        }
        strunzone(num);
    }

    self.nextthink = (time + 1);
};

void () ResetBreakAndReady = {
    local entity te;
    te = find (world, classname, "player");
    while (te != world) {
        te.bvote = 0;
        te.is_ready = 0;
        v_break = 0;
        v_ready = 0;
        te = find (te, classname, "player");
    }
}

void () StartTimer =
{
    local entity timer;
    local entity p;
    local entity te;

    if (clanbattle == 0) {
        if (self != world) {
            sprint(self, 2, "Clan mode off....\n");
            sprint(self, 2, "Match cannot be started.\n");
        }
        else {
            dprint("Clan mode off....\n");
            dprint("Match cannot be started.\n");
        }
        return;
    }
    if (clanbattle == 1 && cb_prematch == 0) {
        if (self != world) {
            sprint(self, 2, "Clan Battle in progress....\n");
            sprint(self, 2, "Type break to stop the current battle.\n");
        }
        else {
            dprint("Clan Battle in progress....\n");
            dprint("Type break to stop the current battle.\n");
        }
        return;
    }
    timer = find(world, classname, "prematch");
    while (timer != world) {
        dremove(timer);
        timer = find(timer, classname, "prematch");
    }
    te = find(world,classname,"pmmessage");
    if (te != world) {
        te.think = SUB_Remove;
        te.nextthink = 0.01;
    }

    ResetBreakAndReady();
    timer = spawn();
    timer.owner = world;
    timer.classname = "prematch";
    timer.cnt = 0;
    timer.cnt2 = rint(stof(infokey(world, "count")));
    if (timer.cnt2 < 1) {
        //By default, 10 seconds of countdown
        timer.cnt2 = 10;
    }
    timer.cnt2 = (timer.cnt2 + 1);
    timer.nextthink = (time + 0.1);
    timer.think = PreMatch_Think;

    p = find(world, classname, "player");
    while (p != world) {
        if (p.netname != "") {
            stuffcmd(p, "play items/protect2.wav\n");
        }
        p = find(timer, classname, "player");
    }
};

void () StopTimer =
{
    local entity t;

    if (infokey(world, "serverdemo") != string_null) {
        localcmd("cancel\n");
    }
    if (cb_prematch) {
        t = find(world, classname, "prematch");
        while (t != world) {
            t.nextthink = (time + 0.1);
            t.think = SUB_Remove;
            t = find (t, classname, "prematch");
        }
        localcmd("serverinfo status Standby\n");
        lightstyle(0, "m");
        return;
    }
    t = find(world, classname, "match");
    if (t != world) {
        remove(t);
    }
    localcmd("serverinfo status Normal\n");
};

void () CenterPrint_Players_NotReady = {
    string players_not_ready;
    entity te;
    players_not_ready = "Not ready: ";

    local float first = 0;
    te = find (world, classname, "player");
    while (te) {
        if (te.is_ready == 0)
        {
            first = first + 1;
            if (first == 1)
            {
                players_not_ready = strcat(players_not_ready, te.netname);
            }
            else if (first > 1 && first < 5)
            {
                players_not_ready = strcat(players_not_ready, ", ", te.netname);
            }
            else if (first >= 5)
            {
                players_not_ready = strcat(players_not_ready, " and others...");
                break;
            }
        }
        te = find (te, classname, "player");
    }
    players_not_ready = strcat(players_not_ready, "\n", "Type \s/ready\s in the console to toggle your ready status\n");

    te = find(world, classname, "player");
    while (te)
    {
        CenterPrint(te, players_not_ready);
        te = find(te, classname, "player");
    }
}

void () Broadcast_Players_NotReady = {
    local entity te;
    if (v_ready != 0) {
        local string players_not_ready = "Not ready: ";
        local float first = 1;
        te = find (world, classname, "player");
        while (te != world) {
            if (te.is_ready == 0) {
                if (!first)
                    players_not_ready = strcat(players_not_ready, ", ");
                else
                    first = 0;
                players_not_ready = strcat(players_not_ready, te.netname);
            }
            te = find (te, classname, "player");
        }
        players_not_ready = strcat(players_not_ready, "\n");
        bprint(1, players_not_ready);
        te = find (world, classname, "player");
        while (te != world) {
            if (te.is_ready == 0)
                sprint(te, 2, "If you are ready, type \s/ready\s in the console\n");
            te = find(te, classname, "player");
        }
        return;
    }
    else {
        bprint(1, "No player is ready\n");
    }

}

void () PlayerNotReady = {
    if (self.is_ready) {
        bprint2 (2, self.netname, " is NOT ready anymore\n ");
        self.is_ready = 0;
        v_ready = (v_ready - 1);
        Broadcast_Players_NotReady();
    }
}

void () PlayerReady =
{
    local float f1;

    if (is_countdown) {
        sprint(self, 2, "You cannot do this after countdown has started.\n");
        return;
    }
    if (infokey (world, "status") != "Standby") {
        sprint(self, 2, "You cannot do this after the match has started.\n");
        return;
    }
    if (self.team_no == 0) {
        sprint(self, 2, "You must join a team first.\n");
        return;
    }
    if (self.playerclass == 0) {
        sprint(self, 2, "You must choose a class first.\n");
        return;
    }
    if (intermission_running)
        return;
    if (self.classname != "player")
        return;
    if (self.is_ready) {
        PlayerNotReady();
        return;
    }
    self.is_ready = 1;
    v_ready = v_ready + 1;
    bprint2 (3, self.netname, " is ready to start the match\n");
    f1 = TeamFortress_GetNoPlayers ();
    if (v_ready == f1 ) {
        if(cease_fire) {
            bprint (2, "All players ready, match will start after ceasefire ends.\n");
        } else {
            bprint (2, "All players ready, starting match\n");
            StartTimer ();
        }
        return;
    }
    Broadcast_Players_NotReady();
};

void () RemoveVotes = {
    if (self.ready) {
        bprint2(2, self.netname, " is NOT ready anymore\n ");
        self.ready = 0;
        v_ready = (v_ready - 1);
    }
};

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

void () QuadRoundOver = {
	round_over = 2;
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

	if (!cease_fire)
		self.cnt2 = (self.cnt2 - 1);

	if (!self.cnt2)	{
		if ((self.cnt == 1) || (self.cnt == 5)) {
			tmp = ftos (self.cnt);
			bprint3(2, "\s[\s", tmp, "\s]\s minute");
			if (self.cnt != 1)
				bprint(2, "s");
			bprint(2, " remaining\n");
		}
		if (!self.cnt) {
			if (rounds > 1)
            {
                local string st;
                st = infokey(world, "round_delay_time");
                bprint(2, "ROUND TIME OVER\nNext round begins in ", st, " seconds\n");
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
			bprint3(2, "\s[\s", tmp, "\s]\s second");
			if ((self.cnt2 != 1))
				bprint(2, "s");
			bprint(2, " remaining\n");
		}
	}
	gametime++;
	self.nextthink = (time + 1);
};

void () QuadRoundBegin = {

	local entity te;
	local entity oldself;
	local float counter;
	localcmd(strcat(strcat("timelimit ", ftos(stof(infokey(world, "round_time")))), "\n"));
	te = find(world, classname, "func_breakable");
	while (te) {
		setmodel(te, te.mdl);
		te.solid = SOLID_BSP;
		te = find(te, classname, "func_breakable");
	}
	cb_prematch = 0;

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
 	round_active = 1;
	round_over = 0;
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

	if ((number_of_teams < 1) || cease_fire)	{
		self.nextthink = (time + 2);
		if (self.cnt2 <= 5)
			self.cnt2 = 10;
		return;
	}
	self.cnt2 = (self.cnt2 - 1);
	if (self.cnt2 == 2)
		round_over = 2;
	else {
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
	}

    num = ftos(self.cnt2);
    p = find (world, classname, "player");
    while (p) {
        if (p.netname != "") {
            CenterPrint3(p, "Round begins in: ", num, " second(s).\nEnsure correct class is chosen!\n");

            if (self.cnt2 <= 5)
            {
                cease_fire = 0;
                stuffcmd(p, "play buttons/switch04.wav\n");
            }
        }
        p = find(p, classname, "player");
    }
	self.nextthink = (time + 1);
};

void () StartQuadRound =
{
	local string st;
	local float fl;
	local entity te;
	local entity te2;
	local entity oldself;
	local entity gren;
	local entity p;

	lightstyle(0, "m");
	cb_prematch = 1;
    cease_fire = 0;

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

	if (rounds == 1) {
		quad_winner = CheckWinningTeam();
		if (quad_winner == 0)
			bprint (2, "Round Drawn!\n");
		else if (quad_winner == 1)
			bprint(2, "Blue Team Wins!\n");
		else if (quad_winner == 2)
			bprint(2, "Red Team Wins!\n");

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
	if (rounds > 1)
		rounds = (rounds - 1);
	if (intermission_running)
		return;

	round_over = 1;

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
	st = infokey(world, "count");
	fl = stof(st);
	if ((fl < 3) || (fl > 20)) {
		fl = 10;
	}

    local float rdt;
    st = infokey(world, "round_delay_time");
    rdt = stof(st);
	te.cnt2 = rdt;
	st = infokey (world, "round_time");
	te.cnt = stof (st);
	quad_winner = CheckWinningTeam();
	localcmd("serverinfo status Standby\n");
	if (rounds > 1) {
		te.think = QuadRoundBegin;
		te.nextthink = (time + 0.01);
	}
	else {
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
