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

  if a_question.match?(/ROGUE DOC SHOP/i)
    "This Territory grants the following Boon:\n
Recruit: The gang may recruit a Rogue Doc Hanger-on for free."
  elsif a_question.match?(/settlement/i)
    "This Territory grants the following Boons:\n
Income: The gang earns D6x10 credits from this Territory when collecting income.\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Recruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a
single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their
House List for free."
  elsif a_question.match?(/slag furnace/i)
    "This Territory grants the following Boon:\n
Income: The gang-earns D6x5 credits from this Territory when collecting income.\n
ENHANCED BOON\n
This Territory grants Goliath gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +2 to its Reputation.\n
Recruit: The gang may choose to roll two D6 after every battle. On a roll of 6 on either dice, the gang may recruit a
single Juve from their House List for free. If both dice come up as 6, then the gang may recruit a Ganger from their
House List for free."
  elsif a_question.match?(/tech bazaar/i)
    "This Territory grants the following Boons:\n
Income: The gang earns D6x10 credits from this Territory when collecting income.\n
Equipment: Select one Leader or Champion to make a Haggle post-battle action. Roll 2D6: The gang may immediately
choose one item from the Rare Trade chart with a Rare value equal to the result of the dice roll and add it to their
Stash for half of its usual value, rounded down. If the roll is lower than 7, pick a Common Weapon or Piece of
equipment to add to the gang's Stash for half of its usual value, rounded down. If the roll is 3 or lower, then the fighter
proves to be very poor at haggling and no equipment is gained. If the fighter selected has Exotic Furs, add +1 to the
result of the 2D6 dice roll.\n
ENHANCED BOON\n
This Territory grants Van Saar gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Income: The gang earns D6x10 credits from this Territory when collecting income. If the gang also controls an
Archaeotech Device, this is increased to 2D6x10."
  elsif a_question.match?(/toll crossing/i)
    "This Territory grants the following Boon:\n
Income: The gang earns D6x5 credits from this Territory when collecting income.\n
ENHANCED BOON\n
This Territory grants Orlock gangs the following Boon:\n
Special: Whilst it controls this Territory, an Orlock gang has Priority in the first round of any battle. Any gang in the
campaign may pay the Orlock gang 20 credits to gain the same benefit in a single battle against another gang."
  elsif a_question.match?(/tunnels/i)
    "This Territory grants the following Boon:\n
Special: Whist it controls this Territory, the gang may choose to have up to three fighters deploy via tunnels ahead of
any battle. These fighters must be part of the crew for a battle, but instead of being set up on the battlefield, they are
placed to one side. During the deployment phase, the player sets up two 2’’ wide tunnel entrance markers on any
table edge on the ground surface of the battlefield. During the Priority phase of each turn, roll a D6. On a 4+, the group
of fighters arrive on the battlefield. That turn they may be activated as a single group, and must move onto the
battlefield from one of the tunnel entrance. If the battle ends before the fighters arrive, they take no part in the battle.\n
ENHANCED BOON\n
This Territory grants Orlock gangs the following Boons:\n
Reputation: Whilst it controls this Territory, the gang adds +1 to its Reputation.\n
Special: An Orlock gang may choose to deploy up to six fighters via tunnels using the method detailed above. The
fighters in each group must be specified before the battle."
  elsif a_question.match?(/narco-distribution/i)
    "Linked Rackets: Out-Hive Smuggling Routes, Ghast Prospecting.\n
RACKET BOONS\n
Income: The gang earns D6x10 credits when they collect Income.\n
Special: Whilst it controls this Racket, the gang treats Chem-synth, Medicae Kit, Stimm-slug Stash, and any weapon
with the Gas or Toxin trait as Common.\n
ENHANCED BOONS\n
Income: If the gang also controls one of the Linked Rackets, the gang earns 2D6x10 credits when they collect Income.\n
Income: If the gang also controls both of the Linked Rackets, the gang earns 3D6x10 credits when they collect Income."
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
