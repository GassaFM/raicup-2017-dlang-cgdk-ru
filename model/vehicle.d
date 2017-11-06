module model.vehicle;

import model.vehicle_type;
import model.vehicle_update;
import model.circular_unit;

/**
 * Класс, определяющий технику. Содержит также все свойства круглых объектов.
 */
immutable class Vehicle : CircularUnit
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает идентификатор игрока, которому принадлежит техника.
     */
    long playerId;
    /**
     * Returns: Возвращает текущую прочность.
     */
    int durability;
    /**
     * Returns: Возвращает максимальную прочность.
     */
    int maxDurability;
    /**
     * Returns: Возвращает максимальное расстояние, на которое данная техника может переместиться за один игровой тик,
     * без учёта типа местности и погоды. При перемещении по дуге учитывается длина дуги,
     * а не кратчайшее расстояние между начальной и конечной точками.
     */
    double maxSpeed;
    /**
     * Returns: Возвращает максимальное расстояние (от центра до центра),
     * на котором данная техника обнаруживает другие объекты, без учёта типа местности и погоды.
     */
    double visionRange;
    /**
     * Returns: Возвращает квадрат максимального расстояния (от центра до центра),
     * на котором данная техника обнаруживает другие объекты, без учёта типа местности и погоды.
     */
    double squaredVisionRange;
    /**
     * Returns: Возвращает максимальное расстояние (от центра до центра),
     * на котором данная техника может атаковать наземные объекты.
     */
    double groundAttackRange;
    /**
     * Returns: Возвращает квадрат максимального расстояния (от центра до центра),
     * на котором данная техника может атаковать наземные объекты.
     */
    double squaredGroundAttackRange;
    /**
     * Returns: Возвращает максимальное расстояние (от центра до центра),
     * на котором данная техника может атаковать воздушные объекты.
     */
    double aerialAttackRange;
    /**
     * Returns: Возвращает квадрат максимального расстояния (от центра до центра),
     * на котором данная техника может атаковать воздушные объекты.
     */
    double squaredAerialAttackRange;
    /**
     * Returns: Возвращает урон одной атаки по наземному объекту.
     */
    int groundDamage;
    /**
     * Returns: Возвращает урон одной атаки по воздушному объекту.
     */
    int aerialDamage;
    /**
     * Returns: Возвращает защиту от атак наземных юнитов.
     */
    int groundDefence;
    /**
     * Returns: Возвращает защиту от атак воздушых юнитов.
     */
    int aerialDefence;
    /**
     * Returns: Возвращает минимально возможный интервал между двумя последовательными атаками данной техники.
     */
    int attackCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, оставшееся до следующей атаки.
     * Для совершения атаки необходимо, чтобы это значение было равно нулю.
     */
    int remainingAttackCooldownTicks;
    /**
     * Returns: Возвращает тип техники.
     */
    VehicleType type;
    /**
     * Returns: Возвращает `true` в том и только том случае, если эта техника воздушная.
     */
    bool aerial;
    /**
     * Returns: Возвращает `true` в том и только том случае, если эта техника выделена.
     */
    bool selected;
    /**
     * Returns: Возвращает группы, в которые входит эта техника.
     */
    int [] groups;

    this (
        long id,
        double x,
        double y,
        double radius,
        long playerId,
        int durability,
        int maxDurability,
        double maxSpeed,
        double visionRange,
        double squaredVisionRange,
        double groundAttackRange,
        double squaredGroundAttackRange,
        double aerialAttackRange,
        double squaredAerialAttackRange,
        int groundDamage,
        int aerialDamage,
        int groundDefence,
        int aerialDefence,
        int attackCooldownTicks,
        int remainingAttackCooldownTicks,
        immutable VehicleType type,
        bool aerial,
        bool selected,
        immutable int [] groups)
    {
        super (id, x, y, radius);

        this.playerId = playerId;
        this.durability = durability;
        this.maxDurability = maxDurability;
        this.maxSpeed = maxSpeed;
        this.visionRange = visionRange;
        this.squaredVisionRange = squaredVisionRange;
        this.groundAttackRange = groundAttackRange;
        this.squaredGroundAttackRange = squaredGroundAttackRange;
        this.aerialAttackRange = aerialAttackRange;
        this.squaredAerialAttackRange = squaredAerialAttackRange;
        this.groundDamage = groundDamage;
        this.aerialDamage = aerialDamage;
        this.groundDefence = groundDefence;
        this.aerialDefence = aerialDefence;
        this.attackCooldownTicks = attackCooldownTicks;
        this.remainingAttackCooldownTicks = remainingAttackCooldownTicks;
        this.type = type;
        this.aerial = aerial;
        this.selected = selected;
        this.groups = groups;
    }

    this (
        immutable Vehicle vehicle,
        immutable VehicleUpdate vehicleUpdate)
    {
        super (vehicle.id, vehicleUpdate.x, vehicleUpdate.y, vehicle.radius);

        this.playerId = vehicle.playerId;
        this.durability = vehicleUpdate.durability;
        this.maxDurability = vehicle.maxDurability;
        this.maxSpeed = vehicle.maxSpeed;
        this.visionRange = vehicle.visionRange;
        this.squaredVisionRange = vehicle.squaredVisionRange;
        this.groundAttackRange = vehicle.groundAttackRange;
        this.squaredGroundAttackRange = vehicle.squaredGroundAttackRange;
        this.aerialAttackRange = vehicle.aerialAttackRange;
        this.squaredAerialAttackRange = vehicle.squaredAerialAttackRange;
        this.groundDamage = vehicle.groundDamage;
        this.aerialDamage = vehicle.aerialDamage;
        this.groundDefence = vehicle.groundDefence;
        this.aerialDefence = vehicle.aerialDefence;
        this.attackCooldownTicks = vehicle.attackCooldownTicks;
        this.remainingAttackCooldownTicks = vehicleUpdate.remainingAttackCooldownTicks;
        this.type = vehicle.type;
        this.aerial = vehicle.aerial;
        this.selected = vehicleUpdate.selected;
        this.groups = vehicleUpdate.groups;
    }
}
