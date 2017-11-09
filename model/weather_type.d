module model.weather_type;

import std.typecons;

/**
 * Тип погоды.
 */
enum WeatherType : byte
{
    /**
     * Ясно.
     */
    clear,

    /**
     * Плотные облака.
     */
    cloud,

    /**
     * Сильный дождь.
     */
    rain
}

alias WeatherTypeOrNull = Nullable !(WeatherType, cast (WeatherType) (-1));
