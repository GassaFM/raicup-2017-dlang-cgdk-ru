module model.unit;
import std.math : hypot;

/**
 * Базовый класс для определения объектов (<<юнитов>>) на игровом поле.
 */
abstract immutable class Unit
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

    protected this (
        long id,
        double x,
        double y)
    {
        this.id = id;
        this.x = x;
        this.y = y;
    }

    /**
     * Params:
     *   x = X-координата точки.
     *   y = Y-координата точки.
     * Returns: Возвращает расстояние до точки от центра данного объекта.
     */
    double getDistanceTo (
        double x,
        double y) const
    {
        return hypot (x - this.x, y - this.y);
    }

    /**
     * Params:
     *   unit = Объект, до центра которого необходимо определить расстояние.
     * Returns: Возвращает расстояние от центра данного объекта до центра указанного объекта.
     */
    double getDistanceTo (
        immutable Unit unit) const
    {
        return getDistanceTo (unit.x, unit.y);
    }

    /**
     * Params:
     *   x = X-координата точки.
     *   y = Y-координата точки.
     * Returns: Возвращает квадрат расстояния до точки от центра данного объекта.
     */
    double getSquaredDistanceTo (
        double x,
        double y) const
    {
        double dx = x - this.x;
        double dy = y - this.y;
        return dx * dx + dy * dy;
    }

    /**
     * Params:
     *   unit = Объект, до центра которого необходимо определить квадрат расстояния.
     * Returns: Возвращает квадрат расстояния от центра данного объекта до центра указанного объекта.
     */
    double getSquaredDistanceTo (
        immutable Unit unit) const
    {
        return getSquaredDistanceTo (unit.x, unit.y);
    }
}
