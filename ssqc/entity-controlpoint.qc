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
    while (tcp)
    {
        
        tcp = find(tcp, classname, "team_control_point");
    }

    return TRUE;
}

float DidTeamWin(float teamno)
{
    entity cpm = find(world, classname, "team_control_point_master");

}

void team_control_point_master()
{
    /*This entity controls all the control points in a map. It is responsible for the layout of the hud icons as well as some round specific settings. */
    
    // do stuff with self.caplayout should be a string with indexes of cap points separated by commas to denote a new line. So 2,0 1 would create a pyramid, with cap point 2 on the top and cap points 0 & 1 on the bottom.

    //self.restrictteamfromwin
    Restrict team from winning <choices>
    Prevent this team from winning by capping all the points. This field is ignored if you''re using control_point_rounds in your map (set the corresponding field inside the rounds).
    0 : Neither
    1 : Both
    2 : Red
    3 : Blue

    //self.switchteamsonwin

    // self.scorestyle - 0 points for hold, 1 points for round win, 2 points for captured cp

    // self.winneronroundend 0, 1, 2 Firing this Input when a point capture is in progress will not cancel the capture, resulting in an Overtime condition.
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

void trigger_capture_area_touch()
{
    if (other.classname == "player")
    {
        // 
    }
}

void trigger_capture_area()
{
    self.solid = SOLID_TRIGGER;
    self.touch = trigger_capture_area_touch;
    self.bluecancap
    self.redcancap
    self.target
    self.numtocap // players required to cap --The ideal value is 2, but if you''re making a map with 5 capture points, ideally, you will want to set the first capture points'' to 1, the second ones'' to 2 and the middle one''s to 3.
    self.timetocap // Ideally, this should be 5-20 seconds.
    self.capnum // capnum it is linked to

//	The HUD will show the waiting for teammate message if the control point is currently disabled.


}