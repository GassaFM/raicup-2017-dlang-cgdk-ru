module model.terrain_type;

/**
 * Тип местности.
 */
enum TerrainType : byte
{
    /**
     * Default value.
     */
    unknown = -1,

    /**
     * Равнина.
     */
    plain,

    /**
     * Топь.
     */
    swamp,

    /**
     * Лес.
     */
    forest
}
