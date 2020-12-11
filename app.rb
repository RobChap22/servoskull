# app.rb
require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'tempfile'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
    config.channel_token = ENV['LINE_ACCESS_TOKEN']
  end
end

def bot_answer_to(a_question, user_name)
  # If you want to add Bob to group chat, uncomment the next line
  # return '' unless a_question.downcase.include?('bob') # Only answer to messages with 'bob'

  # WEAPON KEYWORDS
  if a_question.match?(/(assault|energy) shield/i)
    "An assault/energy shield grants a +2 armour save modifier (to a maximum of 2+) against melee attacks that originate from within the fighter’s vision arc (the 90° arc to their front), and a +1 armour save modifier against ranged attacks that originate from within the fighter’s vision arc; check this before the fighter is placed Prone and is Pinned. If it is not clear whether the attacker is within the target’s front arc, use a Vision Arc template to check – if the centre of the attacker’s base is within the arc, the assault/energy shield can be used. Against attacks with the Blast trait, use the centre of the Blast marker in place of the attacker. If the target does not have a facing (for example, if they are Prone), the assault/energy shield cannot be used"
  elsif a_question.match?(/BACKSTAB/i)
    "If the attacker is not within the target’s vision arc, add 1 to the attack’s Strength."
  elsif a_question.match?(/blaze/i)
    "After an attack with the Blaze trait has been resolved, roll a D6 if the target was hit but not taken Out Of Action. On a 4, 5 or 6, they become subject to the Blaze condition.
When activated, a fighter subject to the Blaze condition suffers an immediate Strength 3, AP -1, Damage 1 hit before acting as follows:\n
- If Prone and Pinned the fighter immediately becomes Standing and Active and acts as described below.\n
- If Standing and Active the fighter moves 2D6\" in a random direction, determined by the Scatter dice. The fighter will stop moving if this movement would bring them within 1\" of an enemy fighter or into base contact with impassable terrain. If this movement brings them within 1⁄2\" of the edge of a level or platform, they risk falling as described on page 29. If this movement takes the fighter beyond the edge of a level or platform, they will simply fall. At the end of this move, the fighter may choose to become Prone and Pinned. The fighter may then attempt to put the fire out.\n
- If Standing and Engaged or Prone and Seriously Injured, the fighter does not move and attempts to put the fire out. To attempt to put the fire out, roll a D6, adding 1 to the result for each other Active friendly fighter within 1\". On a result of 6 or more, the flames go out and the Blaze marker is removed. Pinned or Seriously Injured fighters add 2 to the result of the roll to see if the flames go out."
  elsif a_question.match?(/burrowing/i)
    "Burrowing weapons can be fired at targets outside of the firer’s line of sight. When firing at a target outside of line of sight do not make an attack roll, instead place the 3\" Blast marker anywhere on the battlefield, then move it 2D6\" in a direction determined by the Scatter dice. If a Hit is rolled on the Scatter dice, the Blast marker does not move. At the start of the End phase of the round in which this weapon was fired, before step 1, any fighters touched by the marker are hit by the weapon.\n
Note that this Blast marker can move through impassable terrain such as walls and may move off the battlefield. If the Blast marker does move off the battlefield, the attack will have no effect. Burrowing weapons are capable of digging through several levels of wall and flooring, and can be used regardless of where the fighter is positioned on the battlefield."
  elsif a_question.match?(/chem delivery/i)
    "When a weapon with the Chem Delivery trait is used, the fighter declares what kind of chem they are firing at the target. This can be any chem the fighter is equipped with (note that firing the weapon does not cost a dose of the chem and that friendly fighters cannot be targeted), or if the weapon also has the Toxin or Gas trait, the fighter can use these Traits instead. Instead of making a Wound roll for a Chem Delivery attack, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, the target is affected by the chosen chem just as if they had taken a dose. If the roll is lower than the target’s Toughness, they shrug off the chem’s effects"
  elsif a_question.match?(/combi/i)
    "A combi-weapon has two profiles. When it is fired, pick one of the two profiles and use it for the attack. Due to the compact nature of the weapons, they often have less capacity for ammunition, and are prone to jams and other minor issues. When making an Ammo check for either of the weapons, roll twice and apply the worst result. However, unlike most weapons that have two profiles, ammo for the two parts of the combi-weapon are tracked separately – if one profile runs Out of Ammo, the other can still fire unless it has also run Out of Ammo"
  elsif a_question.match?(/concussion/i)
    "Any model hit by a Concussion weapon has their Initiative reduced by 2 to a minimum of 6+ until the end of the round."
  elsif a_question.match?(/cursed/i)
    "A fighter hit by a weapon with the Cursed trait must make a Willpower check or gain the Insane condition."
  elsif a_question.match?(/defoliate/i)
    "Carnivorous Plants hit by a weapon with the Defoliate Trait immediately take D3 Damage. Brainleaf Zombies hit by a weapon with the Defoliate Trait lose a wound and are removed from the battlefield if they suffer an Out of Action result on the Injury dice."
  elsif a_question.match?(/demolitions/i)
    "Grenade with the Demolitions trait can be used when making close combat attacks against scenery targets (such as locked doors or scenario objectives). A fighter who uses a grenade in this way makes one attack (regardless of how many Attack dice they would normally roll), which hits automatically."
  elsif a_question.match?(/digi/i)
    "A digi weapon is worn mounted on a ring or hidden inside a glove. It can be used in addition to any other Melee weapon or Pistol carried by the fighter granting either an additional shot or an additional close combat attack. A weapon with this trait does not count towards the maximum number of weapons a fighter can carry, however the maximum number of weapon with this trait a fighter can carry is 10."
  elsif a_question.match?(/disarm/i)
    "If the hit roll for an attack made with a Disarm weapon is a natural 6, the target cannot use any weapons when making Reaction attacks during that combat – they make unarmed attacks instead."
  elsif a_question.match?(/drag/i)
    "If a fighter is hit by a Drag weapon but not taken Out of Action, the attacker can attempt to drag the target closer after the attack has been resolved. If a they do, roll a d6. If the score is equal to or higher than the target’s Strength, the target is dragged D3’’ straight towards the attacker, stopping if they hit any terrain. If they move into another fighter (other than the attacker), both fighters are moved the remaining distance towards the attacker.\n
If the weapon also has the Impale special rule and hits more than one fighter, only the last fighter to be hit can be dragged."
  elsif a_question.match?(/entangle/i)
    "Hits scored by weapons with the Entangle trait cannot be negated by the Parry trait. In addition, if the hit roll for an Entangle weapon is a natural 6, any Reaction attacks made by the target have an additional -2 hit modifier"
  elsif a_question.match?(/fear/i)
    "Instead of making an Injury roll for an attack with the Fear trait, the opposing player makes a Nerve test for the target, subtracting 2 from the result. If the test fails, the target is immediately Broken and runs for cover."
  elsif a_question.match?(/flare/i)
    "A fighter who takes a hit from a weapon with the Flare Trait, or who is touched by a Blast marker fired from a weapon with the Flare Trait, is Revealed if the battlefield is in darkness (see Pitch Black). If a weapon has both the Flare Trait and the Blast Trait after determining where the Blast marker ends up, leave it in place. In the End phase, roll a D6. On a 4 or more, the flare goes out and the marker is removed, otherwise it remains in play. While the Blast marker is on the board, all models at least touched by it are illuminated as if they had a Blaze marker or a Revealed marker"
  elsif a_question.match?(/flash/i)
    "If a fighter is hit by a Flash weapon, no wound roll is made. Instead, make an Initiative check for the target. If it is failed, they are blinded. A blinded fighter loses their Ready marker; if they do not have a Ready marker, they do not gain a Ready marker at the start of the following round. Until the next time the fighter is activated, they cannot make any attacks other than reaction attacks, for which any hit rolls will only succeed on a natural 6."
  elsif a_question.match?(/gas/i)
    "When a fighter is hit by an attack made by a Gas weapon, they are not Pinned and a wound roll is not made.\n
Instead, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, make an Injury roll for them (regardless of their Wounds characteristic). If the roll is lower than the target’s Toughness, they shrug off the effects of the gas – no save roll can be made."
  elsif a_question.match?(/graviton pulse/i)
    "Instead of rolling to wound normally with this weapon, any model caught in the blast must instead roll to or under their Strength on a D6 (a roll of 6 always counts as a fail). After the weapon has been fired, leave the Blast marker in place. For the remainder of the round, any model moving through this area will use 2’’ of their movement for every 1’’ they move. Remove the Blast marker during the End phase."
  elsif a_question.match?(/grenade/i)
    "Despite being Wargear, grenades are treated as a special type of ranged weapon. A fighter equipped with grenades can throw one as a Shoot (Basic) action. Grenades do not have a Short range, and their Long range is determined by multiplying the fighter’s Strength by the amount shown.\n
A fighter can only carry a limited number of grenades.The Firepower dice is not rolled when attacking with a grenade. Instead, after the attack has been resolved, an Ammo check is made automatically. If this is failed, grenades cannot be reloaded; the fighter has run out of that type of grenade and cannot use them for the remainder of the battle."
  elsif a_question.match?(/gunk/i)
    "A fighter hit by a weapon with the Gunk Trait becomes subject to the Gunked condition. Gunked fighters reduce their Movement characteristic by 1 to a minimum of 1 and don’t add D3\" to their movement when making a Charge action. In addition, they subtract 1 from the dice roll when making an Initiative check. Gunked fighters are also more flammable and catch fire on a 2+, rather than a 4+, when hit by a weapon with the Blaze trait.\n
The Gunked condition lasts until the End phase or untilthe fighter catches fire after being hit by a weapon with the Blaze Trait"
  elsif a_question.match?(/HEXAGRAMMATIC/i)
    "The ammo used by this weapon has been specially treated to defeat psychic defences and severely harm Psykers. Hits from weapons with this Trait ignore saves provided by psychic powers. Additionally, weapons with this Trait will inflict double damage against Psykers."
  elsif a_question.match?(/IMPALE/i)
    "If an attack made by this weapon hits and wounds the target, and the save roll is unsuccessful (or no save roll is made), the projectile continues through them and might hit another fighter! Trace a straight line from the target, directly away from the attacker. If there are any fighters within 1\" of this line, and within the weapon's Long Range, the one that is closest to the target is at risk of being hit. Roll a D6 – on a 3 or more, resolve the weapon’s attack against that fighter, subtracting 1 from the Strength. The projectile can continue through multiple fighters in this way, but if the Strength is reduced to 0, it cannot hit any more fighters."
  elsif a_question.match?(/KNOCKBACK/i)
    "If the hit roll for a weapon with the Knockback trait is equal to or higher than the target’s Strength, they are immediately moved 1\" directly away from the attacking fighter. If the fighter cannot be moved the full 1\" because of impassable terrain or another fighter, they move as far as possible and the attack’s Damage is increased by 1. If a Blast weapon has the Knockback trait, roll a D6 for each fighter that is hit. If the result is equal to or higher than their Strength, they are knocked back as described above – however, they are moved directly away from the centre of the Blast marker instead. If the centre of the Blast marker was over the centre of their base, roll a Scatter dice to determine which way they are moved. If a Melee weapon has the Knockback trait, the attacking fighter can choose to follow the target up, moving directly towards them after they have been knocked back to remain in base contact. If the attack was made across a barricade, the attacker cannot do this. If any part of the knocked back fighter's base crosses the edge of a platform, make an Initiative check. If this is failed, they will fall. If this is passed, they stop moving at the edge of the platform."
  elsif a_question.match?(/LIMITED/i)
    "This special rule is applied to some special ammo types which can be purchased for weapons. If a weapon fails an Ammo check while using limited ammo, they have run out – that ammo type is deleted from their fighter card, and cannot be used again until more of that special ammo is purchased from the Trading Post. This is in addition to the normal rules for the weapon running Out of Ammo. The weapon can still be reloaded as normal, using its remaining profile(s)."
  elsif a_question.match?(/MELEE/i)
    "This weapon can be used during close combat attacks."
  elsif a_question.match?(/MELTA/i)
    "If a Short range attack from a weapon with this Trait reduces a fighter to 0 wounds, no Injury dice are rolled – instead, any Injury dice that would be rolled cause an automatic Out of Action result."
  elsif a_question.match?(/PAIRED/i)
    "A fighter that is armed with Paired weapons counts as being armed with dual weapons with the Melee trait for the purposes of calculating the number of Attack dice they will roll. Additionally, when making a Charge (Double) action, their Attacks characteristic is doubled."
  elsif a_question.match?(/PARRY/i)
    "After an enemy makes close combat attacks against a fighter armed with a Parry weapon, the defending fighter’s owning player can force the attacking player to re-roll one successful hit. If the defending fighter is armed with two Parry weapons, their owning player can force the attacking player to re-roll two successful hits instead."
  elsif a_question.match?(/PLENTIFUL/i)
    "Ammunition for this weapon is incredibly common. When reloading it, no Ammo check is required – it is automatically reloaded."
  elsif a_question.match?(/POWER/i)
    "The weapon is surrounded by a crackling power field. Attacks made by Power weapons cannot be parried except by other Power weapons. In addition, if the hit roll for a Power weapon is a 6, no save roll can be made against the attack and its Damage is increased by 1."
  elsif a_question.match?(/PULVERISE/i)
    "After making an Injury roll for an attack made by this weapon, the attacking player can roll a D6. If the result is equal to or higher than the target's Toughness, or is a natural 6, they can change one Injury dice from a Flesh Wound result to a Serious Injury result."
  elsif a_question.match?(/rad( |-)phage/i)
    "After fully resolving any successful hits a fighter suffers from a weapon with this Trait, roll an additional D6. If the roll is a 4 or higher, the fighter will suffer an additional Flesh Wound."
  elsif a_question.match?(/RAPID FIRE/i)
    "When firing with a Rapid Fire weapon, a successful hit roll scores a number of hits equal to the number of bullet holes on the Firepower dice. In addition the controlling player can roll more than one Firepower dice, up to the number shown in brackets (for example, when firing a Rapid Fire (2) weapon, up to two firepower dice can be rolled). Make an Ammo check for each Ammo symbol that is rolled. If any of them fail, the gun runs Out of Ammo. If two or more of them fail, the gun has jammed and cannot be used for the rest of the battle.\n
If a Rapid Fire weapon scores more than one hit, the hits can be split between multiple targets. The first must be allocated to the initial target, but the remainder can be allocated to other fighters within 3’’ of the first who are also within range and line of sight. These must not be any harder to hit than the original target – if a target in the open is hit, an obscured target cannot have hits allocated to it. Allocate all of the hits before making any wound rolls."
  elsif a_question.match?(/RECKLESS/i)
    "Reckless weapons are indiscriminate in what they target. Weapons with this Trait ignore the normal target priority rules. Instead, before making an attack with a weapon with this Trait, randomly determine the target of the attack from all eligible models within the fighter’s line of sight."
  elsif a_question.match?(/RENDING/i)
    "If the roll to wound with a Rending weapon is a natural 6 the attack causes 1 extra point of damage."
  elsif a_question.match?(/SCARCE/i)
    "Ammunition is hard to come by for Scarce weapons, and as such they cannot be reloaded – once they run Out of Ammo, they cannot be used again during the battle."
  elsif a_question.match?(/SCATTERSHOT/i)
    "When a target is hit by a scattershot attack, make D6 wounds roll instead of 1."
  elsif a_question.match?(/SEISMIC/i)
    "If the target of a Seismic attack is Active, they are always Pinned – even if they have an ability that would normally allow them to avoid being Pinned by ranged attacks. In addition, if the wound roll for a Seismic weapon is a natural 6, no save roll can be made against that attack."
  elsif a_question.match?(/SEVER/i)
    "If a wound roll from a weapon with this Trait reduces a fighter to 0 wounds, no Injury dice are rolled – instead, any Injury dice that would be rolled cause an automatic Out of Action result."
  elsif a_question.match?(/SHIELD( |)BREAKER/i)
    "Weapons with this Trait ignore the effects of the Assault Shield/Energy Shield trait. In addition, when a target equipped with Field Armour is wounded by a weapon with this Trait, they must roll two dice when making a Field Armour save and choose the lower result."
  elsif a_question.match?(/SHOCK/i)
    "If the hit roll for a Shock weapon is a natural 6, the wound roll is considered to automatically succeed (no wound roll needs to be made)"
  elsif a_question.match?(/SHRED/i)
    "If the roll to wound with a weapon with this trait is a natural 6, then the Armour Penetration of the weapon is doubled."
  elsif a_question.match?(/SIDEARM/i)
    "Weapons with this Trait can be used to make ranged attacks, and can also be used in close combat to make a single attack. Note that their Accuracy bonus only applies when making a ranged attack, not when used to make a close combat attack."
  elsif a_question.match?(/SILENT/i)
    "In scenarios that use the Sneak Attack special rules, there is no test to see whether the alarm is raised when this weapon is fired. Additionally, if using the Pitch Black rules, a fighter using this weapon that is Hidden does not become Revealed."
  elsif a_question.match?(/SINGLE SHOT/i)
    "This weapon can only be used once per game. After use it counts as having automatically failed an Ammo Check. There is no need to roll the Firepower dice unless the weapon also has the Rapid Fire (X) trait."
  elsif a_question.match?(/SMOKE/i)
    "Smoke weapons do not cause hits on fighters – they do not cause Pinning and cannot inflict Wounds. Instead, mark the location where they hit with a counter. They generate an area of dense smoke, which extends 2.5\" out from the centre of the counter; a 5’’ Blast marker can be used to determine this area, but it should be considered to extend vertically as well as horizontally. Fighters can move through the smoke, but it blocks line of sight, so attacks cannot be made into, out of or through it. In the End phase, roll a D6. On a 4 or less, the cloud dissipates and the counter is removed."
  elsif a_question.match?(/template/i)
    "Template weapons use the Flame template to determine how many targets they hit."
  elsif a_question.match?(/TOXIN/i)
    "Instead of making a wound roll for a Toxin attack, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, make an Injury roll for them (regardless of their Wounds characteristic). If the roll is lower than the target’s Toughness, they shrug off the toxin’s effects."
  elsif a_question.match?(/UNSTABLE/i)
    "If the Ammo Symbol is rolled on the Firepower dice when attacking with this weapon, there is a chance the weapon will overheat in addition to needing an Ammo check. Roll a D6. On a 1, 2 or 3, the weapon suffers a catastrophic overload and the attacker is taken Out of Action. The attack is still resolved against the target."
  elsif a_question.match?(/UNWIELDY/i)
    "A Shoot action made with this weapon counts as a Double action as opposed to a Single action. In addition, a fighter who uses a weapon with both the Unwieldy and Melee traits in close combat cannot use a second weapon at the same time – this one requires both hands to use."
  elsif a_question.match?(/VERSATILE/i)
    "The wielder of a Versatile weapon does not need to be in base contact with an enemy fighter in order to Engage them in melee during their activation. They may Engage and make close combat attacks against an enemy fighter during their activation, so long as the distance between their base and that of the enemy fighter is equal to or less than the distance shown for the Versatile weapon’s Long range characteristic. For example, a fighter armed with a Versatile weapon with a Long range of 2\" may Engage an enemy fighter that is up to 2\" away.\n
The enemy fighter is considered to be Engaged, but may not in turn be Engaging the fighter armed with the Versatile weapon unless they too are armed with a Versatile weapon, and so may not be able to make Reaction attacks.\n
At all other times other than during this fighter’s activation, Versatile has no effect."
  elsif a_question.match?(/WEB/i)
    "If the wound roll for a Web attack is successful, no wound is inflicted, and no save roll or Injury roll is made. Instead, the target automatically becomes Webbed. Treat the fighter as if they were Seriously Injured and roll for Recovery for them during the End phase (Web contains a powerful sedative capable of rendering the strongest fighter unconscious). If a Flesh Wound result is rolled during Recovery, apply the result to the fighter as usual and remove the Webbed condition. If a Serious Injury is rolled, the fighter remains Webbed. If an Out of Action result is rolled, the fighter succumbs to the powerful sedative and is removed from play, automatically suffering a result of 12-26 (Out Cold) on the Lasting Injuries table.\n
A fighter that is Webbed at the end of the game does not succumb to their Injuries and will automatically recover. However, during the Wrap Up, when rolling to determine if any enemy fighters are Captured at the end of the game, add +1 to the dice roll for each enemy fighter currently Webbed and include them among any eligible to be Captured."

  # SKILLS
  # AGILITY
  elsif a_question.match?(/CATFALL/i)
    "When this fighter falls or jumps down from a ledge, they count the vertical distance moved as being half of what it actually is, rounded up. In addition, if they are not Seriously Injured, or taken Out of Action by a fall, make an Initiative test for them – if it is passed, they remain Standing rather than being Prone and Pinned."
  elsif a_question.match?(/CLAMBER/i)
    "When the fighter climbs, the vertical distance they move is not halved. In other words, they always count as climbing up or down a ladder."
  elsif a_question.match?(/DODGE/i)
    "If this fighter suffers a wound from a ranged or close combat attack, roll a D6. On a 6, the attack is dodged and has no further effect; otherwise, continue to make a save or resolve the wound as normal.\n
If the model dodges a weapon that uses a Blast marker or Flame template, a roll of 6 does not automatically cancel the attack – instead, it allows the fighter to move up to 2\" before seeing if they are hit. They cannot move within 1\" of an enemy fighter."
  elsif a_question.match?(/MIGHTY LEAP/i)
    "When measuring the distance of a gap this fighter wishes to leap across, ignore the first 2\" of the distance. This means that a fighter with this skill may leap over gaps of 2\" or less without testing against their Initiative. All other rules for leaping over gaps still apply."
  elsif a_question.match?(/SPRING UP/i)
    "If this fighter is Pinned when they are activated, make an Initiative check for them. If the check is passed the fighter can make a Stand Up (Basic) action for free. If the check is failed, the fighter may still stand up, but it costs one action, as usual."
  elsif a_question.match?(/SPRINT/i)
    "If this fighter makes two Move (Simple) actions when activated during a round, they can use the second to Sprint. This lets them move at double their Movement characteristic for the second Move (Simple) action."
  # BRAWN
  elsif a_question.match?(/BULL( |-|)CHARGE/i)
    "When this fighter makes close combat attacks as part of a Charge (Double) action, any weapons with the Melee trait they use gain the Knockback Trait and are resolved at +1 Strength."
  elsif a_question.match?(/BULGING BICEPS/i)
    "This fighter may wield an Unwieldy weapon in one hand rather than the usual two. Note that Unwieldy weapons still take up the space of two weapons with regards to how many a fighter may carry."
  elsif a_question.match?(/CRUSHING BLOW/i)
    "Before rolling to hit for the fighter's close combat attacks, the controlling player can nominate one dice to make a Crushing Blow. This cannot be a dice that is rolling for a weapon with the Sidearm trait. If that dice hits, the attack’s Strength and Damage are each increased by one."
  elsif a_question.match?(/HEADBUTT/i)
    "If the fighter is Standing and Engaged, they can make the following action:\n
Headbutt (Basic) – Pick an Engaged enemy fighter and roll two d6. If either result is equal to or higher than their Toughness, they suffer a hit with a Strength equals to this fighter's Strength +2 resolved at Damage 2. However, if both dice score lower than the enemy fighter's Toughness, this fighter instead suffers a hit equal to their own Strength, resolved at Damage 1."
  elsif a_question.match?(/HURL/i)
    "If the fighter is Standing and Engaged, they can make the following action:\n
Hurl (Basic) – Pick an enemy fighter Engaged by, and in base contact with this fighter or a Seriously Injured enemy fighter within 1’’ of this fighter. Make an Initiative check for the enemy fighter. If failed, the enemy fighter is hurled. Move the enemy fighter d3\" in a direction of your choice – if they were Standing, they become Prone and Pinned after moving. If they come into base contact with a Standing fighter or any terrain, they stop moving and suffer a Strength 3, Damage 1 hit. If they come into base contact with another fighter, that fighter also suffers a Strength 3, Damage 1 hit, and becomes Prone and Pinned."
  elsif a_question.match?(/IRON( |)JAW/i)
    "This fighter's Toughness is treated as being two higher than normal when another fighter makes unarmed attacks against them in close combat."
  # COMBAT
  elsif a_question.match?(/COMBAT(-| )MASTER/i)
    "The fighter never suffers penalties to their hit rolls for interference, and can always grant assists, regardless of how many enemy fighters they are Engaged with."
  elsif a_question.match?(/COUNTER(-| |)ATTACK/i)
    "When this fighter makes Reaction attacks in close combat, they roll one additional Attack dice for each of the attacker’s Attacks that failed to hit (whether they missed, were parried, etc)"
  elsif a_question.match?(/DISARM/i)
    "Any weapons with the Melee trait used by the fighter also gain the Disarm Trait. If a weapon already has this Trait, then the target will be disarmed on a natural roll of 5 or 6, rather than the usual 6."
  elsif a_question.match?(/PARRY/i)
    "The fighter can parry attacks as though they were carrying a weapon with the Parry Trait. If they already have one or more weapons with this Trait, they can parry one additional attack."
  elsif a_question.match?(/RAIN OF BLOWS/i)
    "This fighter treats the Fight action as Fight (Simple) rather than Fight (Basic). In other words, this fighter may make two Fight (Simple) actions when activated."
  elsif a_question.match?(/STEP ASIDE/i)
    "If the fighter is hit in close combat, the fighter can attempt to step aside. Make an Initiative check for them. If the check is passed, the attack misses. This skill can only be used once per enemy in each round or close combat – in other words, if an enemy makes more than one attack, the fighter can only attempt to step aside from one of them."
  # CUNNING
  elsif a_question.match?(/BACKSTAB/i)
    "Any weapons used by this fighter with the Melee trait also gain the Backstab Trait. If they already have this Trait, add 2 to the attacker's Strength rather than the usual 1 when the Trait is used."
  elsif a_question.match?(/ESCAPE ARTIST/i)
    "When this fighter makes a Retreat (Basic) action, add 2 to the result of the Initiative check (a natural 1 still fails). Additionally, if this fighter is Captured at the end of a battle, and if they are equipped with a skin blade, they may add 1 to the result of the dice roll to see if they can escape."
  elsif a_question.match?(/EVADE/i)
    "If an enemy targets this fighter with a ranged attack, and this fighter is Standing and Active and not in partial cover or full cover, there is an additional -1 modifier to the hit roll, or a -2 modifier if the attack is at Long range."
  elsif a_question.match?(/INFILTRATE/i)
    "If this fighter should be set up at the start of a battle, they may instead placed to one side. Then, immediately before the start of the first round, their controlling player may set them up anywhere on the battlefield that is not visible to any enemy fighters, and not within 6\" of any of them. If both players have fighters with this skill, take turns to set one up, starting with the winner of a roll-off."
  elsif a_question.match?(/LIE LOW/i)
    "While this fighter is Prone, enemy fighters cannot target them with a ranged attack unless they are within the attacking weapon's Short range. Weapons that do not have a Short range are unaffected by this rule."
  elsif a_question.match?(/OVERWATCH/i)
    "If this fighter is Standing and Active, and has a Ready marker on them, they can interrupt a visible enemy fighter’s action as soon as it is declared, but before it is carried out. This fighter loses their Ready marker, then immediately makes a Shoot (Basic) action, targeting the enemy fighter whose action they have interrupted. If the enemy is Pinned or Seriously Injured as a result, their activation ends immediately – their action(s) are not made."
  # FEROCITY
  elsif a_question.match?(/BERSERKER/i)
    "When this fighter makes close combat attacks as part of a Charge (Double) action, they roll one additional Attack dice."
  elsif a_question.match?(/FEARSOME/i)
    "If an enemy wishes to make a Charge (Double) action that would result in them making one or more close combat attacks against this fighter, they must make a Willpower check before moving. If the check is failed, they cannot move and their activation ends immediately."
  elsif a_question.match?(/IMPETUOUS/i)
    "When this fighter consolidates at the end of a close combat, they can move up to 4\", rather than the usual 2\"."
  elsif a_question.match?(/NERVES OF STEEL/i)
    "When the fighter is hit by a ranged attack, make a Cool check for them. If it is passed, they may choose not to be Pinned."
  elsif a_question.match?(/TRUE GRIT/i)
    "When making an Injury roll for the fighter, roll one less Injury dice (for example, a Damage 2 weapon would roll one dice). Against attacks with Damage 1, roll two dice – the player controlling the fighter with True Grit, can then choose one dice to discard before the effects of the other are resolved."
  elsif a_question.match?(/UNSTOPPABLE/i)
    "Before making a Recovery test for this fighter in the End phase, roll a D6. If the result is 4 or more, one Flesh Wound they have suffered previously is discarded. If they do not have any Flesh Wounds, and the results is 4 or more, roll one additional dice for their Recovery check and choose one to discard."
  # LEADERSHIP
  elsif a_question.match?(/COMMANDING PRESENCE/i)
    "When this fighter activates to make a group activation, they may include one more fighter than normal as part of the group (ie, a Champion could activate two other fighters instead of one, and a Leader could activate three)."
  elsif a_question.match?(/INSPIRATIONAL/i)
    "If a friendly fighter within 6\" of this fighter fails a Cool check, make a Leadership check for this fighter. If the Leadership check is passed, then the Cool check also counts as having been passed."
  elsif a_question.match?(/IRON WILL/i)
    "Subtract 1 from the result of any Bottle rolls whilst this fighter is on the battlefield and is not Seriously Injured."
  elsif a_question.match?(/MENTOR/i)
    "Make a Leadership check for this fighter each time another friendly fighter within 6\" gains a point of Experience. If the check is passed, the other fighter gains two Experience instead of one."
  elsif a_question.match?(/OVERSEER/i)
    "If the fighter is Active, they can attempt to make the following action:\"
Order (Double) – Pick a friendly fighter within 6\". That fighter can immediately make two actions as though it were their turn to activate, even if they are not Ready. If they are Ready, these actions do not remove their Ready marker."
  elsif a_question.match?(/REGROUP/i)
    "If this fighter is Standing and Active at the end of their activation, the controlling player may make a Leadership check for them. If this check is passed, each friendly fighter that is currently subject to the Broken condition and within 6\" immediately recovers from being Broken."
  # SAVANT
  elsif a_question.match?(/BALLISTICS EXPERT/i)
    "When this fighter makes an Aim (Basic) action, make an Intelligence check for them. If the check is passed, they gain an additional +1 modifier to their hit roll."
  elsif a_question.match?(/CONNECTED/i)
    "This fighter can make a Trade action during the post-battle sequence, in addition to any other actions they make (meaning they could even make two Trade actions). They cannot do this if they are unable to make actions during the post-battle sequence."
  elsif a_question.match?(/SCAVENGER(\W|)(s|)(| )INSTINCT(s|)/i)
    "This fighter can make a Scavenge action during the post-battle sequence, in addition to any other actions they make (meaning they could even make two Scavenge actions). They cannot do this if they are unable to make actions during the post-battle sequence."
  elsif a_question.match?(/FIXER/i)
    "In the Receive Rewards step of the post-battle sequence, as long as the fighter is not Captured or In Recovery, their gang earns an additional d3x10 credits. Note that they do not need to have taken part in the battle to gain this bonus."
  elsif a_question.match?(/MEDICAE/i)
    "When this fighter assists a friendly fighter who is making a Recovery test, re-roll any Out of Action results. If the result is also Out of Action, the result stands."
  elsif a_question.match?(/MUNITIONEER/i)
    "Whenever an Ammo check is failed for this fighter or another fighter from their gang within 6\", it can be re-rolled."
  elsif a_question.match?(/SAVVY TRADER/i)
    "When this fighter makes a Trade action in the post-battle sequence, add 1 to the result of the dice roll to determine the availability of Rare items on offer at the Trading Post on this visit. Additionally, the cost of one item may be reduced by 20 credits on this visit. Note that this means one item, not one type of item. A single power sword may be purchased for 30 credits, but a second power sword will still cost 50 credits."
  elsif a_question.match?(/SAVVY SCAVENGER/i)
    "During the Damnation phase of an Uprising Campaign, while this fighter makes a Scavenge action, add 1 or 2 to the result of the dice roll on the Scavenging Table."
  # SHOOTING
  elsif a_question.match?(/FAST SHOT/i)
    "This fighter treats the Shoot action as (Simple) rather than (Basic), as long as they do not attack with a weapon that has the Unwieldy trait (note that even if a skill or wargear item allows a fighter to ignore one aspect of the Unwieldy trait, Unwieldy weapons retain the Trait)."
  elsif a_question.match?(/GUNFIGHTER/i)
    "If the fighter uses the Twin Guns Blazing rule to attack with two weapons with the Sidearm trait, they do not suffer the -1 penalty to their hit rolls and can, if they wish, target a different enemy model with each weapon with the Sidearm trait."
  elsif a_question.match?(/HIP(|-| )SHOOTING/i)
    "If the fighter is Standing and Active, they can make thefollowing action:\n
Run and Gun (Double) – The fighter may move up to double their Movement characteristic and then make an attack with a ranged weapons. The hit roll suffers an additional -1 modifier, and Unwieldy weapons can never be used in conjunction with this skill."
  elsif a_question.match?(/MARKSMAN/i)
    "The fighter is not affected by the rules for Target Priority. In addition, if the hit roll for an attack made by the fighter with a ranged weapon (that does not have the Blast trait) is a natural 6, they score a critical hit, and the weapon’s Damage is doubled (if they are firing a weapon with the Rapid Fire trait, only the Damage of the first hit is doubled)."
  elsif a_question.match?(/PRECISION SHOT/i)
    "If the hit roll for a ranged attack made by this fighter is a natural 6 (when using a weapon that does not have the Blast Trait), the shot hits an exposed area and no armour save can be made."
  elsif a_question.match?(/TRICK( |-|)SHOT/i)
    "When this fighter makes ranged attacks, they do not suffer a penalty for the target being Engaged or in partial cover. In addition, if the target is in full cover, they reduce the penalty to their hit roll to -1 rather than -2."
  # PALATINE DRILL
  elsif a_question.match?(/GOT YOUR (SIX|6)/i)
    "Once per round if this fighter is Standing and Active, as soon as a visible enemy fighter declares a Charge (Double) action but before it is carried out, this fighter may interrupt the enemy fighter’s Activation to perform a Shoot (Basic) action, targeting the enemy fighter whose action they have interrupted. If the enemy is Pinned or Seriously Injured as a result, their activation ends immediately, and their action(s) are not made."
  elsif a_question.match?(/HELMAWR(\W|)S JUSTICE/i)
    "When this fighter performs a Coup de Grace, they may roll twice on the Lasting Injury table and choose which result to apply."
  elsif a_question.match?(/NON(-|)VERBAL COMMUNICATION/i)
    "If this fighter is Standing and Active, they can attempt to make the following action:\n
Comms (Double): Pick a friendly fighter within 6\". That fighter can immediately make a Cool check. If the check is passed, their vision arc is extended to 360° until the End phase of this round."
  elsif a_question.match?(/RESTRAINT PROTOCOLS/i)
    "Rather than perform a Coup de Grace, this fighter may instead perform a Restrain (Simple) action:\n
Restrain (Simple): This fighter is adept at shackling their opponents, even in the heat of battle. Each time this fighter performs this action, make a note that they have restrained an enemy fighter. During the Wrap-up, add 1 to the dice roll to determine if an enemy fighter has been Captured for each enemy fighter that has been restrained."
  elsif a_question.match?(/TEAM( |)WORK/i)
    "When a fighter with this skill is activated, they may make a group activation as if they were a Champion. If this fighter is a Champion, they may activate two additional Ready fighters within 3\" of them at the start of their Activation, rather than the usual one. If this fighter is a Leader, they may activate three additional Ready fighters within 3\" of them at the start of their Activation, rather than the usual two."
  elsif a_question.match?(/THREAT RESPONSE/i)
    "If an enemy fighter ends their movement within 6\" of this fighter after performing a Charge (Double) action, and if this fighter is Standing and Active and has a Ready marker on them, this fighter may immediately activate and perform a Charge (Double) action, moving towards the charging enemy fighter. If at the end of this movement this fighter has Engaged the enemy fighter, they may immediately perform a Fight (Basic) action as normal for a fighter performing a Charge (Double) action. This activation interrupts the enemy fighter’s action, being performed after movement but before attacks. This fighter then loses their Ready marker."
  # SAVAGERY
  elsif a_question.match?(/AVATAR OF BLOOD/i)
    "For every unsaved wound this fighter inflicts on an enemy fighter with a weapon with the Melee trait, they may immediately discard one Flesh Wound they have previously suffered."
  elsif a_question.match?(/BLOOD(| )LUST/i)
    "After performing a Coup de Grace, this fighter may consolidate as well, moving up to 2\" in any direction."
  elsif a_question.match?(/CRIMSON HAZE/i)
    "If this fighter is Engaged with one or more enemy fighters, they automatically pass any Nerve tests they are required to take."
  elsif a_question.match?(/FRENZY/i)
    "When this fighter makes a Charge (Double) action, they gain an additional D3 Attacks. However, their hit rolls suffer a -1 modifier."
  elsif a_question.match?(/KILLING BLOW/i)
    "Before rolling to hit for the fighter’s close combat attacks, the controlling player can opt instead to make a single Killing Blow attack. This attack cannot be made with a weapon that has the Sidearm trait. If the attack hits, the attack’s Strength and Damage are doubled and no Armour Save roll can be made."
  elsif a_question.match?(/SLAUGHTERBORN/i)
    "For every unsaved wound this fighter inflicts on an enemy fighter with a weapon with the Melee trait, increase their Movement by 1\" for the duration of the battle"
  # FINESSE
  elsif a_question.match?(/ACROBATIC/i)
    "While this fighter is Active, they may ignore enemy fighters when making a Move (Simple) action or a Charge (Double) action. In effect, this allows them to move over other fighters. Note that they must still adhere to the 1\" rule once their movement is complete. This fighter may also cross any barricade or linear terrain feature up to 2\" high without a reduction in movement."
  elsif a_question.match?(/COMBAT FOCUS/i)
    "For every enemy fighter either Out of Action or Seriously Injured, place a token on this fighter’s Fighter card. This fighter adds 1 to their Willpower and Cool checks for each token on their Fighter card. Note that a result of 2 for either a Willpower or Cool check is still a failure regardless of modifiers."
  elsif a_question.match?(/COMBAT VIRTUOSO/i)
    "Any chainswords, fighting knives, power knives, power swords, stiletto knives and stiletto swords wielded by this fighter gain the Versatile trait with a Long range equal to this fighter’s Strength characteristic."
  elsif a_question.match?(/HIT AND RUN/i)
    "After making a Charge (Double) action, this fighter may make a Retreat (Basic) action for free before their opponent makes any reaction attacks. Note that even if the Retreat action is unsuccessful, this fighter’s opponent may only make reaction attacks once."
  elsif a_question.match?(/LIGHTNING REFLEXES/i)
    "When this fighter is Engaged by an enemy fighter, this fighter may attempt to make a Retreat (Basic) action for free before the enemy fighter makes any attacks or additional actions.\n
Whether or not the Retreat action was successful, this fighter may only use this skill once per round. Note that if this fighter has a Ready marker, they may still activate as normal."
  elsif a_question.match?(/SOMERSAULT/i)
    "This fighter gains the ability to perform the Somersault (Basic) action while they are Standing and Active:\n
Somersault (Basic) – Place the fighter anywhere within 6\" of their current position, provided they can see the point they wish to move to before they are placed. Note that the fighter must still adhere to the 1\" rule when being placed. Using this action does not count as moving for the purposes of effects that are triggered by movement and for the firing of weapons with the Unwieldy trait."
  # MUSCLE
  elsif a_question.match?(/fists of steel/i)
    "Unarmed attacks made by this fighter count as having a strength of 2 higher than normal and inflict 2 damage."
  elsif a_question.match?(/iron man/i)
    "This fighter's Toughness is not reduced by Flesh Wounds. However, if this fighter suffers a number of Flesh Wounds equal to their Toughness characteristic, they will go Out of Action as normal."
  elsif a_question.match?(/immovable stance/i)
    "This fighter may perform the Tank (Double) action during their activation:\n
Tank (Double) - Until the start of this fighter's next activation, this fighter increases their armour save by 2 to a maximum of 2+ and cannot be moved from their current location by any skills such as Hurl or Overseer, or any weapon traits such as Knockback or Drag, nor can they be Pinned."
  elsif a_question.match?(/na{1,6}rgah(|!)/i)
    "During this fighter's activation they may attempt to perform a third action after completing their first two. Roll a d6. If the dice roll is equal to or less than their Toughness then they perform the action. If the roll is greater thant their Toughtness, or is a 6, their activation ends immediately. Whether or not they were successful, when their activation ends, this fighter is automatically Pinned (this Pinning cannot be negated by skills such as Nerves of Steel)."
  elsif a_question.match?(/unleash the beast/i)
    "This fighter may perform the Flex (Simple) action while they are Active and Engaged:\n
Flex (Simple) - All fighters (friend or foe) in base contect with this fighter must pass a Strength check or be pushed d3\" directly away from this fighter, stopping only if they come into  contact with another fighter or an impassable terrain feature. If there are multiple enemies being pushed, the player controlling this fighter chooses in which order they are moved."
  elsif a_question.match?(/walk it off/i)
    "Should this fighter perform two or more Move (Simple) actions during their activation, they can make a Toughness check at the end of their activation. If this check is passed, this fighter may recover one lost Wound or discard a single Flesh Wound."

  # TERRITORIES
  elsif a_question.match?(/collapsed dome/i)
    "This Territory grants the following Boon:\n
Income: When collecting income from this Territory, the controlling player may choose to roll between 2D6x10 and 6D6x10. However, if a double is rolled, then no income is generated and a random fighter from the gang suffers a Lasting Injury."
  elsif a_question.match?(/corpse farm/i)
    "This Territory grants the following Boon:\n
Income: When collecting income, the gang gains D6x10 credits for every fighter on either side that was deleted from their roster during the Update Roster step of the preceding battle.\n
ENHANCED BOON
This Territory grants Cawdor gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Income: When collecting income, the gang gains 2D6x10 credits for every fighter on either side that was deleted from their roster during the Update Roster step of the preceding battle."
  elsif a_question.match?(/fighting pit/i)
    "This Territory grants the following Boon:\n
Recruit: Whilst it controls this Territory, the gang may recruit two Hive Scum Hired Guns for free, including their equipment, prior to every battle.\n
ENHANCED BOON
This Territory grants Goliath gangs the following Boon:\n
Reputation: Whilst it controls this Territory, the gang adds +2 to Its Reputation."
  elsif a_question.match?(/gambling den/i)
    "This Territory grants the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Income: The player chooses a suit of cards. The player then draws a card from the shuffled deck of playing cards that includes both Jokers. If they draw a card from the suit they chose, they earn income to the value of the card (Jack 11, Queen 12, King 13, Ace 14) x10 credits. If they draw a card from a suit of the same color, then the Income is the value of the card x5 credits. If it is any other suit they gain no income from the Territory. If, however, they draw a Joker, they must pay all of the income they earn in that post-battle sequence to a random gang taking part in the campaign, as determined by the Arbitrator.\n
ENHANCED BOON
This Territory grants Delaque gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\n
Special: The Delaque player that controls this Territory may nominate a single enemy fighter at the start of the battle. The Delaque have called in the fighter’s debt marker, and in return for keeping all of their limbs intact, the fighter agrees to take no part in the coming battle. The nominated fighter misses the battle."
  elsif a_question.match?(/generatorium/i)
    "This Territory grants the following Boon:\n
Special: If their gang controls this Territory, a player may choose to stall the generators, temporarily cutting the power to the area in which a battle is taking place and plunging it into darkness. The player may declare they will do this at the beginning of any Priority phase, before the roll for Priority.
For the remainder of the battle, the Pitch Black rules (see page 328) are in effect. However, at the start of each End phase, there is a chance that the generators will automatically restart and the light flood back. At the start of each End phase, before making any Bottle tests, the player that controls this Territory rolls a D6. If the result is a 5 or more, the generators restart and the Pitch Black rules immediately cease to be in effect. If the roll is a 1-4, the generators stay silent.\n
ENHANCED BOON
This Territory grants Van Saar gangs the following Boon:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation."
  elsif a_question.match?(/smelting works/i)
    "This Territory grants the following Boon:\n
Income: the gang earns D6x5 credits from this Territory when Collecting income.\n
ENHANCED BOON
This Territory grants Goliath gangs the following Boon:\n
Income: The gang earns D6x5 credits from this Territory when collecting income. If the gang also controls a Slag Furnace, this is increased to D6x10 credits."
  elsif a_question.match?(/stinger mould sprawl/i)
    "This Territory grants the following Boon:\n
Special: During the post-battle sequence, the gang controlling this Territory may re-roll a Single Lasting Injury roll on a fighter. Note that a Memorable Death result may not be re-rolled.\n
ENHANCED BOON
This Territory grants Escher gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Special: An Escher gang may either (1) remove a single existing Lasting Injury from a fighter, or (2) re-roll a single Lasting Injury roll on a fighter, including a Memorable Death result."
  elsif a_question.match?(/wastes/i)
    "This Territory grants the following Boons:\n
Special: If challenged in the Occupation phase, the gang may choose the Territory at stake in the battle, even though it would normally be chosen by the challenger. If challenged in the Takeover phase for a Territory the gang already controls, make an Intelligence check for the gang Leader. If the check is passed, the player of the gang may choose to play the Ambush scenario instead of rolling. They are automatically the attacker."

  # RACKETS
  elsif a_question.match?(/narco( |-)distribution/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Ghast Prospecting.\n\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\nSpecial: Whilst it controls this Racket, the gang treats Chem-synth, Medicae Kit, Stimm-slug Stash, and any weapon with the Gas or Toxin trait as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/OUT( |-)HIVE SMUGGLING ROUTES/i)
    "Linked Rackets: Ghast Prospecting, The Cold Trade.\n\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/GHAST PROSPECTING/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Caravan Route Control.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, three fighters in the gang gain a dose of Ghast each battle for free.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 4D6x10 credits when they collect Income."
  elsif a_question.match?(/THE COLD TRADE/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Spire Patronage.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, one member of the gang may have a single item from the Xenos Weapons section of the Black Market for free.\nSpecial: Whilst it controls this Racket, the gang treats items from the Xenos Weapons section of the Black Market as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income."
  elsif a_question.match?(/LIFE COIN EXCHANGE/i)
    "Linked Rackets: Whisper Brokers, Corpse Guild Bond.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang may recruit two Hive Scum or one Bounty Hunter Hired Gun for free, including their equipment, prior to every battle.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, all of its members gain the Fearsome skill."
  elsif a_question.match?(/XENOS BEAST TRAFFICKING/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Blood Pits.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, the gang Leader may be equipped with either a Grapplehawk or a Gyrinx Cat from the Black Market free of charge.\nSpecial: Whilst it controls this Racket, the gang treats Grapplehawks and Gyrinx Cats from the Black Market as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income."
  elsif a_question.match?(/WHISPER BROKERS/i)
    "Linked Rackets: Life Coin Exchange, Peddlers of Forbidden Lore.\n\nRACKET BOONS\nSpecial: Whilst it controls this racket, the gang may choose an additional D3 Tactics cards in the pre-battle sequence.\n\nENHANCED BOONS\nSpecial: If the gang also controls one of the Linked Rackets, when challenged, the gang may choose the Racket that will be at stake in the battle, even though it would normally be chosen by the challenger.\nSpecial: If the gang also controls both of the Linked Rackets, when challenged for a Racket the gang controls, make an Intelligence check for the gang Leader. If the check is passed, the player of the gang may choose to play the Ambush scenario instead of rolling. They are automatically the attacker."
  elsif a_question.match?(/CORPSE GUILD BOND/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Corpse Guild and may always add a Corpse Harvesting Party to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by 1 for every other Racket the gang controls."
  elsif a_question.match?(/SLAVE GUILD BOND/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Slave Guild and may always add a Slaver Entourage to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/PROMETHIUM GUILD BOND/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Promethium Guild and may always add a Pyromantic Conclave to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/GUILD OF COIN BOND/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Guild of Coin and may always add Toll Collectors to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/WATER GUILD BOND /i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Water Guild and may always add a Nautican Syphoning Delegation to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/ARCHAEOTECH AUCTIONING/i)
    "Linked Rackets: Proxies of the Omnissiah, The Cold Trade.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, one member of the gang may have a single item from the Imperial Weapons section of the Black Market for free.\nIncome: Whilst it controls this Racket, the gang gains 2D6x10 credits when they collect Income. If a double is rolled, they gain nothing.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income. However, if a double is rolled, they gain nothing.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 4D6x10 credits when they collect Income. However, if a double is rolled, they gain nothing."
  elsif a_question.match?(/WITCH SEEKING/i)
    "Linked Rackets: Redemptionist Backers, Slave Guild Bond.\n\nRACKET BOONS\nSpecial: This Racket may only be controlled by a Law Abiding gang. If it is claimed by an Outlaw gang, it is converted into a Wyrd Trade Racket.\nSpecial: Whilst it controls this Racket, all fighters in the gang may add the Shock trait to one of their weapons that has the Melee trait for free.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang doubles the bounty it receives for any fighter that is a Psyker, even if that fighter has become a Psyker temporarily due to the effects of Ghast.\nIncome: If the gang also controls both of the Linked Rackets, the gang Leader may make an Intelligence check before claiming a bounty. If the check is passed, they identify the captive as a witch and receive double the bounty for them."
  elsif a_question.match?(/REDEMPTIONIST BACKERS/i)
    "Linked Rackets: Promethium Guild Bond, Witch Seeking.\n\nRACKET BOONS\nSpecial: Helot Cult, Genestealer Cult and Corpse Grinder Cult gangs may never claim this Racket. If they gain control of it, it becomes dormant until claimed by a different type of gang.\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks for any weapon that has the Blaze trait.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/PROXIES OF THE OMNISSIAH/i)
    "Linked Rackets: Archaeotech Auctioning, Promethium Guild Bond.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks. Additionally, the gang treats all Bionics as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, all fighters in the gang may add either the Shock trait or the Seismic trait to one of their weapons for free. New weapons purchased later may also be given this Trait. These weapons also gain the Unstable trait. If the gang loses control of this Racket, the weapons that gained these additional Traits lose them."
  elsif a_question.match?(/GAMBLING EMPIRE/i)
    "Linked Rackets: Blood Pits, Whisper Brokers.\n\nRACKET BOONS\nIncome: The player of the gang that controls this Racket chooses a suit of cards and then draws a card from a shuffled deck of playing cards. If they draw a card from the suit they chose, they earn income equal to the value of the card (Jack 11, Queen 12, King 13) x 10 credits. If they draw a card from a suit of the same colour, they earn income equal to the value of the card x 5 credits. If it is any other suit, they gain no income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang’s player may nominate a single enemy fighter (but not a Leader or Champion) at the start of the battle. The gang has called in the fighter’s debts. The nominated fighter misses the battle."
  elsif a_question.match?(/BLOOD PITS/i)
    "Linked Rackets: Slave Guild Bond, Xenos Beast Trafficking.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang may recruit up to two Hive Scum Hired Guns for free, including their equipment, prior to every battle.\n\nENHANCED BOONS\nSpecial: If the gang also controls one of the Linked Rackets, as a post-battle action a Leader or Champion may fight in the pits. Make a Weapon Skill check with a -1 modifier for them. If the check is passed, they permanently gain one random Combat or Brawn skill. If the check is failed, nothing happens. If however the check is failed on the roll of a 1, the fighter suffers one roll on the Lasting Injury table.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/SPIRE PATRONAGE/i)
    "Linked Rackets: Proxies of the Omnissiah, Blood Pits.\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains 2D6x10 credits when they collect Income if they won their battle.\n\nENHANCED BOONS\nEquipment: If the gang also controls one of the Linked Rackets, all of the gang’s Leader and Champions may each have one of the following Extravagant Goods for free: Gold-plated Gun, Exotic Furs, Opulent Jewellery, Uphive Raiments.\nIncome: If the gang also controls both of the Linked Rackets, the gang’s Leader gains a Caryatid Exotic Beast for free. This Caryatid will not leave its master if the gang loses Reputation, but will leave if the gang loses control of this Racket."
  elsif a_question.match?(/BULLET CUTTING/i)
    "Linked Rackets: Proxies of the Omnissiah, Blood Pits.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks.\nEquipment: Whilst it controls this Racket, the gang treats all items from either the Trading Post or the Black Market with a Rarity of 9 or below as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/SETTLEMENT PROTECTION/i)
    "Linked Rackets: Guild Bond (any), Bullet Cutting.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang gains one Hanger-on of the controlling player’s choice for free.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/CARAVAN ROUTE CONTROL/i)
    "Linked Rackets: Guild of Coin Bond, The Cold Trade.\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/WYRD TRADE/i)
    "Linked Rackets: Peddlers of Forbidden Lore, Whisper Brokers.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, the gang treats Ghast as a Common item.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income"
  elsif a_question.match?(/PRODUCTION SKIMMING/i)
    "Linked Rackets: Caravan Route Control, Guild Bond (any).\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/RESURRECTION GAME/i)
    "Linked Rackets: Corpse Guild Bond, Peddlers of Forbidden Lore.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang may ignore one Critical Injury or Memorable Death result on the Lasting Injury table per battle. When these results are rolled, the fighter simply goes Into Recovery.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nSpecial: Any gang in the campaign may pay the gang controlling this Racket to return a dead fighter from the grave. This costs the original value of the fighter (including equipment) +100 credits. Roll 2D6. On a roll of 7-12 the fighter is resurrected and gains the Fearsome skill. On a roll of 3-6 the fighter is resurrected but suffers a permanent loss of 1 Toughness and gains the Fearsome skill if they don’t have it already. On a roll of 2, the resurrection fails."
  elsif a_question.match?(/PEDDLERS OF FORBIDDEN LORE/i)
    "Linked Rackets: Wyrd Trade, The Resurrection Game.\n\nRACKET BOONS\nSpecial: Whilst the gang controls this Racket, the controlling player may re-roll the dice when determining Priority.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nSpecial: Whilst the gang controls this Racket, its Leader and its all Champions gain a 4+ saving throw that cannot be modified by a weapon’s Armour Piercing value."



  elsif a_question.match?(/ROGUE DOC SHOP/i)
    "This Territory grants the following Boon:\nRecruit: The gang may recruit a Rogue Doc Hanger-on for free."
  elsif a_question.match?(/settlement/i)
    "This Territory grants the following Boons:\n
Income: The gang earns D6x10 credits from this Territory when collecting income.\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Recruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their House List for free."
  elsif a_question.match?(/slag furnace/i)
    "This Territory grants the following Boon:\nIncome: The gang-earns D6x5 credits from this Territory when collecting income.\nENHANCED BOON\nThis Territory grants Goliath gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nRecruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their House List for free."
  elsif a_question.match?(/tech bazaar/i)
    "This Territory grants the following Boons:\nIncome: The gang earns D6x10 credits from this Territory when collecting income.\nEquipment: Select one Leader or Champion to make a Haggle post-battle action. Roll 2D6: The gang may immediately choose one item from the Rare Trade chart with a Rare value equal to the result of the dice roll and add it to their Stash for half of its usual value, rounded down. If the roll is lower than 7, pick a Common Weapon or Piece of equipment to add to the gang's Stash for half of its usual value, rounded down. If the roll is 3 or lower, then the fighter proves to be very poor at haggling and no equipment is gained. If the fighter selected has Exotic Furs, add +1 to the result of the 2D6 dice roll.\nENHANCED BOON\nThis Territory grants Van Saar gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: The gang earns D6x10 credits from this Territory when collecting income. If the gang also controls an Archaeotech Device, this is increased to 2D6x10."
  elsif a_question.match?(/toll crossing/i)
    "This Territory grants the following Boon:\nIncome: The gang earns D6x5 credits from this Territory when collecting income.\nENHANCED BOON\nThis Territory grants Orlock gangs the following Boon:\nSpecial: Whilst it controls this Territory, an Orlock gang has Priority in the first round of any battle. Any gang in the campaign may pay the Orlock gang 20 credits to gain the same benefit in a single battle against another gang."
  elsif a_question.match?(/tunnels/i)
    "This Territory grants the following Boon:\nSpecial: Whist it controls this Territory, the gang may choose to have up to three fighters deploy via tunnels ahead of any battle. These fighters must be part of the crew for a battle, but instead of being set up on the battlefield, they are placed to one side. During the deployment phase, the player sets up two 2’’ wide tunnel entrance markers on any table edge on the ground surface of the battlefield. During the Priority phase of each turn, roll a D6. On a 4+, the group of fighters arrive on the battlefield. That turn they may be activated as a single group, and must move onto the battlefield from one of the tunnel entrance. If the battle ends before the fighters arrive, they take no part in the battle.\nENHANCED BOON\nThis Territory grants Orlock gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nSpecial: An Orlock gang may choose to deploy up to six fighters via tunnels using the method detailed above. The fighters in each group must be specified before the battle."









  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"
  # elsif a_question.match?(/pham/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # CONDITIONS
  elsif a_question.match?(/ACTIVE/i)
    "A Standing fighter is Active if they are not currently Engaged with any enemy fighters. This is the default Status for a fighter; Standing and Active, and such fighters enjoy the greatest freedom to perform actions."
  elsif a_question.match?(/ENGAGED/i)
    "If the base of a Standing fighter is touching the base of an enemy fighter, they are said to be in base to base contact and are Engaged with that enemy fighter. A Standing fighter that is Engaged can generally only choose to fight or retreat, but factors such as skills may increase the number of available options.\nPlayers should note that in some cases a fighter may be able to Engage an enemy fighter they are not in base to base contact with and may act accordingly when activated."
  elsif a_question.match?(/PRONE/i)
    "A fighter that is laid down is Prone. A Prone fighter has no facing and they effectively have no vision arc. Unless otherwise stated, Prone fighters never block line of sight – they are considered to be well out of the way of the action. A Prone fighter may be placed face-up or facedown, depending upon their Secondary Status.\nWhilst Prone, a fighter will always be subject to one of two Secondary Statuses as well; Pinned or Seriously Injured. This Secondary Status will affect the actions a Prone fighter may perform and the way in which other fighters may interact with them."
  elsif a_question.match?(/READY/i)
    "The most simple but arguably the most important Condition. At the start of each round, during the Priority phase, all fighters will have a Ready marker placed on them. Once that fighter has activated during the Action phase, this marker is removed, indicating that the fighter may not be activated again."
  elsif a_question.match?(/BROKEN/i)
    "A fighter may become Broken as the result of seeing a friendly fighter Seriously Injured or taken Out of Action within 3\" of them. Broken fighters may not perform any actions other than Running for Cover (Double) and if Engaged may only make Reaction attacks with a -2 modifier. They will make a Running for Cover (Double) action every time they are activated. Broken fighters may be rallied in the End phase.\nWhen a Broken fighter moves they must attempt to end their move, in order of priority:\n1. So that they are more than 3\" away from enemy fighters.\n2. So that they are out of line of sight of enemy fighters.\n3. In partial or full cover.\n4. As far away from any enemy fighters as possible.\nIf a Broken fighter is Standing and Engaged when activated, they must make an Initiative check. If it is passed, they must move as described previously. Each enemy fighter that is Engaged with them makes an Initiative check and if passed can make Reaction attacks before the Broken fighter is moved. If the Broken fighter fails the Initiative check, they remain Engaged and can perform no further actions."
  elsif a_question.match?(/(RUNNING|RUN) FOR COVER/i)
    "(DOUBLE): If the fighter is Standing and Active, they will move 2D6\". If the fighter is Prone and Pinned or Prone and Seriously Injured, they can only move half of their Movement characteristic."
  elsif a_question.match?(/OUT OF AMMO/i)
    "Should a fighter roll the Ammo symbol on the Firepower dice, they are required to make an immediate Ammo check for that weapon. If this is failed, that weapon is now Out of Ammo and a marker is placed on the appropriate weapon profile on their Fighter card as a reminder that the weapon cannot be used until it has been reloaded."
  elsif a_question.match?(/(INSANITY|INSANE)/i)
    "Fighters that have become subject to the Insane Condition for any reason can act quite erratically when activated. When activating an Insane fighter, roll a D6 and consult the table below:\n1-2: The fighter immediately becomes Broken – or, if they were already Broken, they flee the battlefield (even if their gang has not failed a Bottle test).\n3-4: The opposing player can control the Insane fighter for the duration of this activation, treating them as part of their gang in all respects until their activation ends. As soon as their activation ends, the Insane fighter no longer counts as being a part of the opposing gang. In the case of a multi-player game, the winner of a roll-off between the other players will control the Insane fighter.\n5-6: The fighter can act as normal. Once their activation is over, make a Willpower check for them. If it is passed, they lose their Insanity marker."

  # OTHER
  elsif a_question.match?(/pham/i)
    "++DONT YOU MEAN JONATHAN++"
  elsif a_question.match?(/JONATHAN/i)
    "Eyyyyyy, lookit Jonny Phambino ovah heah"
  else
    "++INVALID INPUT++"
  end
end

def send_bot_message(message, client, event)
  # Log prints
  p 'Bot message sent!'
  p event['replyToken']
  p client

  message = { type: 'text', text: message }
  p message

  client.reply_message(event['replyToken'], message)
  'OK'
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    p event
    # Focus on the message events (including text, image, emoji, vocal.. messages)
    next if event.class != Line::Bot::Event::Message

    case event.type
    # when receive a text message
    when Line::Bot::Event::MessageType::Text
      user_name = ''
      user_id = event['source']['userId']
      response = client.get_profile(user_id)
      if response.class == Net::HTTPOK
        contact = JSON.parse(response.body)
        p contact
        user_name = contact['displayName']
      else
        # Can't retrieve the contact info
        p "#{response.code} #{response.body}"
      end

      if event.message['text'].downcase == 'hello, world'
        # Sending a message when LINE tries to verify the webhook
        send_bot_message(
          'Everything is working!',
          client,
          event
        )
      else
        # The answer mechanism is here!
        send_bot_message(
          bot_answer_to(event.message['text'], user_name),
          client,
          event
        )
      end
      # when receive an image message
    when Line::Bot::Event::MessageType::Image
      response_image = client.get_message_content(event.message['id'])
      fetch_ibm_watson(response_image) do |image_results|
        # Sending the image results
        send_bot_message(
          "Looking at that picture, the first words that come to me are #{image_results[0..1].join(', ')} and #{image_results[2]}. Pretty good, eh?",
          client,
          event
        )
      end
    end
  end
  'OK'
end
