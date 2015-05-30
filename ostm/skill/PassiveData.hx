package ostm.skill;

class PassiveData {
    public static var skills(default, null) = [
        // Flat Stats
        new PassiveSkill({
            id: 'str',
            requirements: [],
            icon: 'STR+',
            pos: {x: 0, y: 0},
            name: 'Strength+',
            modifier: function(level, mod) {
                mod.flatStrength += 3 * level;
            },
        }),
        new PassiveSkill({
            id: 'dex',
            requirements: [],
            icon: 'DEX+',
            pos: {x: 2, y: 0},
            name: 'Dexterity+',
            modifier: function(level, mod) {
                mod.flatDexterity += 3 * level;
            },
        }),
        // new PassiveSkill({
        //     id: 'int',
        //     requirements: [],
        //     icon: 'INT+',
        //     pos: {x: 4, y: 0},
        //     name: 'Intelligence+',
        //     modifier: function(level, mod) {
        //         mod.flatIntelligence += 3 * level;
        //     },
        // }),
        new PassiveSkill({
            id: 'vit',
            requirements: [],
            icon: 'VIT+',
            pos: {x: 5, y: 0},
            name: 'Vitality+',
            modifier: function(level, mod) {
                mod.flatVitality += 3 * level;
            },
        }),
        new PassiveSkill({
            id: 'end',
            requirements: [],
            icon: 'END+',
            pos: {x: 7, y: 0},
            name: 'Endurance+',
            modifier: function(level, mod) {
                mod.flatEndurance += 3 * level;
            },
        }),

        // Basic
        new PassiveSkill({
            id: 'dam',
            requirements: ['str'],
            icon: 'DAM',
            pos: {x: 0, y: 1},
            name: 'Damage',
            modifier: function(level, mod) {
                mod.flatStrength += 2 * level;
                mod.percentAttack += 9 * level;
            },
        }),
        new PassiveSkill({
            id: 'atk-spd',
            requirements: ['dex'],
            icon: 'ASPD',
            pos: {x: -1, y: 1},
            name: 'AttackSpeed+',
            modifier: function(level, mod) {
                mod.flatDexterity += 2 * level;
                mod.percentAttackSpeed += Math.floor(3.5 * level);
            },
        }),
        new PassiveSkill({
            id: 'crt',
            requirements: ['dex'],
            icon: 'CRT+',
            pos: {x: 0, y: 1},
            name: 'Crit Rating+',
            modifier: function(level, mod) {
                mod.flatDexterity += 2 * level;
                mod.percentCritRating += 6 * level;
            },
        }),
        new PassiveSkill({
            id: 'mp',
            requirements: [],
            // requirements: ['int'],
            icon: 'MP+',
            pos: {x: 8, y: 1},
            name: 'Mana+',
            modifier: function(level, mod) {
                mod.flatMana += 8 * level;
            },
        }),
        new PassiveSkill({
            id: 'hp-reg',
            icon: 'HPRe',
            requirements: ['vit'],
            pos: {x: 0, y: 1},
            name: 'Health Regen+',
            modifier: function(level, mod) {
                mod.flatVitality += 2 * level;
                mod.flatHealthRegen += 0.5 * level;
            },
        }),
        new PassiveSkill({
            id: 'hp',
            icon: 'HP+',
            requirements: ['vit', 'end'],
            pos: {x: 1, y: 1},
            name: 'Health+',
            modifier: function(level, mod) {
                mod.flatEndurance += 2 * level;
                mod.percentHealth += 2.5 * level;
            },
        }),

        // Advanced        
        new PassiveSkill({
            id: 'dam+',
            requirements: ['dam'],
            icon: 'DAM+',
            pos: {x: 0, y: 1},
            name: 'Damage+',
            modifier: function(level, mod) {
                mod.flatStrength += Math.floor(1.5 * level);
                mod.percentAttack += 7 * level;
                mod.percentHealth += 2 * level;
            },
        }),
        new PassiveSkill({
            id: 'cch',
            requirements: ['crt'],
            icon: 'CCH+',
            pos: {x: 1, y: 1},
            name: 'Crit Chance+',
            modifier: function(level, mod) {
                mod.flatDexterity += Math.floor(1.5 * level);
                mod.flatCritRating += 2 * level;
                mod.percentCritChance += 8 * level;
            },
        }),
        new PassiveSkill({
            id: 'mp-reg',
            requirements: ['mp'],
            icon: 'MPRe',
            pos: {x: 0, y: 1},
            name: 'Mana Regen+',
            modifier: function(level, mod) {
                mod.flatIntelligence += Math.floor(1.5 * level);
                mod.percentManaRegen += 10 * level;
            },
        }),
        new PassiveSkill({
            id: 'pct-hp-reg',
            requirements: ['hp-reg'],
            icon: 'HPR%',
            pos: {x: 0, y: 1},
            name: 'Health Regen++',
            modifier: function(level, mod) {
                mod.flatVitality += Math.floor(1.5 * level);
                mod.percentHealthRegen += 5 * level;
            },
        }),
        new PassiveSkill({
            id: 'arm',
            icon: 'ARM+',
            requirements: ['end'],
            pos: {x: 0, y: 1},
            name: 'Armor+',
            modifier: function(level, mod) {
                mod.flatEndurance += Math.floor(1.5 * level);
                mod.flatDefense += level;
            },
        }),

        // Niche
        new PassiveSkill({
            id: 'prc',
            requirements: ['dam+'],
            icon: 'PRC+',
            pos: {x: 0, y: 1},
            name: 'Pierce+',
            modifier: function(level, mod) {
                mod.flatStrength += level;
                mod.flatEndurance += level;
                mod.flatArmorPierce += 5 * level;
                mod.percentAttack += 5 * level;
            },
        }),
        new PassiveSkill({
            id: 'cdm',
            requirements: ['cch'],
            icon: 'CDM+',
            pos: {x: 0, y: 1},
            name: 'Crit Damage+',
            modifier: function(level, mod) {
                mod.flatDexterity += level;
                mod.flatIntelligence += level;
                mod.percentAttackSpeed += Math.floor(2.5 * level);
                mod.percentCritDamage += 12 * level;
            },
        }),
    ];
}
