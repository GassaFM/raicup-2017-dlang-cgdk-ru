// Это стратегия из раздела <<Быстрый старт>>: http://russianaicup.ru/p/quick.
// Чтобы использовать её, сделайте резервную копию своего файла
// ../my_strategy.d, а затем скопируйте этот файл на его место.
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
     * Основной метод стратегии, осуществляющий управление армией. Вызывается каждый тик.
     *
     * Params:
     *   me    = Информация о вашем игроке.
     *   world = Текущее состояние мира.
     *   game  = Различные игровые константы.
     *   move  = Результатом работы метода является изменение полей данного объекта.
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
     * Список целей для каждого типа техники, упорядоченных по убыванию урона по ним.
     */
    static immutable VehicleType [] [VehicleType] preferredTargetTypesByVehicleType;

    static this ()
    {
        with (VehicleType)
        {
            immutable VehicleType [] emptyList;
            preferredTargetTypesByVehicleType = [
                arrv       : emptyList,
                fighter    : [helicopter, fighter].idup,
                helicopter : [tank, arrv, helicopter, ifv, fighter].idup,
                ifv        : [helicopter, arrv, ifv, fighter, tank].idup,
                tank       : [ifv, arrv, tank, fighter, helicopter].idup,
            ];
        }
    }

    /**
     * Инциализируем стратегию.
     * $(BR)
     * Для этих целей обычно можно использовать конструктор, однако в данном случае мы хотим инициализировать генератор
     * случайных чисел значением, полученным от симулятора игры.
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
     * Сохраняем все входные данные в полях класса для упрощения доступа к ним, а также актуализируем сведения о каждой
     * технике и времени последнего изменения её состояния.
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
     * Достаём отложенное действие из очереди и выполняем его.
     *
     * Returns: Возвращает `true`, если и только если отложенное действие было найдено и выполнено.
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
     * Основная логика нашей стратегии.
     */
    void move ()
    {
        auto vehicles = vehicleById.byValue ();
        // Каждые 180 тиков ...
        if (world.tickIndex % 180 == 0)
        {
            auto enemies = vehicles.filter !(v => v.playerId != me.id);
            // ... для каждого типа техники ...
            foreach (teamType; EnumMembers !(VehicleType))
            {
                // ... если этот тип может атаковать ...
                auto goalTypes = preferredTargetTypesByVehicleType[teamType]
                    .find !(t => enemies.any !(e => e.type == t));
                if (goalTypes.empty)
                {
                    continue;
                }
                auto goalType = goalTypes.front;

                // ... получаем центр формации ...
                auto teamList = vehicles.filter !(v =>
                    v.playerId == me.id && v.type == teamType);
                auto teamN = teamList.walkLength;
                double teamX = teamN ? teamList.map !(v => v.x).sum / teamN : double.nan;
                double teamY = teamN ? teamList.map !(v => v.y).sum / teamN : double.nan;

                // ... получаем центр формации противника или центр мира ...
                auto goalList = vehicles.filter !(v =>
                    v.playerId != me.id && v.type == goalType);
                auto goalN = goalList.walkLength;
                double goalX = goalN ? goalList.map !(v => v.x).sum / goalN : double.nan;
                double goalY = goalN ? goalList.map !(v => v.y).sum / goalN : double.nan;

                // .. и добавляем в очередь отложенные действия для выделения и перемещения техники.
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

            // Также находим центр формации наших БРЭМ ...
            auto arrvList = vehicles.filter !(v =>
                v.playerId == me.id && v.type == VehicleType.arrv);
            auto arrvN = arrvList.walkLength;
            double arrvX = arrvN ? arrvList.map !(v => v.x).sum / arrvN : double.nan;
            double arrvY = arrvN ? arrvList.map !(v => v.y).sum / arrvN : double.nan;

            // .. и отправляем их в центр мира.
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

        // Если ни один наш юнит не мог двигаться в течение 60 тиков ...
        if (vehicles.filter !(v => v.playerId == me.id)
            .all !(v => world.tickIndex - updateTickByVehicleId[v.id] > 60))
        {
            // ... находим центр нашей формации ...
            auto oursList = vehicles.filter !(v => v.playerId == me.id);
            auto oursN = oursList.walkLength;
            double oursX = oursN ? oursList.map !(v => v.x).sum / oursN : double.nan;
            double oursY = oursN ? oursList.map !(v => v.y).sum / oursN : double.nan;

            // ... и поворачиваем её на случайный угол.
            if (!isNaN (oursX) && !isNaN (oursY))
            {
                auto move1 = new Move ();
                move1.action = ActionType.clearAndSelect;
                move1.right = world.width;
                move1.bottom = world.height;
                delayedMoves ~= move1;

                auto move2 = new Move ();
                move2.action = ActionType.rotate;
                move2.x = oursX;
                move2.y = oursY;
                move2.angle = uniform (0, 2, random) ? +PI : -PI;
                delayedMoves ~= move2;
            }
        }
    }
}
