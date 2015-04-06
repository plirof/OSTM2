package ostm.skill;

class PassiveData {
    public static var skills(default, null) = [
        new PassiveSkill({
            id: 'str',
            requirements: [],
            icon: 'STR+',
            pos: {x: 0, y: 0},
            name: 'Strength+',
            description: 'Increases strength',
            isPercent: false,
            leveling: function(level) {
                return 4 * level;
            },
            modifier: function(value, mod) {
                mod.flatStrength += value;
            },
        }),
        new PassiveSkill({
            id: 'vit',
            requirements: ['str'],
            icon: 'VIT+',
            pos: {x: 0, y: 1},
            name: 'Vitality+',
            description: 'Increases vitality',
            isPercent: false,
            leveling: function(level) {
                return 4 * level;
            },
            modifier: function(value, mod) {
                mod.flatVitality += value;
            },
        }),
        new PassiveSkill({
            id: 'dex',
            requirements: [],
            icon: 'DEX+',
            pos: {x: 2, y: 0},
            name: 'Dexterity+',
            description: 'Increases dexterity',
            isPercent: false,
            leveling: function(level) {
                return 4 * level;
            },
            modifier: function(value, mod) {
                mod.flatDexterity += value;
            },
        }),
        new PassiveSkill({
            id: 'spd',
            requirements: ['dex'],
            icon: 'SPD+',
            pos: {x: 3, y: 1},
            name: 'Speed+',
            description: 'Increases movement speed',
            isPercent: true,
            leveling: function(level) {
                return 6 * level;
            },
            modifier: function(value, mod) {
                mod.percentMoveSpeed += value;
            },
        }),
        new PassiveSkill({
            id: 'crt',
            requirements: ['dex'],
            icon: 'CCH+',
            pos: {x: 2, y: 1},
            name: 'Crit Rating+',
            description: 'Increases critical rating',
            isPercent: true,
            leveling: function(level) {
                return 6 * level;
            },
            modifier: function(value, mod) {
                mod.percentCritRating += value;
            },
        }),
        new PassiveSkill({
            id: 'cch',
            requirements: ['crt'],
            icon: 'CCH+',
            pos: {x: 1, y: 2},
            name: 'Crit Chance+',
            description: 'Increases global critical hit chance',
            isPercent: true,
            leveling: function(level) {
                return 8 * level;
            },
            modifier: function(value, mod) {
                mod.percentCritChance += value;
            },
        }),
        new PassiveSkill({
            id: 'cdm',
            requirements: ['crt'],
            icon: 'CDM+',
            pos: {x: 2, y: 2},
            name: 'Crit Damage+',
            description: 'Increases global critical hit damage',
            isPercent: true,
            leveling: function(level) {
                return 12 * level;
            },
            modifier: function(value, mod) {
                mod.percentCritDamage += value;
            },
        }),
    ];
}
