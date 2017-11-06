module model.circular_unit;

import model.unit;

/**
 * Базовый класс для определения круглых объектов. Содержит также все свойства юнита.
 */
abstract immutable class CircularUnit : Unit
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает радиус объекта.
     */
    double radius;

    protected this (
        long id,
        double x,
        double y,
        double radius)
    {
        super (id, x, y);

        this.radius = radius;
    }
}
