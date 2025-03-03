class Quiz {
  final String title;
  final String image;
  final String iconName;
  final String titleDescription;
  final List<Question> questions;
  final Map<String, QuizResult> results;

  Quiz({
    required this.title,
    required this.image,
    required this.iconName, // ✅ Uses unique iconName for each quiz
    required this.titleDescription,
    required this.questions,
    required this.results,
  });
}

class QuizResult {
  final String image; // ✅ Keep this as 'image' for JPEG results
  final String description;

  QuizResult({required this.image, required this.description});
}

class Question {
  final String questionText;
  final List<String> options;

  Question({required this.questionText, required this.options});
}

// 🔥 Mood-Based Quiz - Updated with full questions & results
List<Quiz> quizzes = [
  Quiz(
    title: "Mood-Based Quiz",
    image: "assets/quiz/mood_quiz.jpeg",
    iconName: "mood",
    titleDescription:
        "Not sure what to wear? Let your mood decide! Answer a few quick questions and get a style suggestion that matches your vibe. 💫👗✨",
    questions: [
      Question(
        questionText: "How are you feeling today?",
        options: [
          "Happy & Energetic",
          "Calm & Relaxed",
          "Moody & Introspective",
          "Confident & Bold"
        ],
      ),
      Question(
        questionText: "What’s the weather like outside?",
        options: [
          "Sunny & Warm",
          "Cool & Breezy",
          "Rainy & Cloudy",
          "Chilly & Cold"
        ],
      ),
      Question(
        questionText: "What’s your current vibe?",
        options: [
          "Casual & Laid-back",
          "Chic & Classy",
          "Edgy & Unique",
          "Cozy & Comfortable"
        ],
      ),
      Question(
        questionText: "How social do you feel today?",
        options: ["Super social", "A little social", "Not much", "Staying in"],
      ),
      Question(
        questionText: "What colors are you drawn to today?",
        options: [
          "Bright & Playful",
          "Soft & Neutral",
          "Dark & Mysterious",
          "Earthy & Muted"
        ],
      ),
      Question(
        questionText: "What’s your ideal activity for today?",
        options: [
          "Fun day out",
          "Cozy café or art museum",
          "Listening to music or journaling",
          "Watching movies or gaming"
        ],
      ),
      Question(
        questionText: "What type of shoes would you prefer today?",
        options: [
          "Sneakers",
          "Boots",
          "Heels or Dressy Shoes",
          "Slippers or Comfy Flats"
        ],
      ),
      Question(
        questionText: "What’s your preferred fabric right now?",
        options: [
          "Light & Breathable",
          "Soft & Flowy",
          "Structured & Strong",
          "Warm & Cozy"
        ],
      ),
      Question(
        questionText:
            "How much effort do you want to put into your look today?",
        options: ["Quick & Easy", "Well-Styled", "Statement-Making", "Minimal"],
      ),
      Question(
        questionText: "What’s your go-to accessory today?",
        options: [
          "Sunglasses & Fun Jewelry",
          "A Classy Handbag",
          "A Bold Necklace",
          "A Cozy Scarf"
        ],
      ),
      Question(
        questionText:
            "If you had to pick a fashion aesthetic for today, what would it be?",
        options: ["Sporty Chic", "Soft & Elegant", "Dark & Edgy", "Cozy Core"],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/energetic_playful.jpeg",
          description:
              "🌟 Energetic & Playful\nA bright-colored crop top with high-waisted jeans or a tennis skirt.\nSneakers or stylish platform sandals.\nFun sunglasses & bold statement earrings.\nA sporty, laid-back aesthetic."),
      "B": QuizResult(
          image: "assets/quiz_results/calm_elegant.jpeg",
          description:
              "🌿 Calm & Elegant\nFlowy dresses or chic blouses with neutral tones.\nSoft fabric like satin or chiffon.\nDelicate jewelry and a classy handbag.\nBallet flats or elegant boots for a polished look."),
      "C": QuizResult(
          image: "assets/quiz_results/edgy_moody.jpeg",
          description:
              "🌧️ Edgy & Moody\nBlack or dark-colored outfits with layering.\nLeather jackets, ripped jeans, or oversized sweaters.\nChunky boots or platform shoes.\nBold accessories like silver rings or statement necklaces."),
      "D": QuizResult(
          image: "assets/quiz_results/cozy_minimal.jpeg",
          description:
              "🔥 Cozy & Minimalist\nOversized hoodies or warm knits with leggings or wide-leg pants.\nComfy sneakers, fluffy slippers, or simple flats.\nBeanies, scarves, or cozy accessories.\nA relaxed and effortless vibe."),
    },
  ),
  Quiz(
    title: "Occasion-Based Outfit Quiz: What Should You Wear Today?",
    image: "assets/quiz/occasion_quiz.jpeg",
    iconName: "event",
    titleDescription:
        "Dressing for a special occasion? We've got you covered! Answer a few quick questions and get the perfect outfit suggestion for any event. 🎉👗✨",
    questions: [
      Question(
        questionText: "What’s the occasion?",
        options: [
          "A casual day out with friends ☕",
          "A formal or business event 💼",
          "A date or special dinner ❤️",
          "Staying in and relaxing 🏡",
        ],
      ),
      Question(
        questionText: "What’s the setting?",
        options: [
          "Outdoors – Park, picnic, or street shopping 🌿",
          "Office, meeting, or conference room 🏢",
          "A fancy restaurant, event, or party 🍷",
          "Home – Lounging, movie night, or self-care 📺",
        ],
      ),
      Question(
        questionText: "How much effort do you want to put into your outfit?",
        options: [
          "Simple but stylish – Effortless & cute ✨",
          "Well put together – Polished and professional 👔",
          "Glamorous – Dressed to impress 🔥",
          "Minimal – Just pure comfort 😌",
        ],
      ),
      Question(
        questionText: "What’s the expected dress code?",
        options: [
          "Casual & relaxed 👕",
          "Business casual or formal 🏙️",
          "Semi-formal or dressy 💃",
          "No dress code – I’m at home! 🏡",
        ],
      ),
      Question(
        questionText: "What kind of footwear are you in the mood for?",
        options: [
          "Sneakers or comfy flats 👟",
          "Heels, dress shoes, or loafers 👠",
          "Statement shoes – Boots, stilettos, or fancy sandals 👢",
          "Cozy slippers or socks 🧦",
        ],
      ),
      Question(
        questionText: "How long will you be out?",
        options: [
          "Just a few hours, nothing too long ⏳",
          "A full day – Need to stay polished 🌟",
          "A night out – Looking to stand out 🌙",
          "Staying in all day, no outside plans 🛋️",
        ],
      ),
      Question(
        questionText: "How formal do you want to look?",
        options: [
          "Casual – Just put together enough 🙂",
          "Business chic – Professional but stylish 📎",
          "Elegant – Bold and eye-catching 💎",
          "No formality – Just pajamas, please! 😴",
        ],
      ),
      Question(
        questionText: "What’s the weather like?",
        options: [
          "Warm & sunny ☀️",
          "Chilly or breezy 🍂",
          "Cold & wintery ❄️",
          "Doesn’t matter – I’m indoors! 🏠",
        ],
      ),
      Question(
        questionText: "What’s your ideal color palette for today?",
        options: [
          "Bright & fun (Yellows, oranges, playful colors) 🌈",
          "Neutrals & solids (Beige, black, navy, white) 🤍",
          "Deep & bold (Reds, dark greens, purples) 🔥",
          "Soft & muted (Pastels, earthy tones) 🍃",
        ],
      ),
      Question(
        questionText: "What kind of top do you feel like wearing?",
        options: [
          "A comfy oversized tee or a cute crop top 🧡",
          "A structured blazer, shirt, or fitted blouse 💼",
          "A stylish corset, silk top, or elegant bodysuit 🌟",
          "A warm hoodie or soft loungewear sweater ☁️",
        ],
      ),
      Question(
        questionText: "What’s the one accessory you’ll definitely wear?",
        options: [
          "Sunglasses or a cute tote bag 🕶️👜",
          "A watch or minimal jewelry ⌚✨",
          "Statement earrings or bold makeup 💄💎",
          "A cozy blanket or fluffy socks 🧣",
        ],
      ),
    ],
    results: {
      "A": QuizResult(
        image: "assets/quiz_results/casual_effortless.jpeg",
        description:
            "🌿 Casual & Effortless\nA trendy graphic tee or crop top paired with high-waisted jeans.\nSneakers or comfortable sandals.\nMinimal accessories like a tote bag or sunglasses.\nLight layers for an easygoing vibe.",
      ),
      "B": QuizResult(
        image: "assets/quiz_results/business_formal.jpeg",
        description:
            "🏙️ Business & Formal\nA structured blazer with a crisp blouse and tailored pants or a sleek pencil skirt.\nDress shoes, loafers, or heels.\nA minimal watch or simple gold jewelry.\nNeutral or monochrome colors for a sophisticated look.",
      ),
      "C": QuizResult(
        image: "assets/quiz_results/elegant_bold.jpeg",
        description:
            "🔥 Elegant & Bold\nA fitted dress, stylish jumpsuit, or well-coordinated two-piece set.\nStatement heels or knee-high boots.\nBold accessories like chunky earrings, red lipstick, or a chic clutch.\nLuxe fabrics like silk, satin, or velvet.",
      ),
      "D": QuizResult(
        image: "assets/quiz_results/cozy_laidback.jpeg",
        description:
            "🏡 Cozy & Laid-back\nOversized sweaters, fluffy hoodies, or a cute pajama set.\nCozy slippers or socks.\nA warm blanket as your 'accessory'!\nNeutral, pastel, or warm-toned colors for an ultra-relaxed feel.",
      ),
    },
  ),
  Quiz(
    title: "Weather-Based Quiz",
    image: "assets/quiz/weather_quiz.jpeg",
    iconName: "wb_sunny",
    titleDescription:
        "Rain or shine, dress just right! Answer a few quick questions and get the perfect outfit suggestion for the weather. ☀️🌧️👗✨",
    questions: [
      Question(
        questionText: "What's your ideal weather?",
        options: [
          "Warm and sunny ☀️",
          "Light drizzle 🌧️",
          "Cold and snowy ❄️",
          "Breezy and cool 🌬️"
        ],
      ),
      Question(
        questionText: "What fabric do you prefer wearing the most?",
        options: [
          "Cotton or linen 🌿",
          "Wool or fleece 🧣",
          "Cashmere or faux fur 🦢",
          "Denim or windproof material 👖"
        ],
      ),
      Question(
        questionText: "What’s your go-to footwear in uncertain weather?",
        options: [
          "Sandals or sneakers 👡",
          "Waterproof boots 🥾",
          "Stylish leather boots 🖤",
          "Comfortable trainers 👟"
        ],
      ),
      Question(
        questionText: "If the temperature suddenly drops, what’s your plan?",
        options: [
          "Light cardigan or denim jacket 🧥",
          "Pull out my waterproof hoodie ☔",
          "Layer up with a thick trench coat 🖤",
          "Just grab a scarf and I'm good 🧣"
        ],
      ),
      Question(
        questionText: "What’s your mood on a cloudy day?",
        options: [
          "Energetic and outdoorsy 🌞",
          "Cozy and homebound ☕",
          "Moody but stylish 🎭",
          "Adventurous and carefree 🌍"
        ],
      ),
      Question(
        questionText: "What’s your ideal rainy-day activity?",
        options: [
          "Going for a drive with music 🎶",
          "Snuggling up with a book 📚",
          "Dressing up and heading to a café ☕",
          "Walking in the drizzle with no umbrella 🚶‍♂️"
        ],
      ),
      Question(
        questionText: "If a sudden storm hits, what do you do?",
        options: [
          "Run inside and wait it out 🌦️",
          "Watch the rain with a hot drink 🍵",
          "Use it as an excuse to wear my stylish coat 💅",
          "Keep going—storms don’t stop me 🌪️"
        ],
      ),
      Question(
        questionText: "What’s your favorite outerwear?",
        options: [
          "Lightweight summer blazer ☀️",
          "Puffy waterproof jacket 🌧️",
          "Elegant long coat ❄️",
          "Windbreaker or bomber jacket 🌬️"
        ],
      ),
      Question(
        questionText: "Which color palette do you love for your outfits?",
        options: [
          "Bright & pastel shades 🎨",
          "Earthy & neutral tones 🍂",
          "Dark & monochrome shades 🖤",
          "Muted but trendy colors 🌿"
        ],
      ),
      Question(
        questionText:
            "If you could pick one must-have accessory, what would it be?",
        options: [
          "Sunglasses 🕶️",
          "Cozy scarf 🧣",
          "Statement gloves 🖤",
          "A stylish cap or hat 🎩"
        ],
      ),
      Question(
        questionText: "What’s your fashion motto?",
        options: [
          "Comfort meets style 🌞",
          "Cozy over everything 🌧️",
          "Fashion over function ❄️",
          "Effortless but cool 🌬️"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/sunny_chic.jpeg",
          description:
              "🔆 Sunny Chic\nFlowy dresses, linen pants, sunglasses, and summer-friendly outfits.\nLight pastel colors, airy fabrics, and minimal layering.\nThink sundresses, crop tops, and comfy sandals."),
      "B": QuizResult(
          image: "assets/quiz_results/rainy_cozy.jpeg",
          description:
              "☔ Rainy Cozy\nWaterproof essentials, hoodies, scarves, and warm, layered clothing.\nCozy vibes with knitwear, boots, and oversized fits.\nBest suited for drizzly days and indoor relaxation."),
      "C": QuizResult(
          image: "assets/quiz_results/winter_elegance.jpeg",
          description:
              "❄️ Winter Elegance\nStylish coats, leather gloves, and dark, sophisticated outfits.\nCashmere sweaters, long trench coats, and boots.\nPerfect for colder months with an elegant touch."),
      "D": QuizResult(
          image: "assets/quiz_results/windy_casual.jpeg",
          description:
              "🌬️ Windy Casual\nWindbreakers, joggers, denim, and stylish yet functional clothing.\nNeutral but trendy shades, lightweight layers.\nBest for breezy, unpredictable weather."),
    },
  ),
  Quiz(
    title: "Today's Outfit Quiz",
    image: "assets/quiz/todays_outfit_quiz.jpeg",
    iconName: "checkroom",
    titleDescription:
        "Struggling to pick an outfit? Answer a few quick questions, and we’ll style the perfect look for today! 👗✨",
    questions: [
      Question(
        questionText: "What's your vibe for the day?",
        options: [
          "Relaxed and cozy ☁️",
          "Sleek and confident 💄",
          "Energetic and on-the-go 🏃",
          "Edgy and cool 😎"
        ],
      ),
      Question(
        questionText: "What's the weather like?",
        options: [
          "Chilly, need something warm ❄️",
          "Sunny and bright ☀️",
          "Just right, not too hot or cold 🌤️",
          "Cloudy or a little unpredictable 🌫️"
        ],
      ),
      Question(
        questionText: "What type of footwear are you feeling?",
        options: [
          "Sneakers or slip-ons 👟",
          "Heeled boots or chic sandals 👠",
          "Running shoes or sporty slides 🏃‍♂️",
          "Chunky sneakers or combat boots 🖤"
        ],
      ),
      Question(
        questionText: "What color palette are you drawn to today?",
        options: [
          "Neutrals and pastels 🎨",
          "Bold or monochrome shades 🖤",
          "Sporty colors like black, white, or neon ⚡",
          "Dark, oversized, or muted tones 🌑"
        ],
      ),
      Question(
        questionText: "Which bottomwear are you most comfortable in today?",
        options: [
          "Flowy skirt or cozy joggers ✨",
          "Tailored pants or a fitted skirt 👗",
          "Leggings or sporty shorts 🏋️‍♂️",
          "Baggy jeans or cargo pants 🖤"
        ],
      ),
      Question(
        questionText: "What's your go-to layering piece?",
        options: [
          "An oversized cardigan or hoodie ☕",
          "A structured blazer or trendy vest 🕶️",
          "A zip-up hoodie or sports jacket 🎽",
          "A leather jacket or oversized flannel 🖤"
        ],
      ),
      Question(
        questionText: "What's your go-to top style today?",
        options: [
          "Oversized tee or knit sweater 🧶",
          "Fitted crop top or stylish blouse 👗",
          "Breathable workout tee or tank top 🏋️",
          "Graphic tee or layered hoodie 🎸"
        ],
      ),
      Question(
        questionText:
            "If you could pick one statement piece, what would it be?",
        options: [
          "Cozy scarf or bucket hat 🧣",
          "Trendy handbag or sunglasses 👜",
          "A baseball cap or fitness watch ⌚",
          "Chunky chains or ripped denim 🖤"
        ],
      ),
      Question(
        questionText: "What's your ideal outfit aesthetic?",
        options: [
          "Soft and effortless 🍃",
          "Sharp and well-curated 🔥",
          "Functional and active 💪",
          "Unique and expressive 🎭"
        ],
      ),
      Question(
        questionText: "What accessory completes your look?",
        options: [
          "Cute earrings or minimal jewelry ✨",
          "A belt or stylish watch ⏳",
          "Sporty socks or a fanny pack 🎒",
          "Beanie or layered necklaces 🖤"
        ],
      ),
      Question(
        questionText: "What's your fashion motto?",
        options: [
          "Comfort first, always 💕",
          "Dress like you're meeting your ex 💅",
          "If it’s not functional, I don’t want it 🚀",
          "Break the rules, make a statement 🤘"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/casual_comfy.jpeg",
          description:
              "☁️ Casual & Comfy\nOversized knit sweater + joggers + slip-ons\nSoft color palette (neutrals, pastels)\nCozy vibes with an effortless touch."),
      "B": QuizResult(
          image: "assets/quiz_results/chic_trendy.jpeg",
          description:
              "💄 Chic & Trendy\nFitted blazer + tailored pants + heeled boots\nStatement accessories like a belt or sunglasses\nA put-together, fashionable look."),
      "C": QuizResult(
          image: "assets/quiz_results/sporty_active.jpeg",
          description:
              "🏃 Sporty & Active\nBreathable workout tee + leggings + sneakers\nMinimal accessories, focused on function\nPerfect for an active, on-the-go day."),
      "D": QuizResult(
          image: "assets/quiz_results/edgy_streetwear.jpeg",
          description:
              "😎 Edgy & Streetwear\nOversized hoodie + ripped jeans + chunky sneakers\nBold, dark, or graphic elements\nCool, rebellious, and effortlessly stylish."),
    },
  ),
  Quiz(
    title: "Accessories Quiz",
    image: "assets/quiz/accessories_quiz.jpeg",
    iconName: "diamond",
    titleDescription:
        "Complete your look with the perfect accessories! Answer a few quick questions to find the best match for your style. 💎✨",
    questions: [
      Question(
        questionText: "What’s your usual go-to accessory?",
        options: [
          "A simple necklace or studs ✨",
          "Chunky earrings or layered necklaces 🔥",
          "A sporty watch or cap ⌚",
          "Bold rings or a unique bag 🖤"
        ],
      ),
      Question(
        questionText: "What’s your outfit vibe today?",
        options: [
          "Classic and elegant 💃",
          "Trendy and eye-catching 😍",
          "Laid-back and comfy 😎",
          "Edgy and cool 🔥"
        ],
      ),
      Question(
        questionText: "How do you feel about layering accessories?",
        options: [
          "Keep it minimal, less is more 🌸",
          "Love stacking rings, necklaces, and bracelets 💥",
          "Just a few essential pieces, nothing extra 🏃",
          "The more, the better! Go big or go home 🎭"
        ],
      ),
      Question(
        questionText: "What kind of bag do you prefer?",
        options: [
          "A small, structured handbag 👜",
          "A trendy tote or oversized clutch 🛍️",
          "A crossbody or backpack 🎒",
          "A chain-strap bag or studded purse 😈"
        ],
      ),
      Question(
        questionText: "What’s your must-have jewelry piece?",
        options: [
          "A delicate pendant necklace 💎",
          "Bold hoop earrings or stackable rings ✨",
          "A smartwatch or silicone band watch ⏳",
          "A chunky chain or gothic-style rings 🖤"
        ],
      ),
      Question(
        questionText: "What’s your ideal sunglasses style?",
        options: [
          "Cat-eye or classic aviators 🕶️",
          "Oversized or colorful frames 😍",
          "Sporty or wraparound styles 🏃‍♂️",
          "Sharp, geometric, or unique frames 🤘"
        ],
      ),
      Question(
        questionText: "What kind of footwear completes your look?",
        options: [
          "Chic ballet flats or sleek heels 👠",
          "Strappy sandals or trendy boots 👢",
          "Sneakers or slip-ons 👟",
          "Platform shoes or combat boots 🖤"
        ],
      ),
      Question(
        questionText: "How do you choose your accessories?",
        options: [
          "I stick to classic, timeless pieces 🎀",
          "I love experimenting with trendy, bold styles 💥",
          "I prioritize comfort and function over looks 🚀",
          "I go for edgy, artistic, or alternative pieces 🎸"
        ],
      ),
      Question(
        questionText: "What kind of hat would you wear?",
        options: [
          "A classy beret or sun hat ☀️",
          "A trendy bucket hat or fedora 🎩",
          "A sporty cap or beanie 🏋️",
          "A wide-brimmed hat or leather beret 🖤"
        ],
      ),
      Question(
        questionText: "What’s your approach to accessorizing?",
        options: [
          "Keep it classy and simple 💎",
          "More is more – stack it up! 💥",
          "Just one or two practical pieces 🚀",
          "Mix and match unique, bold items 🎭"
        ],
      ),
      Question(
        questionText: "What’s your signature look?",
        options: [
          "Understated elegance, always 💖",
          "Bold and expressive 🌈",
          "Clean, simple, and comfortable ✨",
          "Edgy, artsy, and rebellious 🎸"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/minimal_elegant.jpeg",
          description:
              "💎 Minimal & Elegant\nDelicate jewelry: small studs, thin rings, dainty bracelets.\nClassic watches, pearl earrings, sleek leather bags.\nTimeless sunglasses like aviators or cat-eye frames."),
      "B": QuizResult(
          image: "assets/quiz_results/bold_statement.jpeg",
          description:
              "🔥 Bold & Statement-Making\nChunky necklaces, oversized earrings, stacked bracelets.\nTrendy hats, bright sunglasses, patterned scarves.\nEye-catching handbags and layered jewelry."),
      "C": QuizResult(
          image: "assets/quiz_results/sporty_functional.jpeg",
          description:
              "🚀 Sporty & Functional\nSmartwatches, silicone wristbands, fitness trackers.\nBaseball caps, beanies, minimal sneakers.\nSleek backpacks and crossbody bags for practicality."),
      "D": QuizResult(
          image: "assets/quiz_results/edgy_experimental.jpeg",
          description:
              "🖤 Edgy & Experimental\nChunky chains, gothic rings, leather accessories.\nBold sunglasses, oversized hoodies, combat boots.\nUnique statement bags with studs or unusual designs."),
    },
  )
];
