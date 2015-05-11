package ostm.skill;

class PassiveData {
    public static var skills(default, null) = [
        new PassiveSkill({
            id: 'str',
            icon: 'STR+',
            pos: {x: 0, y: 0},
            name: 'Strength+',
            description: 'Increases strength',
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatStrength += value;
            },
        }),
        new PassiveSkill({
            id: 'dex',
            icon: 'DEX+',
            pos: {x: 1, y: 0},
            name: 'Dexterity+',
            description: 'Increases dexterity',
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatDexterity += value;
            },
        }),
            new PassiveSkill({
                id: 'atk-spd',
                requirements: ['dex'],
                icon: 'ASPD',
                pos: {x: 1, y: 1},
                name: 'AttackSpeed+',
                description: 'Increases attack speed',
                isPercent: true,
                leveling: function(level) {
                    return 3 * level;
                },
                modifier: function(value, mod) {
                    mod.percentAttackSpeed += value;
                },
            }),
                new PassiveSkill({
                    id: 'spd',
                    requirements: ['atk-spd'],
                    icon: 'MSPD',
                    pos: {x: 0, y: 1},
                    name: 'MoveSpeed+',
                    description: 'Increases movement speed',
                    isPercent: true,
                    leveling: function(level) {
                        return 8 * level;
                    },
                    modifier: function(value, mod) {
                        mod.percentMoveSpeed += value;
                    },
                }),
            new PassiveSkill({
                id: 'crt',
                requirements: ['dex'],
                icon: 'CRT+',
                pos: {x: 0, y: 1},
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
                    pos: {x: -1, y: 1},
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
                    pos: {x: 0, y: 1},
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
        new PassiveSkill({
            id: 'int',
            icon: 'INT+',
            pos: {x: 3, y: 0},
            name: 'Intelligence+',
            description: 'Increases intelligence',
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatIntelligence += value;
            },
        }),
            new PassiveSkill({
                id: 'mp',
                requirements: ['int'],
                icon: 'MP+',
                pos: {x: 0, y: 1},
                name: 'Mana+',
                description: 'Increases mana',
                leveling: function(level) {
                    return 8 * level;
                },
                modifier: function(value, mod) {
                    mod.flatMana += value;
                },
            }),
                new PassiveSkill({
                    id: 'mp-reg',
                    requirements: ['mp'],
                    icon: 'MPRe',
                    pos: {x: 0, y: 1},
                    name: 'Mana Regen+',
                    description: 'Increases mana regen',
                    isPercent: true,
                    leveling: function(level) {
                        return 10 * level;
                    },
                    modifier: function(value, mod) {
                        mod.percentManaRegen += value;
                    },
                }),
        new PassiveSkill({
            id: 'vit',
            icon: 'VIT+',
            pos: {x: 4, y: 0},
            name: 'Vitality+',
            description: 'Increases vitality',
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatVitality += value;
            },
        }),
        new PassiveSkill({
            id: 'end',
            icon: 'END+',
            pos: {x: 6, y: 0},
            name: 'Endurance+',
            description: 'Increases endurance',
            leveling: function(level) {
                return 3 * level;
            },
            modifier: function(value, mod) {
                mod.flatEndurance += value;
            },
        }),
            new PassiveSkill({
                id: 'hp',
                icon: 'HP+',
                requirements: ['vit', 'end'],
                pos: {x: 1, y: 1},
                name: 'Health+',
                description: 'Increases health',
                isPercent: true,
                leveling: function(level) {
                    return 2.5 * level;
                },
                modifier: function(value, mod) {
                    mod.percentHealth += value;
                },
            }),
                new PassiveSkill({
                    id: 'hp-reg',
                    icon: 'HPRe',
                    requirements: ['hp'],
                    pos: {x: 0, y: 1},
                    name: 'Health Regen+',
                    description: 'Increases health regen',
                    leveling: function(level) {
                        return 0.5 * level;
                    },
                    modifier: function(value, mod) {
                        mod.flatHealthRegen += value;
                    },
                }),
            new PassiveSkill({
                id: 'arm',
                icon: 'ARM+',
                requirements: ['end'],
                pos: {x: 0, y: 1},
                name: 'Armor+',
                description: 'Increases armor',
                leveling: function(level) {
                    return 1 * level;
                },
                modifier: function(value, mod) {
                    mod.flatDefense += value;
                },
            }),
    ];
}
