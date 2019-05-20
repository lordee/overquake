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
    Designates the location of a capture point; use in conjunction with trigger_capture_area. There is a maximum of 8 control points per map.*/

    self.netname
    self.targetname
    self.capnum // must be unique
    self.team_no // current owner, colours hud too
    self.disabled
    self.noise // played on being captured
    self.noise1 // played on capture finish
    self.noise2 // sound on point resets
    self.neutralmodel // not owned
    self.bluemodel
    self.redmodel
    self.timebetweenpointscore
    self.redmustown1 // If empty, the team must own all points preceding this one. Pointing to itself means no previous point required.
    self.redmustown2
    self.redmustown3
    self.bluemustown1 // If empty, the team must own all points preceding this one. Pointing to itself means no previous point required.
    self.bluemustown2
    self.bluemustown3
}

void CalcCaptureProgress()
{
    // need to track last capture percentage etc
    float percenttime = 100 / self.timetocap;
    float timediff = time - self.cnt;

    float percen = floor(timediff / percenttime);
    if (percen > 0)
    {
        self.progress = self.progress + percen;
        self.cnt = self.cnt + (percen * percenttime);
    }

    // TODO - finish this, what happens on 100 percent etc
}

void trigger_capture_area_Think()
{
    self.nextthink = time + .1;
    //if (!GameStarted)
    //    return;

    entity cp = find(world, targetname, self.target);
    if (!cp)
    {
        bprint(PRINT_HIGH, "trigger_capture_area is not linked to a team_control_point (target/targetname)");
        return;
    }

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
            
            if (p.team_no == self.team_no)
            {
                ownerplayers = ownerplayers + 1;
            }
            else if (p.team_no != self.team_no && self.team_no != 0)
            {
                enemyplayers = enemyplayers + 1;
            }
        }
        
        p = find(p, classname, "player");
    }

    // TODO - refactor, it's ugly
    // if capped
    if (self.progress == 100)
    {
        if (self.team_no == 1)
        {
            if (!self.redcancap)
                return;
        } 
        else if (self.team_no == 2)
        {
            if (!self.bluecancap)
                return;
        }

        if (ownerplayers == 0 && enemyplayers >= self.numtocap)
        {           
            CalcCaptureProgress();
        }
    }
    else
    {
        // if not capped
        if (self.team_no == 0)
        {
            if (blueplayers >= self.numtocap && redplayers == 0 && self.bluecancap)
            {
                CalcCaptureProgress();
            }
            else if (redplayers >= self.numtocap && blueplayers == 0 && self.redcancap)
            {
                CalcCaptureProgress();
            }
        }
        else
        {
            // it has an owner
            if (self.team_no == 1 && redplayers >= self.numtocap && blueplayers == 0 && self.redcancap)
            {
                CalcCaptureProgress();
            }
            else if (self.team_no == 2 && blueplayers >= self.numtocap && redplayers == 0 && self.bluecancap)
            {
                CalcCaptureProgress();
            }
        }
    }
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
    self.capnum // capnum it is linked to

//	The HUD will show the waiting for teammate message if the control point is currently disabled.

    self.think = trigger_capture_area_Think;
    self.nextthink = time + .1;
}