module model.player_context;

import model.world;
import model.player;

immutable class PlayerContext
{
nothrow pure @safe @nogc:

    Player player;
    World world;

    this (
        immutable Player player,
        immutable World world)
    {
        this.player = player;
        this.world = world;
    }
}
