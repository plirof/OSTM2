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
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatStrength += value;
            },
        }),
        new PassiveSkill({
            id: 'vit',
            requirements: ['str'],
            icon: 'VIT+',
            pos: {x: -1, y: 1},
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
            id: 'spd',
            requirements: ['str'],
            icon: 'SPD+',
            pos: {x: 1, y: 1},
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
            id: 'cch',
            requirements: ['spd'],
            icon: 'CCH+',
            pos: {x: 1, y: 2},
            name: 'Crit Chance+',
            description: 'Increases global critical hit chance',
            isPercent: true,
            leveling: function(level) {
                return 15 * level;
            },
            modifier: function(value, mod) {
                mod.percentCritChance += value;
            },
        }),
    ];
}
