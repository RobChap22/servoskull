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

# weapon traits
# skills
# house bullshit
# territories
# rackets
# equipment
# armour
# field armour
# CGC masks
# weapon accessories
# status items
# chems
# conditions

def bot_answer_to(a_question, user_name)
  # If you want to add Bob to group chat, uncomment the next line
  # return '' unless a_question.downcase.include?('bob') # Only answer to messages with 'bob'

  # WEAPON TRAITS
  if a_question.match?(/^(assault|energy) shield$/i)
    "An assault/energy shield grants a +2 armour save modifier (to a maximum of 2+) against melee attacks that originate from within the fighter’s vision arc (the 90° arc to their front), and a +1 armour save modifier against ranged attacks that originate from within the fighter’s vision arc; check this before the fighter is placed Prone and is Pinned. If it is not clear whether the attacker is within the target’s front arc, use a Vision Arc template to check – if the centre of the attacker’s base is within the arc, the assault/energy shield can be used. Against attacks with the Blast trait, use the centre of the Blast marker in place of the attacker. If the target does not have a facing (for example, if they are Prone), the assault/energy shield cannot be used"
  elsif a_question.match?(/^BACKSTAB$/i)
    "If the attacker is not within the target’s vision arc, add 1 to the attack’s Strength."
  elsif a_question.match?(/^blaze$/i)
    "After an attack with the Blaze trait has been resolved, roll a D6 if the target was hit but not taken Out Of Action. On a 4, 5 or 6, they become subject to the Blaze condition.\n\nWhen activated, a fighter subject to the Blaze condition suffers an immediate Strength 3, AP -1, Damage 1 hit before acting as follows:\n\n- If Prone and Pinned the fighter immediately becomes Standing and Active and acts as described below.\n\n- If Standing and Active the fighter moves 2D6\" in a random direction, determined by the Scatter dice. The fighter will stop moving if this movement would bring them within 1\" of an enemy fighter or into base contact with impassable terrain. If this movement brings them within 1⁄2\" of the edge of a level or platform, they risk falling as described on page 29. If this movement takes the fighter beyond the edge of a level or platform, they will simply fall. At the end of this move, the fighter may choose to become Prone and Pinned. The fighter may then attempt to put the fire out.\n\n- If Standing and Engaged or Prone and Seriously Injured, the fighter does not move and attempts to put the fire out.\n\nTo attempt to put the fire out, roll a D6, adding 1 to the result for each other Active friendly fighter within 1\". On a result of 6 or more, the flames go out and the Blaze marker is removed. Pinned or Seriously Injured fighters add 2 to the result of the roll to see if the flames go out."
  elsif a_question.match?(/^burrowing$/i)
    "Burrowing weapons can be fired at targets outside of the firer’s line of sight. When firing at a target outside of line of sight do not make an attack roll, instead place the 3\" Blast marker anywhere on the battlefield, then move it 2D6\" in a direction determined by the Scatter dice. If a Hit is rolled on the Scatter dice, the Blast marker does not move. At the start of the End phase of the round in which this weapon was fired, before step 1, any fighters touched by the marker are hit by the weapon.\n\nNote that this Blast marker can move through impassable terrain such as walls and may move off the battlefield. If the Blast marker does move off the battlefield, the attack will have no effect. Burrowing weapons are capable of digging through several levels of wall and flooring, and can be used regardless of where the fighter is positioned on the battlefield."
  elsif a_question.match?(/^chem delivery$/i)
    "When a weapon with the Chem Delivery trait is used, the fighter declares what kind of chem they are firing at the target. This can be any chem the fighter is equipped with (note that firing the weapon does not cost a dose of the chem and that friendly fighters cannot be targeted), or if the weapon also has the Toxin or Gas trait, the fighter can use these Traits instead. Instead of making a Wound roll for a Chem Delivery attack, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, the target is affected by the chosen chem just as if they had taken a dose. If the roll is lower than the target’s Toughness, they shrug off the chem’s effects"
  elsif a_question.match?(/^combi$/i)
    "A combi-weapon has two profiles. When it is fired, pick one of the two profiles and use it for the attack. Due to the compact nature of the weapons, they often have less capacity for ammunition, and are prone to jams and other minor issues. When making an Ammo check for either of the weapons, roll twice and apply the worst result. However, unlike most weapons that have two profiles, ammo for the two parts of the combi-weapon are tracked separately – if one profile runs Out of Ammo, the other can still fire unless it has also run Out of Ammo"
  elsif a_question.match?(/^concussion$/i)
    "Any model hit by a Concussion weapon has their Initiative reduced by 2 to a minimum of 6+ until the end of the round."
  elsif a_question.match?(/^cursed$/i)
    "A fighter hit by a weapon with the Cursed trait must make a Willpower check or gain the Insane condition."
  elsif a_question.match?(/^defoliate$/i)
    "Carnivorous Plants hit by a weapon with the Defoliate Trait immediately take D3 Damage. Brainleaf Zombies hit by a weapon with the Defoliate Trait lose a wound and are removed from the battlefield if they suffer an Out of Action result on the Injury dice."
  elsif a_question.match?(/^demolitions$/i)
    "Grenade with the Demolitions trait can be used when making close combat attacks against scenery targets (such as locked doors or scenario objectives). A fighter who uses a grenade in this way makes one attack (regardless of how many Attack dice they would normally roll), which hits automatically."
  elsif a_question.match?(/^digi$/i)
    "A digi weapon is worn mounted on a ring or hidden inside a glove. It can be used in addition to any other Melee weapon or Pistol carried by the fighter granting either an additional shot or an additional close combat attack. A weapon with this trait does not count towards the maximum number of weapons a fighter can carry, however the maximum number of weapon with this trait a fighter can carry is 10."
  elsif a_question.match?(/^disarm$/i)
    "If the hit roll for an attack made with a Disarm weapon is a natural 6, the target cannot use any weapons when making Reaction attacks during that combat – they make unarmed attacks instead."
  elsif a_question.match?(/^drag$/i)
    "If a fighter is hit by a Drag weapon but not taken Out of Action, the attacker can attempt to drag the target closer after the attack has been resolved. If a they do, roll a d6. If the score is equal to or higher than the target’s Strength, the target is dragged D3’’ straight towards the attacker, stopping if they hit any terrain. If they move into another fighter (other than the attacker), both fighters are moved the remaining distance towards the attacker.\nIf the weapon also has the Impale special rule and hits more than one fighter, only the last fighter to be hit can be dragged."
  elsif a_question.match?(/^entangle$/i)
    "Hits scored by weapons with the Entangle trait cannot be negated by the Parry trait. In addition, if the hit roll for an Entangle weapon is a natural 6, any Reaction attacks made by the target have an additional -2 hit modifier"
  elsif a_question.match?(/^fear$/i)
    "Instead of making an Injury roll for an attack with the Fear trait, the opposing player makes a Nerve test for the target, subtracting 2 from the result. If the test fails, the target is immediately Broken and runs for cover."
  elsif a_question.match?(/^flare$/i)
    "A fighter who takes a hit from a weapon with the Flare Trait, or who is touched by a Blast marker fired from a weapon with the Flare Trait, is Revealed if the battlefield is in darkness (see Pitch Black). If a weapon has both the Flare Trait and the Blast Trait after determining where the Blast marker ends up, leave it in place. In the End phase, roll a D6. On a 4 or more, the flare goes out and the marker is removed, otherwise it remains in play. While the Blast marker is on the board, all models at least touched by it are illuminated as if they had a Blaze marker or a Revealed marker"
  elsif a_question.match?(/^flash$/i)
    "If a fighter is hit by a Flash weapon, no wound roll is made. Instead, make an Initiative check for the target. If it is failed, they are blinded. A blinded fighter loses their Ready marker; if they do not have a Ready marker, they do not gain a Ready marker at the start of the following round. Until the next time the fighter is activated, they cannot make any attacks other than reaction attacks, for which any hit rolls will only succeed on a natural 6."
  elsif a_question.match?(/^FORCE$/i)
    "In the hands of a non-psyker a Force Weapon has no additional effects. However, when weilded by a fighter with either the Sanctioned Psyker or Non-sanctioned Psyker special rule, the weapon gains both the Power and Sever traits."
  elsif a_question.match?(/^gas$/i)
    "When a fighter is hit by an attack made by a Gas weapon, they are not Pinned and a wound roll is not made.\nInstead, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, make an Injury roll for them (regardless of their Wounds characteristic). If the roll is lower than the target’s Toughness, they shrug off the effects of the gas – no save roll can be made."
  elsif a_question.match?(/^graviton pulse$/i)
    "Instead of rolling to wound normally with this weapon, any model caught in the blast must instead roll to or under their Strength on a D6 (a roll of 6 always counts as a fail).\n\nAfter the weapon has been fired, leave the Blast marker in place. For the remainder of the round, any model moving through this area will use 2’’ of their movement for every 1’’ they move. Remove the Blast marker during the End phase."
  elsif a_question.match?(/^grenade$/i)
    "Despite being Wargear, grenades are treated as a special type of ranged weapon. A fighter equipped with grenades can throw one as a Shoot (Basic) action. Grenades do not have a Short range, and their Long range is determined by multiplying the fighter’s Strength by the amount shown.\nA fighter can only carry a limited number of grenades.The Firepower dice is not rolled when attacking with a grenade. Instead, after the attack has been resolved, an Ammo check is made automatically. If this is failed, grenades cannot be reloaded; the fighter has run out of that type of grenade and cannot use them for the remainder of the battle."
  elsif a_question.match?(/^gunk$/i)
    "A fighter hit by a weapon with the Gunk Trait becomes subject to the Gunked condition. Gunked fighters reduce their Movement characteristic by 1 to a minimum of 1 and don’t add D3\" to their movement when making a Charge action. In addition, they subtract 1 from the dice roll when making an Initiative check. Gunked fighters are also more flammable and catch fire on a 2+, rather than a 4+, when hit by a weapon with the Blaze trait.\nThe Gunked condition lasts until the End phase or untilthe fighter catches fire after being hit by a weapon with the Blaze Trait"
  elsif a_question.match?(/^HEXAGRAMMATIC$/i)
    "The ammo used by this weapon has been specially treated to defeat psychic defences and severely harm Psykers. Hits from weapons with this Trait ignore saves provided by psychic powers. Additionally, weapons with this Trait will inflict double damage against Psykers."
  elsif a_question.match?(/^IMPALE$/i)
    "If an attack made by this weapon hits and wounds the target, and the save roll is unsuccessful (or no save roll is made), the projectile continues through them and might hit another fighter! Trace a straight line from the target, directly away from the attacker. If there are any fighters within 1\" of this line, and within the weapon's Long Range, the one that is closest to the target is at risk of being hit. Roll a D6 – on a 3 or more, resolve the weapon’s attack against that fighter, subtracting 1 from the Strength. The projectile can continue through multiple fighters in this way, but if the Strength is reduced to 0, it cannot hit any more fighters."
  elsif a_question.match?(/^KNOCKBACK$/i)
    "If the hit roll for a weapon with the Knockback trait is equal to or higher than the target’s Strength, they are immediately moved 1\" directly away from the attacking fighter. If the fighter cannot be moved the full 1\" because of impassable terrain or another fighter, they move as far as possible and the attack’s Damage is increased by 1.\n\nIf a Blast weapon has the Knockback trait, roll a D6 for each fighter that is hit. If the result is equal to or higher than their Strength, they are knocked back as described above – however, they are moved directly away from the centre of the Blast marker instead. If the centre of the Blast marker was over the centre of their base, roll a Scatter dice to determine which way they are moved.\n\nIf a Melee weapon has the Knockback trait, the attacking fighter can choose to follow the target up, moving directly towards them after they have been knocked back to remain in base contact. If the attack was made across a barricade, the attacker cannot do this.\n\nIf any part of the knocked back fighter's base crosses the edge of a platform, make an Initiative check. If this is failed, they will fall. If this is passed, they stop moving at the edge of the platform."
  elsif a_question.match?(/^LIMITED$/i)
    "This special rule is applied to some special ammo types which can be purchased for weapons. If a weapon fails an Ammo check while using limited ammo, they have run out – that ammo type is deleted from their fighter card, and cannot be used again until more of that special ammo is purchased from the Trading Post. This is in addition to the normal rules for the weapon running Out of Ammo. The weapon can still be reloaded as normal, using its remaining profile(s)."
  elsif a_question.match?(/^MASTER(-| |)CRAFTED$/i)
    "Once per battle, a fighter with a Master-crafted weapon may re-roll a single failed hit roll."
  elsif a_question.match?(/^MELEE$/i)
    "This weapon can be used during close combat attacks."
  elsif a_question.match?(/^MELTA$/i)
    "If a Short range attack from a weapon with this Trait reduces a fighter to 0 wounds, no Injury dice are rolled – instead, any Injury dice that would be rolled cause an automatic Out of Action result. If a weapon does not have a Short range, then the Melta trait affects all attacks made with this weapon."
  elsif a_question.match?(/^PAIRED$/i)
    "A fighter that is armed with Paired weapons counts as being armed with dual weapons with the Melee trait for the purposes of calculating the number of Attack dice they will roll. Additionally, when making a Charge (Double) action, their Attacks characteristic is doubled."
  elsif a_question.match?(/^PARRY$/i)
    "After an enemy makes close combat attacks against a fighter armed with a Parry weapon, the defending fighter’s owning player can force the attacking player to re-roll one successful hit. If the defending fighter is armed with two Parry weapons, their owning player can force the attacking player to re-roll two successful hits instead."
  elsif a_question.match?(/^PHASE$/i)
    "Save rolls granted by armour or field armour cannot be made against a weapon with this Trait. If the target is hit, treat them as having no save. Note, however, that saves granted by a special rule may still be made - this Trait only ignores armour and field armour. "
  elsif a_question.match?(/^PLENTIFUL$/i)
    "Ammunition for this weapon is incredibly common. When reloading it, no Ammo check is required – it is automatically reloaded."
  elsif a_question.match?(/^POWER$/i)
    "Attacks made by Power weapons cannot be parried except by other Power weapons.\n\nIn addition, if the hit roll for a Power weapon is a 6, no save roll can be made against the attack and its Damage is increased by 1."
  elsif a_question.match?(/^PULVERISE$/i)
    "After making an Injury roll for an attack made by this weapon, the attacking player can roll a D6. If the result is equal to or higher than the target's Toughness, or is a natural 6, they can change one Injury dice from a Flesh Wound result to a Serious Injury result."
  elsif a_question.match?(/^rad( |-)phage$/i)
    "After fully resolving any successful hits a fighter suffers from a weapon with this Trait, roll an additional D6. If the roll is a 4 or higher, the fighter will suffer an additional Flesh Wound."
  elsif a_question.match?(/^RAPID FIRE$/i)
    "When firing with a Rapid Fire weapon, a successful hit roll scores a number of hits equal to the number of bullet holes on the Firepower dice. In addition the controlling player can roll more than one Firepower dice, up to the number shown in brackets (for example, when firing a Rapid Fire (2) weapon, up to two firepower dice can be rolled). Make an Ammo check for each Ammo symbol that is rolled. If any of them fail, the gun runs Out of Ammo. If two or more of them fail, the gun has jammed and cannot be used for the rest of the battle.\n\nIf a Rapid Fire weapon scores more than one hit, the hits can be split between multiple targets. The first must be allocated to the initial target, but the remainder can be allocated to other fighters within 3’’ of the first who are also within range and line of sight. These must not be any harder to hit than the original target – if a target in the open is hit, an obscured target cannot have hits allocated to it. Allocate all of the hits before making any wound rolls."
  elsif a_question.match?(/^RECKLESS$/i)
    "Reckless weapons are indiscriminate in what they target. Weapons with this Trait ignore the normal target priority rules. Instead, before making an attack with a weapon with this Trait, randomly determine the target of the attack from all eligible models within the fighter’s line of sight."
  elsif a_question.match?(/^RENDING$/i)
    "If the roll to wound with a Rending weapon is a natural 6 the attack causes 1 extra point of damage."
  elsif a_question.match?(/^SCARCE$/i)
    "Ammunition is hard to come by for Scarce weapons, and as such they cannot be reloaded – once they run Out of Ammo, they cannot be used again during the battle."
  elsif a_question.match?(/^SCATTERSHOT$/i)
    "When a target is hit by a scattershot attack, make D6 wounds roll instead of 1."
  elsif a_question.match?(/^SEISMIC$/i)
    "If the target of a Seismic attack is Active, they are always Pinned – even if they have an ability that would normally allow them to avoid being Pinned by ranged attacks. In addition, if the wound roll for a Seismic weapon is a natural 6, no save roll can be made against that attack."
  elsif a_question.match?(/^SEVER$/i)
    "If a wound roll from a weapon with this Trait reduces a fighter to 0 wounds, no Injury dice are rolled – instead, any Injury dice that would be rolled cause an automatic Out of Action result."
  elsif a_question.match?(/^SHIELD( |)BREAKER$/i)
    "Weapons with this Trait ignore the effects of the Assault Shield/Energy Shield trait. In addition, when a target equipped with Field Armour is wounded by a weapon with this Trait, they must roll two dice when making a Field Armour save and choose the lower result."
  elsif a_question.match?(/^SHOCK$/i)
    "If the hit roll for a Shock weapon is a natural 6, the wound roll is considered to automatically succeed (no wound roll needs to be made)"
  elsif a_question.match?(/^SHRED$/i)
    "If the roll to wound with a weapon with this trait is a natural 6, then the Armour Penetration of the weapon is doubled."
  elsif a_question.match?(/^SIDEARM$/i)
    "Weapons with this Trait can be used to make ranged attacks, and can also be used in close combat to make a single attack. Note that their Accuracy bonus only applies when making a ranged attack, not when used to make a close combat attack."
  elsif a_question.match?(/^SILENT$/i)
    "In scenarios that use the Sneak Attack special rules, there is no test to see whether the alarm is raised when this weapon is fired. Additionally, if using the Pitch Black rules, a fighter using this weapon that is Hidden does not become Revealed."
  elsif a_question.match?(/^SINGLE SHOT$/i)
    "This weapon can only be used once per game. After use it counts as having automatically failed an Ammo Check. There is no need to roll the Firepower dice unless the weapon also has the Rapid Fire (X) trait."
  elsif a_question.match?(/^SMOKE$/i)
    "Smoke weapons do not cause hits on fighters – they do not cause Pinning and cannot inflict Wounds. Instead, mark the location where they hit with a counter. They generate an area of dense smoke, which extends 2.5\" out from the centre of the counter; a 5’’ Blast marker can be used to determine this area, but it should be considered to extend vertically as well as horizontally. Fighters can move through the smoke, but it blocks line of sight, so attacks cannot be made into, out of or through it. In the End phase, roll a D6. On a 4 or less, the cloud dissipates and the counter is removed."
  elsif a_question.match?(/^template$/i)
    "Template weapons use the Flame template to determine how many targets they hit."
  elsif a_question.match?(/^TOXIN$/i)
    "Instead of making a wound roll for a Toxin attack, roll a D6. If the result is equal to or higher than the target’s Toughness, or is a natural 6, make an Injury roll for them (regardless of their Wounds characteristic). If the roll is lower than the target’s Toughness, they shrug off the toxin’s effects."
  elsif a_question.match?(/^UNSTABLE$/i)
    "If the Ammo Symbol is rolled on the Firepower dice when attacking with this weapon, there is a chance the weapon will overheat in addition to needing an Ammo check. Roll a D6. On a 1, 2 or 3, the weapon suffers a catastrophic overload and the attacker is taken Out of Action. The attack is still resolved against the target."
  elsif a_question.match?(/^UNWIELDY$/i)
    "A Shoot action made with this weapon counts as a Double action as opposed to a Single action. In addition, a fighter who uses a weapon with both the Unwieldy and Melee traits in close combat cannot use a second weapon at the same time – this one requires both hands to use."
  elsif a_question.match?(/^VERSATILE$/i)
    "The wielder of a Versatile weapon does not need to be in base contact with an enemy fighter in order to Engage them in melee during their activation. They may Engage and make close combat attacks against an enemy fighter during their activation, so long as the distance between their base and that of the enemy fighter is equal to or less than the distance shown for the Versatile weapon’s Long range characteristic. For example, a fighter armed with a Versatile weapon with a Long range of 2\" may Engage an enemy fighter that is up to 2\" away.\n\nThe enemy fighter is considered to be Engaged, but may not in turn be Engaging the fighter armed with the Versatile weapon unless they too are armed with a Versatile weapon, and so may not be able to make Reaction attacks.\n\nAt all other times other than during this fighter’s activation, Versatile has no effect."
  elsif a_question.match?(/^WEB$/i)
    "If the wound roll for a Web attack is successful, no wound is inflicted, and no save roll or Injury roll is made. Instead, the target automatically becomes Webbed. Treat the fighter as if they were Seriously Injured and roll for Recovery for them during the End phase (Web contains a powerful sedative capable of rendering the strongest fighter unconscious). If a Flesh Wound result is rolled during Recovery, apply the result to the fighter as usual and remove the Webbed condition. If a Serious Injury is rolled, the fighter remains Webbed. If an Out of Action result is rolled, the fighter succumbs to the powerful sedative and is removed from play, automatically suffering a result of 12-26 (Out Cold) on the Lasting Injuries table.\n\nA fighter that is Webbed at the end of the game does not succumb to their Injuries and will automatically recover. However, during the Wrap Up, when rolling to determine if any enemy fighters are Captured at the end of the game, add +1 to the dice roll for each enemy fighter currently Webbed and include them among any eligible to be Captured."

  # SKILLS

  # AGILITY
  elsif a_question.match?(/^CATFALL$/i)
    "When this fighter falls or jumps down from a ledge, they count the vertical distance moved as being half of what it actually is, rounded up. In addition, if they are not Seriously Injured, or taken Out of Action by a fall, make an Initiative test for them – if it is passed, they remain Standing rather than being Prone and Pinned."
  elsif a_question.match?(/^CLAMBER$/i)
    "When the fighter climbs, the vertical distance they move is not halved. In other words, they always count as climbing up or down a ladder."
  elsif a_question.match?(/^DODGE$/i)
    "If this fighter suffers a wound from a ranged or close combat attack, roll a D6. On a 6, the attack is dodged and has no further effect; otherwise, continue to make a save or resolve the wound as normal.\n
If the model dodges a weapon that uses a Blast marker or Flame template, a roll of 6 does not automatically cancel the attack – instead, it allows the fighter to move up to 2\" before seeing if they are hit. They cannot move within 1\" of an enemy fighter."
  elsif a_question.match?(/^MIGHTY LEAP$/i)
    "When measuring the distance of a gap this fighter wishes to leap across, ignore the first 2\" of the distance. This means that a fighter with this skill may leap over gaps of 2\" or less without testing against their Initiative. All other rules for leaping over gaps still apply."
  elsif a_question.match?(/^SPRING UP$/i)
    "If this fighter is Pinned when they are activated, make an Initiative check for them. If the check is passed the fighter can make a Stand Up (Basic) action for free. If the check is failed, the fighter may still stand up, but it costs one action, as usual."
  elsif a_question.match?(/^SPRINT$/i)
    "If this fighter makes two Move (Simple) actions when activated during a round, they can use the second to Sprint. This lets them move at double their Movement characteristic for the second Move (Simple) action."
  # BRAWN
  elsif a_question.match?(/^BULL( |-|)CHARGE$/i)
    "When this fighter makes close combat attacks as part of a Charge (Double) action, any weapons with the Melee trait they use gain the Knockback Trait and are resolved at +1 Strength."
  elsif a_question.match?(/^BULGING BICEPS$/i)
    "This fighter may wield an Unwieldy weapon in one hand rather than the usual two. Note that Unwieldy weapons still take up the space of two weapons with regards to how many a fighter may carry."
  elsif a_question.match?(/^CRUSHING BLOW$/i)
    "Before rolling to hit for the fighter's close combat attacks, the controlling player can nominate one dice to make a Crushing Blow. This cannot be a dice that is rolling for a weapon with the Sidearm trait. If that dice hits, the attack’s Strength and Damage are each increased by one."
  elsif a_question.match?(/^HEADBUTT$/i)
    "If the fighter is Standing and Engaged, they can make the following action:\n
Headbutt (Basic) – Pick an Engaged enemy fighter and roll two d6. If either result is equal to or higher than their Toughness, they suffer a hit with a Strength equals to this fighter's Strength +2 resolved at Damage 2. However, if both dice score lower than the enemy fighter's Toughness, this fighter instead suffers a hit equal to their own Strength, resolved at Damage 1."
  elsif a_question.match?(/^HURL$/i)
    "If the fighter is Standing and Engaged, they can make the following action:\n
Hurl (Basic) – Pick an enemy fighter Engaged by, and in base contact with this fighter or a Seriously Injured enemy fighter within 1’’ of this fighter. Make an Initiative check for the enemy fighter. If failed, the enemy fighter is hurled. Move the enemy fighter d3\" in a direction of your choice – if they were Standing, they become Prone and Pinned after moving. If they come into base contact with a Standing fighter or any terrain, they stop moving and suffer a Strength 3, Damage 1 hit. If they come into base contact with another fighter, that fighter also suffers a Strength 3, Damage 1 hit, and becomes Prone and Pinned."
  elsif a_question.match?(/^IRON( |)JAW$/i)
    "This fighter's Toughness is treated as being two higher than normal when another fighter makes unarmed attacks against them in close combat."
  # COMBAT
  elsif a_question.match?(/^COMBAT(-| )MASTER$/i)
    "The fighter never suffers penalties to their hit rolls for interference, and can always grant assists, regardless of how many enemy fighters they are Engaged with."
  elsif a_question.match?(/^COUNTER(-| |)ATTACK$/i)
    "When this fighter makes Reaction attacks in close combat, they roll one additional Attack dice for each of the attacker’s Attacks that failed to hit (whether they missed, were parried, etc)"
  elsif a_question.match?(/^DISARM skill$/i)
    "Any weapons with the Melee trait used by the fighter also gain the Disarm Trait. If a weapon already has this Trait, then the target will be disarmed on a natural roll of 5 or 6, rather than the usual 6."
  elsif a_question.match?(/^PARRY SKILL$/i)
    "The fighter can parry attacks as though they were carrying a weapon with the Parry Trait. If they already have one or more weapons with this Trait, they can parry one additional attack."
  elsif a_question.match?(/^RAIN OF BLOWS$/i)
    "This fighter treats the Fight action as Fight (Simple) rather than Fight (Basic). In other words, this fighter may make two Fight (Simple) actions when activated."
  elsif a_question.match?(/^STEP ASIDE$/i)
    "If the fighter is hit in close combat, the fighter can attempt to step aside. Make an Initiative check for them. If the check is passed, the attack misses. This skill can only be used once per enemy in each round or close combat – in other words, if an enemy makes more than one attack, the fighter can only attempt to step aside from one of them."
  # CUNNING
  elsif a_question.match?(/^BACKSTAB skill$/i)
    "Any weapons used by this fighter with the Melee trait also gain the Backstab Trait. If they already have this Trait, add 2 to the attacker's Strength rather than the usual 1 when the Trait is used."
  elsif a_question.match?(/^ESCAPE ARTIST$/i)
    "When this fighter makes a Retreat (Basic) action, add 2 to the result of the Initiative check (a natural 1 still fails). Additionally, if this fighter is Captured at the end of a battle, and if they are equipped with a skin blade, they may add 1 to the result of the dice roll to see if they can escape."
  elsif a_question.match?(/^EVADE$/i)
    "If an enemy targets this fighter with a ranged attack, and this fighter is Standing and Active and not in partial cover or full cover, there is an additional -1 modifier to the hit roll, or a -2 modifier if the attack is at Long range."
  elsif a_question.match?(/^INFILTRATE$/i)
    "If this fighter should be set up at the start of a battle, they may instead placed to one side. Then, immediately before the start of the first round, their controlling player may set them up anywhere on the battlefield that is not visible to any enemy fighters, and not within 6\" of any of them. If both players have fighters with this skill, take turns to set one up, starting with the winner of a roll-off."
  elsif a_question.match?(/^LIE LOW$/i)
    "While this fighter is Prone, enemy fighters cannot target them with a ranged attack unless they are within the attacking weapon's Short range. Weapons that do not have a Short range are unaffected by this rule."
  elsif a_question.match?(/^OVERWATCH$/i)
    "If this fighter is Standing and Active, and has a Ready marker on them, they can interrupt a visible enemy fighter’s action as soon as it is declared, but before it is carried out. This fighter loses their Ready marker, then immediately makes a Shoot (Basic) action, targeting the enemy fighter whose action they have interrupted. If the enemy is Pinned or Seriously Injured as a result, their activation ends immediately – their action(s) are not made."
  # FEROCITY
  elsif a_question.match?(/^BERSERKER$/i)
    "When this fighter makes close combat attacks as part of a Charge (Double) action, they roll one additional Attack dice."
  elsif a_question.match?(/^FEARSOME$/i)
    "If an enemy wishes to make a Charge (Double) action that would result in them making one or more close combat attacks against this fighter, they must make a Willpower check before moving. If the check is failed, they cannot move and their activation ends immediately."
  elsif a_question.match?(/^IMPETUOUS$/i)
    "When this fighter consolidates at the end of a close combat, they can move up to 4\", rather than the usual 2\"."
  elsif a_question.match?(/^NERVES OF STEEL$/i)
    "When the fighter is hit by a ranged attack, make a Cool check for them. If it is passed, they may choose not to be Pinned."
  elsif a_question.match?(/^TRUE GRIT$/i)
    "When making an Injury roll for the fighter, roll one less Injury dice (for example, a Damage 2 weapon would roll one dice). Against attacks with Damage 1, roll two dice – the player controlling the fighter with True Grit, can then choose one dice to discard before the effects of the other are resolved."
  elsif a_question.match?(/^UNSTOPPABLE$/i)
    "Before making a Recovery test for this fighter in the End phase, roll a D6. If the result is 4 or more, one Flesh Wound they have suffered previously is discarded. If they do not have any Flesh Wounds, and the results is 4 or more, roll one additional dice for their Recovery check and choose one to discard."
  # LEADERSHIP
  elsif a_question.match?(/^COMMANDING PRESENCE$/i)
    "When this fighter activates to make a group activation, they may include one more fighter than normal as part of the group (ie, a Champion could activate two other fighters instead of one, and a Leader could activate three)."
  elsif a_question.match?(/^INSPIRATIONAL$/i)
    "If a friendly fighter within 6\" of this fighter fails a Cool check, make a Leadership check for this fighter. If the Leadership check is passed, then the Cool check also counts as having been passed."
  elsif a_question.match?(/^IRON WILL$/i)
    "Subtract 1 from the result of any Bottle rolls whilst this fighter is on the battlefield and is not Seriously Injured."
  elsif a_question.match?(/^MENTOR$/i)
    "Make a Leadership check for this fighter each time another friendly fighter within 6\" gains a point of Experience. If the check is passed, the other fighter gains two Experience instead of one."
  elsif a_question.match?(/^OVERSEER$/i)
    "If the fighter is Active, they can attempt to make the following action:\"
Order (Double) – Pick a friendly fighter within 6\". That fighter can immediately make two actions as though it were their turn to activate, even if they are not Ready. If they are Ready, these actions do not remove their Ready marker."
  elsif a_question.match?(/^REGROUP$/i)
    "If this fighter is Standing and Active at the end of their activation, the controlling player may make a Leadership check for them. If this check is passed, each friendly fighter that is currently subject to the Broken condition and within 6\" immediately recovers from being Broken."
  # SAVANT
  elsif a_question.match?(/^BALLISTICS EXPERT$/i)
    "When this fighter makes an Aim (Basic) action, make an Intelligence check for them. If the check is passed, they gain an additional +1 modifier to their hit roll."
  elsif a_question.match?(/^CONNECTED$/i)
    "This fighter can make a Trade action during the post-battle sequence, in addition to any other actions they make (meaning they could even make two Trade actions). They cannot do this if they are unable to make actions during the post-battle sequence."
  elsif a_question.match?(/^SCAVENGER(\W|)(s|)(| )INSTINCT(s|)$/i)
    "This fighter can make a Scavenge action during the post-battle sequence, in addition to any other actions they make (meaning they could even make two Scavenge actions). They cannot do this if they are unable to make actions during the post-battle sequence."
  elsif a_question.match?(/^FIXER$/i)
    "In the Receive Rewards step of the post-battle sequence, as long as the fighter is not Captured or In Recovery, their gang earns an additional d3x10 credits. Note that they do not need to have taken part in the battle to gain this bonus."
  elsif a_question.match?(/^MEDICAE$/i)
    "When this fighter assists a friendly fighter who is making a Recovery test, re-roll any Out of Action results. If the result is also Out of Action, the result stands."
  elsif a_question.match?(/^MUNITIONEER$/i)
    "Whenever an Ammo check is failed for this fighter or another fighter from their gang within 6\", it can be re-rolled."
  elsif a_question.match?(/^SAVVY TRADER$/i)
    "When this fighter makes a Trade action in the post-battle sequence, add 1 to the result of the dice roll to determine the availability of Rare items on offer at the Trading Post on this visit. Additionally, the cost of one item may be reduced by 20 credits on this visit. Note that this means one item, not one type of item. A single power sword may be purchased for 30 credits, but a second power sword will still cost 50 credits."
  elsif a_question.match?(/^SAVVY SCAVENGER$/i)
    "During the Damnation phase of an Uprising Campaign, while this fighter makes a Scavenge action, add 1 or 2 to the result of the dice roll on the Scavenging Table."
  # SHOOTING
  elsif a_question.match?(/^FAST SHOT$/i)
    "This fighter treats the Shoot action as (Simple) rather than (Basic), as long as they do not attack with a weapon that has the Unwieldy trait (note that even if a skill or wargear item allows a fighter to ignore one aspect of the Unwieldy trait, Unwieldy weapons retain the Trait)."
  elsif a_question.match?(/^GUNFIGHTER$/i)
    "If the fighter uses the Twin Guns Blazing rule to attack with two weapons with the Sidearm trait, they do not suffer the -1 penalty to their hit rolls and can, if they wish, target a different enemy model with each weapon with the Sidearm trait."
  elsif a_question.match?(/^HIP(|-| )SHOOTING$/i)
    "If the fighter is Standing and Active, they can make thefollowing action:\n
    Run and Gun (Double) – The fighter may move up to double their Movement characteristic and then make an attack with a ranged weapons. The hit roll suffers an additional -1 modifier, and Unwieldy weapons can never be used in conjunction with this skill."
  elsif a_question.match?(/^MARKSMAN$/i)
    "The fighter is not affected by the rules for Target Priority. In addition, if the hit roll for an attack made by the fighter with a ranged weapon (that does not have the Blast trait) is a natural 6, they score a critical hit, and the weapon’s Damage is doubled (if they are firing a weapon with the Rapid Fire trait, only the Damage of the first hit is doubled)."
  elsif a_question.match?(/^PRECISION SHOT$/i)
    "If the hit roll for a ranged attack made by this fighter is a natural 6 (when using a weapon that does not have the Blast Trait), the shot hits an exposed area and no armour save can be made."
  elsif a_question.match?(/^TRICK( |-|)SHOT$/i)
    "When this fighter makes ranged attacks, they do not suffer a penalty for the target being Engaged or in partial cover. In addition, if the target is in full cover, they reduce the penalty to their hit roll to -1 rather than -2."
  # PALATINE DRILL
  elsif a_question.match?(/^GOT YOUR (SIX|6)$/i)
    "Once per round if this fighter is Standing and Active, as soon as a visible enemy fighter declares a Charge (Double) action but before it is carried out, this fighter may interrupt the enemy fighter’s Activation to perform a Shoot (Basic) action, targeting the enemy fighter whose action they have interrupted. If the enemy is Pinned or Seriously Injured as a result, their activation ends immediately, and their action(s) are not made."
  elsif a_question.match?(/^HELMAWR(\W|)S JUSTICE$/i)
    "When this fighter performs a Coup de Grace, they may roll twice on the Lasting Injury table and choose which result to apply."
  elsif a_question.match?(/^NON(-|)VERBAL COMMUNICATION$/i)
    "If this fighter is Standing and Active, they can attempt to make the following action:\n
    Comms (Double): Pick a friendly fighter within 6\". That fighter can immediately make a Cool check. If the check is passed, their vision arc is extended to 360° until the End phase of this round."
  elsif a_question.match?(/^RESTRAINT PROTOCOLS$/i)
    "Rather than perform a Coup de Grace, this fighter may instead perform a Restrain (Simple) action:\n
    Restrain (Simple): This fighter is adept at shackling their opponents, even in the heat of battle. Each time this fighter performs this action, make a note that they have restrained an enemy fighter. During the Wrap-up, add 1 to the dice roll to determine if an enemy fighter has been Captured for each enemy fighter that has been restrained."
  elsif a_question.match?(/^TEAM( |)WORK$/i)
    "When a fighter with this skill is activated, they may make a group activation as if they were a Champion. If this fighter is a Champion, they may activate two additional Ready fighters within 3\" of them at the start of their Activation, rather than the usual one. If this fighter is a Leader, they may activate three additional Ready fighters within 3\" of them at the start of their Activation, rather than the usual two."
  elsif a_question.match?(/^THREAT RESPONSE$/i)
    "If an enemy fighter ends their movement within 6\" of this fighter after performing a Charge (Double) action, and if this fighter is Standing and Active and has a Ready marker on them, this fighter may immediately activate and perform a Charge (Double) action, moving towards the charging enemy fighter. If at the end of this movement this fighter has Engaged the enemy fighter, they may immediately perform a Fight (Basic) action as normal for a fighter performing a Charge (Double) action. This activation interrupts the enemy fighter’s action, being performed after movement but before attacks. This fighter then loses their Ready marker."
  # SAVAGERY
  elsif a_question.match?(/^AVATAR OF BLOOD$/i)
    "For every unsaved wound this fighter inflicts on an enemy fighter with a weapon with the Melee trait, they may immediately discard one Flesh Wound they have previously suffered."
  elsif a_question.match?(/^BLOOD(| )LUST$/i)
    "After performing a Coup de Grace, this fighter may consolidate as well, moving up to 2\" in any direction."
  elsif a_question.match?(/^CRIMSON HAZE$/i)
    "If this fighter is Engaged with one or more enemy fighters, they automatically pass any Nerve tests they are required to take."
  elsif a_question.match?(/^FRENZY$/i)
    "When this fighter makes a Charge (Double) action, they gain an additional D3 Attacks. However, their hit rolls suffer a -1 modifier."
  elsif a_question.match?(/^KILLING BLOW$/i)
    "Before rolling to hit for the fighter’s close combat attacks, the controlling player can opt instead to make a single Killing Blow attack. This attack cannot be made with a weapon that has the Sidearm trait. If the attack hits, the attack’s Strength and Damage are doubled and no Armour Save roll can be made."
  elsif a_question.match?(/^SLAUGHTERBORN$/i)
    "For every unsaved wound this fighter inflicts on an enemy fighter with a weapon with the Melee trait, increase their Movement by 1\" for the duration of the battle"
  # FINESSE
  elsif a_question.match?(/^ACROBATIC$/i)
    "While this fighter is Active, they may ignore enemy fighters when making a Move (Simple) action or a Charge (Double) action. In effect, this allows them to move over other fighters. Note that they must still adhere to the 1\" rule once their movement is complete. This fighter may also cross any barricade or linear terrain feature up to 2\" high without a reduction in movement."
  elsif a_question.match?(/^COMBAT FOCUS$/i)
    "For every enemy fighter either Out of Action or Seriously Injured, place a token on this fighter’s Fighter card. This fighter adds 1 to their Willpower and Cool checks for each token on their Fighter card. Note that a result of 2 for either a Willpower or Cool check is still a failure regardless of modifiers."
  elsif a_question.match?(/^COMBAT VIRTUOSO$/i)
    "Any chainswords, fighting knives, power knives, power swords, stiletto knives and stiletto swords wielded by this fighter gain the Versatile trait with a Long range equal to this fighter’s Strength characteristic."
  elsif a_question.match?(/^HIT AND RUN$/i)
    "After making a Charge (Double) action, this fighter may make a Retreat (Basic) action for free before their opponent makes any reaction attacks. Note that even if the Retreat action is unsuccessful, this fighter’s opponent may only make reaction attacks once."
  elsif a_question.match?(/^LIGHTNING REFLEXES$/i)
    "When this fighter is Engaged by an enemy fighter, this fighter may attempt to make a Retreat (Basic) action for free before the enemy fighter makes any attacks or additional actions.\nWhether or not the Retreat action was successful, this fighter may only use this skill once per round. Note that if this fighter has a Ready marker, they may still activate as normal."
  elsif a_question.match?(/^SOMERSAULT$/i)
    "This fighter gains the ability to perform the Somersault (Basic) action while they are Standing and Active:\n\nSomersault (Basic) – Place the fighter anywhere within 6\" of their current position, provided they can see the point they wish to move to before they are placed. Note that the fighter must still adhere to the 1\" rule when being placed. Using this action does not count as moving for the purposes of effects that are triggered by movement and for the firing of weapons with the Unwieldy trait."
  # MUSCLE
  elsif a_question.match?(/^fists of steel$/i)
    "Unarmed attacks made by this fighter count as having a strength of 2 higher than normal and inflict 2 damage."
  elsif a_question.match?(/^iron man$/i)
    "This fighter's Toughness is not reduced by Flesh Wounds. However, if this fighter suffers a number of Flesh Wounds equal to their Toughness characteristic, they will go Out of Action as normal."
  elsif a_question.match?(/^immovable stance$/i)
    "This fighter may perform the Tank (Double) action during their activation:\n
    Tank (Double) - Until the start of this fighter's next activation, this fighter increases their armour save by 2 to a maximum of 2+ and cannot be moved from their current location by any skills such as Hurl or Overseer, or any weapon traits such as Knockback or Drag, nor can they be Pinned."
  elsif a_question.match?(/^na{1,6}rgah(|!)$/i)
    "During this fighter's activation they may attempt to perform a third action after completing their first two. Roll a d6. If the dice roll is equal to or less than their Toughness then they perform the action. If the roll is greater thant their Toughtness, or is a 6, their activation ends immediately. Whether or not they were successful, when their activation ends, this fighter is automatically Pinned (this Pinning cannot be negated by skills such as Nerves of Steel)."
  elsif a_question.match?(/^unleash the beast$/i)
    "This fighter may perform the Flex (Simple) action while they are Active and Engaged:\n
    Flex (Simple) - All fighters (friend or foe) in base contect with this fighter must pass a Strength check or be pushed d3\" directly away from this fighter, stopping only if they come into  contact with another fighter or an impassable terrain feature. If there are multiple enemies being pushed, the player controlling this fighter chooses in which order they are moved."
  elsif a_question.match?(/^walk it off$/i)
    "Should this fighter perform two or more Move (Simple) actions during their activation, they can make a Toughness check at the end of their activation. If this check is passed, this fighter may recover one lost Wound or discard a single Flesh Wound."
  # BRAVADO
  elsif a_question.match?(/^BIG BROTHER$/i)
    "Whilst this fighter is Standing and Active, any friendly fighter with the Gang Fighter (X) special rule that is within 9\" and line of sight of this fighter may use this fighter’s Cool characteristic for Nerve tests instead of their own. "
  elsif a_question.match?(/^BRING IT ON(!|)$/i)
    "The fighter gains the ability to make the Issue Challenge (Basic) action:\n\nIssue Challenge (Basic) – Choose an enemy fighter within 12\". Until the end of this round, or until the chosen fighter is attacked by a friendly fighter, they must make a Willpower check if they wish to make a ranged or close combat attack that targets any fighter other than the fighter who issued the challenge (fighters that have been challenged ignore the normal rules for target priority as detailed in the Necromunda Rulebook)."
  elsif a_question.match?(/^GUILDER CONTACTS$/i)
    "Any Bounty Hunters and Hive Scum hired by this fighter’s gang (as detailed on ) will reduce their hiring fee by D6x10 credits to a minimum of 20 credits. Roll separately for each Bounty Hunter and Hive Scum hired."
  elsif a_question.match?(/^KING HIT$/i)
    "When making an unarmed attack (see the Necromunda Rulebook) this fighter may choose to roll a single Attack dice, irrespective of their Attacks characteristic or any other bonuses. If they choose to do so, the attack gains the Knockback, Shock, Pulverise and Concussion traits."
  elsif a_question.match?(/^SHOTGUN SAVANT$/i)
    "When armed with a shotgun of any type (including combat shotguns and sawn-off shotguns), this fighter may choose to use the shotgun’s Short range Accuracy modifier when making shots at Long range. In addition, when rolling the dice to determine the number of hits from a shotgun with the Scattershot trait, this fighter may roll two D6 and choose the highest."
  elsif a_question.match?(/^STEADY HANDS$/i)
    "When this fighter is activated, before declaring their first action, this fighter may perform a Reload (Simple) action for free. This does not prevent them from performing the same action once or twice more during their activation should they choose."
  # TECH
  elsif a_question.match?(/^COLD AND CALCULATING$/i)
    "Once per round, when making a Cool or Willpower check, this fighter may make the check against their Intelligence characteristic instead."
  elsif a_question.match?(/^GADGETEER$/i)
    "If this fighter is in the starting crew, prior to the first turn, they may modify the Weapon Traits of any weapon they carry that has the Plentiful trait. If they do so, until the end of the battle the weapon loses the Plentiful trait and gains one of the following, as chosen by the controlling player: Knockback, Pulverise, Rending or Shock. Alternatively, a Plentiful weapon with the Rapid Fire (X) trait can add one to the X value. E.g., a Rapid Fire (1) would become Rapid Fire (2)."
  elsif a_question.match?(/^MENTAL MASTERY$/i)
    "This fighter cannot become subject to the Insane condition. In addition, if this fighter is chosen as the target of a Wyrd Power, and is Standing and Active or Prone and Pinned, they may attempt to Disrupt the power as if they were a Psyker"
  elsif a_question.match?(/^PHOTONIC ENGINEER$/i)
    "This fighter may apply a +1 modifier to the Strength characteristic of all las weapons used by them. Doing so, however, causes the weapon to gain the Unstable trait. In addition, this fighter may re-roll failed Ammo checks with las weaponry, provided the weapon does not have the Unstable trait."
  elsif a_question.match?(/^RAD(-| )PHAGED$/i)
    "When this fighter is hit by a weapon with the Gas or Toxin traits, the opposing player must roll two D6 and discard the highest roll when rolling to see if this fighter is affected.\nIn addition, should this fighter suffer a hit from a weapon with the Rad-phage trait, roll an additional D6 as normal. However, on a roll of 4 or higher, they do not suffer an additional Flesh Wound. Instead, the fighter may discard a Flesh Wound they have already suffered.\nFinally, in any scenario that uses the Pitch Black rules, this fighter always counts as being Revealed."
  elsif a_question.match?(/^WEAPONSMITH$/i)
    "Any weapons this fighter is equipped with lose the Scarce trait if it has it. Any weapons this fighter is equipped with will gain the Plentiful trait if it does not have the Scarce trait. Weapons that already have the Plentiful trait gain no additional benefit from this skill."
  # OBFUSICATION
  elsif a_question.match?(/^FACELESS$/i)
    "From the start of each round until after this fighter has activated, enemy fighters must pass a Willpower check to target them with a ranged attack, or place a Blast marker so that it is touching their base. If the check is failed, the enemy fighter may choose another target."
  elsif a_question.match?(/^PSI(-| |)TOUCHED$/i)
    "The fighter may re-roll Willpower checks when attempting to activate Wyrd Powers or to resist them. When visiting the Black Market as part of the post- battle sequence, the fighter may always choose to purchase Ghast without the need to make an Availability roll."
  elsif a_question.match?(/^TAKE(-| |)DOWN$/i)
    "When this fighter takes an enemy fighter Out of Action, place that enemy fighter to one side. At the end of the battle, if this fighter’s gang has won the scenario, then instead of using the normal method for determining if enemy fighters are captured, roll a D6 for each enemy fighter that was taken Out of Action and placed aside by this fighter. On a 4+, this fighter has the choice of automatically capturing that enemy fighter. As normal, a gang cannot capture more than a single fighter after a battle."
  elsif a_question.match?(/^RUMOUR(-| |)MONGER$/i)
    "The fighter can perform the Despicable Rumours post- battle action during the post-battle actions step of the post-battle sequence:\n\nDespicable Rumours\nMake an Intelligence check for the fighter. If they pass, reduce the Reputation of the gang(s) they just faced by D3 and increase the Reputation of this fighter’s own gang by an equal amount."
  elsif a_question.match?(/^FAKE(-| |)OUT$/i)
    "When making the roll to determine the scenario during the pre-battle sequence, this fighter’s gang may roll three D6 rather than the usual two. One of these dice (chosen by the player) must be discarded."
  elsif a_question.match?(/^DOPPELGANGER$/i)
    "During the Select Crews step of the pre-battle sequence, this fighter’s gang may attempt to include an extra fighter than normally allowed by the scenario. Have the leader of the enemy gang make an Intelligence check. If they fail, this fighter’s gang may include one extra fighter in their starting crew."

  # HOUSE BULLSHIT

  # CHEM-ALCHEMY
  elsif a_question.match?(/^BAD BLOOD$/i)
    "When a fighter under the effects of this chem suffers one or more Wounds and/ or Flesh Wounds, all fighters in base contact with them must make an Initiative check. If this check is failed, they are considered to have taken a hit from a weapon with the Toxin trait."
  elsif a_question.match?(/^BLOOD RUSH$/i)
    "When this stimm is administered to a fighter, that fighter may remove a single Flesh Wound or immediately recover from being Seriously Injured."
  elsif a_question.match?(/^BRAIN LOCK$/i)
    "A fighter under the effects of this stimm counts as a Psyker for the purposes of disrupting enemy psychic powers (as described in the Necromunda Rulebook)."
  elsif a_question.match?(/^DREAMLAND$/i)
    "A fighter under the effects of this stimm ignores the effects of the Insane condition."
  elsif a_question.match?(/^HYPER$/i)
    "A fighter under the effects of this stimm increases their Movement characteristic by 2, and, when they take the Charge (Double) Action, they add D6\" to their movement rather than D3\". This increased level of hyper-activity makes them exceptionally twitchy, and they must reduce all their hit rolls by 1."
  elsif a_question.match?(/^ICE COLD$/i)
    "A fighter under the effects of this stimm adds 2 to any Cool checks they are required to make."
  elsif a_question.match?(/^JOLT$/i)
    "Until the end of the round in which this stimm was administered, a fighter under the effects of this stimm counts any Serious Injuries they suffer as Flesh Wounds."
  elsif a_question.match?(/^NIGHT NIGHT$/i)
    "When a fighter under the effects of this stimm goes Out of Action, do not roll for a Lasting Injury. Instead, the fighter counts as having rolled a result of 12-26 Out Cold on the Lasting Injury table. Note that the fighter may still be captured as normal."
  elsif a_question.match?(/^PUKE$/i)
    "A fighter under the effects of this stimm doubles their Toughness when testing to see if they are affected by weapons with the Toxin or Gas traits."
  elsif a_question.match?(/^WIDE(-| )EYE$/i)
    "A fighter under the effects of this stimm ignores the effects of the Pitch Black rules. In addition, if the fighter is a Sentry in a battle using the Sneak Attack rules (as described in the Necromunda Rulebook) then they always count enemy fighters as being ‘in the open’."
  elsif a_question.match?(/^ACIDIC$/i)
    "A fighter hit by a weapon with the Gas trait with this Gaseous Ammo applied does not benefit from armour or Wargear that would normally increase their Toughness against weapons with the Gas trait (i.e., respirators). Out of Action results on the Injury dice generated by hits from a weapon with the Gas trait with this Gaseous Ammo applied count as Seriously Injured results instead."
  elsif a_question.match?(/^BANE$/i)
    "A fighter hit by a weapon with the Gas trait with this Gaseous Ammo applied counts their Toughness as 3, regardless of their actual Toughness characteristic. Note that Wargear such as a respirator can still modify the fighter’s Toughness against Gas weapons as normal."
  elsif a_question.match?(/^BLACKOUT$/i)
    "If a fighter suffers a Serious Injury from a weapon with the Gas trait with this Gaseous Ammo applied, they are taken Out of Action, just as if they had rolled an Out of Action result. Fighters taken Out of Action by a weapon with the Gas trait with this Gaseous Ammo applied do not need to roll on the Lasting Injury table. Instead, the fighter counts as having rolled a result of 12-26 Out Cold on the Lasting Injury table."
  elsif a_question.match?(/^BLINDING$/i)
    "A fighter that suffers a Flesh Wound from a weapon with the Gas trait with this Gaseous Ammo applied becomes subject to the Blind condition until the End phase of the current round."
  elsif a_question.match?(/^EXPANSIVE$/i)
    "This Gaseous Ammo can only be applied to a weapon that has both the Gas and Blast (X\") traits. When placing a Blast marker generated by a weapon with the Gas trait with this Gaseous Ammo applied, a fighter may place one more Blast marker than normal. This marker must be placed so that it is touching at least one other Blast marker generated by this weapon."
  elsif a_question.match?(/^HALLUCINOGEN$/i)
    "A fighter hit by a weapon with the Gas trait with this Gaseous Ammo applied must make a Willpower check in addition to the Toughness check to resist the effects of being hit by a weapon with the Gas trait. If this Willpower check is failed, the fighter immediately becomes subject to the Insane condition."
  elsif a_question.match?(/^LEADEN$/i)
    "After resolving an attack using a weapon with the Gas trait with this Gaseous Ammo applied, place a 3\" Blast marker so that its central hole is within the area of the Flame template or Blast marker placed when making the attack. Any fighters that move through this Blast marker count as being hit by the weapon that made this attack (work out this hit when the fighter ends their current action). This Blast marker remains in play until the End phase of the current round."
  elsif a_question.match?(/^LIFTIN(’|G|)$/i)
    "This Gaseous Ammo can only be applied to a weapon that has both the Gas and Template traits. When making an attack using a weapon with the Gas trait with this Gaseous Ammo applied, the template may be placed up to 6\" away from the fighter making the attack. When placing the template, it must be positioned so the narrow end points directly towards the fighter making the attack. The wide end of the template must be the furthest part of the template from the fighter."
  elsif a_question.match?(/^PATHOGENIC$/i)
    "After a fighter is hit by a weapon with the Gas trait with this Gaseous Ammo applied, place a marker next to them. At the start of that fighter’s next activation, roll a D6. On a 3+, immediately remove this marker. On a roll of 1 or 2, the fighter immediately suffers the effects of the Gas trait, just as if they had been hit by the same weapon again."
  elsif a_question.match?(/^PYROPHORIC$/i)
    "A weapon with the Gas trait with this Gaseous Ammo applied gains the Blaze trait."
  elsif a_question.match?(/^BLEEDING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, and is not taken Out of Action, place a marker on their Fighter card. At the beginning of each End phase, each of these markers is removed and replaced with a Flesh Wound."
  elsif a_question.match?(/^CONCENTRATED$/i)
    "The first time a weapon with the Toxin trait with this Toxic Ammo applied hits an enemy fighter, add 2 to the dice roll to see if it overcomes the fighter’s Toughness. Note that this Toxic Ammo only affects this weapon’s first successful hit, and any subsequent hits, even during the same action, will be worked out as normal."
  elsif a_question.match?(/^DEBILITATING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, and is not taken Out of Action, place a marker on their Fighter card. For each marker on their Fighter card, a fighter must subtract 1 from any Characteristic checks they are required to make. At the end of the battle, or if the fighter goes Out of Action, remove these markers from their Fighter card."
  elsif a_question.match?(/^DECAYING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, and is not taken Out of Action, place a marker on their Fighter card. For each marker on their Fighter card, a fighter must subtract 1 from any Save rolls they are required to make. At the end of the battle, or if the fighter goes Out of Action, remove these markers from their Fighter card."
  elsif a_question.match?(/^EXPLODING$/i)
    "If a fighter is taken Out of Action by a hit from a weapon with the Toxin trait with this Toxic Ammo applied, before removing them from the battlefield place a 3\" Blast marker over that fighter, with the marker’s hole centred on their base. All fighters touched by this Blast marker suffer an immediate hit as if from a weapon with the Gas trait."
  elsif a_question.match?(/^MADDENING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, for the remainder of the battle all their attacks gain the Reckless trait."
  elsif a_question.match?(/^MAIMING$/i)
    "If a fighter is taken Out of Action by a weapon with the Toxin trait with this Toxic Ammo applied, the opposing player may roll twice on the Lasting Injuries table and choose which of the two results to apply."
  elsif a_question.match?(/^PANICKING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, they immediately become Broken, as if they had failed a Nerve test."
  elsif a_question.match?(/^PARALYSING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, they must immediately make a Strength check or become Paralysed. A Paralysed fighter counts as being subject to the Webbed condition."
  elsif a_question.match?(/^SILENCING$/i)
    "If a fighter is Injured by a weapon with the Toxin trait with this Toxic Ammo applied, for the remainder of the round they cannot issue or be part of Group Activations."
  # LEGENDARY NAMES
  elsif a_question.match?(/^Iron Hard$/i)
    "This fighter counts the first Serious Injury or Out of Action result they suffer during any battle as a Flesh Wound instead. However, if this fighter is taken Out of Action, their crew will automatically fail the next Bottle test it is required to make."
  elsif a_question.match?(/^Bullet Dodger$/i)
    "Once per battle, when an enemy fighter makes a ranged attack that targets this fighter, you can force that enemy fighter to re-roll all successful to hit rolls made as part of that ranged attack. During this fighter’s next activation after this ability has been used, they can only make Move (Simple) actions."
  elsif a_question.match?(/^Badzone Legend$/i)
    "This fighter can make a special 3+ save roll against any damage sustained as a result of any environmental hazard (i.e., damage not originating from an attack by another fighter). During this fighter’s next activation after this ability has been used, they cannot initiate or take part in Group Activations."
  elsif a_question.match?(/^Promethium(-| )proof Killer$/i)
    "This fighter ignores all of the effects of the Blaze trait. However, this fighter cannot benefit from or utilise the Leading by Example special rule."
  elsif a_question.match?(/^Slippery Scummer$/i)
    "If the fighter is ever captured (see the Necromunda Rulebook), they can choose to have another fighter from their gang be captured in their place. If this ability is used and another fighter is taken captive in this way, then the gang cannot and will not attempt a Rescue of that fighter."
  elsif a_question.match?(/^Blade Breaker$/i)
    "When this fighter is hit by an attack made by an enemy fighter using a weapon with either the Melee trait, the Versatile trait, or both, immediately roll a D6. On a roll of a natural 6, the hit automatically becomes a miss and the enemy fighter is immediately Disarmed (just as if they had been hit on a roll of 6 by a weapon with the Disarm trait)."
  elsif a_question.match?(/^Bigman$/i)
    "When this fighter makes a Group Activation, they may include fighters within 6\" rather than the usual 3\". However, this fighter must reduce the benefit of any cover they are in by 1 (i.e., while in Full Cover, enemy fighters only suffer a -1 modifier to their hit rolls when targeting this fighter, rather than the usual -2)."
  elsif a_question.match?(/^Lucky$/i)
    "Once per battle, this fighter can change the result of any one dice they have rolled to a 6 (you may decide to use this ability after the dice have been rolled). However, in a battle that uses the Reinforcement rules, this fighter’s Fighter card must be placed in the Reinforcement deck."
  elsif a_question.match?(/^Impressive Scars$/i)
    "As long as a friendly fighter has a line of sight to this fighter, the distance between that fighter and this fighter does not matter for the purposes of the Leading by Example special rule. However, this fighter must reduce the number of fighters they can include in a Group Activation by 1."
  elsif a_question.match?(/^Too Pretty for Primus$/i)
    "If this fighter is still on the battlefield at the end of a battle, their gang adds 2D6x5 credits to their Stash. However, if a double is rolled, these credits are added to your opponent’s Stash instead."
  elsif a_question.match?(/^Iron Stare$/i)
    "Enemy fighters wishing to target this fighter with a ranged attack must first pass a Cool check if this fighter has a line of sight to that enemy fighter. In addition, this fighter never counts as the closest fighter for the purposes of Target Priority."
  elsif a_question.match?(/^Rock Steady$/i)
    "As long as this fighter is Standing and Active, or Standing and Engaged, you can roll two D6 for Bottle tests and apply the lowest result. However, if your gang fails its Bottle test, friendly fighters must re- roll a successful Cool check to see if they flee the battlefield."
  elsif a_question.match?(/^One Punch$/i)
    "When making an unarmed attack (see the Necromunda Rulebook) this fighter may choose to roll a single Attack dice, irrespective of their Attacks characteristic or any other bonuses. If this attack hits, it is resolved at Strength 8 and Damage 2, and no Save roll can be made (with the exception of Field armour)."
  elsif a_question.match?(/^Bullet Lord$/i)
    "Once per battle, rather than rolling the Firepower dice, this fighter can choose the result of the dice roll to be a 3. However, after working out the effects of the attack, the fighter’s weapon counts as having failed an Ammo check."
  elsif a_question.match?(/^Two(-| )guns$/i)
    "When this fighter uses the Twin Guns Blazing rule, after working out the effect of their attacks, enemy fighters within 6\" must make a Nerve test. However, during any round in which this fighter uses the Twin Gun Blazing rule they cannot make, or participate in, a Group Activation."
  elsif a_question.match?(/^Chancer$/i)
    "Whenever this fighter hits an enemy fighter with an Improbable Shot, they gain D3 XP. When spending Experience on skill Advancements, this fighter cannot choose skills, and must always gain a randomly determined new skill instead."
  elsif a_question.match?(/^Headshot$/i)
    "If this fighter takes an enemy fighter Out of Action with their first Shoot (Basic) action of the battle, they gain D3 XP. However, all missed ranged attacks made by the fighter count as Stray Shots."
  elsif a_question.match?(/^One Shot$/i)
    "Once per battle this fighter can choose to automatically hit with a ranged weapon attack, provided the weapon does not have the Rapid Fire (X) trait or the Blast (X) trait. However, if this fighter can take a Shoot (Basic) action during their activation they must do so. Note that, when this fighter uses this ability, they must still roll the Firepower dice."
  # ARCHAEO-CYBERTEKNIKA
  elsif a_question.match?(/^CRANIAL CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers either a Head Injury or Humiliated result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers either a future Head Injury or Humiliated result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: This fighter is immune to the Insane condition.\n\nGamma: This fighter is immune to both the Insane and the Intoxicated conditions.\n\nOmega: This fighter is immune to the Insane and Intoxicated conditions. In addition, the fighter cannot become Broken."
  elsif a_question.match?(/^OCULAR CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers an Eye Injury result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers a future Eye Injury result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: This fighter is considered to always be equipped with an infra-sight, the benefits of which are applied to any ranged weapon they carry.\n\nGamma: This fighter is considered to always be equipped with both an infra-sight and a mono-sight, the benefits of which are applied to any ranged weapon they carry.\n\nOmega: This fighter is considered to always be equipped with an infra-sight and a mono-sight, the benefits of which are applied to any ranged weapon they carry, and photo-goggles."
  elsif a_question.match?(/^SINDEXTROUS CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers a Hand Injury result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers a future Hand Injury result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: This fighter ignores the effects of the Disarm trait.\n\nGamma: This fighter ignores the effects of the Disarm trait and they do not suffer a -1 to hit modifier when making close combat attacks if they have to turn to face their opponent before attacking.\n\nOmega: This fighter ignores the effects of the Disarm trait and they do not suffer a -1 to hit modifier when making close combat attacks if they have to turn to face their opponent before attacking. In addition, this fighter’s attacks cannot be parried."
  elsif a_question.match?(/^MOTIVE CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers a Hobbled Injury result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers a future Hobbled Injury result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: This fighter ignores any negative Movement modifiers caused by moving through difficult terrain.\n\nGamma: This fighter ignores any negative Movement modifiers caused by moving through difficult terrain and adds 2\" to their Movement when moving vertically (for example, when climbing up a ladder or other vertical surface).\n\nOmega: This fighter ignores any negative Movement modifiers caused by moving through difficult terrain and adds 2\" to their Movement when moving vertically (for example, when climbing up a ladder or other vertical surface). In addition, this fighter may re-roll failed Initiative checks to see if they fall when they go from Standing to Prone within ½\" of the edge of a level or platform."
  elsif a_question.match?(/^TORSONIC CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers a Spinal Injury result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers a future Spinal Injury result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: An unarmed attack made by this fighter has a Damage characteristic of 3, rather than the usual 1.\n\nGamma: An unarmed attack made by this fighter has a Damage characteristic of 3, rather than the usual 1. In addition, this fighter may apply a +2 modifier to their Strength characteristic when resolving hits made with a weapon that has either the Melee or Versatile trait.\n\nOmega: An unarmed attack made by this fighter has a Damage characteristic of 3, rather than the usual 1. In addition, this fighter may apply a +2 modifier to their Strength characteristic when resolving hits made with a weapon that has either the Melee or Versatile trait. Finally, any weapon this fighter is equipped with is considered to have suspensors fitted to it."
  elsif a_question.match?(/^VASCULAR CYBERTEKNIKA$/i)
    "This Cyberteknika upgrade repairs the damage caused when a fighter suffers an Enfeebled Injury result on the Lasting Injury table.\n\nThis Cyberteknika upgrade may be damaged if the fighter suffers a future Enfeebled Injury result on the Lasting Injury table.\n\nEach level of this Cyberteknika grants the fighter the benefits detailed below:\n\nAlpha: This fighter may apply a +1 modifier to their Toughness characteristic for the purposes of the number of Flesh Wounds they can take before going Out of Action.\n\nGamma: This fighter may apply a +1 modifier to their Toughness characteristic for the purposes of the number of Flesh Wounds they can take before going Out of Action. In addition, this fighter may re-roll any Toughness check they are required to make.\n\nOmega: This fighter may apply a +1 modifier to their Toughness characteristic for the purposes of the number of Flesh Wounds they can take before going Out of Action. In addition, this fighter may re-roll any Toughness check they are required to make. Finally, in the End phase of each round, this Fighter may discard a Flesh Wound they have suffered."
  # PIETY
  elsif a_question.match?(/^LORD OF RATS$/i)
    "Friendly Juve (or Prospect) fighters that are within 12\" of this fighter and can draw line of sight to them may apply a +2 modifier to their Cool checks and Willpower checks. Rats, including Necromunda Rats, Bomb Delivery Rats and any rats that feature in a battle due to a scenario or environment special rule, that end their movement within 3\" of the fighter are immediately moved by the smallest amount possible so they are at least 3\" away from the fighter."
  elsif a_question.match?(/^SCAVENGER('|)S EYE$/i)
    "During any scenario that features loot markers, scrap or any kind of harvested goods that are then transformed into credits at the end of the battle, the fighter’s gang may add an additional +1 to the dice roll for determining their worth. For example, if a scenario called for the gathering of loot and each loot marker held by the gang at the end of the battle was worth D3x10 credits, then each one would grant the fighter’s gang (D3+1)x10 credits."
  elsif a_question.match?(/^BLAZING FAITH$/i)
    "Should this fighter ever become subject to the Blaze condition, they may continue to act normally rather than acting as determined by the Trait and the condition – though they may still suffer damage each time they activate as normal. In addition, this fighter ignores the effects of the Insanity condition."
  elsif a_question.match?(/^UNSHAKABLE CONVICTION$/i)
    "This fighter may make reaction attacks while Seriously Injured and cannot be the target of a Coup De Grace (Simple) action. In addition, whilst Seriously Injured this fighter may perform the Flock Together (Double) action:\n\nFlock Together (Double):\nThis fighter may move a distance equal to their Movement characteristic plus D3\", provided they move directly towards a friendly House Cawdor fighter."
  elsif a_question.match?(/^DEVOTIONAL FRENZY$/i)
    "When this fighter is activated, their controlling player may declare they will use this skill. Until the start of their next activation, improve their Weapon Skill, Cool, Leadership and Willpower characteristics by D3, rolling separately for each characteristic. At the end of their activation, the fighter immediately suffers an automatic Damage 1 hit which cannot be saved. Devotional Frenzy can only be declared once per round."
  elsif a_question.match?(/^RESTLESS FAITH$/i)
    "During the Choose Crew step of the pre-battle sequence, this fighter may be taken out of Recovery (see the Necromunda Rulebook) and included in the deck of available fighters. If this is done and the fighter takes part in the battle, they begin the battle with a single Flesh Wound."
  # PSYCHOTERIC WHISPERS
  # MADNESS
  elsif a_question.match?(/^Existential Barrage$/i)
    "Existential Barrage (Simple):\nChoose a single enemy fighter that is within 1\" of the Psyker. That fighter immediately makes an Intelligence check. If this check is failed, they become Broken and immediately flee. If, after they have moved, there are any fighters friendly to them within 5\", those fighters must also immediately pass a Nerve test or also become Broken."
  elsif a_question.match?(/^Terrible Truths$/i)
    "Terrible Truths (Basic):\nChoose a single enemy fighter that is within 3\" of the Psyker. That fighter must make an Intelligence check. If this check is failed, they gain the Insane condition."
  elsif a_question.match?(/^Psychotic Lure$/i)
    "Psychotic Lure (Basic):\nChoose a single enemy fighter that currently has a Ready marker and is within 3\" of the Psyker. The opposing player must activate that fighter in their next turn. The chosen fighter cannot perform a Group Activation when next activated."
  elsif a_question.match?(/^Cyclopean Gaze$/i)
    "Cyclopean Gaze (Double):\nChoose a single enemy fighter that currently has a Ready marker and is within 1\" of the Psyker. The chosen fighter immediately loses their Ready Marker."
  elsif a_question.match?(/^Craven Howl$/i)
    "Craven Howl (Basic), Continuous Effect:\nWhile this power is maintained, Broken enemy fighters cannot attempt to Rally whilst within 5\" of the Psyker."
  elsif a_question.match?(/^Unrememberable Utterance$/i)
    "Unrememberable Utterance (Simple), Continuous Effect:\nWhile this power is maintained, all enemy fighters who activate whilst within 3\" of the Psyker can only perform one action, rather than the usual two (note that this means the fighter will be unable to perform a Double action)."
  # DELUSION
  elsif a_question.match?(/^Spatial Psychosis$/i)
    "Spatial Psychosis (Simple):\nChoose a single enemy fighter within 12\" of the Psyker, that is Standing and is not Engaged. That fighter immediately becomes Pinned. Note that if that fighter is within 1⁄2\" of the edge of a ledge or platform, this may cause them to fall."
  elsif a_question.match?(/^Seen Unseen$/i)
    "Seen Unseen (Basic), Continuous Effect:\nChoose a single enemy fighter that is within 3\" of the Psyker. While this power is maintained, the chosen fighter treats all fighters as being enemy fighters, and all fighters treat the chosen fighter as being an enemy fighter.\n\nNote that this means any rule, special or otherwise, that affects friendly fighters or friendly faction fighters ceases to work for the chosen fighter whilst this power is maintained as the chosen fighter has no friendly fighters of any sort on the battlefield."
  elsif a_question.match?(/^Ghost and Shadow$/i)
    "Ghost and Shadow (Basic):\nChoose a single enemy fighter that is within 10\" of the Psyker. The Psyker’s controlling player may immediately change this fighter’s facing (in other words, they may turn the model to face any direction)."
  elsif a_question.match?(/^Deceitful Thoughts$/i)
    "Deceitful Thoughts (Double):\nChoose a single enemy fighter that is within 5\" of the Psyker. That fighter immediately makes an Intelligence check. If this check is failed, the Psyker’s controlling player may immediately move that fighter up to their Move characteristic in any direction. Note that this move may not be used to move enemy fighters off ledges, into dangerous terrain or any other part of the battlefield harmful to them."
  elsif a_question.match?(/^Suicidal Embrace$/i)
    "Suicidal Embrace (Basic):\nChoose a single enemy fighter that is within 3\" of the Psyker. That fighter immediately makes an Intelligence check. If this check is failed, that fighter must resolve a single close combat attack against themselves with one of their Melee weapons (chosen at random, if the fighter has no weapons with the Melee trait, they will make an unarmed attack against themselves). This attack automatically hits, but must roll to wound and inflict Damage as normal."
  elsif a_question.match?(/^Opprobrious Curse$/i)
    "Opprobrious Curse (Simple):\nChoose a single enemy fighter that is within 3\" of the Psyker. That fighter immediately makes a Toughness check. If this check is failed, the fighter immediately suffers a Flesh Wound."
  # DARKNESS
  elsif a_question.match?(/^Cacophony of Silence$/i)
    "Cacophony of Silence (Double), Continuous Effect:\nWhile this power is maintained, all enemy fighters within 5\" of the Psyker must re-roll successful Hit rolls when making a ranged attack."
  elsif a_question.match?(/^Penumbral Mirror$/i)
    "Penumbral Mirror (Basic):\nChoose one enemy fighter and one friendly fighter that are both currently within 5\" of the Psyker. Immediately move the chosen friendly fighter to any other point within 5\" of the chosen enemy fighter. The chosen friendly fighter may even move into base contact with the chosen enemy fighter."
  elsif a_question.match?(/^A Perfect Void$/i)
    "A Perfect Void (Basic), Continuous Effect:\nWhile this power is maintained, the Psyker counts as being in full cover to all enemy fighters within 10\"."
  elsif a_question.match?(/^Eternal Slumber$/i)
    "Eternal Slumber (Double):\nAll Seriously Injured enemy fighters within 3\" of the Psyker immediately go Out of Action."
  elsif a_question.match?(/^Cloak of Whispers$/i)
    "Cloak of Whispers (Basic), Continuous Effect:\nWhile this power is maintained, the Psyker and all friendly Delaque fighters within 3\" of them cannot be the target of, or be affected by, any gang tactics played by the enemy player."
  elsif a_question.match?(/^Sight Blight$/i)
    "Sight Blight (Basic), Continuous Effect:\nWhile this power is maintained, all enemy fighters within 5\" of the Psyker count as being affected by the Pitch Black rules as detailed in the Necromunda Rulebook. Note that this does not actually create an area of darkness and only affects those who enter or remain in range of the Psyker."

  # TERRITORIES
  elsif a_question.match?(/^ARCHAEOTECH DEVICE$/i)
    "This Territory grants the following Boon:\nSpecial: Any number of weapons owned by the gang may be given one of the falling Traits for free: Blaze, Rad-phage, Seismic, or Shock. All Weapons must be given the same Trait and new weapons purchased later may also be given this Trait. These weapons also gain the Unstable Trait. If the Territory is lost, the weapons lose these additional Traits.\n\nThis Territory grants Van Saar gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nSpecial: A Van Saar gang may give any number of weapons it owns two of the following Traits for free: Blaze, Radphage, Seismic, or Shock. All weapons must be given the same Trait and new weapons purchased later may also be given these Traits. These weapons also gain the Unstable trait. If the Territory is lost, the weapons lose these additional Traits."
  elsif a_question.match?(/^BONE SHRINE$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns 2D6x5 credits from this Territory when collecting income.\n\nThis Territory grants Cawdor gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nIncome: The gang earns 4D6x5 credits from this Territory when collecting income."
  elsif a_question.match?(/^collapsed dome$/i)
    "This Territory grants the following Boon:\nIncome: When collecting income from this Territory, the controlling player may choose to roll between 2D6x10 and 6D6x10. However, if a double is rolled, then no income is generated and a random fighter from the gang suffers a Lasting Injury."
  elsif a_question.match?(/^corpse farm$/i)
    "This Territory grants the following Boon:\nIncome: When collecting income, the gang gains D6x10 credits for every fighter on either side that was deleted from their roster during the Update Roster step of the preceding battle.\n\nThis Territory grants Cawdor gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: When collecting income, the gang gains 2D6x10 credits for every fighter on either side that was deleted from their roster during the Update Roster step of the preceding battle."
  elsif a_question.match?(/^DRINKING HOLE$/i)
    "This Territory grants the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nSpecial: Whilst it controls this Territory, any fighter in the gang may re-roll any failed Cool checks. If a fighter uses this option, place a marker on their card to show that they have hit the bottle. The marked fighters suffer a -1 to hit penalty for the rest of the battle.\n\nThis Territory grants Delaque gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nSpecial: A Delaque gang may not use the standard Boon. Instead, the player of the Delaque gang that controls this Territory may nominate three enemy fighters at the start of the battle, and places an Intoxicated marker on each fight to show that their drink was spiked. The marked fighters suffer -1 to all tests and checks for the duration of the battle."
  elsif a_question.match?(/^fighting pit$/i)
    "This Territory grants the following Boon:\nRecruit: Whilst it controls this Territory, the gang may recruit two Hive Scum Hired Guns for free, including their equipment, prior to every battle.\n\nThis Territory grants Goliath gangs the following Boon:\nReputation: Whilst it controls this Territory, the gang adds +2 to Its Reputation."
  elsif a_question.match?(/^gambling den$/i)
    "This Territory grants the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: The player chooses a suit of cards. The player then draws a card from the shuffled deck of playing cards that includes both Jokers. If they draw a card from the suit they chose, they earn income to the value of the card (Jack 11, Queen 12, King 13, Ace 14) x10 credits. If they draw a card from a suit of the same color, then the Income is the value of the card x5 credits. If it is any other suit they gain no income from the Territory. If, however, they draw a Joker, they must pay all of the income they earn in that post-battle sequence to a random gang taking part in the campaign, as determined by the Arbitrator.\n\nThis Territory grants Delaque gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nSpecial: The Delaque player that controls this Territory may nominate a single enemy fighter at the start of the battle. The Delaque have called in the fighter’s debt marker, and in return for keeping all of their limbs intact, the fighter agrees to take no part in the coming battle. The nominated fighter misses the battle."
  elsif a_question.match?(/^generatorium$/i)
    "This Territory grants the following Boon:\nSpecial: If their gang controls this Territory, a player may choose to stall the generators, temporarily cutting the power to the area in which a battle is taking place and plunging it into darkness. The player may declare they will do this at the beginning of any Priority phase, before the roll for Priority. For the remainder of the battle, the Pitch Black rules (see page 328) are in effect. However, at the start of each End phase, there is a chance that the generators will automatically restart and the light flood back. At the start of each End phase, before making any Bottle tests, the player that controls this Territory rolls a D6. If the result is a 5 or more, the generators restart and the Pitch Black rules immediately cease to be in effect. If the roll is a 1-4, the generators stay silent.\n\nThis Territory grants Van Saar gangs the following Boon:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation."
  elsif a_question.match?(/^MINE WORKINGS$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns D6x10 credits from this Territory when collecting income. The gang may set Captured fighters to work in the mines rather than selling them to the Guilders. For every Captive working the mine, roll an additional D6 to generate income. If the Territory changes control, all of the Captives remain working the mine. A Captive sent to the mines may not subsequently be Sold to Guild. While a Captive is working in the mine, the gang may attempt a Rescue Mission at any time.\n\nThis Territory grants Orlock gangs the following Boon:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation."
  elsif a_question.match?(/^NARCO DEN$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns D6x5 credits from this Territory when collecting income.\n\nThis Territory grants Escher gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: The gang earns D6x5 credits from this Territory when collecting income. If the gang also controls a Synth Still, this is increased to D6x10."
  elsif a_question.match?(/^NEEDLE WAYS$/i)
    "This Territory grants the following Boon:\nSpecial: Whilst it controls this Territory, the gang may infiltrate up to three fighters onto the battlefield ahead of any battle. Infiltrating fighters must be part of the crew for a battle, but instead of being set up on the battlefield, they are placed to one side. At the end of the first round, the controlling player nominates any spot on the ground surface of the battlefield and sets up each infiltrating fighter within 2’’ of that spot.\n\nThis Territory grants Delaque gangs the following Boons:\nSpecial: A Delaque gang that controls this Territory may infiltrate two groups of up to three fighters using the method detailed above. The fighters in each group must be specified before the battle."
  elsif a_question.match?(/^OLD RUINS$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns D3x10 credits from this Territory when collecting income. Additionally, add +1 to the dice roll for each Dome Runner attached to the gang."
  elsif a_question.match?(/^PROMETHIUM CACHE$/i)
    "This Territory grants the following Boons:\nEquipment: Whilst it controls this Territory, three fighters in the gang gain incendiary charges for free.\nSpecial: All fighters in the gang may re-roll Ammo checks for any weapon that has the Blaze trait."
  elsif a_question.match?(/^REFUSE DRIFT$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns 2D6x5 credits from this Territory when collecting income. However, if a double is rolled, a randomly determined fighter has a nasty encounter with a waste-lurker and must miss the next battle whilst they recover. No income is lost.\n\nThis Territory grants Cawdor gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: The gang earns 2D6x5 credits from this Territory when collecting income. A Cawdor gang has no risk of encountering a nasty waste-lurker."
  elsif a_question.match?(/^ROGUE DOC SHOP$/i)
    "This Territory grants the following Boon:\nRecruit: The gang may recruit a Rogue Doc Hanger-on for free."
  elsif a_question.match?(/^settlement$/i)
    "This Territory grants the following Boons:\nIncome: The gang earns D6x10 credits from this Territory when collecting income.\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nRecruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their House List for free."
  elsif a_question.match?(/^slag furnace$/i)
    "This Territory grants the following Boon:\nIncome: The gang-earns D6x5 credits from this Territory when collecting income.\nENHANCED BOON\nThis Territory grants Goliath gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\nRecruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their House List for free."
  elsif a_question.match?(/^SLUDGE SEA$/i)
    "This Territory grants the following Boon:\nEquipment: Whilst it controls this Territory, three fighters in the gang gain choke gas grenades for free."
  elsif a_question.match?(/^smelting works$/i)
    "This Territory grants the following Boon:\nIncome: the gang earns D6x5 credits from this Territory when Collecting income.\n\nThis Territory grants Goliath gangs the following Boon:\nIncome: The gang earns D6x5 credits from this Territory when collecting income. If the gang also controls a Slag Furnace, this is increased to D6x10 credits."
  elsif a_question.match?(/^SYNTH STILL$/i)
    "This Territory grants the following Boon:\nSpecial: Whilst it controls this Territory, the gang treats chem-synths, medicae kits, stimm-slug stashes and any weapon with the Gas or Toxin trait as Common.\n\nThis Territory grants Escher gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nSpecial: Whilst it holds this Territory, the gang treats chem-synths, medicae kits, stimm-slug stashes and any weapon with the Gas or Toxin trait as Common, and halves the cost of these items (rounding up)."
  elsif a_question.match?(/^stinger mould sprawl$/i)
    "This Territory grants the following Boon:\nSpecial: During the post-battle sequence, the gang controlling this Territory may re-roll a Single Lasting Injury roll on a fighter. Note that a Memorable Death result may not be re-rolled.\n\nThis Territory grants Escher gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nSpecial: An Escher gang may either (1) remove a single existing Lasting Injury from a fighter, or (2) re-roll a single Lasting Injury roll on a fighter, including a Memorable Death result."
  elsif a_question.match?(/^tech bazaar$/i)
    "This Territory grants the following Boons:\nIncome: The gang earns D6x10 credits from this Territory when collecting income.\nEquipment: Select one Leader or Champion to make a Haggle post-battle action. Roll 2D6: The gang may immediately choose one item from the Rare Trade chart with a Rare value equal to the result of the dice roll and add it to their Stash for half of its usual value, rounded down. If the roll is lower than 7, pick a Common Weapon or Piece of equipment to add to the gang's Stash for half of its usual value, rounded down. If the roll is 3 or lower, then the fighter proves to be very poor at haggling and no equipment is gained. If the fighter selected has Exotic Furs, add +1 to the result of the 2D6 dice roll.\nENHANCED BOON\nThis Territory grants Van Saar gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nIncome: The gang earns D6x10 credits from this Territory when collecting income. If the gang also controls an Archaeotech Device, this is increased to 2D6x10."
  elsif a_question.match?(/^toll crossing$/i)
    "This Territory grants the following Boon:\nIncome: The gang earns D6x5 credits from this Territory when collecting income.\nENHANCED BOON\nThis Territory grants Orlock gangs the following Boon:\nSpecial: Whilst it controls this Territory, an Orlock gang has Priority in the first round of any battle. Any gang in the campaign may pay the Orlock gang 20 credits to gain the same benefit in a single battle against another gang."
  elsif a_question.match?(/^tunnels$/i)
    "This Territory grants the following Boon:\nSpecial: Whist it controls this Territory, the gang may choose to have up to three fighters deploy via tunnels ahead of any battle. These fighters must be part of the crew for a battle, but instead of being set up on the battlefield, they are placed to one side. During the deployment phase, the player sets up two 2’’ wide tunnel entrance markers on any table edge on the ground surface of the battlefield. During the Priority phase of each turn, roll a D6. On a 4+, the group of fighters arrive on the battlefield. That turn they may be activated as a single group, and must move onto the battlefield from one of the tunnel entrance. If the battle ends before the fighters arrive, they take no part in the battle.\nENHANCED BOON\nThis Territory grants Orlock gangs the following Boons:\nReputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\nSpecial: An Orlock gang may choose to deploy up to six fighters via tunnels using the method detailed above. The fighters in each group must be specified before the battle."
  elsif a_question.match?(/^wastes$/i)
    "This Territory grants the following Boons:\nSpecial: If challenged in the Occupation phase, the gang may choose the Territory at stake in the battle, even though it would normally be chosen by the challenger. If challenged in the Takeover phase for a Territory the gang already controls, make an Intelligence check for the gang Leader. If the check is passed, the player of the gang may choose to play the Ambush scenario instead of rolling. They are automatically the attacker."
  elsif a_question.match?(/^WORKSHOP$/i)
    "This Territory grants the following Boon:\nRecruit: The gang may recruit an Ammo-jack Hanger-on for free."


  # RACKETS
  elsif a_question.match?(/^narco( |-)distribution$/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Ghast Prospecting.\n\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\nSpecial: Whilst it controls this Racket, the gang treats Chem-synth, Medicae Kit, Stimm-slug Stash, and any weapon with the Gas or Toxin trait as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/^OUT( |-)HIVE SMUGGLING ROUTES$/i)
    "Linked Rackets: Ghast Prospecting, The Cold Trade.\n\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/^GHAST PROSPECTING$/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Caravan Route Control.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, three fighters in the gang gain a dose of Ghast each battle for free.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 4D6x10 credits when they collect Income."
  elsif a_question.match?(/^THE COLD TRADE$/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Spire Patronage.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, one member of the gang may have a single item from the Xenos Weapons section of the Black Market for free.\nSpecial: Whilst it controls this Racket, the gang treats items from the Xenos Weapons section of the Black Market as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income."
  elsif a_question.match?(/^LIFE COIN EXCHANGE$/i)
    "Linked Rackets: Whisper Brokers, Corpse Guild Bond.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang may recruit two Hive Scum or one Bounty Hunter Hired Gun for free, including their equipment, prior to every battle.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, all of its members gain the Fearsome skill."
  elsif a_question.match?(/^XENOS BEAST TRAFFICKING$/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Blood Pits.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, the gang Leader may be equipped with either a Grapplehawk or a Gyrinx Cat from the Black Market free of charge.\nSpecial: Whilst it controls this Racket, the gang treats Grapplehawks and Gyrinx Cats from the Black Market as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income."
  elsif a_question.match?(/^WHISPER BROKERS$/i)
    "Linked Rackets: Life Coin Exchange, Peddlers of Forbidden Lore.\n\nRACKET BOONS\nSpecial: Whilst it controls this racket, the gang may choose an additional D3 Tactics cards in the pre-battle sequence.\n\nENHANCED BOONS\nSpecial: If the gang also controls one of the Linked Rackets, when challenged, the gang may choose the Racket that will be at stake in the battle, even though it would normally be chosen by the challenger.\nSpecial: If the gang also controls both of the Linked Rackets, when challenged for a Racket the gang controls, make an Intelligence check for the gang Leader. If the check is passed, the player of the gang may choose to play the Ambush scenario instead of rolling. They are automatically the attacker."
  elsif a_question.match?(/^CORPSE GUILD BOND$/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Corpse Guild and may always add a Corpse Harvesting Party to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by 1 for every other Racket the gang controls."
  elsif a_question.match?(/^SLAVE GUILD BOND$/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Slave Guild and may always add a Slaver Entourage to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/^PROMETHIUM GUILD BOND$/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Promethium Guild and may always add a Pyromantic Conclave to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/^GUILD OF COIN BOND$/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Guild of Coin and may always add Toll Collectors to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/^WATER GUILD BOND$/i)
    "Linked Rackets: None\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang can control no other Guild Bond Racket.\nRecruit: Whilst it controls this Racket, and if the gang is Law Abiding, it forms an automatic alliance with the Water Guild and may always add a Nautican Syphoning Delegation to a crew during any pre-battle sequence. Alternatively, or if this Racket is controlled by an Outlaw gang, the gang may recruit one Bounty Hunter and up to two Hive Scum for free during any pre-battle sequence, including their equipment.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income. The result of the roll is increased by +1 for every other Racket the gang controls."
  elsif a_question.match?(/^ARCHAEOTECH AUCTIONING$/i)
    "Linked Rackets: Proxies of the Omnissiah, The Cold Trade.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, one member of the gang may have a single item from the Imperial Weapons section of the Black Market for free.\nIncome: Whilst it controls this Racket, the gang gains 2D6x10 credits when they collect Income. If a double is rolled, they gain nothing.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income. However, if a double is rolled, they gain nothing.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 4D6x10 credits when they collect Income. However, if a double is rolled, they gain nothing."
  elsif a_question.match?(/^WITCH SEEKING$/i)
    "Linked Rackets: Redemptionist Backers, Slave Guild Bond.\n\nRACKET BOONS\nSpecial: This Racket may only be controlled by a Law Abiding gang. If it is claimed by an Outlaw gang, it is converted into a Wyrd Trade Racket.\nSpecial: Whilst it controls this Racket, all fighters in the gang may add the Shock trait to one of their weapons that has the Melee trait for free.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang doubles the bounty it receives for any fighter that is a Psyker, even if that fighter has become a Psyker temporarily due to the effects of Ghast.\nIncome: If the gang also controls both of the Linked Rackets, the gang Leader may make an Intelligence check before claiming a bounty. If the check is passed, they identify the captive as a witch and receive double the bounty for them."
  elsif a_question.match?(/^REDEMPTIONIST BACKERS$/i)
    "Linked Rackets: Promethium Guild Bond, Witch Seeking.\n\nRACKET BOONS\nSpecial: Helot Cult, Genestealer Cult and Corpse Grinder Cult gangs may never claim this Racket. If they gain control of it, it becomes dormant until claimed by a different type of gang.\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks for any weapon that has the Blaze trait.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/^PROXIES OF THE OMNISSIAH$/i)
    "Linked Rackets: Archaeotech Auctioning, Promethium Guild Bond.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks. Additionally, the gang treats all Bionics as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nSpecial: If the gang also controls both of the Linked Rackets, all fighters in the gang may add either the Shock trait or the Seismic trait to one of their weapons for free. New weapons purchased later may also be given this Trait. These weapons also gain the Unstable trait. If the gang loses control of this Racket, the weapons that gained these additional Traits lose them."
  elsif a_question.match?(/^GAMBLING EMPIRE$/i)
    "Linked Rackets: Blood Pits, Whisper Brokers.\n\nRACKET BOONS\nIncome: The player of the gang that controls this Racket chooses a suit of cards and then draws a card from a shuffled deck of playing cards. If they draw a card from the suit they chose, they earn income equal to the value of the card (Jack 11, Queen 12, King 13) x 10 credits. If they draw a card from a suit of the same colour, they earn income equal to the value of the card x 5 credits. If it is any other suit, they gain no income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang’s player may nominate a single enemy fighter (but not a Leader or Champion) at the start of the battle. The gang has called in the fighter’s debts. The nominated fighter misses the battle."
  elsif a_question.match?(/^BLOOD PITS$/i)
    "Linked Rackets: Slave Guild Bond, Xenos Beast Trafficking.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang may recruit up to two Hive Scum Hired Guns for free, including their equipment, prior to every battle.\n\nENHANCED BOONS\nSpecial: If the gang also controls one of the Linked Rackets, as a post-battle action a Leader or Champion may fight in the pits. Make a Weapon Skill check with a -1 modifier for them. If the check is passed, they permanently gain one random Combat or Brawn skill. If the check is failed, nothing happens. If however the check is failed on the roll of a 1, the fighter suffers one roll on the Lasting Injury table.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/^SPIRE PATRONAGE$/i)
    "Linked Rackets: Proxies of the Omnissiah, Blood Pits.\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains 2D6x10 credits when they collect Income if they won their battle.\n\nENHANCED BOONS\nEquipment: If the gang also controls one of the Linked Rackets, all of the gang’s Leader and Champions may each have one of the following Extravagant Goods for free: Gold-plated Gun, Exotic Furs, Opulent Jewellery, Uphive Raiments.\nIncome: If the gang also controls both of the Linked Rackets, the gang’s Leader gains a Caryatid Exotic Beast for free. This Caryatid will not leave its master if the gang loses Reputation, but will leave if the gang loses control of this Racket."
  elsif a_question.match?(/^BULLET CUTTING$/i)
    "Linked Rackets: Proxies of the Omnissiah, Blood Pits.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, all fighters in the gang may re-roll any failed Ammo checks.\nEquipment: Whilst it controls this Racket, the gang treats all items from either the Trading Post or the Black Market with a Rarity of 9 or below as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income."
  elsif a_question.match?(/^(SETTLEMENT PROTECTION|FEARFUL TRIBUTE)$/i)
    "Linked Rackets: Guild Bond (any), Bullet Cutting.\n\nRACKET BOONS\nRecruit: Whilst it controls this Racket, the gang gains one Hanger-on of the controlling player’s choice for free.\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/^(CARAVAN ROUTE CONTROL|DARK TECH TRADERS)$/i)
    "Linked Rackets: Guild of Coin Bond, The Cold Trade.\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/^WYRD TRADE$/i)
    "Linked Rackets: Peddlers of Forbidden Lore, Whisper Brokers.\n\nRACKET BOONS\nEquipment: Whilst it controls this Racket, the gang treats Ghast as a Common item.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income"
  elsif a_question.match?(/^PRODUCTION SKIMMING$/i)
    "Linked Rackets: Caravan Route Control, Guild Bond (any).\n\nRACKET BOONS\nIncome: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/^RESURRECTION GAME$/i)
    "Linked Rackets: Corpse Guild Bond, Peddlers of Forbidden Lore.\n\nRACKET BOONS\nSpecial: Whilst it controls this Racket, the gang may ignore one Critical Injury or Memorable Death result on the Lasting Injury table per battle. When these results are rolled, the fighter simply goes Into Recovery.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nSpecial: Any gang in the campaign may pay the gang controlling this Racket to return a dead fighter from the grave. This costs the original value of the fighter (including equipment) +100 credits. Roll 2D6. On a roll of 7-12 the fighter is resurrected and gains the Fearsome skill. On a roll of 3-6 the fighter is resurrected but suffers a permanent loss of 1 Toughness and gains the Fearsome skill if they don’t have it already. On a roll of 2, the resurrection fails."
  elsif a_question.match?(/^PEDDLERS OF FORBIDDEN LORE$/i)
    "Linked Rackets: Wyrd Trade, The Resurrection Game.\n\nRACKET BOONS\nSpecial: Whilst the gang controls this Racket, the controlling player may re-roll the dice when determining Priority.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\nSpecial: Whilst the gang controls this Racket, its Leader and its all Champions gain a 4+ saving throw that cannot be modified by a weapon’s Armour Piercing value."
  elsif a_question.match?(/^SHROOM HARVEST(|S)$/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Ghast Prospecting.\n\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\nSpecial: Whilst it controls this Racket, the gang treats Chem-synth, Medicae Kit, Stimm-slug Stash, and any weapon with the Gas or Toxin trait as Common.\n\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."


  # EQUIPMENT
  elsif a_question.match?(/^AMMO CACHE$/i)
    "Ammo caches are added to the gang’s Stash, instead of being carried by a particular fighter. Immediately after the last of the fighters in the crew is set up at the start of a battle, the controlling player can choose to set up any ammo caches from their Stash. If the scenario has an attacker and a defender, and this gang is defending, roll a D6 for each of their ammo caches. On a 1-4, they were not expecting the attackers and the caches cannot be used; on a 5 or 6, they are lucky enough to have them to hand.\nEach ammo cache must be set up within 1\" of one of their fighters and within their deployment zone if the scenario has one. It is then deleted from the gang’s Stash. During the battle, ammo caches follow the rules on page 328."
  elsif a_question.match?(/^ARMOURED UNDERSUIT$/i)
    "If a fighter is wearing an armoured undersuit, their save roll is improved by 1. For example, if they are wearing Flak armour and an armoured undersuit, they would have a 5+ save, which would be increased to a 4+ save against blasts. If a fighter does not already have a save roll, an armoured undersuit grants a save of 6+."
  elsif a_question.match?(/^ARCHAEOTECH DEVICE$/i)
    "When a player buys an Archaeotech Device from the Trading Post, they won’t know what it does. They must allocate it to one of their fighters and roll on the Archaeotech Device table to determine its type. If an Archaeotech Device is given to a different fighter in the gang for any reason, the new fighter must pass an Intelligence check the first time they wish to activate it. If they pass, they may use the device as normal from now on. If they fail, they wait until their next game to try to activate the device again.\n\nD6 Type:\n1 Dangerous: The fighter accidentally triggers the device as they’re messing about with it. They immediately suffer D6 Str 2 Damage 1 hits and the archaeotech is reduced to a pile of worthless molten slag.\n\n2 Viewer: The fighter can use the device to view different places, shifting their perspective to almost any point, even if it’s beyond closed doors and solid walls. A fighter with this device can make the Scan (Simple) action to place a Revealed marker on an enemy fighter within 18\". If the fighter is selected to be a sentry, when they are activated, roll a D6 for them. On a 6, they automatically raise the alarm as they spot the enemy sneaking around.\n\n3 Cutting Beam: The device can be used to focus a cutting beam of great power on a stationary object. Unfortunately, it’s useless as a weapon because both the target and the fighter have to be perfectly still for the beam to focus, but it makes for a good can opener! A fighter with this device can make the Laser Cut (Double) action if they are within 1\" of a door, loot casket or other damageable piece of terrain. This action inflicts a single automatic hit against the chosen target, resolved with Strength 8 and Damage 3.\n\n4 Lifter: The device is a sophisticated form of suspensor which can negate or lessen gravity for its bearer, allowing them to float up or down for a limited period. When making a Move or Charge action, the fighter ignores all terrain, may move freely between levels without restriction, and can never fall. They may not, however, ignore impassable terrain or walls, and may not end their movement with their base overlapping an obstacle or another fighter’s base.\n\n5 Holo Projector: The device functions as a holo projector and can be used to make the fighter appear a short distance away from where they really are. This gives the fighter a saving throw of 4, 5 or 6 on a D6 against any hits from shooting, which is not affected by Armour Penetration. As soon as the saving throw is failed, the projector stops working for the rest of the game. Also note that the holo projector is useless against close combat attacks and weapons with the Template or Blast Traits.\n\n6 Weapon: The device is a powerful and compact weapon. It is only pistol-sized but it is as effective as a much larger piece of ordnance. Roll a D6 to find out what it is: 1-2 – boltgun, 3 – flamer, 4 – meltagun, 5 – plasma gun, 6 – grenade launcher with frag grenades. The weapon has the standard profile for a weapon of its type but with the addition of the Sidearm Trait. Because the weapon is compact and selfmaintaining it can be used by anyone, not just Specialists, Champions or Leaders."
  elsif a_question.match?(/^BIO-BOOSTER$/i)
    "The first time in each game that an Injury roll is made for a fighter with a bio-booster, one less Injury dice is rolled. If only one dice should have been rolled, two dice are rolled instead and the player controlling the fighter with the biobooster can discard one of them."
  elsif a_question.match?(/^BIO-SCANNER$/i)
    "If a fighter with a bio-scanner is a sentry in a scenario that uses the Sentries special rule, they can attempt to spot attackers even if they are not within their vision arc. In addition, the D6 roll to see whether a fighter is spotted has a +1 modifier (a natural 1 still fails)."
  elsif a_question.match?(/^BLIND SNAKE POUCH$/i)
    "A fighter with a Blind Snake Pouch gains the Dodge skill. If they already have the Dodge skill then they will successfully dodge attacks on a D6 roll of 5 or 6 rather than just a roll of 6. In addition, when making a dodge against an attack made by a fighter using the Overwatch skill, the dodge will succeed on a D6 roll of 4, 5 or 6."
  elsif a_question.match?(/^BOMB DELIVERY RATS$/i)
    "A fighter equipped with bomb delivery rats may deploy one per turn to carry a single grenade of a type that fighter is equipped with by performing a Prime Bomb Rat (Basic) action. When a bomb delivery rat is deployed, make an Ammo roll for the grenade used as if it had been used normally. The fighter may run out of grenades before they run out of rats!\nWhen the bomb delivery rat is deployed, place it so that the edge of its base is touching that of the fighter and make an Intelligence check for the fighter. If the check is passed, the fighter may choose which direction the rat moves in. If the check is failed, the rat will move in a direction determined by rolling a Scatter dice. In either case, the rat may move up to 6\". Bomb delivery rats ignore all terrain when moving except any that would normally be impassable, such as walls and structures. They suffer no penalties for climbing, they will never fall, and they may freely leap any gap of 2\" or less. Wider gaps are considered impassable.\nA bomb delivery rat is not a fighter and may pass within 1\" of other models. Should the rat end its movement within 1\" of a fighter, friend or enemy, or another bomb delivery rat, roll a D6. On a 2+, the grenade will go off. On a 1, the grenade proves to be a dud and the rat vanishes into the darkness to dwell upon its good fortune. In a either case, the rat is removed from play.\nAt the start of every subsequent round, after rolling for Priority but before activating any fighters, if the bomb delivery rat has not exploded then it will activate again. Check to see if it is within 9’’ of the fighter that deployed it. If it is and if that fighter is Active or Pinned, make an Intelligence check for the fighter. If this is passed, the rat will immediately move up to 6’’ in a direction of your choosing. If it is beyond 9’’, the Intelligence check is failed, the fighter is Engaged or Seriously Injured (Secondary Statuses have no effect), or if the fighter has been taken Out of Action, then the rat will move 6’’ in a direction determined by rolling a Scatter dice. Should the rat end its movement within 1’’ of a fighter, friend or enemy, or another bomb delivery rat, roll a D6. On a 2+, the grenade will go off. On a 1, the grenade proves to be a dud. In either case, the rat is removed from play.\nAny fighter may attempt to shoot at a bomb delivery rat or make a melee attack against one as if it were an enemy fighter. However, there is always an additional -1 modifier on any hit roll made against a bomb delivery rat. If the rat is hit, roll a D6. On a 4+, the grenade goes off. On a 1-3, the grenade does not go off. In either case, once a bomb delivery rat has been hit by a shooting or melee attack, it is removed from play. "
  elsif a_question.match?(/^BOOBY TRAP(S|)$/i)
    "FRAG, GAS, AND MELTA\nA booby trap is represented by a marker placed upon the battlefield at the start of the game, after the battlefield has been set up but before deploying any fighters. If both gangs possess and wish to use booby traps, the defender or the winner of a roll-off (if there is no defender) places theirs first.\nIf any fighter, friendly or enemy, comes within 2\" of a booby trap for any reason, they risk setting the booby trap off. Roll a D6. On a 1, the booby trap is a dud and is removed from the battlefield. On a 2 or 3, the booby trap does not go off but is left in place. On a 4, 5 or 6, the booby trap is triggered and will explode. The profiles for booby traps can be found in the weapon section. The movement of a moving fighter is interrupted whilst this roll is resolved. If the booby trap does not go off, their movement continues after the roll is made. If the booby trap does go off, and the fighter is Pinned or Injured as a result, their movement ends.\nAny fighter can target a booby trap with ranged attacks. Doing so has a -1 modifier to the hit roll at Short range, or a -2 modifier at Long range. If the booby trap is hit, roll a D6. On a 1-2, it is unaffected. On a 3-4, it is immediately triggered. On a 5-6, it is disarmed and removed."
  elsif a_question.match?(/^CAMELEOLINE CLOAK$/i)
    "Cameleoline is a much-sought after material within the Imperium, and is commonly used by the armies of the Emperor for stealth and scout troops. On Necromunda, some examples of the material can be found in the underhive, stitched into more common clothing or as an extra layer on a cloak, allowing the wearer to seemingly vanish if they stand still. If the wearer of a Cameleoline cloak did not move during their activation, ranged attacks made against them suffer a -2 to hit until the start of their next activation."
  elsif a_question.match?(/^CHEM(-| )SYNTH$/i)
    "At the start of their activation, a Standing and Active or Standing and Engaged fighter with a chem-synth can choose to make an Intelligence check. If the check is passed, any Gas or Toxin weapons they use until the end of their activation are enhanced and the target’s Toughness is reduced by 1 when resolving those attacks."
  elsif a_question.match?(/^CHRONO-CRYSTAL$/i)
    "The opportunity to acquire one of Bald Bryen’s Chronocrystals is vanishingly rare, and possession of such an item will not only result in the owner earning the eternal enmity of the infamous mayor of Rust Town, but may also lead to them crossing paths with the Ordo Chronos in the future (or, perhaps, in the past…). Certain scenario special rules will detail the ways in which a Chrono-crystal can be used."
  elsif a_question.match?(/^CRED( |-)SNIFFER$/i)
    "Cred Sniffers are modified auspexes created by enterprising archaeo-thieves. They literally sniff out the rare alloys in cred chits and direct the user to their location. If a fighter equipped with a Cred Sniffer was part of a game and was not taken Out of Action or Seriously Injured, at the end of the battle they earn 4D6 credits for their gang. A gang can only benefit from the effects of one Cred Sniffer at a time."
  elsif a_question.match?(/^CULT ICON$/i)
    "Only one fighter in a gang may carry a cult icon, this must be either the gang Leader or a Champion. This symbol of dedication and devotion serves to inspire gang members to greater acts in battle. When the Leader or Champion carrying the icon makes a group activation, they may activate one additional Readied fighter within 3\", meaning that the Leader may activate three additional fighters whilst a Champion may activate two additional fighters."
  elsif a_question.match?(/^CORPSE GRINDER CULT ICON$/i)
    "Only one fighter in a gang may carry a Corpse Grinder cult icon, this must be either the gang Leader or a Champion. A fighter cannot carry more than one icon.\nThis symbol of blood and gore serves to work members of the cult into a frenzy, throwing themselves at their enemies in a crimson rage. If the fighter carrying this icon is Standing and Active, they may make the following action:\nEnrage: All friendly fighters that are completely within 6\" of this fighter, that have a Ready marker, and that are Standing and Active, add D3\" to their Move characteristic until the End phase of this round."
  elsif a_question.match?(/^DATA(-| )THIEF$/i)
    "Data-thief slates monitor enemy comms and farm useful information from Necromunda’s various vox-nets. If a crew includes at least one fighter equipped with a Datathief,at the start of the game they can make their opponent randomly reveal one of their Gang Tactics cards."
  elsif a_question.match?(/^DROP RIG$/i)
    "An Active fighter with a drop rig can make the following action while they are within 1\" of the edge of a platform:\n\nDescend (Basic):\nThe fighter makes a move of up to 3\" horizontally and up to 12\" vertically. Any vertical movement must be downwards, ie. towards the ground."
  elsif a_question.match?(/^FALSEHOOD$/i)
    "When this device is activated it projects a distortion field that changes the wearer’s appearance, making them appear as someone else. A fighter equipped with a Falsehood cannot be targeted by ranged or melee attacks or enemy psychic powers, and will not cause the alarm to be raised if spotted by a sentry in a game using the Sneak Attack rules. These effects last until the fighter makes a melee or ranged attack, uses a psychic power on an enemy fighter, or until the End phase of the second round. At this point their suspicious or openly hostile acts give them away, the illusion is dispelled and the hood has no further effect."
  elsif a_question.match?(/^(CHAOS |)FAMILIAR$/i)
    "SPECIAL RULES\n\nOmen of Fortune: A Chaos Familiar is able to sense bad fortune and forewarn its chosen companion, giving them a flash of precognition.\nWhilst the Familiar is within 3\" of its owner, that fighter may avoid one successful hit per turn by making a successful Willpower check. Make the check immediately after a successful roll to hit has been made against the fighter. If the check is failed, the attack hits as normal. If the check is passed, the attack counts as having missed and the dice roll is discarded. Templates and Blast markers are placed as normal for the purposes of determining hits against other models, but the Familiar’s owner is assumed to have somehow dodged clear.\n\nPrecognition: The gift of foresight possessed by the Chaos Familiar enables it to dodge and evade all but the most unexpected of attacks. This tremendous precognition grants the Familiar a 3+ save roll, which cannot be modified by Armour Piercing.\nAdditionally, a Chaos Familiar may avoid being caught by Blast or Template weapon. If a Familiar is caught under a Blast or Flame Template, the attacker should roll a D6. On a 4-6, it is hit by the attack. On a 1-3, it is able to dodge clear of the area of the attack. Leave the model where it is and assume it has scuttled around and returned to where it was.Psychic Manifestation: A Chaos Familiar is an extension of its owner’s will and a clear indication of the favour the dark gods of Chaos have bestowed upon them. If the owning fighter is a Psyker, once per round they may re-roll a failed Willpower check to perform a Wyrd Power (X) action.\n\nClamber: When the fighter climbs, the vertical distance they move is not halved. In other words, they always count as climbing up or down a ladder."
  elsif a_question.match?(/^FILTER PLUGS$/i)
    "If a fighter with filter plugs is hit by a weapon with the Gas trait, their Toughness is increased by 1 for the purposes of the roll to see whether they are affected. Filter plugs are one-use; if a fighter uses them during a battle, they are deleted from their fighter’s card when the battle ends."
  elsif a_question.match?(/^FORGED GUILDER SEAL$/i)
    "Truly decent forged documents are a rarity in the underhive, and ones good enough for a ganger to pass themselves off as a Guilder even more so – though they do exist. Only the boldest criminals pretend to be Guilders, however, for the consequences of being discovered and caught involves a long and painful execution. When a fighter with a Forged Guilder Seal visits the Trading Post, they reduce the Rarity of Items by 2. In addition, the prices of any items they buy are reduced by 3D6 credits to a minimum of 10 credits. However, if they roll a double 1 or double 6 when reducing the price of an item, they have been discovered. The item is bought as normal, however, the seal is then removed from their Fighter card, and the fighter’s gang are declared Outlaws."
  elsif a_question.match?(/^FRENZON COLLAR$/i)
    "A method of control, the Frenzon collar is usually found clamped around the necks of unwilling penal troopers, where its cocktail of combat drugs drives them into battle at the behest of their masters. Underhive gangers sometimes wear these collars willingly into combat, or as part of a dare. A fighter equipped with a Frenzon collar is considered to be permanently under the effects of Frenzon. In addition, each collar comes with a master motivator. At the start of the game, the player must decide if their Leader or one of their Champions is carrying the master motivator. When the Leader or Champion with the master motivator makes a group activation, they may include models wearing Frenzon collars (up to the normal number of fighters they may group activate) regardless of where they are on the battlefield. Note that if a gang includes more than one fighter equipped with a Frenzon collar, they will only ever have a single master motivator which governs all collars in the gang."
  elsif a_question.match?(/^GRAPNEL(-| )LAUNCHER$/i)
    "An Active fighter with a grapnel launcher can make the following action:\n\nGrapnel (Double):\nThe fighter can move up to 12\" in a straight line, in any direction. This move can take them to a different level, as long as they do not move through any terrain."
  elsif a_question.match?(/^GRAV(-| )CHUTE$/i)
    "If a fighter falls or jumps down to a lower level, they do not suffer any damage – they simply move down without any rolls being made."
  elsif a_question.match?(/^GRAV-CUTTER$/i)
    "A fighter equipped with a grav-cutter increases their Movement characteristic by 2\", ignores all terrain, may move freely between levels without restriction, can never fall, and may move over enemy fighters, ignoring the 1\" rule. They may not, however, ignore impassable terrain and may not end their movement with their base overlapping an obstacle or within 1\" of another fighter’s base.\n\nWhen a fighter equipped with a grav-cutter is hit by a ranged attack, they do not become Prone and Pinned. However, a fighter equipped with a grav-cutter is unable to perform a Take Cover (Basic) action, nor can they voluntarily become Prone and Pinned for any other reason. In addition, a fighter equipped with a grav-cutter is not able to make the best use of cover. To represent this, when an enemy fighter shoots at a fighter equipped with a grav-cutter, any negative modifiers that may apply to the hit roll due to cover are reduced by 1.\n\nShould a fighter equipped with a grav-cutter ever become Prone for any other reason (due to being Seriously Injured and then recovering, for example), they are unable to make a Stand Up (Basic) action and must instead make a Stand Up (Double) action, regardless of any other special rules or skills that may otherwise affect their ability to stand up (the Spring Up skill, for example).\n\nFLY BY ATTACKS – A fighter equipped with a grav-cutter is able to use its speed and bulk to strike down enemy fighters as they pass them by. A fighter equipped with a grav-cutter may perform the following action:\n\nHit & Run (Basic): This fighter may move a distance up to their Movement characteristic, exactly as if they were making a Move (Simple) action. If, during the course of this movement, the fighter passes over any enemy fighters, nominate one of those fighters to be the target of a single attack, representing this fighter attempting to strike them a glancing blow with the grav-cutter. Make a single hit roll by making a WS check as normal. If this check is passed, resolve a Strength 4, AP -, Damage 1 hit against the target, as if made by a weapon with both the Concussion and Knockback traits."
  elsif a_question.match?(/^GUILDER CARTOGRAPH$/i)
    "While a gang is in possession of a Guilder Cartograph, they may alter the Environment when using the Badzones Environments Events Cards or chart. After determining the Environment at the beginning of the game, the gang with the Cartograph may immediately discard it and generate a new Environment. If both players have a Cartograph, they should roll off to see who gets to use theirs for this scenario.\nIn addition to changing the Environment, Cartographs often show the location of Guilder supply caches. During deployment, a gang with a Cartograph can place four loot caskets anywhere on the battlefield.\nOf course, the underhive is changing, and maps can become outdated. After each game in which a gang used their Guilder Cartograph, their player should roll a D6. On a 4+, the information it contains is still good, otherwise it is of no further use and should be deleted from the gang roster"
  elsif a_question.match?(/^HALO DEVICE$/i)
    "From the forlorn regions beyond the edge of the Imperium, intrepid Rogue Traders sometimes bring back strange objects. Known as Halo devices, these alien artefacts are often imbued with ancient energies, able to sustain their owners even beyond death, though often at a cost to others. When a fighter equipped with a Halo device suffers a Lasting Injury (including death), their player can choose another member of their gang to suffer the effects of the Lasting Injury instead. Note that if the fighter was taken Out of Action they are still removed from the game, while the fighter chosen to suffer the Lasting Injury remains on the board unless the result was a 61-66, in which case they are removed."
  elsif a_question.match?(/^HARRIER(-| )SKULLS$/i)
    "With every innovation in combat there is usually a counter-innovation to defeat it. Harrier-skulls are a kind of servo-skull designed to act as decoys for Grapplehawks and other hunting beasts. If an Exotic Beast wants to make an attack against a fighter equipped with Harrierskulls, it must first pass an Intelligence check – otherwise the Attack action fails and is wasted. If the owner of the Exotic Beast is within 3\" of the target of the attack, the beast may use its owner’s Intelligence for the check instead."
  elsif a_question.match?(/^HEXAGRAMMIC FETISH$/i)
    "Badzone peddlers and sumphole wise women often sell charms and fetishes ‘guaranteed’ to offer protection. The truly astonishing thing is some of these charms actually work! When a fighter buys a Hexagrammic Fetish they must roll a D6. On a 1, the fetish is rubbish, though the fighter can sell it on to an unsuspecting underhiver for 3D6 credits. On a 2-5, it has some power, and if a Psyker targets the fighter with a psychic power, the Psyker suffers a -1 to their Willpower check. On a 6, the fetish has some real juice; it works as above except the Psyker will suffer a -3 to their Willpower check"
  elsif a_question.match?(/^HOLOCHROMATIC FIELD$/i)
    "A Holochromatic field surrounds its wearer in an aura of scintillating colours. Ranged attacks against a fighter with a Holochromatic field suffer a -2 to hit, while melee attacks against them suffer a -1 to hit. Each time the fighter is targeted with an attack, roll a D6. On a 1, the Holochromatic field has been drained and cannot be used again this game. Fighters wearing an active Holochromatic field count as always having a revealed marker on them in scenarios using the Pitch Black rules. A Holochromatic field cannot be combined with Cameleoline Cloaks or similar devices that make the wearer harder to see."
  elsif a_question.match?(/^INDUSTRIAL RESPIRATOR$/i)
    "An Industrial Respirator adds 3 to a fighter’s Toughness, or 4 if combined with a Hazard Suit, against attacks from weapons with the Gas trait. In addition, an Industrial Respirator contains a limited air supply. Once per game, when a fighter with an Industrial Respirator is activated, they can declare they are using its air supply. Until the fighter is activated again, they gain immunity to Gas attacks, can act normally while on fire (though they may still take damage) and may ignore effects keyed to breathing or air quality."
  elsif a_question.match?(/^ISOTROPIC FUEL ROD$/i)
    "A gang with an Isotropic Fuel Rod can use it to turn any Territory into a Settlement Territory. Doing so uses up the Isotropic Fuel Rod, so it should be deleted from the gang roster, and permanently changes the Territory."
  elsif a_question.match?(/^JUMP BOOSTER$/i)
    "Once per activation, a fighter equipped with a jump booster may choose to use it when they make either a Move (Simple) action or a Charge (Double) action. When a jump booster is used, it may be used in one of two ways, chosen by the controlling player:\n\n• The fighter may use the jump booster in ‘safe mode’, allowing them to add 3\" to their Movement characteristic for the duration of this action.\n• The fighter may ‘overcharge’ the jump booster, allowing them to add D3+3\" to their Movement characteristic for the duration of this action. However, doing so is not without risk, and should a natural 1 be rolled when rolling the dice, something has gone wrong and the jump booster will malfunction. The fighter does not move at all, and instead immediately becomes Prone and Pinned. \n\nWhen a fighter moves with the aid of a jump booster, up to half of their total movement may be made vertically, allowing the fighter to move between levels and even to move over impassable terrain if they have sufficient movement to do so. However, should the fighter’s movement end in the air, i.e., if the fighter does not have sufficient movement to land safely on a level surface, they will fall the remaining distance (note that, if this distance is 2\" or less, the fighter will count as jumping down).\nShould a fighter use a jump booster when making a Charge (Double) action, for the duration of this activation they may apply both a +1 modifier to each Hit roll they make and a +1 modifier to their Strength characteristic.\n\nHAZARDOUS EQUIPMENT\nUsing a jump booster is not without its risks, and this is never more true than when the user is attempting to use flame weapons or lob grenades! To represent this added danger, during any activation in which a fighter equipped with a jump booster uses it when making a Move (Simple) action, any weapons they are armed with that have either the Grenade or Template trait will also gain the Unstable trait. Once the fighter’s activation ends, this rule ceases to apply."
  elsif a_question.match?(/^LHO STICKS$/i)
    "A fighter equipped with lho sticks is considered to be ‘cool’ by the more gullible members of their gang. Any friendly fighter with an Intelligence characteristic of 8+ or worse may use this fighter’s Cool characteristic instead of their own if they are within 6\" and line of sight of this fighter."
  elsif a_question.match?(/^LOCK(-| )PUNCH$/i)
    "Lock-punches are crude pneumatic devices used to smash locks out of doors and force them open. A fighter equipped with a lock-punch can use it when they are taking the Force Door (Basic) action to add 4 to their Strength. Doors opened with lock-punches are permanently damaged and must be removed from the board."
  elsif a_question.match?(/^MAGNACLES$/i)
    "A fighter equipped with Magnacles can try to lock them onto an enemy in base contact as an Attack (Basic) action. The target must make an Initiative check to avoid the attack. If this test is failed they are locked in place and cannot move, cannot make ranged attacks and can only make melee attacks at -2 to hit. The target can attempt to free themselves by performing the following action:\n\nBreak Bonds (Double)\nRoll 2D6. If the result is equal or lower than their Strength then they have freed themselves, otherwise they remain trapped. Each friendly fighter in base contact with the target adds 2 to their Strength for the purposes of this roll."
  elsif a_question.match?(/^MALEFIC ARTEFACT$/i)
    "Malefic Artefacts are objects of the Warp or those that have lingered in the hands of corrupted individuals. When a player buys a Malefic Artefact from the Black Market, they won’t know what it does. They must allocate it to one of their fighters and roll a D6 on the Malefic Artefacts table to determine its type. If a Malefic Artefact is later given to a different fighter in the gang for any reason, the new fighter must pass an Intelligence check the first time they wish to activate it. If they pass, they may use the artefact as normal from now on. If they fail, they wait until their next game to try to activate the artefact again.\n\nD6 Effect:\n1 Cursed Artefact: The fighter accidentally triggers the artefact as they’re messing about with it. The Malefic Artefact mysteriously vanishes and the fighter begins their next game with the Insane condition.\n\n2 Whisper Vox: Hidden truths issue forth from the artefact, informing its bearer as to the intentions of those around them. The fighter gains the Overwatch skill. If they already have the Overwatch skill, they can take the Aim (Basic) action in addition to the Shoot (Basic) action when using this skill.\n\n3 Void Gate: The artefact is a gateway to a dark yawning void that the fighter may open to sap the strength of those around them. The fighter can perform the Unleash the Void (Double) action. If they take this action, all other fighters within 6\" of them can only take a single action during their activation.\n\n4 Etheric Lantern: When the artefact is activated, it acts as a beacon to the denizens of the Warp who would feast upon the dead and dying. The fighter can perform the Ignite Etheric Lantern (Double) action. If they do, any Seriously Injured fighter within 12\" must make a Toughness check or go Out of Action.\n\n5 Chronoscope: Time works differently around the artefact, sometimes speeding up, sometimes slowing down. When the fighter activates roll a D6. On a 1, they may take no actions this round. On a 2-5, they can take an extra action this round. On a 6, after they complete their activation they may be placed anywhere within 12\" of their current location.\n\n6 Terrox Telepathica: Dire thoughts are projected from the artefact driving all those nearby mad. The fighter gains immunity to the Insane condition. Any other fighter that activates within 6\" of the fighter must immediately make a Willpower check or gain the Insane condition."
  elsif a_question.match?(/^MEDICAE KIT$/i)
    "When a fighter with a Medicae kit assists a friendly fighter’s Recovery test, roll an extra injury dice then choose one to discard."
  elsif a_question.match?(/^PSYCHOMANCER('|)S HARNESS$/i)
    "This strange form of servo harness combines familiar underhive technology with the mysterious psychic sciences of House Delaque. Plugging directly into the wearer’s mind mechanically and psychically, the wearer’s strength and agility is greatly enhanced by the harness.\nA fighter wearing a psychomancer’s harness increases their Move characteristic by +2\". Additionally, when this fighter climbs, the vertical distance they move is not halved. In other words, they always count as climbing up or down a ladder.\nA fighter wearing a psychomancer’s harness is automatically equipped with paired psychomantic claws. However, the fighter can only be equipped with a maximum of two weapons purchased from those listed in their entry (rather than the usual three) and may not be equipped with any weapons marked with an asterisk (*), or any weapons with the Unwieldy trait."
  elsif a_question.match?(/^PHOTO(-| )GOGGLES$/i)
    "A fighter with photo goggles can attack through smoke clouds, can make ranged attacks against fighters 12\" away under the Pitch Black rules and may gain other benefits in low light conditions, depending upon the scenario. In addition, if they are hit by a Flash weapon, add 1 to the result of the Initiative test to see whether they become subject to the Blind condition."
  elsif a_question.match?(/^MNEMONIC INLOAD SPIKE$/i)
    "Adeptus Mechanicus Tech-Priests use Mnemonic Inload Spikes for the swift transfer of data from one cortex to the next. Each spike contains potential secrets and skills that the user can inload directly to their brain, though for those without the proper cybernetic interfaces the process can be fatal. When a gang buys an inload spike, they must choose one of their fighters to attempt to use its data. The chosen fighter must immediately roll on the Lasting Injuries table. If the fighter is still alive after making this roll they gain one skill of their choice from Agility, Brawn, Combat, Cunning, Ferocity, Leadership, Savant or Shooting. The spike is then used up and removed from the gang’s stash."
  elsif a_question.match?(/^PHOTO(-| )LUMENS$/i)
    "Commonly carried by Palanite Enforcers, a fighter that is equipped with a photo-lumen can make ranged attacks against enemy fighters up to 12\" away under the Pitch Black rules. However, when the Pitch Black rules are in effect, a fighter equipped with a photo-lumen cannot be Hidden – they are instead always subject to the Revealed condition due to the bright light emanating from their gear."
  elsif a_question.match?(/^PSI(-| )GRUB$/i)
    "Psi-grubs are alien parasites that feed upon psychic power. When bloated with the energies of the Immaterium, they can then be used to fuel psychic abilities. If a fighter with a Psi-grub uses a psychic power or is the target of a psychic power, place a token on their Fighter card after working out the effects of the power. Once there is at least one token on the fighter’s card, they can attempt to use the Psi-grub whenever they manifest a psychic power.\nTo trigger the Psi-grub, the fighter makes a Tap Psi-Grub (Basic) Action and rolls a D6. If the result is equal to or lower than the number of tokens on their Fighter card, the Psi-grub is triggered, otherwise there is no effect. When the Psi-grub is triggered, remove all Psi-grub tokens from the fighter’s card and immediately use one of the fighter’s psychic powers just as if they had taken the Wyrd Power (X) action. This action does not require the fighter to make a Willpower check.\nIf there are ever six tokens on the fighter’s card, the Psigrub immediately explodes! Remove all the tokens and the Psi-grub from the fighter’s card and roll an Injury dice for the fighter"
  elsif a_question.match?(/^RADCOUNTER$/i)
    "A fighter equipped with a radcounter can never be the random target of an Event unless there are no other fighters to choose from."
  elsif a_question.match?(/^RATSKIN MAP$/i)
    "Before a gang with a Ratskin Map rolls to determine the scenario as part of the pre-game sequence, they can declare they are using their Ratskin Map. If both gangs have a Ratskin Map, they should roll off to see whose gang gets to use theirs for this game – capitalising on the map’s information before their opponent can. The player then rolls on the Ratskin Map table to see how valuable the information on it is. Note, once the type of map is determined, it remains the same, and provided it is worth something, a gang may use it again in the pre-game sequence of subsequent games.\n\nD6 Effect:\n1 Fake Instead of rolling for the scenario as normal, your opponent chooses the scenario for this game. Remove the Ratskin Map from your gang roster.\n\n2 Worn and Incomplete: After making the roll to determine the scenario, you may add or subtract 1 from the result.\n\n3 Treasure Map: Roll another D6. On a 1-5, the map is a Fake (see above). On a 6, it is a genuine treasure map. If your gang wins the scenario, they can add D6x20 credits to their Stash in addition to any other rewards.\n\n4 Ancient and Faded: After making the roll to determine the scenario, you may add or subtract 2 from the result.\n\n5 Secret Pathways: D3 Fighters in your gang gain the Infiltrate skill for the duration of this scenario.\n\n6 Recent and Accurate: After making the roll to determine the scenario, you may add or subtract up to 3 from the result."
  elsif a_question.match?(/^RESPIRATOR$/i)
    "If a fighter with a respirator is hit by a weapon with the Gas trait, their Toughness is increased by 2 for the purposes of the roll to see whether they are affected."
  elsif a_question.match?(/^SANCTIONING WRIT$/i)
    "A Sanctioning Writ is an official document penned and signed by the Merchants Guild granting its bearer the right to set bounties on the enemies of Necromunda. Sometimes these are stolen from Guilders – signed but without the subject of the bounty filled in – and are used by gangs to put an official target on their rivals. A fighter can use a Sanctioning Writ to place a bounty on any member of a Law Abiding gang. This bounty remains in place until it is fulfilled, the targeted fighter dies or the campaign comes to an end.\nA Sanctioning Writ can only be used once, after which it is lost, and a fighter can only have one bounty on their head at a time."
  elsif a_question.match?(/^SECOND BEST$/i)
    "A fighter with a bottle of Second Best can make the Take a Swig (Simple) action. After they take this action, roll a D6. On a 1, 2 or 3, the bottle is empty; remove it from the fighter’s card. Every time a fighter makes this action, place an Intoxicated marker on their card and remove one of their Flesh Wounds (if they have any). Intoxicated markers remain until the end of the game. The effects of the booze are dependent on how many markers they have on their card.\n\nIntoxicated Markers/Effect:\n1 Feeling Good: -1 to ranged attack hit rolls, +1 to the result of Cool checks.\n2 Getting Unsteady: -2 to ranged attack hit rolls, +2 to the result of Cool checks. If the fighter makes two Move actions in a row, they must pass an Initiative check after completing the second action or become Prone.\n3+ Blind Drunk: -3 to ranged attack hit rolls and -1 to melee attack hit rolls, +3 to the result of Cool checks. When the fighter makes a Move action, instead of using the fighter’s Movement characteristic, move the fighter D6\" in a direction determined by the Scatter dice."
  elsif a_question.match?(/^(SERVO HARNESS - PARTIAL|SERVO HARNESS PARTIAL|PARTIAL SERVO HARNESS)$/i)
    "A fighter wearing a partial servo harness gains a +2 modifier to their Strength characteristic and a +1 modifier to their Toughness characteristic. This may take them above their maximum characteristics but it is not a permanent increase and will be lost should the servo harness be lost or cease to function for any reason.\nAdditionally, a fighter wearing partial servo harness gains the benefits of suspensors on any Unwieldy ranged weapon they carry. However, a fighter wearing a partial servo harness reduces their Movement and Initiative by 1. This item cannot be combined with a servo claw or any other type of servo harness."
  elsif a_question.match?(/^(SERVO HARNESS - FULL|SERVO HARNESS FULL|FULL SERVO HARNESS)$/i)
    "A fighter wearing a full servo harness gains all of the benefits of a partial servo harness, but without the negative modifiers to Movement and Initiative. This item cannot be combined with a servo claw or any other type of servo harness."
  elsif a_question.match?(/^SKINBLADE$/i)
    "If the fighter is captured at the end of a battle, they can attempt to escape. If they do, roll a D6. On a result of 1 or 2, they are unsuccessful. On a result of 3 or 4, they can escape but are injured in the process – make a Lasting Injury roll for them. On a result of 5 or 6, they escape. A fighter who escapes is no longer Captured, however, their skinblade is lost and deleted from their Fighter card."
  elsif a_question.match?(/^STIMM(-| )SLUG STASH$/i)
    "Once per game, a fighter with a stimm-slug stash can use it at the start of their turn, when they are chosen to make an action. Immediately discard one Flesh Wound from the fighter’s card, if any are present. Until the end of the round, the fighter’s Move, Strength and Toughness characteristics are each increased by 2. At the start of the End phase, roll a D6. On a 1, the stimm overload is too much – roll an Injury dice and apply the result to the fighter."
  elsif a_question.match?(/^STRIP KIT$/i)
    "When a fighter with a strip kit makes an Intelligence check to operate a door terminal or bypass the lock on a loot casket, add 2 to the result."
  elsif a_question.match?(/^suspensor harness$/i)
    "A fighter equipped with a suspensor harness may carry four weapons rather than three, while a Hired Gun Bounty Hunter with a suspensor harness may carry six weapons rather than five. As usual, weapons marked on the Equipment List with (*) take up the space of two weapons."
  elsif a_question.match?(/^THREADNEEDLE WORMS$/i)
    "Threadneedle worms are a deadly bio-weapon able to ravage an area of life in seconds. The lethality of Threadneedle worms makes them an ideal weapon of last resort for gangers who don’t care about collateral damage. A fighter equipped with Threadneedle worms can unleash them by taking the Can of Worms (Basic) action. Threadneedle worms can only be used once, after which they are removed from the fighter’s card. When Threadneedle worms are used, roll a D6 on the Threadneedle Worms table. The worms are then used up and removed from the gang’s stash.\n\nD6 Result\n1 The Worms Turn: Roll an Injury dice for the fighter using the Threadneedle Worms.\n2-3 A Few Live Worms: Place a 5\" Blast marker anywhere within D6\" of the fighter then roll an Injury dice for each model under the marker.\n4-5 A Few More Live Worms: Place a 5\" Blast marker anywhere within D6\" of the fighter, then place two additional 5\" Blast markers so they are in contact with the first marker. Roll an Injury dice for each model under any of the markers.\n6 A Can Full of Worms: Roll an Injury dice for every enemy fighter on the battlefield, treating Out of Action results as Seriously Injured."
  elsif a_question.match?(/^WILD(| )SNAKE$/i)
    "A fighter with a bottle of Wild Snake can make the Take a Swig (Simple) action. After they make this action, roll a D6. On a 1 or 2, the bottle is empty; remove it from the fighter’s card. Every time a fighter makes this action, place an Intoxicated marker on their card and remove one of their Flesh Wounds (if they have any). Intoxicated markers remain until the end of the game. The effects of the booze are dependent on how many markers they have on their card:\n\nIntoxicated Markers / Effect:\n1 A Good Buzz: -1 to ranged attack hit rolls, +2 to the result of Cool checks.\n2 Seeing Double: -1 to ranged attack hit rolls, +3 to the result of Cool checks. When making ranged attack hit rolls after choosing a target, randomise the actual target of the attack between the intended target and any model (friend or foe) within 6\" of them.\n3+ Snake Courage!: -2 to ranged attack hit rolls, automatically pass any Cool checks"
  elsif a_question.match?(/^WEB SOLVENT$/i)
    "When a fighter equipped with web solvent makes a Recovery check due to the Webbed condition, roll an extra Injury dice, picking one of the dice to resolve it and discarding the other. Additionally, when a fighter equipped with web solvent assists a fighter subject to the Webbed condition with a Recovery test, roll an extra two Injury dice and choose which one to apply."
  elsif a_question.match?(/^XENOCULUM$/i)
    "A Xenoculum can represent any number of esoteric alien devices, the true purposes of which only becomes apparent through experimentation. When a player buys a Xenoculum from the Black Market, they won’t know what it does. They must allocate it to one of their fighters and roll a D6 on the Xenoculum table to determine its type. If a Xenoculum is later given to a different fighter in the gang for any reason, the new fighter must pass an Intelligence check the first time they wish to activate it. If they pass, they may use the device as normal from now on. If they fail, they wait until their next game to try to activate the device again.\n\nD6 Effect:\n1 Alien Trap: The fighter accidentally triggers the Xenoculum as they’re messing about with it. They immediately suffer D3 S3 D1 hits and the Xenoculum is reduced to a collection of junk.\n\n2 Xenos Claws: The Xenoculum moulds itself to the fighter’s hands, lengthening into a pair of lethal claws. The fighter’s unarmed attacks become S+2 D2 and gain the Power trait. While the fighter is equipped with the Xenoculum any attacks they make with ranged weapons suffer a -2 to hit.\n\n3 Ghost Form: The Xenoculum is a powerful transmatter convertor, allowing its user to slip out of sequence with reality for short periods. When the fighter activates, they can enter ghost form. This state persists until their next activation. While in ghost form, the fighter ignores all terrain, the effects of falling and all attacks with the exception of psychic powers. However, they cannot make attacks themselves or interact with their environment in any way. Each time the fighter enters ghost form, they must roll a D6. On a 4+, the Xenoculum has expended its charge and cannot be used again during the battle.\n\n4 Horror Aura: A subliminal animalistic howl constantly screams forth from the Xenoculum and only its user is immune to its effects. When the fighter activates, any fighter, friend or foe, within 6\" must make a Nerve test or become Broken.\n\n5 Alien Chemfactory: Strange mechanisms concoct alien chems within the Xenoculum, dispensing them as the fighter desires. The fighter rolls two extra Injury dice when making Recovery rolls, or assisting another Seriously Injured fighter in the Recovery phase, and chooses the dice they wish to take effect. In addition, in the post-battle sequence, one member of the fighter’s crew can make a Medical Escort action for free.\n\n6 Brain Booster: A cranial spike allows the Xenoculum to be affixed to the fighter’s brain, greatly boosting their cognitive function. The fighter adds 5 to the dice roll when making an Intelligence check. In addition, each time the fighter would gain Experience, they gain one additional point of Experience."

  # ARMOUR
  elsif a_question.match?(/^ABLATIVE OVERLAY$/i)
    "The first time a fighter wearing an ablative overlay is required to make a save, their save is 2 better than normal (i.e., a model with a 5+ save would gain a 3+ save). A model without a save gains a 5+ save. The second time they must make a save, it becomes 1 better than normal or 6+ if they did not already have a save. After the fighter has been hit twice, the ablative overlay is spent and has no further effect on the game, but is retained by the fighter and may be used again in future games."
  elsif a_question.match?(/^ARCHAEO(-| )CARAPACE$/i)
    "An Archaeo-carapace grants its wearer a 4+ save. If the wearer suffers a Lasting Injury result of Humiliated, Head Injury, Eye Injury, Hand Injury, Hobbled, Spinal Injury or Enfeebled, instead of suffering the effects of the injury they gain a bionic appropriate to the location damaged (i.e., if a Head Injury was suffered, they would gain a Cortex-cogitator bionic). These bionics do not increase the fighter’s characteristics. Unlike normal bionics, they cannot be damaged or destroyed, and if the fighter suffers an injury to a location already replaced by a bionic then the injury is ignored.\nTransformation into a blasphemous cyber-creature is not without its perils, however. Whenever the fighter activates they must roll a D6. If the result is less than the number of bionics they currently have, they gain the Insane condition. If the fighter ever has six or more bionics, they vanish into the underhive never to be seen again – the player must remove the fighter from their gang roster."
  elsif a_question.match?(/^ARMOURED BODYGLOVE$/i)
    "Van Saar fighters are somewhat protected from the effects of their own rad weapons by their armour and are therefore immune to the effects of the Rad-phage Weapon Trait (i.e., they will not suffer the additional flesh wound) unless, otherwise noted. If a fighter is wearing an armoured bodyglove, their save roll is improved by 1. For example, if they are wearing Flak armour and an armoured bodyglove, they would have a 5+ save, which would be increased to 4+ against Blasts. If a fighter does not already have a save roll, an armoured bodyglove grants a 6+ save. An armoured bodyglove may be combined with other types of armour. It may not however be combined with an armoured undersuit."
  elsif a_question.match?(/^ARMOURWEAVE$/i)
    "Armourweave grants its wearer a save of 5+. This save cannot be reduced to lower than 6+ by AP or other modifiers, though attacks that do not allow a save will ignore Armourweave as normal."
  elsif a_question.match?(/^CARAPACE$/i)
    "Light: Light carapace armour grants a 4+ save roll.\n\nHeavy: Heavy carapace armour grants a 4+ save roll. This is increased to 3+ against attacks originating within the fighter’s vision arc (the 90° arc to their front); check this before the fighter model is placed prone and is Pinned. If it is not clear if the attacker is within the fighter’s arc, use a Vision Arc template to check – if the centre of the attacker’s base is within the arc, use the 3+ save roll. Against attacks with the Blast trait, use the centre of the Blast marker in place of the attacker. If the fighter does not have a facing (for example, if they are prone), use the 4+ save roll. However, due to the extra weight of this armour, the fighter’s Initiative is reduced by 1 and their movement by 1\" when making a Charge action."
  elsif a_question.match?(/^CERAMITE SHIELD$/i)
    "A fighter with a Ceramite shield adds +2 to their save against attacks originating in their line of sight provided they are Standing, however for the wielder the Move action becomes a (Basic) action rather than a (Simple) action. A fighter with a Ceramite shield ignores the effects of the Melta trait if an attack originates in their line of sight."
  elsif a_question.match?(/^FLAK$/i)
    "Flak armour grants a 6+ save roll. Against weapons that use a Blast marker or Flame template, this is increased to 5+ save roll."
  elsif a_question.match?(/^FURNACE PLATES$/i)
    "Furnace plates grant a 6+ save roll. This is increased to 5+ against attacks originating within the fighter’s vision arc (the 90° arc to their front); check this before the fighter model is placed prone and is Pinned. If it is not clear if the attacker is within the fighter’s arc, use a Vision Arc template to check – if the centre of the attacker’s base is within the arc, use the 5+ save roll. Against attacks with the Blast trait, use the centre of the Blast marker in place of the attacker. If the fighter does not have a facing (for example, if they are prone), use the 6+ save roll."
  elsif a_question.match?(/^GUTTERFORGED CLOAK$/i)
    "A Gutterforged cloak grants its wearer a save of 6+, or a save of 5+ against damage resulting from Underhive Perils or environmental effects."
  elsif a_question.match?(/^HARDENED FLAK ARMOUR$/i)
    "Flak armour grants a 6+ save roll. Against weapons that use a Blast marker or Flame template, this is increased to a 5+ save roll. Additionally, when an enemy fighter makes a ranged attack against a fighter wearing hardened flak armour, the Armour Penetration of the weapon used is decreased by 1, to a minimum of -1."
  elsif a_question.match?(/^HARDENED LAYERED FLAK ARMOUR$/i)
    "Hardened layered flak armour grants a 5+ save roll. Against weapons that use a Blast marker or Flame template, this is increased to a 4+ save roll. Additionally, when an enemy fighter makes a ranged attack against a fighter wearing hardened layered flak armour, the Armour Penetration of the weapon used is decreased by 1, to a minimum of -1."
  elsif a_question.match?(/^HAZARD SUIT$/i)
    "A hazard suit grants a 6+ save roll. Additionally, when a hazard suit is combined with a respirator, the fighter’s Toughness is increased by 3 against Gas attacks, rather than the usual 2. Finally, a fighter wearing a hazard suit is immune to the Blaze and Rad-phage traits."
  elsif a_question.match?(/^LAYERED FLAK ARMOUR$/i)
    "Layered flak armour grants a 5+ save roll. Against weapons that use a Blast marker or Flame template, this is increased to a 4+ save roll."
  elsif a_question.match?(/^MANTLE MALIFICA$/i)
    "A Mantle Malifica grants its wearer a 5+ save, or an unmodifiable 4+ save against the effects of psychic powers. Note that this save, if successful, does not cancel the use of a psychic power, it only renders the wearer immune to the power’s effects. In the End phase of each round, the wearer must make a Willpower check or gain the Insane condition."
  elsif a_question.match?(/^MESH$/i)
    "Mesh armour grants a 5+ save roll."
  elsif a_question.match?(/^PLATE MAIL$/i)
    "Plate mail grants a 6+ save roll. This is increased to a 5+ save roll against attacks originating within the fighter’s vision arc (the 90° arc to their front); check this before the fighter model is placed Prone and is Pinned. If it is not clear if the attacker is within the fighter’s front arc, use a Vision Arc template to check – if the centre of the attacker’s base is within the arc, use the 5+ save roll. Against attacks with the Blast trait, plate mail always grants a 5+ save roll."
  elsif a_question.match?(/^REFLEC SHROUD$/i)
    "A Reflec shroud grants its wearer a save of 5+. The wearer also counts the AP of las, plasma and melta weapons as ‘-’ regardless of their actual AP."
  elsif a_question.match?(/^SCRAP SHIELD$/i)
    "A fighter can be equipped with a scrap shield in addition to a suit of armour. The scrap shield offers no protection against ranged attacks, but while Engaged, the fighter increases their save by 1 against Reaction attacks."

  # FIELD ARMOUR
  elsif a_question.match?(/^CONVERSION FIELD$/i)
    "When a fighter wearing a conversion field is hit by an attack, roll a D6. On a 5+, the conversion field works and the attack has no further effect. However, any fighters, friend or foe, within 3\" of the wearer count as being hit by a weapon with the Flash trait as the field reacts in a tremendous burst of light. Note that the wearer is unaffected by this flash of light as they are inside the field."
  elsif a_question.match?(/^DISPLACER FIELD$/i)
    "If a fighter wearing a displacer field is hit, roll a D6. On a 4+, the fighter is moved a number of inches equal to the Strength of the attack in a random direction, determined by rolling a Scatter dice, and the hit is ignored (even if any part of the fighter is still under the template – if the attack used one – after being displaced). A displacer field will not deposit its wearer inside a terrain feature, the fighter will move by the shortest route possible so that it can be placed clear of any impassable terrain features. Similarly, the fighter’s base cannot overlap another fighter’s base and the wearer must be moved by the shortest route possible until its base can be placed without overlapping. Note that the wearer may end up within 1\" of an enemy fighter and may even end up Engaged as a result of being displaced.\nHowever, displacer fields are notoriously oblivious to safe footings. In a Zone Mortalis game, a fighter wearing a displacer field may be deposited above a pit fall or similar hazard. In a Sector Mechanicus game, a fighter above ground level may simply be flung into the open air. If any part of the fighter’s base ends overhanging a hazard or overhanging a platform edge, the fighter must pass an initiative test or will fall, following all the rules for falling as required by the terrain type being fought over. If the entirety of the fighter's base is over a hazard or in the open air, they will simply fall.\nIf a fighter wearing a displacer field is transported off the board, they immediately go Out of Action.\nIf an attack does not have a Strength value, then a displacer field cannot work against it."
  elsif a_question.match?(/^REFRACTOR FIELD$/i)
    "When a fighter wearing a refractor field is hit by an attack, roll a D6. On a 5+ the hit is ignored.\nHowever, should the field work and the hit be ignored, roll another D6. If the result is a 1, then the field has been overburdened by the attack and its generator is burned out. Remove the refractor field from the fighter’s card, it no longer works."

  # CORPSE GRINDER MASKS
  elsif a_question.match?(/^INITIATE(’|)S MASK$/i)
    "An Initiate’s mask adds 1 to any save rolls the fighter makes.\nAdditionally, should a fighter wearing this mask suffer a Lasting Injury result of 51: Head Injury or 52: Eye Injury, roll a D6. On a 6, the fighter does not suffer the characteristic reduction, but will still go Into Recovery."
  elsif a_question.match?(/^SKINNER(’|)S MASK$/i)
    "A Skinner’s mask adds 1 to any save rolls the fighter makes.\nAdditionally, should a fighter wearing this mask suffer a Lasting Injury result of 51: Head Injury, or 52: Eye Injury, roll a D6. On a 6, the fighter does not suffer the characteristic reduction, but will still go Into Recovery.\nFinally, the mask grants the fighter wearing it the Fearsome (Ferocity) skill:\nFearsome: If an enemy wishes to make a Charge (Double) action that would result in them making one or more close combat attacks against this fighter, they must make a Willpower check before moving. If the check is failed, they cannot move and their activation ends immediately."
  elsif a_question.match?(/^CUTTER(’|)S MASK$/i)
    "A Cutter’s mask adds 1 to any save rolls the fighter makes.\nAdditionally, should a fighter wearing this mask suffer a Lasting Injury result of 51: Head Injury or 52: Eye Injury, roll a D6. On a 6, the fighter does not suffer the characteristic reduction, but will still go Into Recovery.\nFinally, this mask confers the Terrifying special rule onto the fighter wearing it:\nTerrifying: If an enemy fighter wishes to make a Fight (Basic) or Shoot (Basic) action that targets this fighter, they must make a Willpower check. If the check is failed, they cannot perform the action and their action ends immediately."
  elsif a_question.match?(/^BUTCHER(’|)S MASK$/i)
    "A Butcher’s mask grants the fighter a save roll of 6+. This save cannot be combined with other armour, but neither can it be modified by a weapon’s Armour Piercing value. However, a fighter can only make one save attempt per attack. Therefore, you must choose to either make a save attempt using the fighter’s armour save or using this save.\nAdditionally, should a fighter wearing this mask suffer a Lasting Injury result of 51: Head Injury or 52: Eye Injury, roll a D6. On a 6, the fighter does not suffer the characteristic reduction, but will still go Into Recovery.\nFinally, this mask confers the Terrifying special rule onto the fighter wearing it:\nTerrifying: If an enemy fighter wishes to make a Fight (Basic) or Shoot (Basic) action that targets this fighter, they must make a Willpower check. If the check is failed, they cannot perform the action and their action ends immediately."

  # WEAPON ACCESSORIES
  elsif a_question.match?(/^GUNSHROUD$/i)
    "(Pistols and Basic weapons)\nA weapon fitted with a gunshroud gains the Silent trait."
  elsif a_question.match?(/^HOT(-| |)SHOT LAS(-| |)PACK$/i)
    "(Lasgun and Laspistol only)\nAt the expense of reliability, a lasgun or laspistol (not including las carbines, las sub-carbines or suppression lasers) can be fitted with a hotshot las pack, increasing its Strength to 4 and Armour Piercing to -1. However, the weapon loses the Plentiful trait and its Ammo value is reduced to 4+."
  elsif a_question.match?(/^INFRA(-| |)SIGHT$/i)
    "(Pistols, Basic, Special and Heavy weapons)\nWeapons with the Rapid Fire (X) or Blast (3\"/5\") trait cannot be fitted with an infra-sight. A weapon with an infra-sight can be used to attack through smoke clouds, and prove more effective in Pitch Black conditions (see page 328). In addition, there is no hit modifier when the weapon targets a fighter in partial cover, and a -1 modifier (instead of -2) when it targets a fighter in full cover."
  elsif a_question.match?(/^LAS(-| |)PROJECTOR$/i)
    "(Pistols, Basic and Special weapons)\nThe weapon’s Short range accuracy bonus is improved by 1 (for example, if it is +1 it becomes +2; if it is – it becomes +1; if it is -1 it becomes – )"
  elsif a_question.match?(/^MONO(-| |)SIGHT$/i)
    "(Basic, Special and Heavy weapons)\nIf the fighter attacks with this weapon after making an Aim action, add 2 to the result of the hit roll instead of 1."
  elsif a_question.match?(/^PSI(-| )AMPLIFIER$/i)
    "(Melee weapons)\nIn order for a Psi-amplifier to be fitted to a weapon, a specialist must be found. To attempt to find one, Leaders and Champions may make a Psi Attune post-battle action. This is carried out in the same way as a Trade action, though its only benefit is if you roll a 15 or more you may fit the psi-amplifier to a weapon. Once fitted, the weapon gains the Force trait."
  elsif a_question.match?(/^SUSPENSOR$/i)
    "(Heavy weapons)\nAn Unwieldy ranged weapon fitted with suspensors is far more manoeuvrable. Firing it becomes a Basic action rather than a Double action.\n\nAn Unweildy close combat weapon fitted with suspensors can be used single-handedly, allowing the fighter to use a second close combat weapon."
  elsif a_question.match?(/^TELESCOPIC SIGHT$/i)
    "(Pistols, Basic and Special weapons)\nIf a fighter attacks with this weapon after making an Aim action, the weapon’s Short range accuracy modifier is used even if the target is within the weapon’s Long range."

  # STATUS ITEMS
  elsif a_question.match?(/^GOLD(-| )PLATED GUN$/i)
    "Any weapon can be gold-plated. A fighter with a goldplated gun adds +1 to their Leadership characteristic. Additionally, once per game, the fighter may re-roll a failed Ammo check."
  elsif a_question.match?(/^EXOTIC FURS$/i)
    "Should this fighter make a Trade action in the post-battle sequence, they add an additional +1 modifier to the dice roll to determine the rarity of the items on offer."
  elsif a_question.match?(/^MASTER(-| )CRAFTED WEAPON$/i)
    "The fighter purchases a new weapon of exceptional craftsmanship. Any weapon may be master-crafted (note that grenades are Wargear, not weapons). The cost of a master-crafted weapon is that of the weapon plus 25%, with fractions rounded up to the nearest 5 credits. For example, a master- crafted bolter/plasma combi weapon would cost 145 credits (115 credits plus 25% equals 143.75 credits. Rounded up to the nearest 5 credits, this weapon costs 145 credits).\nNote that the fighter may replace a weapon with which they are already equipped with a master- crafted version of that weapon, and that the original may be discarded and added to the gang’s Stash. This is an exception to the norm.\nA fighter may re-roll a single failed hit roll for this weapon every round."
  elsif a_question.match?(/^MUNG VASE$/i)
    "A Mung Vase is a type of Status Item. However unlike other Status Items, rather than being given to a Leader or Champion to carry, the Mung Vase is kept in the gang’s Stash. When a gang in possession of a Mung Vase recruits a Hired Gun, they can reduce the Hire Gun’s cost by D6x10 credits, to a minimum of 10 credits. The vase is shown off as an example of the gang’s wealth and success, and the Hired Gun believes that agreeing to a reduced fee now will earn them favour with this potentially prosperous employer. There is, however, a chance the Hired Gun will simply try to steal the vase when they leave! After a game in which a Mung Vase was used to reduce the hiring cost of a Hired Gun, roll a D6. On a 1, both the Hired Gun and the vase disappear, never to be seen again.\nIn the post-battle sequence of any battle, a gang can sell the vase. If they do, roll a D6 on the Mung Vase table to see what it is worth (players should resist the temptation to roll on this table unless their gang is attempting to sell a Mung Vase – you don’t need to know your vase is a fake, ignorance is bliss!).\n\nD6 Result\n1 Dismal Fake: A truly sad knock-off. The vase nets the gang D3x5 credits.\n\n2-3 Passable Fake: A nice conversation piece. The vase nets the gang D6x10 credits.\n\n4-5 Impressive Fake: A fine example of the counterfeiters’ art. The vase nets the gang D6x20 credits.\n\n6 Outstanding Fake?: Make an Intelligence check for the gang Leader. If they fail, count this result as an Impressive Fake. If they pass, they realise what they have just in time – add D6x50 to the gang’s Stash.\n\nFinally, if the gang Leader is killed and removed from the gang roster, the vase is lost too – no one else in the gang knows where the vase has been kept hidden!"
  elsif a_question.match?(/^OPULENT JEWELLERY$/i)
    "If this fighter makes a Medical Escort action in the postbattle sequence, they will attempt to impress the Doc with their visible wealth. Sometimes this works, sometimes it does not… You may re-roll the dice when determining the fee the Doc charges, but you must accept the second result, even if it is worse."
  elsif a_question.match?(/^UPHIVE RAIMENTS$/i)
    "If this fighter is not In Recovery during the post-battle sequence, their gang gains an extra D3x10 credits during the Collect Income step."
  elsif a_question.match?(/^SENSOR SKULL$/i)
    "A sensor skull grants the owning fighter the same benefits as a bio-scanner. In addition, when the fighter takes an Aim action, they may add 2 to the result of any hit rolls they make for subsequent shots taken in the same activation rather than the usual 1. This bonus is in addition to any granted by any other wargear or skills the fighter may have."
  elsif a_question.match?(/^MEDI SKULL$/i)
    "When making a Recovery test for the owning fighter, roll an extra Injury dice, then pick one of the dice to resolve and discard the other. This is in addition to any friendly fighters assisting the recovery and any other items such as medicae kits, so it is possible that the owning fighter may be rolling several Injury dice to choose from."
  elsif a_question.match?(/^GUN SKULL$/i)
    "A gun skull is equipped with a compact autopistol and will target whatever or whoever the owning fighter does when they make a ranged attack. Simply roll one extra hit dice and one extra Ammo dice for the gun skull, ideally of a different colour to those being used for the fighter, to represent the gun skull making a ranged attack. Note though that range, line of sight and cover must be worked out from the gun skull itself rather than that of the owning fighter. If the owning fighter does not possess any ranged weapons, the gun skull may shoot at an enemy it can see, chosen by the owning fighter and following the normal target priority rules in relation to the owning fighter’s position.\nThe owning fighter is never considered to be in the way of a gun skull’s shooting attacks and cannot be hit by Stray Shots.\nA gun skull has a BS of 5+ and may never benefit from aiming or any wargear or skills that modify the owning fighter’s to-hit rolls."

  # CHEMS
  elsif a_question.match?(/^FRENZON$/i)
    "A fighter under the influence of Frenzon gains the Nerves of Steel, True Grit, Unstoppable and Berserk skills, however, all their weapons count as having the Reckless Trait. Unless the fighter is Engaged or Seriously Injured, the fighter must use at least one of their actions to move toward the nearest enemy fighter or perform a Charge (Double) action against a visible enemy if one is within range.\n\nSIDE EFFECTS\nFrenzon is highly addictive. During the Wrap-up, any fighter who used Frenzon must make a Toughness check, adding 2 to the dice roll. If the check is failed, the fighter has become addicted to Frenzon. Once a fighter is addicted to Frenzon, they can only be included in a crew if they have taken a dose of the chem. The only way a fighter can shake this addiction is to pay 2D6x10 credits for anti-addiction chems during the post-battle sequence when the gang is buying equipment."
  elsif a_question.match?(/^GHAST$/i)
    "When a fighter uses Ghast, they roll a D6. On a 1, they become subject to the Insane condition. On a 2-5, they gain a random psychic power from the table below. On a 6, they both gain a random psychic power and become subject to the Insane condition.\n\nD6 Result\nTelekinesis – Assail (Basic):\nImmediately make a ranged attack against an enemy fighter or an obstacle within 12\" and line of sight. If hit, move the target D3\" in any direction.\n\n2 Pyromancy – Flame Blast (Basic), Continuous Effect:\nFor as long as this Wyrd Power is maintained, one ranged weapon carried by this fighter gains the Blaze Trait.\n\n3 Chronomancy – Freeze Time (Double):\nAll fighters, friend and foe, within 12\", may only take a single action when activated for the remainder of this round.\n\n4 Technomancy – Weapon Jinx (Simple):\nChoose an enemy fighter within 18\" of this fighter. The enemy fighter must immediately make an Ammo check for one of their weapons, chosen by this fighter.\n\n5 Telepathy – Terrify (Double):\nChoose an enemy fighter within 18\" of this fighter. The enemy fighter must make a Nerve test with -3 to the roll or become subject to the Broken condition.\n\n6 Biomancy – Quickening (Basic), Continuous Effect:\nFor as long as this Wyrd Power is maintained, increase this fighter’s M by 3 and their WS, BS and I by 1 (to a maximum of 2+).\n\nSIDE EFFECTS\nAt the end of any game in which a fighter used Ghast, they must make a Willpower check. If the check is failed, the fighter suffers a decrease of 1 to their Willpower (i.e., if the fighter’s Willpower is 7+, it becomes 8+). If a natural 12 is rolled for the check, the fighter’s mind is permanently damaged and they must begin any future battles subject to the Insane condition."
  elsif a_question.match?(/^ICROTIC SLIME$/i)
    "When a fighter uses Icrotic Slime, make a Characteristic check for their Movement, Strength, Toughness, Initiative, Attacks and Cool characteristics. For each test that is passed, improve that characteristic by D3.\n\nSIDE EFFECTS\nWhilst under the effects of Icrotic Slime, the fighter’s Leadership, Intelligence and Willpower are decreased to 10+ (unless these characteristics are already worse than this). At the end of any battle in which a fighter used Icrotic Slime, roll 2D6 for that fighter. On a roll of 2, the slime eats the fighter’s brain and they are killed. Immediately remove them from the gang’s roster. On a roll of 3-11, the slime is successfully removed but the fighter is placed Into Recovery. On a roll of 12, the slime is successfully removed but not without complications. Make a roll on the Lasting Injury table against the fighter, re-rolling results of 61-66."
  elsif a_question.match?(/^KALMA$/i)
    "In addition to other methods of use, a gang can give Kalma to a fighter they hold captive during the Rescue scenario. When a fighter affected by Kalma wishes to make an action, roll 2D6 for them and add their Toughness. On a roll of 11 or lower, they do nothing and the action is wasted. On a roll of 12 or more, they shake off the effects of the chem and can act normally for the remainder of the battle.\n\nSIDE EFFECTS\nThere are no long term effects from taking Kalma."
  elsif a_question.match?(/^OBSCURA$/i)
    "In addition to other methods of use, a gang can give Obscura to a fighter they hold captive during the Rescue scenario. A fighter under the influence of Obscura changes their Movement characteristic to D6\" and all their weapons count as having the Reckless trait.\nNote that when they move, a fighter under the influence of Obscura must move the full distance rolled, even if this would take them into base contact with an enemy fighter, in which case they will Engage that enemy fighter, or over the edge of a ledge. Fighters under the influence of Obscura must still respect the 1\" rule – if they cannot get into base contact with an enemy fighter when moving, they must stop 1\" away.\nIn the End phase of each round a fighter affected by Obscura may, if their controlling player wishes, roll 2D6 and add their Toughness. If the result is 12 or more, they shake off the effects of the chem.\n\nSIDE EFFECTS\nWhen a dose of Obscura wears off, the fighter enters a deep melancholy and they may only perform a single action in each of their activations for the remainder the battle.\nDuring the Wrap-up, any fighter who used Obscura must make a Toughness check. If the check is failed, the fighter has become addicted to Obscura. Once a fighter is addicted to Obscura, they can only be included in a crew on a D6 roll of a 4+ prior to the battle. The only way a fighter can shake this addiction is to pay 2D6x10 credits for anti-addiction chems during the post-battle sequence when the gang is buying equipment."
  elsif a_question.match?(/^(‘|)SLAUGHT$/i)
    "A fighter affected by ‘Slaught increases their Weapon Skill and Initiative to 2+ and adds 1 to their Attacks characteristic.\n\nSIDE EFFECTS\nDuring the Wrap-up, any fighter who used ‘Slaught must make a Toughness check. If the check is failed, the fighter has become addicted to ‘Slaught. In each future battle the fighter takes part in, if they do not take a dose of ‘Slaught, they must decrease their Weapon Skill and Initiative to 5+, and their Attacks to 1 (unless these characteristics are already worse than this). If they take a dose, the effects are reduced and their Weapon Skill and Initiative become 3+ and they gain no bonus to their Attacks characteristics. A fighter can shake their addiction to ‘Slaught by voluntarily going into Recovery during any post-battle sequence."
  elsif a_question.match?(/^SPUR$/i)
    "A fighter affected by Spur increases their Movement characteristic by 2 and improves their Initiative characteristic to 2+.\n\nSIDE EFFECTS\nOnce a fighter has taken a dose of Spur, they must check to see if it wears off in each subsequent End phase. Roll 2D6 for the fighter and add their Toughness. If the result is 10 or more, the Spur has worn off and the fighter is no longer subject to its effects."
  elsif a_question.match?(/^STINGER MO(U|)LD$/i)
    "A dose of Stinger Mould can be used after a fighter has rolled on the Lasting Injury table. If the result of the roll was anything other than a 66 – Memorable Death, the result it is ignored (including positive results such as 11 – Lesson Learned).\nAlternatively, a fighter can attempt to use a dose of Stinger Mould to remove an existing Lasting Injury. During Step 6 of the post-battle sequence, after distributing equipment but before updating the gang roster, roll a D6 for any fighter attempting to use Stinger Mould in this way. On a 5 or 6, the effects of one Lasting Injury the fighter has suffered are immediately negated.\n\nSIDE EFFECTS\nThere are no long term effects of taking Stinger Mould."


  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # elsif a_question.match?(/^$/i)
  #   "++DONT YOU MEAN JONATHAN++"

  # CONDITIONS
  elsif a_question.match?(/^ACTIVE$/i)
    "A Standing fighter is Active if they are not currently Engaged with any enemy fighters. This is the default Status for a fighter; Standing and Active, and such fighters enjoy the greatest freedom to perform actions."
  elsif a_question.match?(/^BLIND(|ED)$/i)
    "A blinded fighter loses their Ready marker; if they do not have a Ready marker, they do not gain a Ready marker at the start of the following round. Until the next time the fighter is activated, they cannot make any attacks other than reaction attacks, for which any hit rolls will only succeed on a natural 6."
  elsif a_question.match?(/^BOTTLE(| TESTS|TEST)$/i)
    "At the start of the End phase, either or both players will be required to make a Bottle test for their gang if one or more of their fighters are either Seriously Injured or Out of Action.\nTo make a Bottle test for the gang, roll a D6 and add to the result the total number of fighters that are Seriously Injured or Out of Action. If the final result is higher than the total number of fighters in the starting crew (the number of fighters who were present at the start of the battle), then the gang as a whole has failed the Bottle test and has bottled out.\n\nFLEEING THE BATTLEFIELD\nOnce a gang has bottled out, fighters may begin to flee the battlefield. At the start of the Action phase, the controlling player will have to make a Cool check for each of their fighters on the battlefield. Each fighter that fails this Cool check will immediately flee the battlefield and is removed from play.\n\nLEADING BY EXAMPLE\nFighters draw courage from their leaders and will follow their example:\n- If the gang Leader passes their Cool check, any friendly fighters within 12\" are considered to have passed their Cool check and will not flee the battlefield.\n\n- If a Champion passes their Cool check, any friendly fighters that are not the Leader or another Champion within 6\" are considered to have passed their Cool check and will not flee the battlefield."
  elsif a_question.match?(/^BROKEN$/i)
    "A fighter may become Broken as the result of seeing a friendly fighter Seriously Injured or taken Out of Action within 3\" of them. Broken fighters may not perform any actions other than Running for Cover (Double) and if Engaged may only make Reaction attacks with a -2 modifier. They will make a Running for Cover (Double) action every time they are activated. Broken fighters may be rallied in the End phase.\nWhen a Broken fighter moves they must attempt to end their move, in order of priority:\n\n1. So that they are more than 3\" away from enemy fighters.\n\n2. So that they are out of line of sight of enemy fighters.\n\n3. In partial or full cover.\n\n4. As far away from any enemy fighters as possible.\n\nIf a Broken fighter is Standing and Engaged when activated, they must make an Initiative check. If it is passed, they must move as described previously. Each enemy fighter that is Engaged with them makes an Initiative check and if passed can make Reaction attacks before the Broken fighter is moved. If the Broken fighter fails the Initiative check, they remain Engaged and can perform no further actions."
  elsif a_question.match?(/^ENGAGED$/i)
    "If the base of a Standing fighter is touching the base of an enemy fighter, they are said to be in base to base contact and are Engaged with that enemy fighter. A Standing fighter that is Engaged can generally only choose to fight or retreat, but factors such as skills may increase the number of available options.\nPlayers should note that in some cases a fighter may be able to Engage an enemy fighter they are not in base to base contact with and may act accordingly when activated."
  elsif a_question.match?(/^HERETEK$/i)
    "If a gang includes a Heretek then it can have them enhance one of the gang’s weapons before a game. At the end of Step 5 of the pre-battle sequence, select one fighter from your crew. One of the weapons carried by the fighter gains either the Blaze, Concussion, Power, Rad-phage or Shock trait, as chosen by the controlling player. The weapon also gains the Unstable trait, or the Reckless trait if it has the Melee trait as well. These traits last until the end of the battle."
  elsif a_question.match?(/(^INSANITY|INSANE)$/i)
    "Fighters that have become subject to the Insane Condition for any reason can act quite erratically when activated. When activating an Insane fighter, roll a D6 and consult the table below:\n\n1-2: The fighter immediately becomes Broken – or, if they were already Broken, they flee the battlefield (even if their gang has not failed a Bottle test).\n\n3-4: The opposing player can control the Insane fighter for the duration of this activation, treating them as part of their gang in all respects until their activation ends. As soon as their activation ends, the Insane fighter no longer counts as being a part of the opposing gang. In the case of a multi-player game, the winner of a roll-off between the other players will control the Insane fighter.\n\n5-6: The fighter can act as normal. Once their activation is over, make a Willpower check for them. If it is passed, they lose their Insanity marker."
  elsif a_question.match?(/^OUT OF AMMO$/i)
    "Should a fighter roll the Ammo symbol on the Firepower dice, they are required to make an immediate Ammo check for that weapon. If this is failed, that weapon is now Out of Ammo and a marker is placed on the appropriate weapon profile on their Fighter card as a reminder that the weapon cannot be used until it has been reloaded."
  elsif a_question.match?(/^PRONE$/i)
    "A fighter that is laid down is Prone. A Prone fighter has no facing and they effectively have no vision arc. Unless otherwise stated, Prone fighters never block line of sight – they are considered to be well out of the way of the action. A Prone fighter may be placed face-up or facedown, depending upon their Secondary Status.\nWhilst Prone, a fighter will always be subject to one of two Secondary Statuses as well; Pinned or Seriously Injured. This Secondary Status will affect the actions a Prone fighter may perform and the way in which other fighters may interact with them."
  elsif a_question.match?(/^READY$/i)
    "The most simple but arguably the most important Condition. At the start of each round, during the Priority phase, all fighters will have a Ready marker placed on them. Once that fighter has activated during the Action phase, this marker is removed, indicating that the fighter may not be activated again."
  elsif a_question.match?(/(^RUNNING|RUN) FOR COVER$/i)
    "(DOUBLE): If the fighter is Standing and Active, they will move 2D6\". If the fighter is Prone and Pinned or Prone and Seriously Injured, they can only move half of their Movement characteristic."
  elsif a_question.match?(/^STRAY SHOTS$/i)
    "If an attack with a ranged weapon misses, there is a chance that other fighters, friendly or enemy, that are Engaging the target, or that are within 1\" of the line along which the range between the attacker and the target was measured, will be hit.\nIf the attack misses, roll a D6 for each fighter that is at risk of being hit, starting with the fighter closest to the attacker. On the roll of 1, 2 or 3, the fighter is hit by the attack. On a 4, 5 or 6, the shot misses them - move on to the next fighter at risk of being hit. If the attack would have caused more than one hit, follow this sequence for every hit."
  elsif a_question.match?(/^WEBBED$/i)
    "Treat the fighter as if they were Seriously Injured and roll for Recovery for them during the End phase. If a Flesh Wound result is rolled during Recovery, apply the result to the fighter as usual and remove the Webbed condition. If a Serious Injury is rolled, the fighter remains Webbed. If an Out of Action result is rolled, the fighter succumbs and is removed from play, automatically suffering a result of 12-26 (Out Cold) on the Lasting Injuries table.\nA fighter that is Webbed at the end of the game does not succumb to their Injuries and will automatically recover. However, during the Wrap Up, when rolling to determine if any enemy fighters are Captured at the end of the game, add +1 to the dice roll for each enemy fighter currently Webbed and include them among any eligible to be Captured."

  # WEAPON TRAITS JP
  elsif a_question.match?(/^(assault|energy) shield JP$/i)
    "アサルト/エナジーシールドは、ファイターの視界アーク（前方90度の弧）内からの近接攻撃に対して+2、ファイターの視界アーク内からの遠距離攻撃に対して+1のアーマーセーフの修正を与える。攻撃者がターゲットのフロントアーク内にいるかどうかがはっきりしない場合、ビジョンアーク・テンプレートを使って確認する--攻撃者のベースの中心がアーク内にある場合、アサルト／エナジーシールドを使用できる。Blast 特性を有する攻撃に対しては、攻撃側の代わりに Blast マーカの中心を使用する。目標に向きがない場合(例えば、伏せられている場合)、突撃/エネルギー シールドを使用することはできない。"
  elsif a_question.match?(/^BACKSTAB JP$/i)
    "攻撃者が対象の視界アーク内にいない場合、攻撃のStrengthに1を加算する。"
  elsif a_question.match?(/^blaze JP$/i)
    "Blazeの特性を持つ攻撃が解決された後、対象が命中したが行動不能になっていない場合、D6を振る。4、5、6が出た場合、その対象はBlazeの対象となる。\n\n発動時、Blaze状態を受けたファイターは即座にStrength 3、AP -1、Damage 1のダメージを受けた後、以下のように行動するようになる。\n\n- Prone and Pinnedの場合、ファイターは直ちにStanding and Activeになり、以下のように行動します。\n\n- スタンディングでアクティブの場合、ファイターはScatterダイスで決定されたランダムな方向に2D6\"移動します。この移動によって敵のファイターから1インチ以内に入るか、通れない地形に接触する場合、ファイターは移動を停止する。移動によって平地やプラットフォームの端から1/2インチ以内に入る場合、29ページで説明されているように落下する危険があります。この移動で平地やプラットフォームの端を超えた場合、そのまま落下します。この移動の終わりに、ファイターはProneとPinnedになることを選択できます。その後、消火を試みることができます。\n\n- 立っていて交戦中、または伏せていて重傷の場合、ファイターは動かずに消火を試みる。\n\n消火を試みるには、D6を1回振り、その結果に1インチ以内の他のアクティブな味方ファイター1人ごとに1を加える。結果が6以上の場合、炎は消え、ブレイズ・マーカーは取り除かれる。固定されているファイターや重傷を負ったファイターは、炎が消えるかどうかを確認するために、ダイスの結果に2を足す。"
  elsif a_question.match?(/^burrowing JP$/i)
    "埋伏武器は、発射者の視線の外にある目標に対して発射することができる。視線外の目標に発射する場合、攻撃ロールを行わず、代わりに3\"厚の錫杖を置く。Blastマーカーを戦場の任意の場所に置き、Scatterダイスで決定された方向に2D6\"移動する。散布ダイスに命中が 出た場合、Blast マーカーを移動させない。この武器が発射されたラウンドの終了フェイズ開始時、ステップ 1 より前 に、このマーカーに触れているファイターはこの武器によって攻撃を 受ける。Blastマーカーが戦場から移動した場合、その攻撃は何の効果もない。Burrowing武器は数段の壁や床を掘り進むことができ、ファイターが戦場のどこにいても使用することができます。"
  elsif a_question.match?(/^chem delivery JP$/i)
    "ケム・デリバリーの特性を持つ武器を使用する場合、ファイターはどのようなケムをターゲットに発射するかを宣言します。これはファイターが装備しているどのようなケムでもかまいません（武器を発射してもケムの消費はなく、味方ファイターは対象にならないことに注意してください）。化学薬品の運搬攻撃では、負傷判定を行なう代わりにD6を振ります。その結果が対象のタフネスと同じかそれ以上の場合、あるいはナチュラル6だった場合、対象は化学物質を投与されたのと同じように影響を受けます。出目が対象のタフネスより低い場合、対象はその化学薬品の影響を受けない。"
  elsif a_question.match?(/^combi JP$/i)
    "コンビ・ウェポンは2つのプロファイルを持つ。発射時には、2つのプロファイルのうち1つを選んで攻撃に使用する。コンパクトな武器のため、弾薬の容量が少ないことが多く、ジャムやその他の細かい問題が発生しやすい。どちらの武器でも弾薬チェックをするときは、2回振って一番悪い結果を適用する。ただし、2つのプロファイルを持つ多くの武器とは異なり、コンビ武器の2つの部分の弾薬は別々に追跡される。一方のプロファイルが弾切れになっても、もう一方のプロファイルも弾切れにならない限り発射することができる。"
  elsif a_question.match?(/^concussion JP$/i)
    "Concussion weapon によって命中したモデルは、ラウンド終了時までその Initiatives を 2 減らし、最低 6+ とする。"
  elsif a_question.match?(/^cursed JP$/i)
    "Cursedの特性を持つ武器で殴られたファイターは、Willpowerチェックを行わなければInsaneの状態を得ることができない。"
  elsif a_question.match?(/^defoliate JP$/i)
    "肉食植物がDefoliateの特性を持つ武器に当たった場合、直ちにD3のダメージを受ける。枯葉の特性を持つ武器で攻撃を受けた Brainleaf Zombies は負傷を失い、負傷のダイスの結果が行動不能であった場合、戦場から取り除かれる。"
  elsif a_question.match?(/^demolition(s|) JP$/i)
    "解体の特性を持つ手榴弾は、風景の目標（鍵のかかったドアやシナリオの目標など）に対して接近戦を行う際に使用することができます。この方法で手榴弾を使用したファイターは、（通常の攻撃ダイスの数に関係なく）1回攻撃を行い、自動的に命中します。"
  elsif a_question.match?(/^digi JP$/i)
    "デジ・ウェポンは指輪に装着するか、グローブの中に隠して使用する。ファイターが持っている他の近接武器やピストルに加えて使用することができ、追加ショットや追加近接攻撃を与えることができる。この特性を持つ武器はファイターが所持できる武器の最大数にカウントされないが、この特性を持つ武器の最大数は10である。"
  elsif a_question.match?(/^disarm JP$/i)
    "Disarm武器による攻撃の当たり判定が自然6の場合、その戦闘中に対象は反応攻撃を行う際にいかなる武器も使用できず、代わりに非武装攻撃を行う。"
  elsif a_question.match?(/^drag JP$/i)
    "ファイターがドラッグ・ウェポンの攻撃を受けたが行動不能にならなかった場合、攻撃者は攻撃解決後に対象をドラッグして近づけようと試みることができます。その場合、d6を1回振る。そのスコアが対象の体力と同じかそれ以上の場合、対象は攻撃側の方向にD3\"まっすぐ引きずられ、地形にぶつかったら止まる。攻撃側以外のファイターとぶつかった場合、両方のファイターが攻撃側の方向に残りの距離だけ移動します。\n\nこの武器がインペイルの特殊ルールを持ち、複数のファイターに命中した場合、最後に命中したファイターだけがドラッグされることがあります。"
  elsif a_question.match?(/^entangle JP$/i)
    "Entangleの特性を持つ武器によるヒットは、Parryの特性によって否定されることはない。さらに、Entangle武器の命中判定がナチュラル6の場合、ターゲットが行う反応攻撃にはさらに-2の命中修正が加えられる。"
  elsif a_question.match?(/^fear JP$/i)
    "恐怖の特性を持つ攻撃に対して傷害のロールを行う代わりに、相手プレイヤーは対象に対して神経テストを行い、その結果から2を引く。テストが失敗した場合、対象は直ちに壊れ、隠れて走る。"
  elsif a_question.match?(/^flare JP$/i)
    "Flareの特性を持つ武器からヒットを受けたファイター、またはFlareの特性を持つ武器から発射されたBlastマーカーに触れたファイターは、戦場が暗闇（Pitch Blackを参照）であればRevealedとなる。Blast マーカが到達する場所を決定した後、武器が Flare 特性と Blast 特性の両方を有している場合、その場所に残す。終了フェイズに、D6 をふる。4 以上の場合、火炎信号は消滅してそのマーカーは除去され、そうでない 場合はそのままプレイされる。Blast マーカがボード上にある間、少なくともそれに触れているす べてのモデルは Blaze マーカーまたは Revealed マーカーを有してい るかのように照らされる。"
  elsif a_question.match?(/^flash JP$/i)
    "ファイターが閃光武器で命中した場合、傷のロールは行いません。その代わり、対象のイニシアチブ・チェックを行う。失敗した場合、そのファイターは盲目となる。盲目になったファイターはReadyマーカーを失います。Readyマーカーを持っていない場合、次のラウンドの開始時にReadyマーカーを獲得することはありません。次にそのファイターが起動されるまでは、リアクション攻撃以外の攻撃を行うことができず、その際のヒットロールは自然6の場合のみ成功します。"
  elsif a_question.match?(/^FORCE JP$/i)
    "サイカーでない者が手にした場合、フォース・ウェポンに追加効果はない。しかし、Sanctioned PsykerまたはNon-Sanctioned Psykerの特殊ルールを持つファイターが使用する場合、その武器はPowerとSeverの両方の特性を獲得する。"
  elsif a_question.match?(/^gas JP$/i)
    "ファイターがガス兵器による攻撃を受けたとき、そのファイターは固定されず、傷のロールは行われません。代わりにD6を振る。その結果が対象のタフネスと同じかそれ以上であるか、自然6の場合、（傷の特性に関係なく）その対象の傷のロールを行う。出目が対象のタフネスより低い場合、その対象はガスの影響を受けず、救命ロールを行うことができない。"
  elsif a_question.match?(/^graviton pulse JP$/i)
    "この武器で通常通り傷をつける代わりに、爆風に巻き込まれたモデルはD6で自分の戦力以下でなければならない（6の出目は常に失敗とみなされる）。\n\n武器が発射された後、爆風マーカーをその場に残しておく。そのラウンドの残りの間、この領域を通って移動しているモデル は移動量 1\" につき 2\" を使用する。終了フェイズに爆風マーカーを取り除く。"
  elsif a_question.match?(/^grenade JP$/i)
    "手榴弾は武具でありながら、特殊な射撃武器として扱われる。手榴弾を装備したファイターは、射撃（基本）アクションとして手榴弾を投げることができる。グレネードには短射程がなく、長射程はファイターのStrengthに表示されている値を掛けたものになります。\n\nファイターは限られた数のグレネードしか所持できません。グレネードで攻撃する場合、火力ダイスは振られません。手榴弾で攻撃する場合、火力のダイスは振られません。その代わり、攻撃が解決された後、自動的に弾薬のチェックが行われます。失敗した場合、手榴弾の再装填はできません。ファイターはその種類の手榴弾を使い果たし、残りの戦闘の間、手榴弾を使用することはできません。"
  elsif a_question.match?(/^gunk JP$/i)
    "ガンクの特性を持つ武器で殴られたファイターはガンク状態になる。ガンク状態になったファイターは、移動特性を最小で1減らし、チャージ・アクションを行う際に移動にD3を加算しない。さらに、イニシアティブ・チェックを行う際のダイスの目から1を引く。また、Gunkedファイターは燃えやすく、Blazeの特性を持つ武器で殴られた場合、4+ではなく2+で火がつく。\n\nGunkedの状態はエンドフェイズまで、またはBlazeの特性を持つ武器の攻撃を受けてファイターが火傷を負うまで続く。"
  elsif a_question.match?(/^HEXAGRAMMATIC JP$/i)
    "この武器で使用される弾薬は、サイキック防御を破り、サイカーに深刻なダメージを与えるよう特別に処理されたものである。この特性を持つ武器の攻撃は、サイキック・パワーによるセーブを無視する。さらに、この特性を持つ武器はサイカーに対して2倍のダメージを与える。"
  elsif a_question.match?(/^IMPALE JP$/i)
    "この武器による攻撃が対象に命中して負傷させ、セーブ・ロールが失敗した場合（あるいはセーブ・ロールが行われなかった場合）、弾丸は対象を貫通し、他のファイターに命中するかもしれない！？標的から、攻撃者から直接離れるように一直線になぞる。この直線から1インチ以内にファイターがいて、武器のロングレンジ内にいる場合、ターゲットに最も近いファイターが命中する危険性があります。D6を振り、3以上の場合、そのファイターに対する武器の攻撃を決定し、戦力から1を引く。この方法で弾丸は複数のファイターを貫通することができますが、Strengthが0になるとそれ以上のファイターには当たりません。"
  elsif a_question.match?(/^KNOCKBACK JP$/i)
    "ノックバックの特性を持つ武器の命中率が対象の体力と同じかそれ以上の場合、その対象は直ちに攻撃したファイターから直接1インチ離れた場所に移動します。通り抜けられない地形や他のファイターのせいで1インチ全部を移動できない場合、そのファイターは可能な限り遠くに移動し、攻撃のダメージは1増加します。\n\nブラスト武器にノックバックの特性がある場合、命中したファイター1体につき、D6を1回振ります。その結果が体力と同じかそれ以上であった場合、上記のようにノックバックされますが、代わりにブラストマーカーの中心から直接離れるように移動します。爆風マーカーの中心がその拠点の中心より上にある場合、散布ダイスを 1 個 振ってその移動方向を決定する。\n\nMeleeウェポンがノックバックの特性を持つ場合、攻撃側のファイターはターゲットがノックバックされた後、直接ターゲットに向かって移動し、ベースコンタクトを維持したままフォローすることを選択できる。攻撃がバリケードを越えて行われた場合、攻撃者はこれを行うことができない。\n\nノックバックされたファイターの基盤の一部がプラットフォームの縁を越えている場合、イニシアチブ・チェックを行います。失敗した場合、ファイターは落下します。成功した場合、ファイターはプラットフォームの端で動きを止めます。"
  elsif a_question.match?(/^LIMITED JP$/i)
    "この特別なルールは、武器に購入できる一部の特殊な弾薬に適用されます。限定弾薬を使用しているときに弾薬チェックに失敗すると、その武器は使い果たしたことになります。その弾薬はファイターカードから削除され、交易所からその特殊弾薬を購入するまで再び使用することができなくなります。これは武器の弾薬切れに関する通常のルールに加えて行われます。武器は通常通り、残っているプロファイルを使って再装填することができます。"
  elsif a_question.match?(/^MASTER(-| |)CRAFTED JP$/i)
    "1戦闘につき、Master-craftedの武器を持つファイターは、失敗した命中判定を1回だけ再ロールすることができる。"
  elsif a_question.match?(/^MELEE JP$/i)
    "近接攻撃時に使用できる武器です。"
  elsif a_question.match?(/^MELTA JP$/i)
    "この特性を持つ武器の近距離攻撃でファイターの傷口が0になった場合、Injuryダイスは振られませんが、代わりにInjuryダイスが振られた場合、自動的にOut of Actionという結果になります。近距離武器がない場合、メルタの特性はその武器で行われるすべての攻撃に影響します。"
  elsif a_question.match?(/^PAIRED JP$/i)
    "ペアウェポンで武装しているファイターは、攻撃のダイスの数を計算するために、Melee特性のあるデュアルウェポンで武装しているものとしてカウントされます。さらに、チャージ（ダブル）アクションを行った場合、その攻撃力は2倍になる。"
  elsif a_question.match?(/^PARRY JP$/i)
    "敵がParry武器を装備したファイターに対して接近戦を仕掛けた後、防御側のファイターのオーナープレイヤーは、攻撃側のプレイヤーにヒット1回分のリロールを成功させることができます。防御側のファイターが2つのパリィ・ウェポンを装備している場合、その持ち主は攻撃側のファイターに対して、代わりに2回のリロールを成功させることができます。"
  elsif a_question.match?(/^PHASE JP$/i)
    "鎧やフィールドアーマーによるセーブロールは、この特性を持つ武器に対して行うことはできない。命中した場合、セーブがないものとして扱う。ただし、特別なルールによるセーヴは可能であり、この特性はアーマーとフィールドアーマーのみを無視する。"
  elsif a_question.match?(/^PLENTIFUL JP$/i)
    "この武器の弾薬は非常に一般的なものです。リロードする際、弾薬のチェックは必要なく、自動的にリロードされます。"
  elsif a_question.match?(/^POWER JP$/i)
    "パワーウェポンによる攻撃は、他のパワーウェポン以外では受け流すことができません。\n\nまた、パワー・ウェポンの命中判定が6の場合、その攻撃に対してセーブロールを行うことができず、そのダメージは1増加します。"
  elsif a_question.match?(/^PULVERISE JP$/i)
    "この武器による攻撃で負傷の判定を行った後、攻撃プレイヤーはD6を振ることができる。その結果が対象のタフネスと同じかそれ以上であるか、自然6の場合、負傷のダイス1つを肉体の負傷の結果から重傷の結果に変更することができる。"
  elsif a_question.match?(/^rad( |-)phage JP$/i)
    "この特性を持つ武器からファイターが受けた命中が完全に解決された後、さらにD6を振ります。出目が4以上の場合、そのファイターは追加でFlesh Woundを受けます。"
  elsif a_question.match?(/^RAPID FIRE JP$/i)
    "速射武器で射撃する場合、ヒットロールに成功すると、火力ダイスの弾痕の数と同じ数のヒットを獲得します。また、操作プレイヤーは括弧内の数まで、複数の火力ダイスを振る ことができる（例えば、速射砲(2)を発射する場合、火力ダイスは最大で 2 個まで振ることができる）。出た弾薬のシンボルごとに弾薬チェックを行います。どれか1つでも失敗すれば、その銃は弾切れになります。2つ以上失敗した場合、銃はジャムってしまい、その後の戦闘で使用することはできません。\n\nRapid Fire武器が複数のヒットを出した場合、そのヒットを複数のターゲットに分割することができる。最初のヒットは最初のターゲットに割り当てられなければならないが、残りのヒットは最初のターゲットから3インチ以内で射程と視線内にある他のファイターに割り当てることができる。これらのターゲットは最初のターゲットよりも命中しにくいものであってはならない。開けた場所にいるターゲットに命中した場合、隠れているターゲットに命中させることはできない。負傷のロールをおこなう前にすべての命中率を割り当てる。"
  elsif a_question.match?(/^RECKLESS JP$/i)
    "無謀な武器は対象が無差別である。この特性を持つ武器は、通常のターゲット優先ルールを無視する。その代わり、この特性を持つ武器で攻撃を行う前に、ファイターの視線内にいるすべての対象モデルからランダムに攻撃対象を決定する。"
  elsif a_question.match?(/^RENDING JP$/i)
    "レンディング・ウェポンの傷の出目が自然6の場合、その攻撃は1点の追加ダメージを与える。"
  elsif a_question.match?(/^SCARCE JP$/i)
    "弾薬の入手が困難なScarce武器は、リロードができないため、一度弾薬を使い切ると、戦闘中に再び使用することはできません。"
  elsif a_question.match?(/^SCATTERSHOT JP$/i)
    "ターゲットに散弾が命中したとき、1の代わりにD6の傷の出目を行う。"
  elsif a_question.match?(/^SEISMIC JP$/i)
    "Seismic攻撃の対象がActiveであれば、通常Ranged攻撃によるPinnedを回避できる能力を持っていたとしても、常にPinnedとなる。さらに、Seismic武器の傷の判定がナチュラル6の場合、その攻撃に対してセーブロールを行うことができない。"
  elsif a_question.match?(/^SEVER JP$/i)
    "この特性を持つ武器の傷によってファイターの傷が0になった場合、傷のダイスは振られません。代わりに、傷のダイスが振られた場合、自動的に行動不能の結果が発生します。"
  elsif a_question.match?(/^SHIELD( |)BREAKER JP$/i)
    "この特性を持つ武器は、アサルトシールド/エナジーシールドの特性の効果を無視する。また、Field Armourを装備した対象がこの特性を持つ武器で負傷した場合、Field Armourのセーブを行う際に2つのダイスを振り、結果の低い方を選択しなければならない。"
  elsif a_question.match?(/^SHOCK JP$/i)
    "衝撃武器の命中判定が自然6の場合、傷の判定は自動的に成功したとみなされる(傷の判定をする必要はない)。"
  elsif a_question.match?(/^SHRED JP$/i)
    "この特性を持つ武器で傷をつけるための出目が自然6の場合、その武器の鎧の貫通力は2倍になる。"
  elsif a_question.match?(/^SIDEARM JP$/i)
    "この特性を持つ武器は、範囲攻撃を行うことができ、また接近戦では単体攻撃を行うことができる。ただし、精度のボーナスは範囲攻撃をするときにのみ適用され、接近戦をするときに適用されるわけではない。"
  elsif a_question.match?(/^SILENT JP$/i)
    "スニークアタックの特別ルールを使用するシナリオでは、この武器を発射したときに警報が鳴るかどうかのテストは行われない。さらに、Pitch Blackルールを使用する場合、隠れているこの武器を使用するファイターは、Revealedにならない。"
  elsif a_question.match?(/^SINGLE SHOT JP$/i)
    "この武器は1ゲームに1回しか使用できません。使用後は自動的に弾薬チェックに失敗したものとみなされる。この武器が「速射（X）」の特性を持っていない限り、火力ダイスを振る必要はない。"
  elsif a_question.match?(/^SMOKE JP$/i)
    "煙火はファイターに命中させることはできません。その代わり、それらが命中した場所をカウンターでマークする。この領域は 5 インチブラストマーカーで決定できるが、水平方向だけでな く垂直方向にも広がっていると考える必要がある。戦闘員は煙の中を移動できるが、煙は視線を遮るため、煙の中、外、 または煙を通って攻撃をおこなうことはできない。エンドフェイズに、D6を振ります。4以下であれば、雲は消滅し、カウンターは取り除かれる。"
  elsif a_question.match?(/^template JP$/i)
    "テンプレート兵器は、Flame テンプレートを使用して、命中する対象の数を決定します。"
  elsif a_question.match?(/^TOXIN JP$/i)
    "毒素攻撃で傷のロールを行う代わりに、D6を振る。その結果が対象のタフネスと同じかそれ以上であるか、自然な6であった場合、その対象について負傷のロールを行う（傷の特性に関係なく）。出目が対象のタフネスより低い場合、その対象は毒素の効果を無視する。"
  elsif a_question.match?(/^UNSTABLE JP$/i)
    "この武器で攻撃するとき、火力ダイスに弾薬記号が出た場合、弾薬チェックが必要な上、オーバーヒートする可能性があります。D6を振ってください。1、2、3の場合、武器は壊滅的なオーバーロードを起こし、攻撃者は行動不能になります。攻撃はまだターゲットに対して解決されます。"
  elsif a_question.match?(/^UNWIELDY JP$/i)
    "この武器で行う射撃アクションは、シングルアクションではなく、ダブルアクションとしてカウントされる。また、接近戦でUnwieldyとMeleeの両方の特性を持つ武器を使用するファイターは、同時に2つ目の武器を使用することはできません-この武器は両手を使う必要があります。"
  elsif a_question.match?(/^VERSATILE JP$/i)
    "多用途武器の使用者は、その発動中に敵のファイターと近接戦闘を行うために、そのファイターと基本的に接触している必要はない。自分の拠点と敵ファイターの拠点との距離が、万能武器の遠距離特性で示された距離以下であれば、その発動中に敵ファイターと交戦し、接近戦を仕掛けることができる。例えば、射程2インチの万能武器を装備したファイターは、射程2インチまでの距離にいる敵のファイターと交戦することができる。\n\n敵のファイターは交戦中とみなされますが、万能武器を装備しているファイターが交戦中でない限り、そのファイターも万能武器を装備しているので、反応攻撃を行うことができない可能性があります。\n\nこのファイターの発動中以外の時は、Versatileは何の効果も持ちません。"
  elsif a_question.match?(/^WEB JP$/i)
    "Web攻撃の傷のロールが成功した場合、傷は与えられず、セーブロールやインジャリーロールは行われない。その代わり、対象は自動的に蜘蛛の巣になる。そのファイターは重傷を負ったものとして扱い、エンドフェイズに回復のためのロールを行います（ウェブには強力な鎮静剤が含まれており、最も強いファイターでも意識を失わせることが可能です）。回復中にFlesh Woundの結果が出た場合、その結果を通常通りそのファイターに適用し、Webbedの状態を解除します。もしSerious Injuryが出た場合、そのファイターはWebbedのままです。行動不能の結果が出た場合、そのファイターは強力な鎮静剤に負けてプレイから外され、自動的にLasting Injuriesテーブルの結果が12-26（Out Cold）となります。\n\nゲーム終了時にWebbedになっているファイターは、Injuryに屈せず、自動的に回復します。ただし、Wrap Upの間、ゲーム終了時に敵ファイターを捕獲するかどうかを決定するダイスを振るとき、現在Webbedになっている敵ファイター1体につき+1し、捕獲対象として含める。"
    



  # OTHER
  elsif a_question.match?(/^pham$/i)
    "++DONT YOU MEAN JONATHAN++"
  else
    "++ENTER KEYWORD EXACTLY++\n++CHECK README TO SEE SUPPORTED RULES++"
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
