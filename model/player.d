module model.player;

/**
 * Содержит данные о текущем состоянии игрока.
 */
immutable class Player
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает уникальный идентификатор игрока.
     */
    long id;
    /**
     * Returns: Возвращает `true` в том и только в том случае, если этот игрок ваш.
     */
    bool me;
    /**
     * Returns: Возвращает специальный флаг --- показатель того, что стратегия игрока <<упала>>.
     * Более подробную информацию можно найти в документации к игре.
     */
    bool strategyCrashed;
    /**
     * Returns: Возвращает количество баллов, набранное игроком.
     */
    int score;
    /**
     * Returns: Возвращает количество тиков, оставшееся до любого следующего действия.
     * Если значение равно `0`, игрок может совершить действие в данный тик.
     */
    int remainingActionCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, оставшееся до следующего тактического ядерного удара.
     * Если значение равно `0`, игрок может запросить удар в данный тик.
     */
    int remainingNuclearStrikeCooldownTicks;
    /**
     * Returns: Возвращает идентификатор техники, осуществляющей наведение ядерного удара на цель или `-1`.
     */
    long nextNuclearStrikeVehicleId;
    /**
     * Returns: Возвращает тик нанесения следующего ядерного удара или `-1`.
     */
    int nextNuclearStrikeTickIndex;
    /**
     * Returns: Возвращает абсциссу цели следующего ядерного удара или `-1.0`.
     */
    double nextNuclearStrikeX;
    /**
     * Returns: Возвращает ординату цели следующего ядерного удара или `-1.0`.
     */
    double nextNuclearStrikeY;

    this (
        long id,
        bool me,
        bool strategyCrashed,
        int score,
        int remainingActionCooldownTicks,
        int remainingNuclearStrikeCooldownTicks,
        long nextNuclearStrikeVehicleId,
        int nextNuclearStrikeTickIndex,
        double nextNuclearStrikeX,
        double nextNuclearStrikeY)
    {
        this.id = id;
        this.me = me;
        this.strategyCrashed = strategyCrashed;
        this.score = score;
        this.remainingActionCooldownTicks = remainingActionCooldownTicks;
        this.remainingNuclearStrikeCooldownTicks = remainingNuclearStrikeCooldownTicks;
        this.nextNuclearStrikeVehicleId = nextNuclearStrikeVehicleId;
        this.nextNuclearStrikeTickIndex = nextNuclearStrikeTickIndex;
        this.nextNuclearStrikeX = nextNuclearStrikeX;
        this.nextNuclearStrikeY = nextNuclearStrikeY;
    }
}
