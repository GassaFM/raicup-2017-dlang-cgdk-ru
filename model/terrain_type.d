module model.terrain_type;

import std.typecons;

/**
 * Тип местности.
 */
enum TerrainType : byte
{
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

alias TerrainTypeOrNull = Nullable !(TerrainType, cast (TerrainType) (-1));
