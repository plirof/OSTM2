package ostm.battle;

typedef StatDisplayData = {
    var name :String;
    var value: Float;
    var isPercent :Bool;
};

class StatModifier {
    public var flatAttack :Int = 0;
    public var flatDefense :Int = 0;
    public var flatCritRating :Int = 0;
    public var flatHealth :Int = 0;
    public var flatHealthRegen :Float = 0;
    public var flatMana :Int = 0;
    public var flatHuntSkill :Int = 0;

    public var flatStrength :Int = 0;
    public var flatDexterity :Int = 0;
    public var flatVitality :Int = 0;
    public var flatEndurance :Int = 0;
    public var flatIntelligence :Int = 0;

    public var percentHealth :Float = 0;
    public var percentMana :Int = 0;
    public var percentManaRegen :Int = 0;
    public var percentAttack :Int = 0;
    public var percentDefense :Int = 0;
    public var percentAttackSpeed :Int = 0;
    public var percentMoveSpeed :Int = 0;
    public var percentCritRating :Int = 0;
    public var percentCritChance :Int = 0;
    public var percentCritDamage :Int = 0;

    public var localPercentAttack :Int = 0;
    public var localPercentDefense :Int = 0;
    public var localPercentAttackSpeed :Int = 0;
    public var localPercentCritRating :Int = 0;

    public function new() { }

    function rawDisplayData() :Array<StatDisplayData> {
        return [
            {
                value: flatAttack,
                name: 'Attack',
                isPercent: false,
            }, {
                value: flatDefense,
                name: 'Defense',
                isPercent: false,
            }, {
                value: flatCritRating,
                name: 'Crit Rating',
                isPercent: false,
            }, {
                value: flatHealth,
                name: 'Health',
                isPercent: false,
            }, {
                value: flatHealthRegen,
                name: 'Health Regen',
                isPercent: false,
            }, {
                value: flatMana,
                name: 'Mana',
                isPercent: false,
            }, {
                value: flatHuntSkill,
                name: 'Hunting',
                isPercent: false,
            }, {
                value: flatStrength,
                name: 'Strength',
                isPercent: false,
            }, {
                value: flatDexterity,
                name: 'Dexterity',
                isPercent: false,
            }, {
                value: flatVitality,
                name: 'Vitality',
                isPercent: false,
            }, {
                value: flatEndurance,
                name: 'Endurance',
                isPercent: false,
            }, {
                value: flatIntelligence,
                name: 'Intelligence',
                isPercent: false,
            }, {
                value: percentHealth,
                name: 'Health',
                isPercent: true,
            }, {
                value: percentMana,
                name: 'Mana',
                isPercent: true,
            }, {
                value: percentManaRegen,
                name: 'Mana Regen',
                isPercent: true,
            }, {
                value: percentAttack,
                name: 'Attack',
                isPercent: true,
            }, {
                value: percentDefense,
                name: 'Defense',
                isPercent: true,
            }, {
                value: percentAttackSpeed,
                name: 'Attack Speed',
                isPercent: true,
            }, {
                value: percentMoveSpeed,
                name: 'Move Speed',
                isPercent: true,
            }, {
                value: percentCritRating,
                name: 'Crit Rating',
                isPercent: true,
            }, {
                value: percentCritChance,
                name: 'Crit Chance',
                isPercent: true,
            }, {
                value: percentCritDamage,
                name: 'Crit Damage',
                isPercent: true,
            }, {
                value: localPercentAttack,
                name: 'Attack',
                isPercent: true,
            }, {
                value: localPercentDefense,
                name: 'Defense',
                isPercent: true,
            }, {
                value: localPercentAttackSpeed,
                name: 'Attack Speed',
                isPercent: true,
            }, {
                value: localPercentCritRating,
                name: 'Crit Rating',
                isPercent: true,
            },
        ];
    }

    public function getDisplayData() :Array<StatDisplayData> {
        var stats = rawDisplayData();
        var toReturn = [];
        for (s in stats) {
            if (s.value > 0) {
                toReturn.push(s);
            }
        }
        return toReturn;
    }

    public function getDisplayDataAllowingZeroes() :Array<StatDisplayData> {
        return rawDisplayData();
    }
}
