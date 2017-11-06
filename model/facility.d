module model.facility;

import model.vehicle_type;
import model.facility_type;

/**
 * Класс, определяющий сооружение --- прямоугольную область на карте.
 */
immutable class Facility
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает уникальный идентификатор сооружения.
     */
    long id;
    /**
     * Returns: Возвращает тип сооружения.
     */
    FacilityType type;
    /**
     * Returns: Возвращает идентификатор игрока, захватившего сооружение, или `-1`, если сооружение никем не
     * контролируется.
     */
    long ownerPlayerId;
    /**
     * Returns: Возвращает абсциссу левой границы сооружения.
     */
    double left;
    /**
     * Returns: Возвращает ординату верхней границы сооружения.
     */
    double top;
    /**
     * Returns: Возвращает индикатор захвата сооружения в интервале от `-game.maxFacilityCapturePoints` до
     * `game.maxFacilityCapturePoints`. Если индикатор находится в положительной зоне, очки захвата принадлежат
     * вам, иначе вашему противнику.
     */
    double capturePoints;
    /**
     * Returns: Возвращает тип техники, производящейся в данном сооружении, или `null`. Применимо только к заводу
     * (`FacilityType.vehicleFactory`).
     */
    VehicleType vehicleType;
    /**
     * Returns: Возвращает неотрицательное число --- прогресс производства техники. Применимо только к заводу
     * (`FacilityType.vehicleFactory`).
     */
    int productionProgress;

    this (
        long id,
        immutable FacilityType type,
        long ownerPlayerId,
        double left,
        double top,
        double capturePoints,
        immutable VehicleType vehicleType,
        int productionProgress)
    {
        this.id = id;
        this.type = type;
        this.ownerPlayerId = ownerPlayerId;
        this.left = left;
        this.top = top;
        this.capturePoints = capturePoints;
        this.vehicleType = vehicleType;
        this.productionProgress = productionProgress;
    }
}
