module model.facility_type;

/**
 * Тип сооружения.
 */
enum FacilityType : byte
{
    /**
     * Default value.
     */
    unknown = -1,

    /**
     * Центр управления. Увеличивает возможное количество действий игрока на
     * `game.additionalActionCountPerControlCenter` за `game.actionDetectionInterval` игровых тиков.
     */
    controlCenter,

    /**
     * Завод. Может производить технику любого типа по выбору игрока.
     */
    vehicleFactory
}
