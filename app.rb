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

  if a_question.match?(/collapsed dome/i)
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
  elsif a_question.match?(/OUT( |-)HIVE SMUGGLING ROUTES/i)
    "RACKET BOONS\n
Income: The gang earns D6x10 credits when they collect Income.\n
ENHANCED BOONS
Linked Rackets: Ghast Prospecting, The Cold Trade.\n
Income: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\n
Income: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/LIFE COIN EXCHANGE /i)
    "RACKET BOONS\n
Recruit: Whilst it controls this Racket, the gang may recruit two Hive Scum or one Bounty Hunter Hired Gun for free, including their equipment, prior to every battle.\n
ENHANCED BOONS
Linked Rackets: Whisper Brokers, Corpse Guild Bond.\n
Income: If the gang also controls one of the Linked Rackets, the gang earns D6x10 credits when they collect Income.\n
Special: If the gang also controls both of the Linked Rackets, all of its members gain the Fearsome skill."
  elsif a_question.match?(/GAMBLING EMPIRE/i)
    "RACKET BOONS\n
Income: The player of the gang that controls this Racket chooses a suit of cards and then draws a card from a shuffled deck of playing cards. If they draw a card from the suit they chose, they earn income equal to the value of the card (Jack 11, Queen 12, King 13) x 10 credits. If they draw a card from a suit of the same colour, they earn income equal to the value of the card x 5 credits. If it is any other suit, they gain no income.\n
ENHANCED BOONS
Linked Rackets: Blood Pits, Whisper Brokers.\n
Income: If the gang also controls one of the Linked Rackets, the gang’s player may nominate a single enemy fighter (but not a Leader or Champion) at the start of the battle. The gang has called in the fighter’s debts. The nominated fighter misses the battle."
  elsif a_question.match?(/SETTLEMENT PROTECTION/i)
    "RACKET BOONS\n
Recruit: Whilst it controls this Racket, the gang gains one Hanger-on of the controlling player’s choice for free.\n
Income: Whilst it controls this Racket, the gang gains D6x10 credits when they collect Income.\n
ENHANCED BOONS
Linked Rackets: Guild Bond (any), Bullet Cutting.\n
Income: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\n
Income: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income."
  elsif a_question.match?(/WYRD TRADE/i)
    "RACKET BOONS\n
Equipment: Whilst it controls this Racket, the gang treats Ghast as a Common item.\n
ENHANCED BOONS
Linked Rackets: Peddlers of Forbidden Lore, Whisper Brokers.\n
Income: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\n
Income: If the gang also controls both of the Linked Rackets, the gang gains 3D6x10 credits when they collect Income"
  elsif a_question.match?(/RESURRECTION GAME/i)
    "RACKET BOONS\n
Special: Whilst it controls this Racket, the gang may ignore one Critical Injury or Memorable Death result on the Lasting Injury table per battle. When these results are rolled, the fighter simply goes Into Recovery.\n
ENHANCED BOONS
Linked Rackets: Corpse Guild Bond, Peddlers of Forbidden Lore.\n
Income: If the gang also controls one of the Linked Rackets, the gang gains 2D6x10 credits when they collect Income.\n
Special: Any gang in the campaign may pay the gang controlling this Racket to return a dead fighter from the grave. This costs the original value of the fighter (including equipment) +100 credits. Roll 2D6. On a roll of 7-12 the fighter is resurrected and gains the Fearsome skill. On a roll of 3-6 the fighter is resurrected but suffers a permanent loss of 1 Toughness and gains the Fearsome skill if they don’t have it already. On a roll of 2, the resurrection fails."
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
  elsif a_question.match?(/narco( |-)distribution/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Ghast Prospecting.\nRACKET BOONS\nIncome: The gang earns D6x10 credits when they collect Income.\nSpecial: Whilst it controls this Racket, the gang treats Chem-synth, Medicae Kit, Stimm-slug Stash, and any weapon with the Gas or Toxin trait as Common.\nENHANCED BOONS\nIncome: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\nIncome: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
  elsif a_question.match?(/blaze/i)
    "After an attack with the Blaze trait has been resolved, roll
    a D6 if the target was hit but not taken Out Of Action. On
    a 4, 5 or 6, they become subject to the Blaze condition.
    When activated, a fighter subject to the Blaze condition
    suffers an immediate Strength 3, AP -1, Damage 1 hit
    before acting as follows:\n
    - If Prone and Pinned the fighter immediately becomes
    Standing and Active and acts as described below.\n
    - If Standing and Active the fighter moves 2D6\" in a
    random direction, determined by the Scatter dice. The
    fighter will stop moving if this movement would bring
    them within 1\" of an enemy fighter or into base
    contact with impassable terrain. If this movement
    brings them within 1⁄2\" of the edge of a level or
    platform, they risk falling as described on page 29. If
    this movement takes the fighter beyond the edge of a
    level or platform, they will simply fall. At the end of
    this move, the fighter may choose to become Prone
    and Pinned. The fighter may then attempt to put the
    fire out.\n
    - If Standing and Engaged or Prone and Seriously
    Injured, the fighter does not move and attempts to put
    the fire out. To attempt to put the fire out, roll a D6,
    adding 1 to the result for each other Active friendly
    fighter within 1\". On a result of 6 or more, the flames
    go out and the Blaze marker is removed. Pinned or
    Seriously Injured fighters add 2 to the result of the roll
    to see if the flames go out."
  elsif a_question.match?(/melta/i)
    "If a Short range attack from a weapon with the Melta trait
    reduces a fighter to 0 wounds, no Injury dice are rolled –
    instead, any Injury dice that would be rolled cause an
    automatic Out of Action result."
  elsif a_question.match?(/power/i)
    "The weapon is surrounded by a crackling power field.
    Attacks made by Power weapons cannot be parried
    except by other Power weapons. In addition, if the hit roll
    for a Power weapon is a 6, no save roll can be made
    against the attack and its Damage is increased by 1."
  elsif a_question.match?(/rending/i)
    "If the roll to wound with a Rending weapon is a natural 6 the attack causes 1 extra point of damage."
  elsif a_question.match?(/web/i)
    "If the wound roll for a Web attack is successful, no wound
    is inflicted, and no save roll or Injury roll is made. Instead,
    the target automatically becomes Webbed. Treat the
    fighter as if they were Seriously Injured and roll for
    Recovery for them during the End phase (Web contains a
    powerful sedative capable of rendering the strongest
    fighter unconscious). If a Flesh Wound result is rolled
    during Recovery, apply the result to the fighter as usual
    and remove the Webbed condition. If a Serious Injury is
    rolled, the fighter remains Webbed. If an Out of Action
    result is rolled, the fighter succumbs to the powerful
    sedative and is removed from play, automatically
    suffering a result of 12-26 (Out Cold) on the Lasting
    Injuries table.\n
    A fighter that is Webbed at the end of the game does not
    succumb to their Injuries and will automatically recover.
    However, during the Wrap Up, when rolling to determine
    if any enemy fighters are Captured at the end of the
    game, add +1 to the dice roll for each enemy fighter
    currently Webbed and include them among any eligible
    to be Captured."
  elsif a_question.match?(/pham/i)
    "++DONT YOU MEAN JONATHAN++"
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
