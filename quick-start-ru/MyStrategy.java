import model.*;

import java.util.*;
import java.util.function.Consumer;
import java.util.stream.Stream;

@SuppressWarnings({"UnsecureRandomNumberGeneration", "FieldCanBeLocal", "unused", "OverlyLongMethod"})
public final class MyStrategy implements Strategy {
    /**
     * Список целей для каждого типа техники, упорядоченных по убыванию урона по ним.
     */
    private static final Map<VehicleType, VehicleType[]> preferredTargetTypesByVehicleType;

    static {
        preferredTargetTypesByVehicleType = new EnumMap<>(VehicleType.class);

        preferredTargetTypesByVehicleType.put(VehicleType.FIGHTER, new VehicleType[] {
                VehicleType.HELICOPTER, VehicleType.FIGHTER
        });

        preferredTargetTypesByVehicleType.put(VehicleType.HELICOPTER, new VehicleType[] {
                VehicleType.TANK, VehicleType.ARRV, VehicleType.HELICOPTER, VehicleType.IFV, VehicleType.FIGHTER
        });

        preferredTargetTypesByVehicleType.put(VehicleType.IFV, new VehicleType[] {
                VehicleType.HELICOPTER, VehicleType.ARRV, VehicleType.IFV, VehicleType.FIGHTER, VehicleType.TANK
        });

        preferredTargetTypesByVehicleType.put(VehicleType.TANK, new VehicleType[] {
                VehicleType.IFV, VehicleType.ARRV, VehicleType.TANK, VehicleType.FIGHTER, VehicleType.HELICOPTER
        });
    }

    private Random random;

    private TerrainType[][] terrainTypeByCellXY;
    private WeatherType[][] weatherTypeByCellXY;

    private Player me;
    private World world;
    private Game game;
    private Move move;

    private final Map<Long, Vehicle> vehicleById = new HashMap<>();
    private final Map<Long, Integer> updateTickByVehicleId = new HashMap<>();
    private final Queue<Consumer<Move>> delayedMoves = new ArrayDeque<>();

    /**
     * Основной метод стратегии, осуществляющий управление армией. Вызывается каждый тик.
     *
     * @param me    Информация о вашем игроке.
     * @param world Текущее состояние мира.
     * @param game  Различные игровые константы.
     * @param move  Результатом работы метода является изменение полей данного объекта.
     */
    @Override
    public void move(Player me, World world, Game game, Move move) {
        initializeStrategy(world, game);
        initializeTick(me, world, game, move);

        if (me.getRemainingActionCooldownTicks() > 0) {
            return;
        }

        if (executeDelayedMove()) {
            return;
        }

        move();

        executeDelayedMove();
    }

    /**
     * Инциализируем стратегию.
     * <p>
     * Для этих целей обычно можно использовать конструктор, однако в данном случае мы хотим инициализировать генератор
     * случайных чисел значением, полученным от симулятора игры.
     */
    private void initializeStrategy(World world, Game game) {
        if (random == null) {
            random = new Random(game.getRandomSeed());

            terrainTypeByCellXY = world.getTerrainByCellXY();
            weatherTypeByCellXY = world.getWeatherByCellXY();
        }
    }

    /**
     * Сохраняем все входные данные в полях класса для упрощения доступа к ним, а также актуализируем сведения о каждой
     * технике и времени последнего изменения её состояния.
     */
    private void initializeTick(Player me, World world, Game game, Move move) {
        this.me = me;
        this.world = world;
        this.game = game;
        this.move = move;

        for (Vehicle vehicle : world.getNewVehicles()) {
            vehicleById.put(vehicle.getId(), vehicle);
            updateTickByVehicleId.put(vehicle.getId(), world.getTickIndex());
        }

        for (VehicleUpdate vehicleUpdate : world.getVehicleUpdates()) {
            long vehicleId = vehicleUpdate.getId();

            if (vehicleUpdate.getDurability() == 0) {
                vehicleById.remove(vehicleId);
                updateTickByVehicleId.remove(vehicleId);
            } else {
                vehicleById.put(vehicleId, new Vehicle(vehicleById.get(vehicleId), vehicleUpdate));
                updateTickByVehicleId.put(vehicleId, world.getTickIndex());
            }
        }
    }

    /**
     * Достаём отложенное действие из очереди и выполняем его.
     *
     * @return Возвращает {@code true}, если и только если отложенное действие было найдено и выполнено.
     */
    private boolean executeDelayedMove() {
        Consumer<Move> delayedMove = delayedMoves.poll();
        if (delayedMove == null) {
            return false;
        }

        delayedMove.accept(move);
        return true;
    }

    /**
     * Основная логика нашей стратегии.
     */
    private void move() {
        // Каждые 180 тиков ...
        if (world.getTickIndex() % 180 == 0) {
            // ... для каждого типа техники ...
            for (VehicleType vehicleType : VehicleType.values()) {
                VehicleType[] targetTypes = preferredTargetTypesByVehicleType.get(vehicleType);

                // ... если этот тип может атаковать ...
                if (targetTypes == null || targetTypes.length == 0) {
                    continue;
                }

                // ... получаем центр формации ...
                double x = streamVehicles(
                        Ownership.ALLY, vehicleType
                ).mapToDouble(Vehicle::getX).average().orElse(Double.NaN);

                double y = streamVehicles(
                        Ownership.ALLY, vehicleType
                ).mapToDouble(Vehicle::getY).average().orElse(Double.NaN);

                // ... получаем центр формации противника или центр мира ...
                double targetX = Arrays.stream(targetTypes).map(
                        targetType -> streamVehicles(
                                Ownership.ENEMY, targetType
                        ).mapToDouble(Vehicle::getX).average().orElse(Double.NaN)
                ).filter(Double::isFinite).findFirst().orElseGet(
                        () -> streamVehicles(
                                Ownership.ENEMY
                        ).mapToDouble(Vehicle::getX).average().orElse(world.getWidth() / 2.0D)
                );

                double targetY = Arrays.stream(targetTypes).map(
                        targetType -> streamVehicles(
                                Ownership.ENEMY, targetType
                        ).mapToDouble(Vehicle::getY).average().orElse(Double.NaN)
                ).filter(Double::isFinite).findFirst().orElseGet(
                        () -> streamVehicles(
                                Ownership.ENEMY
                        ).mapToDouble(Vehicle::getY).average().orElse(world.getHeight() / 2.0D)
                );

                // .. и добавляем в очередь отложенные действия для выделения и перемещения техники.
                if (!Double.isNaN(x) && !Double.isNaN(y)) {
                    delayedMoves.add(move -> {
                        move.setAction(ActionType.CLEAR_AND_SELECT);
                        move.setRight(world.getWidth());
                        move.setBottom(world.getHeight());
                        move.setVehicleType(vehicleType);
                    });

                    delayedMoves.add(move -> {
                        move.setAction(ActionType.MOVE);
                        move.setX(targetX - x);
                        move.setY(targetY - y);
                    });
                }
            }

            // Также находим центр формации наших БРЭМ ...
            double x = streamVehicles(
                    Ownership.ALLY, VehicleType.ARRV
            ).mapToDouble(Vehicle::getX).average().orElse(Double.NaN);

            double y = streamVehicles(
                    Ownership.ALLY, VehicleType.ARRV
            ).mapToDouble(Vehicle::getY).average().orElse(Double.NaN);

            // .. и отправляем их в центр мира.
            if (!Double.isNaN(x) && !Double.isNaN(y)) {
                delayedMoves.add(move -> {
                    move.setAction(ActionType.CLEAR_AND_SELECT);
                    move.setRight(world.getWidth());
                    move.setBottom(world.getHeight());
                    move.setVehicleType(VehicleType.ARRV);
                });

                delayedMoves.add(move -> {
                    move.setAction(ActionType.MOVE);
                    move.setX(world.getWidth() / 2.0D - x);
                    move.setY(world.getHeight() / 2.0D - y);
                });
            }

            return;
        }

        // Если ни один наш юнит не мог двигаться в течение 60 тиков ...
        if (streamVehicles(Ownership.ALLY).allMatch(
                vehicle -> world.getTickIndex() - updateTickByVehicleId.get(vehicle.getId()) > 60
        )) {
            // ... находим центр нашей формации ...
            double x = streamVehicles(Ownership.ALLY).mapToDouble(Vehicle::getX).average().orElse(Double.NaN);
            double y = streamVehicles(Ownership.ALLY).mapToDouble(Vehicle::getY).average().orElse(Double.NaN);

            // ... и поворачиваем её на случайный угол.
            if (!Double.isNaN(x) && !Double.isNaN(y)) {
                move.setAction(ActionType.ROTATE);
                move.setX(x);
                move.setY(y);
                move.setAngle(random.nextBoolean() ? StrictMath.PI : -StrictMath.PI);
            }
        }
    }

    private Stream<Vehicle> streamVehicles(Ownership ownership, VehicleType vehicleType) {
        Stream<Vehicle> stream = vehicleById.values().stream();

        switch (ownership) {
            case ALLY:
                stream = stream.filter(vehicle -> vehicle.getPlayerId() == me.getId());
                break;
            case ENEMY:
                stream = stream.filter(vehicle -> vehicle.getPlayerId() != me.getId());
                break;
            default:
        }

        if (vehicleType != null) {
            stream = stream.filter(vehicle -> vehicle.getType() == vehicleType);
        }

        return stream;
    }

    private Stream<Vehicle> streamVehicles(Ownership ownership) {
        return streamVehicles(ownership, null);
    }

    private Stream<Vehicle> streamVehicles() {
        return streamVehicles(Ownership.ANY);
    }

    private enum Ownership {
        ANY,

        ALLY,

        ENEMY
    }
}
