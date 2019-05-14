void CSEv_JoinTeam_f (float teamnum)
{
    self.team_no = teamnum;
    self.menu = MNU_LOBBYCHAMP;
}

void CSEv_ChooseChamp_f (float c)
{
    self.menu = MNU_INACTIVE;
    self.champ_id = c;

    // force a respawn as that champ
    ClientKill();
}

// meh.. outgoing
float Player_SendEntity(entity ePVEnt, float flChanged) {
    WriteByte(MSG_ENTITY, SE_PLAYER); // Unique Identifier, I suggest you use enums to make it easy on yourself
    WriteCoord(MSG_ENTITY, self.origin_x); // Position X
    WriteCoord(MSG_ENTITY, self.origin_y); // Position Y
    WriteCoord(MSG_ENTITY, self.origin_z); // Position Z
    WriteCoord(MSG_ENTITY, self.angles_x); // Angle X
    WriteCoord(MSG_ENTITY, self.angles_y); // Angle Y
    WriteCoord(MSG_ENTITY, self.angles_z); // Angle Z
    WriteShort(MSG_ENTITY, self.velocity_x); // Velocity X
    WriteShort(MSG_ENTITY, self.velocity_y); // Velocity X
    WriteShort(MSG_ENTITY, self.velocity_z); // Velocity X
    WriteFloat(MSG_ENTITY, self.flags); // Flags, important for physics

	WriteString(MSG_ENTITY, self.netname);
	WriteFloat(MSG_ENTITY, self.champ_id);
	WriteFloat(MSG_ENTITY, self.ready);
	WriteFloat(MSG_ENTITY, self.mana);
	WriteFloat(MSG_ENTITY, self.max_mana);
	WriteFloat(MSG_ENTITY, self.health);
	WriteFloat(MSG_ENTITY, self.max_health);
    WriteFloat(MSG_ENTITY, self.skill_selected);
    WriteFloat(MSG_ENTITY, self.skill_one_cooldown);
    WriteFloat(MSG_ENTITY, self.skill_two_cooldown);
    WriteFloat(MSG_ENTITY, self.skill_three_cooldown);
    WriteFloat(MSG_ENTITY, self.skill_four_cooldown);
    WriteFloat(MSG_ENTITY, self.stunned);

    return TRUE;
}

void (entity player, float upd_type, float multicast_type) SendUpdate = {
    msg_entity = player;
    WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET); 
    WriteByte(MSG_MULTICAST, upd_type); 
    switch (upd_type)
    {
        /*case SE_READY:
            WriteByte(MSG_MULTICAST, player.id);
            WriteByte(MSG_MULTICAST, player.ready);
            break;*/
    }
    if (multicast_type == MULTICAST_ONE)
    {
        multicast('0 0 0', multicast_type); 
    }
    else
    {
        multicast(player.origin, multicast_type);     
    }
}