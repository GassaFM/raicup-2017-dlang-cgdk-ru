module model.weather_type;

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

