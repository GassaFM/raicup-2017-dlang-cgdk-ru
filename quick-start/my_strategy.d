// This is the ``Quick Start'' strategy: http://russianaicup.ru/p/quick.
// To use it, make a backup copy of your file
// ../my_strategy.d, and then copy this file there.
module my_strategy;

import std.algorithm;
import std.array;
import std.math;
import std.random;
import std.range;
import std.traits;
import std.typecons;

import model;
import strategy;

final class MyStrategy : Strategy
{
    /**
     * Main strategy method, controlling the vehicles.
     * The game engine calls this method once each time tick.
     *
     * @param me    the owner player of this strategy.
     * @param world the current world snapshot.
     * @param game  many game constants.
     * @param move  the object that encapsulates all strategy instructions.
     */
    void move (immutable Player me, immutable World world,
        immutable Game game, Move move)
    {
        initializeStrategy (world, game);
        initializeTick (me, world, game, move);
        if (me.remainingActionCooldownTicks > 0)
        {
            return;
        }
        if (executeDelayedMove ())
        {
            return;
        }
        this.move ();
        executeDelayedMove ();
    }

private:
    Random random;

    Rebindable !(immutable TerrainType [] []) terrainTypeByCellXY;
    Rebindable !(immutable WeatherType [] []) weatherTypeByCellXY;

    Rebindable !(immutable Player) me;
    Rebindable !(immutable World) world;
    Rebindable !(immutable Game) game;
    Move theMove;

    Rebindable !(immutable Vehicle) [long] vehicleById;
    int [long] updateTickByVehicleId;
    Move [] delayedMoves;

    /**
     * Initialize our strategy.
     * $(BR)
     * Usually you can use a constructor, but in this case we want to initialize the generator of random numbers
     * with a value obtained from the game engine.
     */
    void initializeStrategy (immutable World world, immutable Game game)
    {
        if (terrainTypeByCellXY is null || weatherTypeByCellXY is null)
        {
            random.seed (cast (uint) (game.randomSeed));

            terrainTypeByCellXY = world.terrainByCellXY;
            weatherTypeByCellXY = world.weatherByCellXY;
        }
    }

    /**
     * Save all input data in the strategy fields for simpler access and actualize vehicle data.
     */
    void initializeTick (immutable Player me, immutable World world,
        immutable Game game, Move move)
    {
        this.me = me;
        this.world = world;
        this.game = game;
        this.theMove = move;

        foreach (vehicle; world.newVehicles)
        {
            vehicleById[vehicle.id] = vehicle;
            updateTickByVehicleId[vehicle.id] = world.tickIndex;
        }

        foreach (vehicleUpdate; world.vehicleUpdates)
        {
            auto vehicleId = vehicleUpdate.id;

            if (vehicleUpdate.durability == 0)
            {
                vehicleById.remove (vehicleId);
                updateTickByVehicleId.remove (vehicleId);
            }
            else
            {
                vehicleById[vehicleId] = new immutable Vehicle
                    (vehicleById[vehicleId], vehicleUpdate);
                updateTickByVehicleId[vehicleId] = world.tickIndex;
            }
        }
    }

    /**
     * Take delayed move from queue and execute.
     *
     * Returns: `true` if and only if a delayed move has been found and executed.
     */
    bool executeDelayedMove ()
    {
        if (delayedMoves.empty)
        {
            return false;
        }
        foreach (fieldName; FieldNameTuple !(Move))
        {
            mixin ("theMove." ~ fieldName ~
                " = delayedMoves.front." ~ fieldName ~ ";");
        }
        delayedMoves.popFront ();
        return true;
    }

    /**
     * The core logic of our strategy.
     */
    void move ()
    {
        auto vehicles = vehicleById.byValue ();
        // Every 300 ticks ...
        if (world.tickIndex % 300 == 0)
        {
            // ... for each vehicle type ...
            foreach (teamType; EnumMembers !(VehicleType))
            {
                auto goalType = getPreferredTargetType (teamType);

                // ... if it can attack ...
                if (goalType == VehicleType.unknown)
                {
                    continue;
                }

                // ... find center of our formation ...
                auto teamList = vehicles.filter !(v =>
                    v.playerId == me.id && v.type == teamType);
                auto teamN = teamList.walkLength;
                double teamX = teamN ? teamList.map !(v => v.x).sum / teamN : double.nan;
                double teamY = teamN ? teamList.map !(v => v.y).sum / teamN : double.nan;

                // ... find center of enemy formation or center of the world ...
                auto goalList = vehicles.filter !(v =>
                    v.playerId != me.id && v.type == goalType);
                auto goalN = goalList.walkLength;
                double goalX = goalN ? goalList.map !(v => v.x).sum / goalN : double.nan;
                double goalY = goalN ? goalList.map !(v => v.y).sum / goalN : double.nan;

                // .. and add delayed moves to select and move our vehicles.
                if (!isNaN (teamX) && !isNaN (teamY))
                {
                    auto move1 = new Move ();
                    move1.action = ActionType.clearAndSelect;
                    move1.right = world.width;
                    move1.bottom = world.height;
                    move1.vehicleType = teamType;
                    delayedMoves ~= move1;

                    auto move2 = new Move ();
                    move2.action = ActionType.move;
                    move2.x = goalX - teamX;
                    move2.y = goalY - teamY;
                    delayedMoves ~= move2;
                }
            }

            // Also find center of our ARRV formation ...
            auto arrvList = vehicles.filter !(v =>
                v.playerId == me.id && v.type == VehicleType.arrv);
            auto arrvN = arrvList.walkLength;
            double arrvX = arrvN ? arrvList.map !(v => v.x).sum / arrvN : double.nan;
            double arrvY = arrvN ? arrvList.map !(v => v.y).sum / arrvN : double.nan;

            // .. and send it to the center of the world.
            if (!isNaN (arrvX) && !isNaN (arrvY))
            {
                auto move1 = new Move ();
                move1.action = ActionType.clearAndSelect;
                move1.right = world.width;
                move1.bottom = world.height;
                move1.vehicleType = VehicleType.arrv;
                delayedMoves ~= move1;

                auto move2 = new Move ();
                move2.action = ActionType.move;
                move2.x = world.width / 2.0 - arrvX;
                move2.y = world.height / 2.0 - arrvY;
                delayedMoves ~= move2;
            }

            return;
        }

        // If all our vehicles are stuck for 60 ticks ...
        if (vehicles.filter !(v => v.playerId == me.id)
            .all !(v => world.tickIndex - updateTickByVehicleId[v.id] > 60))
        {
            // ... find center of our formation ...
            auto oursList = vehicles.filter !(v => v.playerId == me.id);
            auto oursN = oursList.walkLength;
            double oursX = oursN ? oursList.map !(v => v.x).sum / oursN : double.nan;
            double oursY = oursN ? oursList.map !(v => v.y).sum / oursN : double.nan;

            // ... and rotate it.
            if (!isNaN (oursX) && !isNaN (oursY))
            {
                auto move1 = new Move ();
                move1.action = ActionType.move;
                move1.x = oursX;
                move1.y = oursY;
                move1.angle = uniform (0, 2, random) ? +PI : -PI;
                delayedMoves ~= move1;
            }
        }
    }

    /**
     * Find a vehicle type, that specified vehicle type is strong against.
     *
     * Params:
     *   vehicleType = vehicle type.
     * Returns: target vehicle type.
     */
    static auto getPreferredTargetType (VehicleType vehicleType)
    {
        with (VehicleType)
        {
            final switch (vehicleType)
            {
                case unknown:
                    return unknown;
                case fighter:
                    return helicopter;
                case helicopter:
                    return tank;
                case ifv:
                    return helicopter;
                case tank:
                    return ifv;
                case arrv:
                    return unknown;
            }
        }
    }
}
