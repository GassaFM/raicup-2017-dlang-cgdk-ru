module model.weather_type;

/**
 * Тип погоды.
 */
enum WeatherType : byte
{
    /**
     * Default value.
     */
    unknown = -1,

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
