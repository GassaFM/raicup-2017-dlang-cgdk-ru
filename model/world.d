module model.world;

import model.facility;
import model.weather_type;
import model.vehicle_update;
import model.vehicle;
import model.player;
import model.terrain_type;

/**
 * Этот класс описывает игровой мир. Содержит также описания всех игроков, игровых объектов (<<юнитов>>) и сооружений.
 */
immutable class World
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает номер текущего тика.
     */
    int tickIndex;
    /**
     * Returns: Возвращает базовую длительность игры в тиках. Реальная длительность может отличаться от этого значения в
     * меньшую сторону. Эквивалентно `game.tickCount`.
     */
    int tickCount;
    /**
     * Returns: Возвращает ширину мира.
     */
    double width;
    /**
     * Returns: Возвращает высоту мира.
     */
    double height;
    /**
     * Returns: Возвращает список игроков (в случайном порядке).
     * В зависимости от реализации, объекты, задающие игроков, могут пересоздаваться после каждого тика.
     */
    Player [] players;
    /**
     * Returns: Возвращает список техники, о которой у стратегии не было информации в предыдущий игровой тик. В этот
     * список попадает как только что произведённая техника, так и уже существующая, но находящаяся вне зоны видимости
     * до этого момента.
     */
    Vehicle [] newVehicles;
    /**
     * Returns: Возвращает значения изменяемых полей для каждой видимой техники, если хотя бы одно поле этой техники
     * изменилось. Нулевая прочность означает, что техника была уничтожена либо ушла из зоны видимости.
     */
    VehicleUpdate [] vehicleUpdates;
    /**
     * Returns: Возвращает карту местности.
     */
    TerrainType [] [] terrainByCellXY;
    /**
     * Returns: Возвращает карту погоды.
     */
    WeatherType [] [] weatherByCellXY;
    /**
     * Returns: Возвращает список сооружений (в случайном порядке).
     * В зависимости от реализации, объекты, задающие сооружения, могут пересоздаваться после каждого тика.
     */
    Facility [] facilities;

    this (
        int tickIndex,
        int tickCount,
        double width,
        double height,
        immutable Player [] players,
        immutable Vehicle [] newVehicles,
        immutable VehicleUpdate [] vehicleUpdates,
        immutable TerrainType [] [] terrainByCellXY,
        immutable WeatherType [] [] weatherByCellXY,
        immutable Facility [] facilities)
    {
        this.tickIndex = tickIndex;
        this.tickCount = tickCount;
        this.width = width;
        this.height = height;
        this.players = players;
        this.newVehicles = newVehicles;
        this.vehicleUpdates = vehicleUpdates;
        this.terrainByCellXY = terrainByCellXY;
        this.weatherByCellXY = weatherByCellXY;
        this.facilities = facilities;
    }

    /**
     * Returns: Возвращает вашего игрока.
     */
    immutable (Player) getMyPlayer ()
    {
        foreach (player; players) {
            if (player.me) {
                return player;
            }
        }

        return null;
    }

    /**
     * Returns: Возвращает игрока, соревнующегося с вами.
     */
    immutable (Player) getOpponentPlayer ()
    {
        foreach (player; players) {
            if (!player.me) {
                return player;
            }
        }

        return null;
    }
}
