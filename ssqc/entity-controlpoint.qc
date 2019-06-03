float CheckEnts()
{
    entity cpm = find(world, classname, "team_control_point_master");
    if (!cpm)
    {
        bprint(PRINT_HIGH, "team_control_point_master does not exist, cannot load map");
        return FALSE;
    }
        
    entity tcp;
    tcp = find(world, classname, "team_control_point");
    if (!tcp)
    {
        bprint(PRINT_HIGH, "team_control_point does not exist, cannot load map");
        return FALSE;
    }

    return TRUE;
}

float CanTeamWin(float teamno)
{
    entity cpm = find(world, classname, "team_control_point_master");

    if (cpm.restrictteamfromwin == teamno || cpm.restrictteamfromwin == OPT_BOTH)
    {
        return FALSE;
    }
    return TRUE;
}

void DoRoundWin(float teamno)
{
    rounds = rounds - 1;

    if (rounds == 0)
    {
        // game is over
        switch (self.scorestyle)
        {
            case SCORESTYLE_HOLD:
                switch (teamno)
                {
                    case TEAM_NONE:

                        break;
                    case TEAM_BLUE:

                        break;
                    case TEAM_RED:

                        break;
                }
                break;
            case SCORESTYLE_TIME:

                break;
        }
    }
    else
    {
        switch (self.scorestyle)
        {
            case SCORESTYLE_HOLD:
                
                break;
            case SCORESTYLE_TIME:
                // TODO - track round time, set as countdown time for next round, swap teams
                
                break;
        }
        
        if (self.switchteamsonwin)
        {
            // reset all ents to their original values (disabled/activated etc)
            // change team nums on each ent
        }
    }
}

void CalcScoreHold()
{
    entity cp;
    cp = find(world, classname, "team_control_point");
    while (cp)
    {
        if (cp.team_no != 0)
        {
            if (self.scorestyle == SCORESTYLE_HOLD)
            {
                if ((cp.timesincelastpointscore + cp.timebetweenpointscore) <= time)
                {
                    // award points to team
                    switch (cp.team_no)
                    {
                        case TEAM_BLUE:
                            team1score++;
                            break;
                        case TEAM_RED:
                            team2score++;
                            break;
                    }
                    
                    cp.timesincelastpointscore = cp.timesincelastpointscore + cp.timebetweenpointscore;
                }
            }
        }
        cp = find(cp, classname, "team_control_point");
    }

    float maxscore;
    maxscore = stof(infokey(world, "max_teamscore"));
    if (team1score >= maxscore && team2score >= maxscore)
    {
        // TODO draw?
        DoRoundWin(TEAM_NONE);
    }
    else if (team1score >= maxscore)
    {
        DoRoundWin(TEAM_BLUE);
    }
    else if (team2score >= maxscore)
    {
        DoRoundWin(TEAM_RED);
    }
}

void CalcScoreTime()
{
    float won = TRUE;
    float capteam = TEAM_NONE;
    entity cp;
    cp = find(world, classname, "team_control_point");
    while (cp)
    {
        if (won == 0)
        {
            if (cp.team_no == TEAM_NONE)
            {
                won = FALSE;
                break;
            }
            else
            {
                capteam = cp.team_no;
                won = TRUE;
                cp = find(cp, classname, "team_control_point");
                continue;
            }
        }

        if (cp.team_no != capteam)
        {
            won = FALSE;
            break;
        }

        cp = find(cp, classname, "team_control_point");
    }

    if (won)
    {
        DoRoundWin(capteam);
    }
}

void team_control_point_master_Think()
{
    self.nextthink = time + 1;
    //if (!GameStarted)
    //    return;

    // go through capture points, see if points need to be awarded to a team
    switch (self.scorestyle)
    {
        case SCORESTYLE_HOLD:
            CalcScoreHold();
            break;
        case SCORESTYLE_TIME:
            CalcScoreTime();
            break;
    }
}

/*This entity controls all the control points in a map. It is responsible for the layout of the hud icons as well as some round specific settings. */
void team_control_point_master()
{
    // fastest to cap cps in a round, other team gets that time to cap
    // points every x seconds whilst holding 
    
    // self.caplayout should be a string with indexes of cap points separated by commas to denote a new line. So 2,0 1 would create a pyramid, with cap point 2 on the top and cap points 0 & 1 on the bottom.
    float count = 0;
    entity cp;
    cp = find (world, classname, "team_control_point");
    string layout = "";
    while(cp)
    {
        count++;
        layout = strcat(layout, ", ", ftos(cp.capnum));
        cp = find(cp, classname, "team_control_point");
    }

    if (!self.caplayout)
    {
        // random caplayout string if not set
        self.caplayout = layout;
    }
    
    // self.switchteamsonwin

    self.think = team_control_point_master_Think;
    self.nextthink = time + 1;
}

/*Designates the location of a capture point; use in conjunction with trigger_capture_area.*/
void team_control_point()
{
    if (!self.targetname)
    {
        bprint(PRINT_HIGH, "targetname not set on team_control_point!");
        return;
    }

    if (!self.noise)
        self.noise = "capture.wav";
    
    if (!self.noise1)
        self.noise1 = "capturefinish.wav";

    if (!self.noise2)
        self.noise2 = "capturereset.wav";
        
    precache_sound(self.noise);
    precache_sound(self.noise1);
    precache_sound(self.noise2);

    if (!self.neutralmodel)
        self.neutralmodel = "captureneutral.mdl";

    if (!self.bluemodel)
        self.bluemodel = "captureblue.mdl";

    if (!self.redmodel)
        self.redmodel = "capturered.mdl";

    precache_model(self.neutralmodel);
    precache_model(self.bluemodel);
    precache_model(self.redmodel);

    if (!self.timebetweenpointscore)
        self.timebetweenpointscore = 5;
}

// TODO - this might be wrong, does it take into account leftover time between each whole percentage point? Review it
void DoCaptureProgress(float teamcapping, float increase)
{
    // need to track last capture percentage etc
    float percenttime = 100 / self.timetocap;
    float timediff = time - self.cnt;

    float percen = floor(timediff / percenttime);

    if (percen > 0)
    {
        if (increase == TRUE)
        {
            self.progress = self.progress + percen;
        }
        else
        {
            self.progress = self.progress - percen;
        }
        self.cnt = self.cnt + (percen * percenttime);
    }

    // check if cap finished
    entity p = find(world, classname, "player");
    string cmd = "play ";
    if (self.progress == 100)
    {
        self.owner.team_no = teamcapping;
        string model = teamcapping == 1 ? self.owner.bluemodel : self.owner.redmodel;
        
        setmodel(self.owner, model);
        cmd = strcat(cmd, self.owner.noise1, "\n");
        while (p)
        {
            stuffcmd(p, cmd);
            p = find(p, classname, "player");
        }
    }
    else if (self.progress == 0)
    {
        setmodel(self.owner, self.neutralmodel);
        cmd = strcat(cmd, self.owner.noise2, "\n");
        while (p)
        {
            stuffcmd(p, cmd);
            p = find(p, classname, "player");
        }
    }
}

float PrecedingCapsOwned(float teamno, float cpnum, float selfcpnum)
{
    // cpnum is only checked here for blank for first one
    // must own all points preceding this one if blank
    if (!cpnum)
    {
        return FALSE;
    }

    // required cp points to self, it can be capped whenever
    if (cpnum == selfcpnum)
    {
        return TRUE;
    }

    // is specifying what other capnums need to be owned
    float owned;
    owned = 0;
    entity cp;
    cp = find(world, classname, "team_control_point");
    while (cp)
    {
        if (cp.capnum == cpnum)
        {
            if (cp.team_no == teamno)
            {
                return TRUE;
            }
        }
        cp = find(cp, classname, "team_control_point");
    }

    // not satisfied
    return FALSE;
}

// TODO - what about when a player steps out/it's not capped, we need to reset self.cnt = time, right?  Otherwise 30 seconds later someone caps and it automatically does 100%
void trigger_capture_area_Think()
{
    self.nextthink = time + .1;
    //if (!GameStarted)
    //    return;

    if (!self.owner)
    {
        entity cp = find(world, targetname, self.target);
        if (!cp)
        {
            bprint(PRINT_HIGH, "trigger_capture_area is not linked to a team_control_point (target/targetname)");
            self.nextthink = 0;
            return;
        }
        else
        {
            self.owner = cp;
        }
    }

    // figure out who is capping
    float ownerplayers = 0;
    float enemyplayers = 0;
    float blueplayers = 0;
    float redplayers = 0;
    entity p;
    p = find (world, classname, "player");

    while (p)
    {
        if (p.origin_z >= self.absmin_z && p.origin_x >= self.absmin_x && p.origin_y >= self.absmin_y)
        {
            if (p.origin_z >= self.absmax_z && p.origin_x >= self.absmax_x && p.origin_y >= self.absmax_y)
            {
                if (p.team_no == TEAM_BLUE)
                {
                    blueplayers = blueplayers + 1;
                }
                else if (p.team_no == TEAM_RED)
                {
                    redplayers = redplayers + 1;
                }
                
                if (p.team_no == self.owner.team_no)
                {
                    ownerplayers = ownerplayers + 1;
                }
                else if (p.team_no != self.owner.team_no && self.owner.team_no != TEAM_NONE)
                {
                    enemyplayers = enemyplayers + 1;
                }
            }
        }
        
        p = find(p, classname, "player");
    }

    // check there's enough players
    float teamcapping;
    teamcapping = TEAM_NONE;
    float cappingplayers = 0;

    if (blueplayers >= self.numtocap && redplayers == 0)
    {
        teamcapping = TEAM_BLUE;
        cappingplayers = blueplayers;
    }
    else if (redplayers >= self.numtocap && blueplayers == 0)
    {
        teamcapping = TEAM_RED;
        cappingplayers = redplayers;
    }
    else if (self.owner.team_no != TEAM_NONE)
    {
        return;
    } 

    if (teamcapping > 0)
    {
        // a team is capping, now check if they're allowed
        switch (teamcapping)
        {
            case TEAM_BLUE:
                if (!self.owner.bluecancap)
                    return;

                if (!PrecedingCapsOwned(TEAM_BLUE, self.owner.bluemustown1, self.owner.capnum))
                    return;
                // check others for a value, blank value only checked on first field
                if (self.owner.redmustown2)
                {
                    if (!PrecedingCapsOwned(TEAM_BLUE, self.owner.bluemustown2, self.owner.capnum))
                        return;
                }

                if (self.owner.redmustown3)
                {
                    if (!PrecedingCapsOwned(TEAM_BLUE, self.owner.bluemustown3, self.owner.capnum))
                        return;
                }
                break;
            case TEAM_RED:
                if (!self.owner.redcancap)
                    return;

                if (!PrecedingCapsOwned(TEAM_RED, self.owner.redmustown1, self.owner.capnum))
                    return;
                // check others for a value, blank value only checked on first field
                if (self.owner.redmustown2)
                {
                    if (!PrecedingCapsOwned(TEAM_RED, self.owner.redmustown2, self.owner.capnum))
                        return;
                }

                if (self.owner.redmustown3)
                {
                    if (!PrecedingCapsOwned(TEAM_RED, self.owner.redmustown3, self.owner.capnum))
                        return;
                }     
                break;
        }
    }

    if (cappingplayers < self.numtocap && teamcapping != TEAM_NONE)
        return;

    // work out if increasing or decreasing cap progress
    float increase = FALSE;
    if (self.owner.team_no == teamcapping)
    {
        // already owned by capping team and progress is 100
        if (self.progress == 100)
        {
            return;
        }
        else
        {
            if (teamcapping == TEAM_NONE)
            {
                increase = FALSE;
            }
            else
            {
                increase = TRUE;
            }
        }
    }
    else
    {
        // unowned, so increase progress
        if (self.owner.team_no == TEAM_NONE)
        {
            if (teamcapping == TEAM_NONE)
            {
                increase = FALSE;
            }
            else
            {
                increase = TRUE;    
            }
        }
        else
        {
            increase = FALSE;
        }
        
    }
    
    // do cap progress
    DoCaptureProgress(teamcapping, increase);
}


void trigger_capture_area_Touch()
{
    string mer = strcat("other touch: ", other.classname);
    dprint(mer);
/*
    if (other.capnum != self.capnum)
    {
        other.capnum = self.capnum;
        switch (other.team_no)
        {
            case TEAM_BLUE:
                self.blueplayers = self.blueplayers + 1;
                break;
            case TEAM_RED:
                self.redplayers = self.redplayers + 1;
                break;
        }
    }
*/
    
}

void trigger_capture_area()
{
    self.solid = SOLID_TRIGGER;
    self.touch = trigger_capture_area_Touch;

    self.think = trigger_capture_area_Think;
    self.nextthink = time + .1;
}