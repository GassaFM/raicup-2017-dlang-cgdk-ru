module model.vehicle_update;

/**
 * Класс, частично определяющий технику. Содержит уникальный идентификатор техники, а также все поля техники,
 * значения которых могут изменяться в процессе игры.
 */
immutable class VehicleUpdate
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает уникальный идентификатор объекта.
     */
    long id;
    /**
     * Returns: Возвращает X-координату центра объекта. Ось абсцисс направлена слева направо.
     */
    double x;
    /**
     * Returns: Возвращает Y-координату центра объекта. Ось ординат направлена сверху вниз.
     */
    double y;
    /**
     * Returns: Возвращает текущую прочность или `0`, если техника была уничтожена либо ушла из зоны видимости.
     */
    int durability;
    /**
     * Returns: Возвращает количество тиков, оставшееся до следующей атаки.
     * Для совершения атаки необходимо, чтобы это значение было равно нулю.
     */
    int remainingAttackCooldownTicks;
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
        int durability,
        int remainingAttackCooldownTicks,
        bool selected,
        immutable int [] groups)
    {
        this.id = id;
        this.x = x;
        this.y = y;
        this.durability = durability;
        this.remainingAttackCooldownTicks = remainingAttackCooldownTicks;
        this.selected = selected;
        this.groups = groups;
    }
}
