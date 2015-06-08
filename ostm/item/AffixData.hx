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
            base: 2,
            perLevel: 1,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.localFlatAttack += value;
            },
            multipliers: [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-attack-speed',
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
            base: 5,
            perLevel: 1.5,
            modifierFunc: function(value, mod) {
                mod.localPercentAttack += value;
            },
            multipliers: [ Weapon => 1.0 ]
        }),
        new AffixType({
            id: 'flat-crit-rating',
            base: 4,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.localFlatCritRating += value;
            },
            multipliers: [ Weapon => 1.0, Gloves => 0.5, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-crit-rating',
            base: 5,
            perLevel: 1,
            modifierFunc: function(value, mod) {
                mod.localPercentCritRating += value;
            },
            multipliers: [ Weapon => 1.0 ]
        }),
        new AffixType({
            id: 'flat-defense',
            base: 2,
            perLevel: 1.25,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.localFlatDefense += value;
            },
            multipliers: [ Body => 1.0, Boots => 0.5, Helmet => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'flat-hp-regen',
            base: 1,
            perLevel: 0.35,
            modifierFunc: function(value, mod) {
                mod.flatHealthRegen += value;
            },
            multipliers: [ Body => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-hp',
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
            base: 5,
            perLevel: 2.5,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatMana += value;
            },
            multipliers: [ Body => 0.5, Helmet => 1.0, Ring => 0.5, Gloves => 0.5 ]
        }),
        new AffixType({
            id: 'flat-hunt',
            base: 3,
            perLevel: 2,
            levelPower: 0.75,
            modifierFunc: function(value, mod) {
                mod.flatHuntSkill += value;
            },
            multipliers: [ Helmet => 0.5, Boots => 1.0, Ring => 0.5, Jewel => 0.5 ]
        }),
        new AffixType({
            id: 'percent-mp-regen',
            base: 10,
            perLevel: 3,
            modifierFunc: function(value, mod) {
                mod.percentManaRegen += value;
            },
            multipliers: [ Helmet => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'local-percent-defense',
            base: 10,
            perLevel: 5,
            modifierFunc: function(value, mod) {
                mod.localPercentDefense += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 0.5, Gloves => 0.5 ]
        }),
        new AffixType({
            id: 'percent-attack-speed',
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
            base: 2,
            perLevel: 1,
            modifierFunc: function(value, mod) {
                mod.percentCritChance += value;
            },
            multipliers: [ Weapon => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-crit-damage',
            base: 10,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.percentCritDamage += value;
            },
            multipliers: [ Weapon => 1.0, Ring => 0.5 ]
        }),
        new AffixType({
            id: 'percent-move-speed',
            base: 10,
            perLevel: 2,
            modifierFunc: function(value, mod) {
                mod.percentMoveSpeed += value;
            },
            multipliers: [ Boots => 1.0, Jewel => 0.5 ]
        }),
        new AffixType({
            id: 'flat-strength',
            base: 2,
            perLevel: 0.75,
            levelPower: 0.9,
            modifierFunc: function(value, mod) {
                mod.flatStrength += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-dexterity',
            base: 2,
            perLevel: 0.75,
            levelPower: 0.9,
            modifierFunc: function(value, mod) {
                mod.flatDexterity += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-vitality',
            base: 2,
            perLevel: 0.75,
            levelPower: 0.9,
            modifierFunc: function(value, mod) {
                mod.flatVitality += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-endurance',
            base: 2,
            perLevel: 0.75,
            levelPower: 0.9,
            modifierFunc: function(value, mod) {
                mod.flatEndurance += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'flat-intelligence',
            base: 2,
            perLevel: 0.75,
            levelPower: 0.9,
            modifierFunc: function(value, mod) {
                mod.flatIntelligence += value;
            },
            multipliers: [ Body => 1.0, Helmet => 1.0, Boots => 1.0, Gloves => 1.0, Ring => 1.0 ]
        }),
        new AffixType({
            id: 'xp-gain',
            base: 2,
            perLevel: 1,
            levelPower: 0.8,
            modifierFunc: function(value, mod) {
                mod.percentXpGained += value;
            },
            multipliers: [ Jewel => 1.0 ],
        }),
        new AffixType({
            id: 'gold-gain',
            base: 5,
            perLevel: 2,
            levelPower: 0.8,
            modifierFunc: function(value, mod) {
                mod.percentGoldGained += value;
            },
            multipliers: [ Jewel => 1.0 ],
        }),
        new AffixType({
            id: 'gem-drop',
            base: 2,
            perLevel: 0.65,
            levelPower: 0.8,
            modifierFunc: function(value, mod) {
                mod.percentGemDropRate += value;
            },
            multipliers: [ Jewel => 1.0 ],
        }),
        new AffixType({
            id: 'item-drop',
            base: 3,
            perLevel: 1,
            levelPower: 0.8,
            modifierFunc: function(value, mod) {
                mod.percentItemDropRate += value;
            },
            multipliers: [ Jewel => 1.0 ],
        }),
        new AffixType({
            id: 'item-rarity',
            base: 8,
            perLevel: 2,
            levelPower: 0.8,
            modifierFunc: function(value, mod) {
                mod.percentItemRarity += value;
            },
            multipliers: [ Jewel => 1.0 ],
        }),
    ];
}
