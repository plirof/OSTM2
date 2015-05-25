package ostm.item;

import ostm.item.ItemType;
import ostm.item.Affix.AffixType;

class SqrtAffixType extends AffixType {
    public override function levelModifier(baseLevel :Int) :Int {
        return Math.round(Math.sqrt(baseLevel) + 2);
    }
}

class AffixData {
    public static var affixTypes = [
        new AffixType({
            id: 'flat-attack',
            description: 'Attack',
            base: 2,
            perLevel: 1,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatAttack += value;
            },
            multipliers: [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-attack-speed',
            description: '% Attack Speed',
            base: 5,
            perLevel: 1,
            levelPower: 0.5,
            modifierFunc: function(value, mod) {
                mod.localPercentAttackSpeed += value;
            },
            multipliers: [ Weapon => 1.0 ]
        }),
        new AffixType({
            id: 'local-percent-attack',
            description: '% Attack',
            base: 5,
            perLevel: 1.5,
            modifierFunc: function(value, mod) {
                mod.localPercentAttack += value;
            },
            multipliers: [ Weapon => 1.0 ]
        }),
        new AffixType({
            id: 'flat-crit-rating',
            description: 'Crit Rating',
            base: 4,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.flatCritRating += value;
            },
            multipliers: [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-crit-rating',
            description: '% Crit Rating',
            base: 5,
            perLevel: 1,
            modifierFunc: function(value, mod) {
                mod.localPercentCritRating += value;
            },
            multipliers: [ Weapon => 1.0 ]
        }),
        new AffixType({
            id: 'flat-defense',
            description: 'Defense',
            base: 2,
            perLevel: 1.25,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatDefense += value;
            },
            multipliers: [ Body => 1.0, Boots => 0.5, Helmet => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'flat-hp-regen',
            description: 'Health Regen',
            base: 1,
            perLevel: 0.35,
            modifierFunc: function(value, mod) {
                mod.flatHealthRegen += value;
            },
            multipliers: [ Body => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-hp',
            description: '% Health',
            base: 8,
            perLevel: 2,
            levelPower: 0.5,
            modifierFunc: function(value, mod) {
                mod.percentHealth += value;
            },
            multipliers: [ Helmet => 1.0 ]
        }),
        new AffixType({
            id: 'flat-mp',
            description: 'Mana',
            base: 5,
            perLevel: 2.5,
            modifierFunc: function(value, mod) {
                mod.flatMana += value;
            },
            multipliers: [ Body => 0.5, Helmet => 1.0, Ring => 0.5, Gloves => 0.5 ]
        }),
        new AffixType({
            id: 'percent-mp-regen',
            description: '% Mana Regen',
            base: 10,
            perLevel: 3,
            modifierFunc: function(value, mod) {
                mod.percentManaRegen += value;
            },
            multipliers: [ Helmet => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-defense',
            description: '% Defense',
            base: 10,
            perLevel: 5,
            modifierFunc: function(value, mod) {
                mod.localPercentDefense += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 0.5, Gloves => 0.5 ]
        }),
        new AffixType({
            id: 'percent-attack-speed',
            description: '% Global Attack Speed',
            base: 3,
            perLevel: 1,
            levelPower: 0.65,
            modifierFunc: function(value, mod) {
                mod.percentAttackSpeed += value;
            },
            multipliers: [ Gloves => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-crit-chance',
            description: '% Global Crit Chance',
            base: 2,
            perLevel: 1,
            modifierFunc: function(value, mod) {
                mod.percentCritChance += value;
            },
            multipliers: [ Weapon => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-crit-damage',
            description: '% Global Crit Damage',
            base: 10,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.percentCritDamage += value;
            },
            multipliers: [ Weapon => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-move-speed',
            description: '% Move Speed',
            base: 10,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.percentMoveSpeed += value;
            },
            multipliers: [ Boots => 1.0 ]
        }),
        new AffixType({
            id: 'flat-strength',
            description: 'Strength',
            base: 2,
            perLevel: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatStrength += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-dexterity',
            description: 'Dexterity',
            base: 2,
            perLevel: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatDexterity += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-vitality',
            description: 'Vitality',
            base: 2,
            perLevel: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatVitality += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-endurance',
            description: 'Endurance',
            base: 2,
            perLevel: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatEndurance += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-intelligence',
            description: 'Intelligence',
            base: 2,
            perLevel: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatIntelligence += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
    ];
}
