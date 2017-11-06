module model.game;

import model.weather_type;
import model.terrain_type;
import model.facility_type;

/**
 * Предоставляет доступ к различным игровым константам.
 */
immutable class Game
{
nothrow pure @safe @nogc:

    /**
     * Returns: Возвращает некоторое число, которое ваша стратегия может использовать для инициализации генератора
     * случайных чисел. Данное значение имеет рекомендательный характер, однако позволит более точно воспроизводить
     * прошедшие игры.
     */
    long randomSeed;
    /**
     * Returns: Возвращает базовую длительность игры в тиках. Реальная длительность может отличаться от этого значения в
     * меньшую сторону. Эквивалентно `world.tickCount`.
     */
    int tickCount;
    /**
     * Returns: Возвращает ширину карты.
     */
    double worldWidth;
    /**
     * Returns: Возвращает высоту карты.
     */
    double worldHeight;
    /**
     * Returns: Возвращает `true`, если и только если в данной игре включен режим частичной видимости.
     */
    bool fogOfWarEnabled;
    /**
     * Returns: Возвращает количество баллов, получаемое игроком в случае уничтожения всех юнитов противника.
     */
    int victoryScore;
    /**
     * Returns: Возвращает количество баллов за захват сооружения.
     */
    int facilityCaptureScore;
    /**
     * Returns: Возвращает количество баллов за уничтожение юнита противника.
     */
    int vehicleEliminationScore;
    /**
     * Returns: Возвращает интервал, учитываемый в ограничении количества действий стратегии.
     */
    int actionDetectionInterval;
    /**
     * Returns: Возвращает базовое количество действий, которое может совершить стратегия за
     * `actionDetectionInterval` последовательных тиков.
     */
    int baseActionCount;
    /**
     * Returns: Возвращает дополнительное количество действий за каждый захваченный центр управления
     * (`FacilityType.controlCenter`).
     */
    int additionalActionCountPerControlCenter;
    /**
     * Returns: Возвращает максимально возможный индекс группы юнитов.
     */
    int maxUnitGroup;
    /**
     * Returns: Возвращает количество столбцов в картах местности и погоды.
     */
    int terrainWeatherMapColumnCount;
    /**
     * Returns: Возвращает количество строк в картах местности и погоды.
     */
    int terrainWeatherMapRowCount;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора наземной техники, находящейся на равнинной местности
     * (`TerrainType.plain`).
     */
    double plainTerrainVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении наземной техники противника,
     * находящейся на равнинной местности (`TerrainType.plain`).
     */
    double plainTerrainStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости наземной техники, находящейся на равнинной местности
     * (`TerrainType.plain`).
     */
    double plainTerrainSpeedFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора наземной техники, находящейся в болотистой местности
     * (`TerrainType.swamp`).
     */
    double swampTerrainVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении наземной техники противника,
     * находящейся в болотистой местности (`TerrainType.swamp`).
     */
    double swampTerrainStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости наземной техники, находящейся в болотистой местности
     * (`TerrainType.swamp`).
     */
    double swampTerrainSpeedFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора наземной техники, находящейся в лесистой местности
     * (`TerrainType.forest`).
     */
    double forestTerrainVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении наземной техники противника,
     * находящейся в лесистой местности (`TerrainType.forest`).
     */
    double forestTerrainStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости наземной техники, находящейся в лесистой местности
     * (`TerrainType.forest`).
     */
    double forestTerrainSpeedFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора воздушной техники, находящейся в области ясной погоды
     * (`WeatherType.clear`).
     */
    double clearWeatherVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении воздушной техники противника,
     * находящейся в области ясной погоды (`WeatherType.clear`).
     */
    double clearWeatherStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости воздушной техники, находящейся в области ясной погоды
     * (`WeatherType.clear`).
     */
    double clearWeatherSpeedFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора воздушной техники, находящейся в плотных облаках
     * (`WeatherType.cloud`).
     */
    double cloudWeatherVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении воздушной техники противника,
     * находящейся в плотных облаках (`WeatherType.cloud`).
     */
    double cloudWeatherStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости воздушной техники, находящейся в плотных облаках
     * (`WeatherType.cloud`).
     */
    double cloudWeatherSpeedFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора воздушной техники, находящейся в условиях сильного дождя
     * (`WeatherType.rain`).
     */
    double rainWeatherVisionFactor;
    /**
     * Returns: Возвращает мультипликатор радиуса обзора любой техники при обнаружении воздушной техники противника,
     * находящейся в условиях сильного дождя (`WeatherType.rain`).
     */
    double rainWeatherStealthFactor;
    /**
     * Returns: Возвращает мультипликатор максимальной скорости воздушной техники, находящейся в условиях сильного дождя
     * (`WeatherType.rain`).
     */
    double rainWeatherSpeedFactor;
    /**
     * Returns: Возвращает радиус техники.
     */
    double vehicleRadius;
    /**
     * Returns: Возвращает максимальную прочность танка.
     */
    int tankDurability;
    /**
     * Returns: Возвращает максимальную скорость танка.
     */
    double tankSpeed;
    /**
     * Returns: Возвращает базовый радиус обзора танка.
     */
    double tankVisionRange;
    /**
     * Returns: Возвращает дальность атаки танка по наземным целям.
     */
    double tankGroundAttackRange;
    /**
     * Returns: Возвращает дальность атаки танка по воздушным целям.
     */
    double tankAerialAttackRange;
    /**
     * Returns: Возвращает урон одной атаки танка по наземной технике.
     */
    int tankGroundDamage;
    /**
     * Returns: Возвращает урон одной атаки танка по воздушной технике.
     */
    int tankAerialDamage;
    /**
     * Returns: Возвращает защиту танка от атак наземной техники.
     */
    int tankGroundDefence;
    /**
     * Returns: Возвращает защиту танка от атак воздушной техники.
     */
    int tankAerialDefence;
    /**
     * Returns: Возвращает интервал в тиках между двумя последовательными атаками танка.
     */
    int tankAttackCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, необхожимое для производства одного танка на заводе
     * (`FacilityType.vehicleFactory`).
     */
    int tankProductionCost;
    /**
     * Returns: Возвращает максимальную прочность БМП.
     */
    int ifvDurability;
    /**
     * Returns: Возвращает максимальную скорость БМП.
     */
    double ifvSpeed;
    /**
     * Returns: Возвращает базовый радиус обзора БМП.
     */
    double ifvVisionRange;
    /**
     * Returns: Возвращает дальность атаки БМП по наземным целям.
     */
    double ifvGroundAttackRange;
    /**
     * Returns: Возвращает дальность атаки БМП по воздушным целям.
     */
    double ifvAerialAttackRange;
    /**
     * Returns: Возвращает урон одной атаки БМП по наземной технике.
     */
    int ifvGroundDamage;
    /**
     * Returns: Возвращает урон одной атаки БМП по воздушной технике.
     */
    int ifvAerialDamage;
    /**
     * Returns: Возвращает защиту БМП от атак наземной техники.
     */
    int ifvGroundDefence;
    /**
     * Returns: Возвращает защиту БМП от атак воздушной техники.
     */
    int ifvAerialDefence;
    /**
     * Returns: Возвращает интервал в тиках между двумя последовательными атаками БМП.
     */
    int ifvAttackCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, необхожимое для производства одной БМП на заводе
     * (`FacilityType.vehicleFactory`).
     */
    int ifvProductionCost;
    /**
     * Returns: Возвращает максимальную прочность БРЭМ.
     */
    int arrvDurability;
    /**
     * Returns: Возвращает максимальную скорость БРЭМ.
     */
    double arrvSpeed;
    /**
     * Returns: Возвращает базовый радиус обзора БРЭМ.
     */
    double arrvVisionRange;
    /**
     * Returns: Возвращает защиту БРЭМ от атак наземной техники.
     */
    int arrvGroundDefence;
    /**
     * Returns: Возвращает защиту БРЭМ от атак воздушной техники.
     */
    int arrvAerialDefence;
    /**
     * Returns: Возвращает количество тиков, необхожимое для производства одной БРЭМ на заводе
     * (`FacilityType.vehicleFactory`).
     */
    int arrvProductionCost;
    /**
     * Returns: Возвращает максимальное расстояние (от центра до центра), на котором БРЭМ может ремонтировать
     * дружественную технику.
     */
    double arrvRepairRange;
    /**
     * Returns: Возвращает максимальное количество прочности, которое БРЭМ может восстановить дружественной технике за
     * один тик.
     */
    double arrvRepairSpeed;
    /**
     * Returns: Возвращает максимальную прочность ударного вертолёта.
     */
    int helicopterDurability;
    /**
     * Returns: Возвращает максимальную скорость ударного вертолёта.
     */
    double helicopterSpeed;
    /**
     * Returns: Возвращает базовый радиус обзора ударного вертолёта.
     */
    double helicopterVisionRange;
    /**
     * Returns: Возвращает дальность атаки ударного вертолёта по наземным целям.
     */
    double helicopterGroundAttackRange;
    /**
     * Returns: Возвращает дальность атаки ударного вертолёта по воздушным целям.
     */
    double helicopterAerialAttackRange;
    /**
     * Returns: Возвращает урон одной атаки ударного вертолёта по наземной технике.
     */
    int helicopterGroundDamage;
    /**
     * Returns: Возвращает урон одной атаки ударного вертолёта по воздушной технике.
     */
    int helicopterAerialDamage;
    /**
     * Returns: Возвращает защиту ударного вертолёта от атак наземной техники.
     */
    int helicopterGroundDefence;
    /**
     * Returns: Возвращает защиту ударного вертолёта от атак воздушной техники.
     */
    int helicopterAerialDefence;
    /**
     * Returns: Возвращает интервал в тиках между двумя последовательными атаками ударного вертолёта.
     */
    int helicopterAttackCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, необхожимое для производства одного ударного вертолёта на заводе
     * (`FacilityType.vehicleFactory`).
     */
    int helicopterProductionCost;
    /**
     * Returns: Возвращает максимальную прочность истребителя.
     */
    int fighterDurability;
    /**
     * Returns: Возвращает максимальную скорость истребителя.
     */
    double fighterSpeed;
    /**
     * Returns: Возвращает базовый радиус обзора истребителя.
     */
    double fighterVisionRange;
    /**
     * Returns: Возвращает дальность атаки истребителя по наземным целям.
     */
    double fighterGroundAttackRange;
    /**
     * Returns: Возвращает дальность атаки истребителя по воздушным целям.
     */
    double fighterAerialAttackRange;
    /**
     * Returns: Возвращает урон одной атаки истребителя по наземной технике.
     */
    int fighterGroundDamage;
    /**
     * Returns: Возвращает урон одной атаки истребителя по воздушной технике.
     */
    int fighterAerialDamage;
    /**
     * Returns: Возвращает защиту истребителя от атак наземной техники.
     */
    int fighterGroundDefence;
    /**
     * Returns: Возвращает защиту истребителя от атак воздушной техники.
     */
    int fighterAerialDefence;
    /**
     * Returns: Возвращает интервал в тиках между двумя последовательными атаками истребителя.
     */
    int fighterAttackCooldownTicks;
    /**
     * Returns: Возвращает количество тиков, необхожимое для производства одного истребителя на заводе
     * (`FacilityType.vehicleFactory`).
     */
    int fighterProductionCost;
    /**
     * Returns: Возвращает максимально возможную абсолютную величину индикатора захвата сооружения
     * (`facility.capturePoints`).
     */
    double maxFacilityCapturePoints;
    /**
     * Returns: Возвращает скорость изменения индикатора захвата сооружения (`facility.capturePoints`) за каждую
     * единицу техники, центр которой находится внутри сооружения.
     */
    double facilityCapturePointsPerVehiclePerTick;
    /**
     * Returns: Возвращает ширину сооружения.
     */
    double facilityWidth;
    /**
     * Returns: Возвращает высоту сооружения.
     */
    double facilityHeight;

    this (
        long randomSeed,
        int tickCount,
        double worldWidth,
        double worldHeight,
        bool fogOfWarEnabled,
        int victoryScore,
        int facilityCaptureScore,
        int vehicleEliminationScore,
        int actionDetectionInterval,
        int baseActionCount,
        int additionalActionCountPerControlCenter,
        int maxUnitGroup,
        int terrainWeatherMapColumnCount,
        int terrainWeatherMapRowCount,
        double plainTerrainVisionFactor,
        double plainTerrainStealthFactor,
        double plainTerrainSpeedFactor,
        double swampTerrainVisionFactor,
        double swampTerrainStealthFactor,
        double swampTerrainSpeedFactor,
        double forestTerrainVisionFactor,
        double forestTerrainStealthFactor,
        double forestTerrainSpeedFactor,
        double clearWeatherVisionFactor,
        double clearWeatherStealthFactor,
        double clearWeatherSpeedFactor,
        double cloudWeatherVisionFactor,
        double cloudWeatherStealthFactor,
        double cloudWeatherSpeedFactor,
        double rainWeatherVisionFactor,
        double rainWeatherStealthFactor,
        double rainWeatherSpeedFactor,
        double vehicleRadius,
        int tankDurability,
        double tankSpeed,
        double tankVisionRange,
        double tankGroundAttackRange,
        double tankAerialAttackRange,
        int tankGroundDamage,
        int tankAerialDamage,
        int tankGroundDefence,
        int tankAerialDefence,
        int tankAttackCooldownTicks,
        int tankProductionCost,
        int ifvDurability,
        double ifvSpeed,
        double ifvVisionRange,
        double ifvGroundAttackRange,
        double ifvAerialAttackRange,
        int ifvGroundDamage,
        int ifvAerialDamage,
        int ifvGroundDefence,
        int ifvAerialDefence,
        int ifvAttackCooldownTicks,
        int ifvProductionCost,
        int arrvDurability,
        double arrvSpeed,
        double arrvVisionRange,
        int arrvGroundDefence,
        int arrvAerialDefence,
        int arrvProductionCost,
        double arrvRepairRange,
        double arrvRepairSpeed,
        int helicopterDurability,
        double helicopterSpeed,
        double helicopterVisionRange,
        double helicopterGroundAttackRange,
        double helicopterAerialAttackRange,
        int helicopterGroundDamage,
        int helicopterAerialDamage,
        int helicopterGroundDefence,
        int helicopterAerialDefence,
        int helicopterAttackCooldownTicks,
        int helicopterProductionCost,
        int fighterDurability,
        double fighterSpeed,
        double fighterVisionRange,
        double fighterGroundAttackRange,
        double fighterAerialAttackRange,
        int fighterGroundDamage,
        int fighterAerialDamage,
        int fighterGroundDefence,
        int fighterAerialDefence,
        int fighterAttackCooldownTicks,
        int fighterProductionCost,
        double maxFacilityCapturePoints,
        double facilityCapturePointsPerVehiclePerTick,
        double facilityWidth,
        double facilityHeight)
    {
        this.randomSeed = randomSeed;
        this.tickCount = tickCount;
        this.worldWidth = worldWidth;
        this.worldHeight = worldHeight;
        this.fogOfWarEnabled = fogOfWarEnabled;
        this.victoryScore = victoryScore;
        this.facilityCaptureScore = facilityCaptureScore;
        this.vehicleEliminationScore = vehicleEliminationScore;
        this.actionDetectionInterval = actionDetectionInterval;
        this.baseActionCount = baseActionCount;
        this.additionalActionCountPerControlCenter = additionalActionCountPerControlCenter;
        this.maxUnitGroup = maxUnitGroup;
        this.terrainWeatherMapColumnCount = terrainWeatherMapColumnCount;
        this.terrainWeatherMapRowCount = terrainWeatherMapRowCount;
        this.plainTerrainVisionFactor = plainTerrainVisionFactor;
        this.plainTerrainStealthFactor = plainTerrainStealthFactor;
        this.plainTerrainSpeedFactor = plainTerrainSpeedFactor;
        this.swampTerrainVisionFactor = swampTerrainVisionFactor;
        this.swampTerrainStealthFactor = swampTerrainStealthFactor;
        this.swampTerrainSpeedFactor = swampTerrainSpeedFactor;
        this.forestTerrainVisionFactor = forestTerrainVisionFactor;
        this.forestTerrainStealthFactor = forestTerrainStealthFactor;
        this.forestTerrainSpeedFactor = forestTerrainSpeedFactor;
        this.clearWeatherVisionFactor = clearWeatherVisionFactor;
        this.clearWeatherStealthFactor = clearWeatherStealthFactor;
        this.clearWeatherSpeedFactor = clearWeatherSpeedFactor;
        this.cloudWeatherVisionFactor = cloudWeatherVisionFactor;
        this.cloudWeatherStealthFactor = cloudWeatherStealthFactor;
        this.cloudWeatherSpeedFactor = cloudWeatherSpeedFactor;
        this.rainWeatherVisionFactor = rainWeatherVisionFactor;
        this.rainWeatherStealthFactor = rainWeatherStealthFactor;
        this.rainWeatherSpeedFactor = rainWeatherSpeedFactor;
        this.vehicleRadius = vehicleRadius;
        this.tankDurability = tankDurability;
        this.tankSpeed = tankSpeed;
        this.tankVisionRange = tankVisionRange;
        this.tankGroundAttackRange = tankGroundAttackRange;
        this.tankAerialAttackRange = tankAerialAttackRange;
        this.tankGroundDamage = tankGroundDamage;
        this.tankAerialDamage = tankAerialDamage;
        this.tankGroundDefence = tankGroundDefence;
        this.tankAerialDefence = tankAerialDefence;
        this.tankAttackCooldownTicks = tankAttackCooldownTicks;
        this.tankProductionCost = tankProductionCost;
        this.ifvDurability = ifvDurability;
        this.ifvSpeed = ifvSpeed;
        this.ifvVisionRange = ifvVisionRange;
        this.ifvGroundAttackRange = ifvGroundAttackRange;
        this.ifvAerialAttackRange = ifvAerialAttackRange;
        this.ifvGroundDamage = ifvGroundDamage;
        this.ifvAerialDamage = ifvAerialDamage;
        this.ifvGroundDefence = ifvGroundDefence;
        this.ifvAerialDefence = ifvAerialDefence;
        this.ifvAttackCooldownTicks = ifvAttackCooldownTicks;
        this.ifvProductionCost = ifvProductionCost;
        this.arrvDurability = arrvDurability;
        this.arrvSpeed = arrvSpeed;
        this.arrvVisionRange = arrvVisionRange;
        this.arrvGroundDefence = arrvGroundDefence;
        this.arrvAerialDefence = arrvAerialDefence;
        this.arrvProductionCost = arrvProductionCost;
        this.arrvRepairRange = arrvRepairRange;
        this.arrvRepairSpeed = arrvRepairSpeed;
        this.helicopterDurability = helicopterDurability;
        this.helicopterSpeed = helicopterSpeed;
        this.helicopterVisionRange = helicopterVisionRange;
        this.helicopterGroundAttackRange = helicopterGroundAttackRange;
        this.helicopterAerialAttackRange = helicopterAerialAttackRange;
        this.helicopterGroundDamage = helicopterGroundDamage;
        this.helicopterAerialDamage = helicopterAerialDamage;
        this.helicopterGroundDefence = helicopterGroundDefence;
        this.helicopterAerialDefence = helicopterAerialDefence;
        this.helicopterAttackCooldownTicks = helicopterAttackCooldownTicks;
        this.helicopterProductionCost = helicopterProductionCost;
        this.fighterDurability = fighterDurability;
        this.fighterSpeed = fighterSpeed;
        this.fighterVisionRange = fighterVisionRange;
        this.fighterGroundAttackRange = fighterGroundAttackRange;
        this.fighterAerialAttackRange = fighterAerialAttackRange;
        this.fighterGroundDamage = fighterGroundDamage;
        this.fighterAerialDamage = fighterAerialDamage;
        this.fighterGroundDefence = fighterGroundDefence;
        this.fighterAerialDefence = fighterAerialDefence;
        this.fighterAttackCooldownTicks = fighterAttackCooldownTicks;
        this.fighterProductionCost = fighterProductionCost;
        this.maxFacilityCapturePoints = maxFacilityCapturePoints;
        this.facilityCapturePointsPerVehiclePerTick = facilityCapturePointsPerVehiclePerTick;
        this.facilityWidth = facilityWidth;
        this.facilityHeight = facilityHeight;
    }
}
