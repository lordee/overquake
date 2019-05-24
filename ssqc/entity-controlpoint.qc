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

void team_control_point_master_Think()
{
    //if (!GameStarted)
    //    return;

    
}

void team_control_point_master()
{
    /*This entity controls all the control points in a map. It is responsible for the layout of the hud icons as well as some round specific settings. */
    
    // do stuff with self.caplayout should be a string with indexes of cap points separated by commas to denote a new line. So 2,0 1 would create a pyramid, with cap point 2 on the top and cap points 0 & 1 on the bottom.

    // self.switchteamsonwin

    // self.scorestyle - 0 points for hold, 1 points for round win, 2 points for captured cp

    // self.winneronroundend 0, 1, 2 Firing this Input when a point capture is in progress will not cancel the capture, resulting in an Overtime condition.

    self.think = team_control_point_master_Think;
    self.nextthink = time + 1;
}

void team_control_point()
{
    /*
    Designates the location of a capture point; use in conjunction with trigger_capture_area.*/

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
    if (self.progress == 100)
    {
        self.owner.team_no = teamcapping;
        string model = teamcapping == 1 ? self.owner.bluemodel : self.owner.redmodel;
        
        setmodel(self.owner, model);
        entity p = find(world, classname, "player");
        string cmd = strcat("play ", self.owner.noise1, "\n");
        while (p)
        {
            stuffcmd(p, cmd);
            p = find(p, classname, "player");
        }
    }
    else if (self.progress == 0)
    {
        setmodel(self.owner, self.neutralmodel);
        entity p = find(world, classname, "player");
        string cmd = strcat("play ", self.owner.noise2, "\n");
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
    float ownerplayers;
    float enemyplayers;
    float blueplayers;
    float redplayers;
    entity p;
    p = find (world, classname, "player")
    {
        if (p is within brush ent area)
        {
            if (p.team_no == 1)
            {
                blueplayers = blueplayers + 1;
            }
            else if (p.team_no == 2)
            {
                redplayers = redplayers + 1;
            }
            
            if (p.team_no == self.owner.team_no)
            {
                ownerplayers = ownerplayers + 1;
            }
            else if (p.team_no != self.owner.team_no && self.owner.team_no != 0)
            {
                enemyplayers = enemyplayers + 1;
            }
        }
        
        p = find(p, classname, "player");
    }

    // check there's enough players
    float teamcapping;
    teamcapping = 0;

    if (blueplayers >= self.numtocap && redplayers == 0)
    {
        teamcapping = 1;
        cappingplayers = blueplayers;
    }
    else if (redplayers >= self.numtocap && blueplayers == 0)
    {
        teamcapping = 2;
        cappingplayers = redplayers;
    }
    else if (self.owner.team_no != 0)
    {
        return;
    } 

    if (teamcapping > 0)
    {
        // a team is capping, now check if they're allowed
        switch (teamcapping)
        {
            case 1:
                if (!self.owner.bluecancap)
                    return;

                if (!PrecedingCapsOwned(1, self.owner.bluemustown1, self.owner.capnum))
                    return;
                // check others for a value, blank value only checked on first field
                if (self.owner.redmustown2)
                {
                    if (!PrecedingCapsOwned(1, self.owner.bluemustown2, self.owner.capnum))
                        return;
                }

                if (self.owner.redmustown3)
                {
                    if (!PrecedingCapsOwned(1, self.owner.bluemustown3, self.owner.capnum))
                        return;
                }
                break;
            case 2:
                if (!self.owner.redcancap)
                    return;

                if (!PrecedingCapsOwned(2, self.owner.redmustown1, self.owner.capnum))
                    return;
                // check others for a value, blank value only checked on first field
                if (self.owner.redmustown2)
                {
                    if (!PrecedingCapsOwned(2, self.owner.redmustown2, self.owner.capnum))
                        return;
                }

                if (self.owner.redmustown3)
                {
                    if (!PrecedingCapsOwned(2, self.owner.redmustown3, self.owner.capnum))
                        return;
                }     
                break;
        }
    }

    if (cappingplayers < self.numtocap && teamcapping != 0)
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
            if (teamcapping == 0)
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
        if (self.owner.team_no == 0)
        {
            if (teamcapping == 0)
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
    dprint("other touch: ", other.classname);
}

void trigger_capture_area()
{

    self.solid = SOLID_TRIGGER;
    self.touch = trigger_capture_area_Touch;
    self.bluecancap
    self.redcancap
    self.target
    self.numtocap // players required to cap --The ideal value is 2, but if you''re making a map with 5 capture points, ideally, you will want to set the first capture points'' to 1, the second ones'' to 2 and the middle one''s to 3.
    self.timetocap // Ideally, this should be 5-20 seconds.

//	The HUD will show the waiting for teammate message if the control point is currently disabled.

    self.think = trigger_capture_area_Think;
    self.nextthink = time + .1;
}