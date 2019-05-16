void team_control_point_master()
{
    /*This entity controls all the control points in a map. It is responsible for the layout of the hud icons as well as some round specific settings. */



Name <string>
The targetname that other entities refer to this entity by.

Cap Layout <string>
A string that tells the HUD how to lay out the cap points. It should be a string with indexes of cap points separated by commas to denote a new line. So 2,0 1 would create a pyramid, with cap point 2 on the top and cap points 0 & 1 on the bottom.
Custom cap position X <float>
Set the cap layout custom X position [0,1]
Custom cap position Y <float>
Set the cap layout custom Y position [0,1]
Restrict team from winning <choices>
Prevent this team from winning by capping all the points. This field is ignored if you''re using control_point_rounds in your map (set the corresponding field inside the rounds).
0 : Neither
1 : Both
2 : Red
3 : Blue
Switch teams on map win? <boolean>
Switch the teams when one team has won the map and the game is going to be reset.
Scoring style <choices>
Sets the style of scoring used for capture point maps.
0 : Add team score for each round won
1 : Add team score for each captured point
Partial cap rate <float>
Rate at which to give partial cap points for area captures.

Inputs
Targetname:
Kill
Removes this entity and any entities parented to it from the world.

EnableDisable:
Enable
Disable
Enable/disable this entity from performing its task. It might also disappear from view.
SetWinner  <integer>
Set the winner of the round to this team (0 for a stalemate).
 Bug: 	Firing this Input when a point capture is in progress will not cancel the capture, resulting in an Overtime condition.
SetWinnerAndForceCaps  <integer>
Set the winner of the round to this team and give them ownership of all points.
 Bug: 	Firing this Input when a point capture is in progress will not cancel the capture, resulting in an Overtime condition.
SetCapLayout  <string>
Set the cap layout string.

OnWonByTeam1
Sent when RED wins the game.
OnWonByTeam2
Sent when BLUE wins the game.

}

void team_control_point()
{
    /*
    Designates the location of a capture point; use in conjunction with trigger_capture_area. There is a maximum of 8 control points per map.*/

Name: control_point_1
Print name: (you can set a descriptive name of the place here - selected warehouse) Warehouse
Group index: Unless you are making a multi-round map, leave this set to the default 0 value for all capture points.
Default owner: This determines the owner of the point when the round starts. Leave it set it to Neither.
Index: You should order your control points starting from 0. So if this is the nth point, set this to n-1.
Warning Type: Normal Announcements



Keyvalues
Targetname:

Name <string>
The targetname that other entities refer to this entity by.
Entity Scripts <scriptlist> (New with Left 4 Dead 2)
Space delimited list of VScript files (without file extension) that are executed after all entities have spawned. The scripts are all executed in the same script scope, later ones overwriting any identical variables and functions.
Script think function <string> (New with Left 4 Dead 2)
Name of a function in this entity''s script which will be called automatically every 100 milliseconds (ten times a second) for the duration of the script. It can be used to create timers or to simulate autonomous behavior. The return value (if present) will set the time until the next call.
 Note:	Try to avoid expensive operations in this function, as it may cause performance problems.
Parentname:

Parent <targetname>
Specifies a movement parent. An entity will maintain its initial offset from its parent. An attachment point can be added to the end of the name, separated by a comma.
Angles:

Pitch Yaw Roll (Y Z X) <angle>
This entity''s orientation in the world. Pitch is rotation around the Y axis, yaw is the rotation around the Z axis, roll is the rotation around the X axis.
EnableDisable:

Start Disabled (StartDisabled) <boolean>
Stay dormant until activated (probably with the Enable input).
Start locked <boolean>
Locked means the point will not be available for capture until it is unlocked via its input.
Print Name <string>
LOCALIZED name to print on the HUD.
Group Index <integer>
Used for grouping points together under a team_control_point_master (not using control point rounds).
Default Owner <choices>
Default Owner of the control point.
0 : Neither
2 : Red
3 : Blue
Index <integer>
Index of this point (must be unique).
Warning Type <choices>
Type of warning to issue to the team that owns the control point when the opposing team starts to capture it.
0 : Normal Announcements
1 : Final Capture Point Warning
2 : No Announcements
Warning sound <string>
Sound to be played when this point is being captured (if warn on capture is set).
Randomly set the owner on restart <boolean>
Randomly set the owner of this point during a full restart of the map. The ratio of default owners among the points with this flag will be kept when selecting random owners.
Time-based point value for RED. <integer>
To do: add description
Time-based point value for BLUE. <integer>
To do: add description
Reset Sound <sound>
Sound made when point resets.
Red Capture Sound <sound>
Sound made when RED captures.
Blue Capture Sound <sound>
Sound made when BLUE captures.
Reset model bodygroup <integer>
Control point model bodygroup used when point reverts to neutral state.
RED model bodygroup <integer>
Control point model bodygroup used when RED owns the point.
BLUE model bodygroup <integer>
Control point model bodygroup used when RED owns the point.
HUD overlay neutral <material>
HUD material that will overlay the icon when no one owns the point.
HUD overlay RED <material>
HUD material that will overlay the icon when RED owns the point.
HUD overlay BLUE <material>
HUD material that will overlay the icon when BLUE owns the point.
RED Previous Required Point 1 <targetname>
The name of a previous capture point that RED must own to be able to capture this point. If empty, the team must own all points preceding this one. Pointing to itself means no previous point required.
RED Previous Required Point 2 <targetname>
The name of a second previous capture point that RED must own to be able to capture this point.
RED Previous Required Point 3 <targetname>
The name of a third previous capture point that RED must own to be able to capture this point.
BLUE Previous Required Point 1 <targetname>
The name of a previous capture point that BLUE must own to be able to capture this point. If empty, the team must own all points preceding this one. Pointing to itself means no previous point required.
BLUE Previous Required Point 2 <targetname>
The name of a second previous capture point that BLUE must own to be able to capture this point.
BLUE Previous Required Point 3 <targetname>
The name of a third previous capture point that BLUE must own to be able to capture this point.
Flags
1 : Hide Control Point on HUD
2 : Start with model hidden
4 : Disable shadow
8 : Disable sounds
Inputs
Targetname:

Kill
Removes this entity and any entities parented to it from the world.
KillHierarchy
Functions the same as Kill, although entities with a large number of children are killed marginally faster.
AddOutput  <string>
Evaluates a keyvalue/output on this entity. It can be potentially very dangerous, use with care.
Format: <key> <value>
Format: <output name> <targetname>:<inputname>:<parameter>:<delay>:<max times to fire, -1 means infinite>
FireUser1 to FireUser4
Fire the OnUser outputs; see User Inputs and Outputs.
Use  !FGD
Same as a player invoking +use; may not do anything. Can also be invoked by creating an output that does not specify an input.
This input is not included in Valve''s FGDs.
RunScriptFile  <script> (New with Left 4 Dead 2)
Execute a VScript file from disk, without file extension. The script contents are merged with the script scope of the receiving entity.
RunScriptCode  <string> (New with Left 4 Dead 2)
Execute a string of VScript source code in the scope of the entity receiving the input. String quotation may be needed when fired via console.
 Bug: 	In <Left 4 Dead 2>, the code is executed in the script scope of the entity that fires the output, not the one receiving the input.
 Warning: Never try to pass string parameters to a script function with this input. It will corrupt the VMF structure because of the nested quotation marks, which then must be removed manually with a text editor.
CallScriptFunction  <string> (New with Left 4 Dead 2) !FGD
Execute a VScript function in the scope of the receiving entity.
 Note:	This input is missing from some games FGD files.
SetLocalOrigin  <origin> (New with Alien Swarm) !FGD
Set this entity''s origin in the map.
 Note:	This input is missing from some games FGD files.
SetLocalAngles  <angles> (New with Alien Swarm) !FGD
Set this entity''s angles in the map.
 Note:	This input is missing from some games FGD files.
Parentname:

SetParent  <string>
Move with this entity. See Entity Hierarchy (parenting).
SetParentAttachment  <string>
Change this entity to attach to a specific attachment point on its parent. The entity will teleport so that the position of its root bone matches that of the attachment. Entities must be parented before being sent this input.
SetParentAttachmentMaintainOffset  <string>
As above, but without teleporting. The entity retains its position relative to the attachment at the time of the input being received.
ClearParent
Removes this entity from the the movement hierarchy, leaving it free to move independently.
Template:I Angles
EnableDisable:

Enable
Disable
Enable/disable this entity from performing its task. It might also disappear from view.
SetOwner  <integer>
Set the owner of the point.
HideModel
Hide the control point model.
ShowModel
Show the control point model again.
SetLocked  <integer>
Lock the control point. 0 = unlocked, 1 = locked
SetUnlockTime  <integer>
This will automatically unlock the control point in the specified amound of time (seconds).
Outputs
Targetname:

OnUser1 to OnUser4
These Outputs each fire in response to the firing of the like-numbered FireUser1 to FireUser4 Input; see User Inputs and Outputs.
OnKilled  (New with Left 4 Dead)
This Output fires when the entity is killed and removed from the game.
OnOwnerChangedToTeam1
Sent when owner is changed to RED.
OnOwnerChangedToTeam2
Sent when owner is changed to BLUE.
OnCapReset
Sent when owner is changed to neutral.
OnRoundStartOwnedByTeam1
Sent when a round is starting and the point is owned by RED.
OnRoundStartOwnedByTeam2
Sent when a round is starting and the point is owned by BLUE.
OnCapTeam1
Sent when RED capture this point.
OnCapTeam2
Sent when BLUE capture this point.
OnUnlocked
Sent when point unlocks.
}

void trigger_capture_area()
{
Name: capture_area_1
Control Point: control_point_1
Can *team* cap?: If you want an Attack/Defense style map, set the value for the defending team to No, otherwise leave both teams set to Yes.
Number of *team* players to cap: The ideal value is 2, but if you''re making a map with 5 capture points, ideally, you will want to set the first capture points'' to 1, the second ones'' to 2 and the middle one''s to 3.
*team* spawn adjust: You don''t want to set this too high or a team will either spawn too fast or never spawn. I set both to 5.
Time to cap: The closer to the headquarters, the less you will want this to be. Ideally, this should be 5-20 seconds.


Capture area for a team_control_point to make a capture point. Also used to define the push/block zone around a Payload cart when a func_tracktrain is defined as its parent.

 Bug: 	The HUD will show the waiting for teammate message if the control point is currently disabled.
Keyvalues
Targetname:

Name <string>
The targetname that other entities refer to this entity by.
Entity Scripts <scriptlist> (New with Left 4 Dead 2)
Space delimited list of VScript files (without file extension) that are executed after all entities have spawned. The scripts are all executed in the same script scope, later ones overwriting any identical variables and functions.
Script think function <string> (New with Left 4 Dead 2)
Name of a function in this entity''s script which will be called automatically every 100 milliseconds (ten times a second) for the duration of the script. It can be used to create timers or to simulate autonomous behavior. The return value (if present) will set the time until the next call.
 Note:	Try to avoid expensive operations in this function, as it may cause performance problems.
EnableDisable:
Start Disabled (StartDisabled) <boolean>
Stay dormant until activated (probably with the Enable input).
Control point <targetname>
Name of the control point this area is linked to.
Can RED Cap? <boolean>
Can RED capture this point?
Can BLU Cap? <boolean>
Can BLU capture this point?
Number of RED players to cap <integer>
Number of RED players needed to begin capturing this point. If not enough players are present, the point will say "Waiting for teammate."
Number of BLU players to cap <integer>
Number of BLU players needed to begin capturing this point. If not enough players are present, the point will say "Waiting for teammate."
RED Spawn Adjust <integer>
Adjust the minimum respawn time for the RED team by this amount (in seconds) when RED captures this point. If the RED team owns this point when BLU captures it, this adjustment is reversed.
BLU Spawn Adjust <integer>
Adjust the minimum respawn time for the BLU team by this amount (in seconds) when BLU captures this point. If the BLU team owns this point when RED captures it, this adjustment is reversed.
Time to cap (sec) <integer>
Time to capture this area (in seconds).

Inputs
Targetname:

Kill
Removes this entity and any entities parented to it from the world.
KillHierarchy
Functions the same as Kill, although entities with a large number of children are killed marginally faster.
AddOutput  <string>
Evaluates a keyvalue/output on this entity. It can be potentially very dangerous, use with care.
Format: <key> <value>
Format: <output name> <targetname>:<inputname>:<parameter>:<delay>:<max times to fire, -1 means infinite>
FireUser1 to FireUser4
Fire the OnUser outputs; see User Inputs and Outputs.
Use  !FGD
Same as a player invoking +use; may not do anything. Can also be invoked by creating an output that does not specify an input.
This input is not included in Valve''s FGDs.
RunScriptFile  <script> (New with Left 4 Dead 2)
Execute a VScript file from disk, without file extension. The script contents are merged with the script scope of the receiving entity.
RunScriptCode  <string> (New with Left 4 Dead 2)
Execute a string of VScript source code in the scope of the entity receiving the input. String quotation may be needed when fired via console.
 Bug: 	In <Left 4 Dead 2>, the code is executed in the script scope of the entity that fires the output, not the one receiving the input.
 Warning: Never try to pass string parameters to a script function with this input. It will corrupt the VMF structure because of the nested quotation marks, which then must be removed manually with a text editor.
CallScriptFunction  <string> (New with Left 4 Dead 2) !FGD
Execute a VScript function in the scope of the receiving entity.
 Note:	This input is missing from some games FGD files.
SetLocalOrigin  <origin> (New with Alien Swarm) !FGD
Set this entity''s origin in the map.
 Note:	This input is missing from some games FGD files.
SetLocalAngles  <angles> (New with Alien Swarm) !FGD
Set this entity''s angles in the map.
 Note:	This input is missing from some games FGD files.
EnableDisable:

Enable
Disable
Enable/disable this entity from performing its task. It might also disappear from view.
SetTeam

<integer> Changes the entity''s team.
SetTeamCanCap

<string> Set whether a specific team is allowed to capture this point. Format is: <team number> <(0/1)>. i.e. ''2 0'' would prevent RED from capturing this point, whereas ''3 1'' would allow BLU to cap it.
Outputs
Targetname:

OnUser1 to OnUser4
These Outputs each fire in response to the firing of the like-numbered FireUser1 to FireUser4 Input; see User Inputs and Outputs.
OnKilled  (New with Left 4 Dead)
This Output fires when the entity is killed and removed from the game.
OnStartTeam1

Sent when RED start capture.
OnBreakTeam1

Sent when a RED capture is broken. Note that the capture progress on a point must be completely drained for the capture to be considered broken.
OnCapTeam1

Sent when RED captures.
OnStartTeam2

Sent when BLU start capture.
OnBreakTeam2

Sent when a BLU capture is broken.
OnCapTeam2

Sent when BLU captures.
OnStartCap

Sent when either team starts capture.
OnBreakCap

Sent when either team breaks capture.
OnEndCap

Sent when either team captures.
OnNumCappersChanged

Sent when the number of people in the capture area changes. The output value is the number of capturing players. To do: What about no players and blocking players?

}