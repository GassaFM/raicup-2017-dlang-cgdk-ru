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

    this (
        long id,
        bool me,
        bool strategyCrashed,
        int score,
        int remainingActionCooldownTicks)
    {
        this.id = id;
        this.me = me;
        this.strategyCrashed = strategyCrashed;
        this.score = score;
        this.remainingActionCooldownTicks = remainingActionCooldownTicks;
    }
}
