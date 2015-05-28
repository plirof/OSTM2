package ostm.skill;

class PassiveData {
    public static var skills(default, null) = [
        new PassiveSkill({
            id: 'str',
            icon: 'STR+',
            pos: {x: 0, y: 0},
            name: 'Strength+',
            modifier: function(level, mod) {
                mod.flatStrength += 3 * level;
            },
        }),
        new PassiveSkill({
            id: 'dex',
            icon: 'DEX+',
            pos: {x: 2, y: 0},
            name: 'Dexterity+',
            modifier: function(level, mod) {
                mod.flatDexterity += 3 * level;
            },
        }),
            new PassiveSkill({
                id: 'danger',
                requirements: ['str', 'dex'],
                icon: 'DNG',
                pos: {x: 1, y: 1},
                name: 'Dangerousness',
                modifier: function(level, mod) {
                    mod.flatDexterity += level;
                    mod.percentAttackSpeed += 3 * level;
                },
            }),
            new PassiveSkill({
                id: 'atk-spd',
                requirements: ['dex'],
                icon: 'ASPD',
                pos: {x: 1, y: 1},
                name: 'AttackSpeed+',
                modifier: function(level, mod) {
                    mod.percentAttackSpeed += 3 * level;
                },
            }),
                new PassiveSkill({
                    id: 'spd',
                    requirements: ['atk-spd'],
                    icon: 'MSPD',
                    pos: {x: 0, y: 1},
                    name: 'MoveSpeed+',
                    modifier: function(level, mod) {
                        mod.percentMoveSpeed += 8 * level;
                    },
                }),
            new PassiveSkill({
                id: 'crt',
                requirements: ['dex'],
                icon: 'CRT+',
                pos: {x: 0, y: 1},
                name: 'Crit Rating+',
                modifier: function(level, mod) {
                    mod.percentCritRating += 6 * level;
                },
            }),
                new PassiveSkill({
                    id: 'cch',
                    requirements: ['crt'],
                    icon: 'CCH+',
                    pos: {x: -1, y: 1},
                    name: 'Crit Chance+',
                    modifier: function(level, mod) {
                        mod.percentCritChance += 8 * level;
                    },
                }),
                new PassiveSkill({
                    id: 'cdm',
                    requirements: ['crt'],
                    icon: 'CDM+',
                    pos: {x: 0, y: 1},
                    name: 'Crit Damage+',
                    modifier: function(level, mod) {
                        mod.percentCritDamage += 12 * level;
                    },
                }),
        new PassiveSkill({
            id: 'int',
            icon: 'INT+',
            pos: {x: 4, y: 0},
            name: 'Intelligence+',
            modifier: function(level, mod) {
                mod.flatIntelligence += 3 * level;
            },
        }),
            new PassiveSkill({
                id: 'mp',
                requirements: ['int'],
                icon: 'MP+',
                pos: {x: 0, y: 1},
                name: 'Mana+',
                modifier: function(level, mod) {
                    mod.flatMana += 8 * level;
                },
            }),
                new PassiveSkill({
                    id: 'mp-reg',
                    requirements: ['mp'],
                    icon: 'MPRe',
                    pos: {x: 0, y: 1},
                    name: 'Mana Regen+',
                    modifier: function(level, mod) {
                        mod.percentManaRegen += 10 * level;
                    },
                }),
        new PassiveSkill({
            id: 'vit',
            icon: 'VIT+',
            pos: {x: 5, y: 0},
            name: 'Vitality+',
            modifier: function(level, mod) {
                mod.flatVitality += 3 * level;
            },
        }),
        new PassiveSkill({
            id: 'end',
            icon: 'END+',
            pos: {x: 7, y: 0},
            name: 'Endurance+',
            modifier: function(level, mod) {
                mod.flatEndurance += 3 * level;
            },
        }),
            new PassiveSkill({
                id: 'hp',
                icon: 'HP+',
                requirements: ['vit', 'end'],
                pos: {x: 1, y: 1},
                name: 'Health+',
                modifier: function(level, mod) {
                    mod.percentHealth += 2.5 * level;
                },
            }),
                new PassiveSkill({
                    id: 'hp-reg',
                    icon: 'HPRe',
                    requirements: ['hp'],
                    pos: {x: 0, y: 1},
                    name: 'Health Regen+',
                    modifier: function(level, mod) {
                        mod.flatHealthRegen += 0.5 * level;
                    },
                }),
            new PassiveSkill({
                id: 'arm',
                icon: 'ARM+',
                requirements: ['end'],
                pos: {x: 0, y: 1},
                name: 'Armor+',
                modifier: function(level, mod) {
                    mod.flatDefense += level;
                },
            }),
    ];
}
