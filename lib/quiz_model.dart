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
          "A. Happy & Energetic 🌞",
          "B. Calm & Relaxed 🌿",
          "C. Moody & Introspective 🌙",
          "D. Confident & Bold 🔥"
        ],
      ),
      Question(
        questionText: "What’s the weather like outside?",
        options: [
          "A. Sunny & Warm ☀️",
          "B. Cool & Breezy 🍃",
          "C. Rainy & Cloudy 🌧️",
          "D. Chilly & Cold ❄️"
        ],
      ),
      Question(
        questionText: "What’s your current vibe?",
        options: [
          "A. Casual & Laid-back 👕",
          "B. Chic & Classy 👗",
          "C. Edgy & Unique 🖤",
          "D. Cozy & Comfortable 🛋️"
        ],
      ),
      Question(
        questionText: "How social do you feel today?",
        options: [
          "A. Super social 🎉",
          "B. A little social 🗣️",
          "C. Not much 🤐",
          "D. Staying in 🏡"
        ],
      ),
      Question(
        questionText: "What colors are you drawn to today?",
        options: [
          "A. Bright & Playful 🌈",
          "B. Soft & Neutral 🤍",
          "C. Dark & Mysterious 🖤",
          "D. Earthy & Muted 🍂"
        ],
      ),
      Question(
        questionText: "What’s your ideal activity for today?",
        options: [
          "A. Fun day out 🎡",
          "B. Cozy café or art museum ☕🎨",
          "C. Listening to music or journaling 🎶📖",
          "D. Watching movies or gaming 🎬🎮"
        ],
      ),
      Question(
        questionText: "What type of shoes would you prefer today?",
        options: [
          "A. Sneakers 👟",
          "B. Boots 🥾",
          "C. Heels or Dressy Shoes 👠",
          "D. Slippers or Comfy Flats 🥿"
        ],
      ),
      Question(
        questionText: "What’s your preferred fabric right now?",
        options: [
          "A. Light & Breathable 🌬️",
          "B. Soft & Flowy 🩳",
          "C. Structured & Strong 🏛️",
          "D. Warm & Cozy 🧥"
        ],
      ),
      Question(
        questionText:
            "How much effort do you want to put into your look today?",
        options: [
          "A. Quick & Easy ⏳",
          "B. Well-Styled 💅",
          "C. Statement-Making 💥",
          "D. Minimal 🎭"
        ],
      ),
      Question(
        questionText: "What’s your go-to accessory today?",
        options: [
          "A. Sunglasses & Fun Jewelry 🕶️💍",
          "B. A Classy Handbag 👜",
          "C. A Bold Necklace 📿",
          "D. A Cozy Scarf 🧣"
        ],
      ),
      Question(
        questionText:
            "If you had to pick a fashion aesthetic for today, what would it be?",
        options: [
          "A. Sporty Chic 🏀",
          "B. Soft & Elegant 🎀",
          "C. Dark & Edgy 🌑",
          "D. Cozy Core 🧸"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/energetic_playful.jpeg",
          description:
              "🌟 Energetic & Playful 🌟\nA bright-colored crop top with high-waisted jeans or a tennis skirt.\nSneakers or stylish platform sandals.\nFun sunglasses & bold statement earrings.\nA sporty, laid-back aesthetic."),
      "B": QuizResult(
          image: "assets/quiz_results/calm_elegant.jpeg",
          description:
              "🌿 Calm & Elegant 🌿\nFlowy dresses or chic blouses with neutral tones.\nSoft fabric like satin or chiffon.\nDelicate jewelry and a classy handbag.\nBallet flats or elegant boots for a polished look."),
      "C": QuizResult(
          image: "assets/quiz_results/edgy_moody.jpeg",
          description:
              "🌧️ Edgy & Moody 🌧️\nBlack or dark-colored outfits with layering.\nLeather jackets, ripped jeans, or oversized sweaters.\nChunky boots or platform shoes.\nBold accessories like silver rings or statement necklaces."),
      "D": QuizResult(
          image: "assets/quiz_results/cozy_minimal.jpeg",
          description:
              "🔥 Cozy & Minimalist 🔥 \nOversized hoodies or warm knits with leggings or wide-leg pants.\nComfy sneakers, fluffy slippers, or simple flats.\nBeanies, scarves, or cozy accessories.\nA relaxed and effortless vibe."),
    },
  ),
  Quiz(
    title: "Occasion-Based Outfit Quiz:",
    image: "assets/quiz/occasion_quiz.jpeg",
    iconName: "event",
    titleDescription:
        "Dressing for a special occasion? We've got you covered! Answer a few quick questions and get the perfect outfit suggestion for any event. 🎉👗✨",
    questions: [
      Question(
        questionText: "What’s the occasion?",
        options: [
          "A. A casual day out with friends ☕",
          "B. A formal or business event 💼",
          "C. A date or special dinner ❤️",
          "D. Staying in and relaxing 🏡",
        ],
      ),
      Question(
        questionText: "What’s the setting?",
        options: [
          "A. Outdoors – Park, picnic, or street shopping 🌿",
          "B. Office, meeting, or conference room 🏢",
          "C. A fancy restaurant, event, or party 🍷",
          "D. Home – Lounging, movie night, or self-care 📺",
        ],
      ),
      Question(
        questionText: "How much effort do you want to put into your outfit?",
        options: [
          "A. Simple but stylish – Effortless & cute ✨",
          "B. Well put together – Polished and professional 👔",
          "C. Glamorous – Dressed to impress 🔥",
          "D. Minimal – Just pure comfort 😌",
        ],
      ),
      Question(
        questionText: "What’s the expected dress code?",
        options: [
          "A. Casual & relaxed 👕",
          "B. Business casual or formal 🏙️",
          "C. Semi-formal or dressy 💃",
          "D. No dress code – I’m at home! 🏡",
        ],
      ),
      Question(
        questionText: "What kind of footwear are you in the mood for?",
        options: [
          "A. Sneakers or comfy flats 👟",
          "B. Heels, dress shoes, or loafers 👠",
          "C. Statement shoes – Boots, stilettos, or fancy sandals 👢",
          "D. Cozy slippers or socks 🧦",
        ],
      ),
      Question(
        questionText: "How long will you be out?",
        options: [
          "A. Just a few hours, nothing too long ⏳",
          "B. A full day – Need to stay polished 🌟",
          "C. A night out – Looking to stand out 🌙",
          "D. Staying in all day, no outside plans 🛋️",
        ],
      ),
      Question(
        questionText: "How formal do you want to look?",
        options: [
          "A. Casual – Just put together enough 🙂",
          "B. Business chic – Professional but stylish 📎",
          "C. Elegant – Bold and eye-catching 💎",
          "D. No formality – Just pajamas, please! 😴",
        ],
      ),
      Question(
        questionText: "What’s the weather like?",
        options: [
          "A. Warm & sunny ☀️",
          "B. Chilly or breezy 🍂",
          "C. Cold & wintery ❄️",
          "D. Doesn’t matter – I’m indoors! 🏠",
        ],
      ),
      Question(
        questionText: "What’s your ideal color palette for today?",
        options: [
          "A. Bright & fun (Yellows, oranges, playful colors) 🌈",
          "B. Neutrals & solids (Beige, black, navy, white) 🤍",
          "C. Deep & bold (Reds, dark greens, purples) 🔥",
          "D. Soft & muted (Pastels, earthy tones) 🍃",
        ],
      ),
      Question(
        questionText: "What kind of top do you feel like wearing?",
        options: [
          "A. A comfy oversized tee or a cute crop top 🧡",
          "B. A structured blazer, shirt, or fitted blouse 💼",
          "C. A stylish corset, silk top, or elegant bodysuit 🌟",
          "D. A warm hoodie or soft loungewear sweater ☁️",
        ],
      ),
      Question(
        questionText: "What’s the one accessory you’ll definitely wear?",
        options: [
          "A. Sunglasses or a cute tote bag 🕶️👜",
          "B. A watch or minimal jewelry ⌚✨",
          "C. Statement earrings or bold makeup 💄💎",
          "D. A cozy blanket or fluffy socks 🧣",
        ],
      ),
    ],
    results: {
      "A": QuizResult(
        image: "assets/quiz_results/casual_effortless.jpeg",
        description:
            "🌿 Casual & Effortless 🌿 \nA trendy graphic tee or crop top paired with high-waisted jeans.\nSneakers or comfortable sandals.\nMinimal accessories like a tote bag or sunglasses.\nLight layers for an easygoing vibe.",
      ),
      "B": QuizResult(
        image: "assets/quiz_results/business_formal.jpeg",
        description:
            "🏙️ Business & Formal 🏙️ \nA structured blazer with a crisp blouse and tailored pants or a sleek pencil skirt.\nDress shoes, loafers, or heels.\nA minimal watch or simple gold jewelry.\nNeutral or monochrome colors for a sophisticated look.",
      ),
      "C": QuizResult(
        image: "assets/quiz_results/elegant_bold.jpeg",
        description:
            "🔥 Elegant & Bold 🔥 \nA fitted dress, stylish jumpsuit, or well-coordinated two-piece set.\nStatement heels or knee-high boots.\nBold accessories like chunky earrings, red lipstick, or a chic clutch.\nLuxe fabrics like silk, satin, or velvet.",
      ),
      "D": QuizResult(
        image: "assets/quiz_results/cozy_laidback.jpeg",
        description:
            "🏡 Cozy & Laid-back 🏡 \nOversized sweaters, fluffy hoodies, or a cute pajama set.\nCozy slippers or socks.\nA warm blanket as your 'accessory'!\nNeutral, pastel, or warm-toned colors for an ultra-relaxed feel.",
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
          "A. Warm and sunny ☀️",
          "B. Light drizzle 🌧️",
          "C. Cold and snowy ❄️",
          "D. Breezy and cool 🌬️"
        ],
      ),
      Question(
        questionText: "What fabric do you prefer wearing the most?",
        options: [
          "A. Cotton or linen 🌿",
          "B. Wool or fleece 🧣",
          "C. Cashmere or faux fur 🦢",
          "D. Denim or windproof material 👖"
        ],
      ),
      Question(
        questionText: "What’s your go-to footwear in uncertain weather?",
        options: [
          "A. Sandals or sneakers 👡",
          "B. Waterproof boots 🥾",
          "C. Stylish leather boots 🖤",
          "D. Comfortable trainers 👟"
        ],
      ),
      Question(
        questionText: "If the temperature suddenly drops, what’s your plan?",
        options: [
          "A. Light cardigan or denim jacket 🧥",
          "B. Pull out my waterproof hoodie ☔",
          "C. Layer up with a thick trench coat 🖤",
          "D. Just grab a scarf and I'm good 🧣"
        ],
      ),
      Question(
        questionText: "What’s your mood on a cloudy day?",
        options: [
          "A. Energetic and outdoorsy 🌞",
          "B. Cozy and homebound ☕",
          "C. Moody but stylish 🎭",
          "D. Adventurous and carefree 🌍"
        ],
      ),
      Question(
        questionText: "What’s your ideal rainy-day activity?",
        options: [
          "A. Going for a drive with music 🎶",
          "B. Snuggling up with a book 📚",
          "C. Dressing up and heading to a café ☕",
          "D. Walking in the drizzle with no umbrella 🚶‍♂️"
        ],
      ),
      Question(
        questionText: "If a sudden storm hits, what do you do?",
        options: [
          "A. Run inside and wait it out 🌦️",
          "B. Watch the rain with a hot drink 🍵",
          "C. Use it as an excuse to wear my stylish coat 💅",
          "D. Keep going—storms don’t stop me 🌪️"
        ],
      ),
      Question(
        questionText: "What’s your favorite outerwear?",
        options: [
          "A. Lightweight summer blazer ☀️",
          "B. Puffy waterproof jacket 🌧️",
          "C. Elegant long coat ❄️",
          "D. Windbreaker or bomber jacket 🌬️"
        ],
      ),
      Question(
        questionText: "Which color palette do you love for your outfits?",
        options: [
          "A. Bright & pastel shades 🎨",
          "B. Earthy & neutral tones 🍂",
          "C. Dark & monochrome shades 🖤",
          "D. Muted but trendy colors 🌿"
        ],
      ),
      Question(
        questionText:
            "If you could pick one must-have accessory, what would it be?",
        options: [
          "A. Sunglasses 🕶️",
          "B. Cozy scarf 🧣",
          "C. Statement gloves 🖤",
          "D. A stylish cap or hat 🎩"
        ],
      ),
      Question(
        questionText: "What’s your fashion motto?",
        options: [
          "A. Comfort meets style 🌞",
          "B. Cozy over everything 🌧️",
          "C. Fashion over function ❄️",
          "D. Effortless but cool 🌬️"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/sunny_chic.jpeg",
          description:
              "🔆 Sunny Chic 🔆 \nFlowy dresses, linen pants, sunglasses, and summer-friendly outfits.\nLight pastel colors, airy fabrics, and minimal layering.\nThink sundresses, crop tops, and comfy sandals."),
      "B": QuizResult(
          image: "assets/quiz_results/rainy_cozy.jpeg",
          description:
              "☔ Rainy Cozy ☔ \nWaterproof essentials, hoodies, scarves, and warm, layered clothing.\nCozy vibes with knitwear, boots, and oversized fits.\nBest suited for drizzly days and indoor relaxation."),
      "C": QuizResult(
          image: "assets/quiz_results/winter_elegance.jpeg",
          description:
              "❄️ Winter Elegance ❄️ \nStylish coats, leather gloves, and dark, sophisticated outfits.\nCashmere sweaters, long trench coats, and boots.\nPerfect for colder months with an elegant touch."),
      "D": QuizResult(
          image: "assets/quiz_results/windy_casual.jpeg",
          description:
              "🌬️ Windy Casual 🌬️\nWindbreakers, joggers, denim, and stylish yet functional clothing.\nNeutral but trendy shades, lightweight layers.\nBest for breezy, unpredictable weather."),
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
          "A. Relaxed and cozy ☁️",
          "B. Sleek and confident 💄",
          "C. Energetic and on-the-go 🏃",
          "D. Edgy and cool 😎"
        ],
      ),
      Question(
        questionText: "What's the weather like?",
        options: [
          "A. Chilly, need something warm ❄️",
          "B. Sunny and bright ☀️",
          "C. Just right, not too hot or cold 🌤️",
          "D. Cloudy or a little unpredictable 🌫️"
        ],
      ),
      Question(
        questionText: "What type of footwear are you feeling?",
        options: [
          "A. Sneakers or slip-ons 👟",
          "B. Heeled boots or chic sandals 👠",
          "C. Running shoes or sporty slides 🏃‍♂️",
          "D. Chunky sneakers or combat boots 🖤"
        ],
      ),
      Question(
        questionText: "What color palette are you drawn to today?",
        options: [
          "A. Neutrals and pastels 🎨",
          "B. Bold or monochrome shades 🖤",
          "C. Sporty colors like black, white, or neon ⚡",
          "D. Dark, oversized, or muted tones 🌑"
        ],
      ),
      Question(
        questionText: "Which bottomwear are you most comfortable in today?",
        options: [
          "A. Flowy skirt or cozy joggers ✨",
          "B. Tailored pants or a fitted skirt 👗",
          "C. Leggings or sporty shorts 🏋️‍♂️",
          "D. Baggy jeans or cargo pants 🖤"
        ],
      ),
      Question(
        questionText: "What's your go-to layering piece?",
        options: [
          "A. An oversized cardigan or hoodie ☕",
          "B. A structured blazer or trendy vest 🕶️",
          "C. A zip-up hoodie or sports jacket 🎽",
          "D. A leather jacket or oversized flannel 🖤"
        ],
      ),
      Question(
        questionText: "What's your go-to top style today?",
        options: [
          "A. Oversized tee or knit sweater 🧶",
          "B. Fitted crop top or stylish blouse 👗",
          "C. Breathable workout tee or tank top 🏋️",
          "D. Graphic tee or layered hoodie 🎸"
        ],
      ),
      Question(
        questionText:
            "If you could pick one statement piece, what would it be?",
        options: [
          "A. Cozy scarf or bucket hat 🧣",
          "B. Trendy handbag or sunglasses 👜",
          "C. A baseball cap or fitness watch ⌚",
          "D. Chunky chains or ripped denim 🖤"
        ],
      ),
      Question(
        questionText: "What's your ideal outfit aesthetic?",
        options: [
          "A. Soft and effortless 🍃",
          "B. Sharp and well-curated 🔥",
          "C. Functional and active 💪",
          "D. Unique and expressive 🎭"
        ],
      ),
      Question(
        questionText: "What accessory completes your look?",
        options: [
          "A. Cute earrings or minimal jewelry ✨",
          "B. A belt or stylish watch ⏳",
          "C. Sporty socks or a fanny pack 🎒",
          "D. Beanie or layered necklaces 🖤"
        ],
      ),
      Question(
        questionText: "What's your fashion motto?",
        options: [
          "A. Comfort first, always 💕",
          "B. Dress like you're meeting your ex 💅",
          "C. If it’s not functional, I don’t want it 🚀",
          "D. Break the rules, make a statement 🤘"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/casual_comfy.jpeg",
          description:
              "☁️ Casual & Comfy ☁️ \nOversized knit sweater + joggers + slip-ons\nSoft color palette (neutrals, pastels)\nCozy vibes with an effortless touch."),
      "B": QuizResult(
          image: "assets/quiz_results/chic_trendy.jpeg",
          description:
              "💄 Chic & Trendy 💄 \nFitted blazer + tailored pants + heeled boots\nStatement accessories like a belt or sunglasses\nA put-together, fashionable look."),
      "C": QuizResult(
          image: "assets/quiz_results/sporty_active.jpeg",
          description:
              "🏃 Sporty & Active 🏃\nBreathable workout tee + leggings + sneakers\nMinimal accessories, focused on function\nPerfect for an active, on-the-go day."),
      "D": QuizResult(
          image: "assets/quiz_results/edgy_streetwear.jpeg",
          description:
              "😎 Edgy & Streetwear 😎\nOversized hoodie + ripped jeans + chunky sneakers\nBold, dark, or graphic elements\nCool, rebellious, and effortlessly stylish."),
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
          "A. A simple necklace or studs ✨",
          "B. Chunky earrings or layered necklaces 🔥",
          "C. A sporty watch or cap ⌚",
          "D. Bold rings or a unique bag 🖤"
        ],
      ),
      Question(
        questionText: "What’s your outfit vibe today?",
        options: [
          "A. Classic and elegant 💃",
          "B. Trendy and eye-catching 😍",
          "C. Laid-back and comfy 😎",
          "D. Edgy and cool 🔥"
        ],
      ),
      Question(
        questionText: "How do you feel about layering accessories?",
        options: [
          "A. Keep it minimal, less is more 🌸",
          "B. Love stacking rings, necklaces, and bracelets 💥",
          "C. Just a few essential pieces, nothing extra 🏃",
          "D. The more, the better! Go big or go home 🎭"
        ],
      ),
      Question(
        questionText: "What kind of bag do you prefer?",
        options: [
          "A. A small, structured handbag 👜",
          "B. A trendy tote or oversized clutch 🛍️",
          "C. A crossbody or backpack 🎒",
          "D. A chain-strap bag or studded purse 😈"
        ],
      ),
      Question(
        questionText: "What’s your must-have jewelry piece?",
        options: [
          "A. A delicate pendant necklace 💎",
          "B. Bold hoop earrings or stackable rings ✨",
          "C. A smartwatch or silicone band watch ⏳",
          "D. A chunky chain or gothic-style rings 🖤"
        ],
      ),
      Question(
        questionText: "What’s your ideal sunglasses style?",
        options: [
          "A. Cat-eye or classic aviators 🕶️",
          "B. Oversized or colorful frames 😍",
          "C. Sporty or wraparound styles 🏃‍♂️",
          "D. Sharp, geometric, or unique frames 🤘"
        ],
      ),
      Question(
        questionText: "What kind of footwear completes your look?",
        options: [
          "A. Chic ballet flats or sleek heels 👠",
          "B. Strappy sandals or trendy boots 👢",
          "C. Sneakers or slip-ons 👟",
          "D. Platform shoes or combat boots 🖤"
        ],
      ),
      Question(
        questionText: "How do you choose your accessories?",
        options: [
          "A. I stick to classic, timeless pieces 🎀",
          "B. I love experimenting with trendy, bold styles 💥",
          "C. I prioritize comfort and function over looks 🚀",
          "D. I go for edgy, artistic, or alternative pieces 🎸"
        ],
      ),
      Question(
        questionText: "What kind of hat would you wear?",
        options: [
          "A. A classy beret or sun hat ☀️",
          "B. A trendy bucket hat or fedora 🎩",
          "C. A sporty cap or beanie 🏋️",
          "D. A wide-brimmed hat or leather beret 🖤"
        ],
      ),
      Question(
        questionText: "What’s your approach to accessorizing?",
        options: [
          "A. Keep it classy and simple 💎",
          "B. More is more – stack it up! 💥",
          "C. Just one or two practical pieces 🚀",
          "D. Mix and match unique, bold items 🎭"
        ],
      ),
      Question(
        questionText: "What’s your signature look?",
        options: [
          "A. Understated elegance, always 💖",
          "B. Bold and expressive 🌈",
          "C. Clean, simple, and comfortable ✨",
          "D. Edgy, artsy, and rebellious 🎸"
        ],
      ),
    ],
    results: {
      "A": QuizResult(
          image: "assets/quiz_results/minimal_elegant.jpeg",
          description:
              "💎 Minimal & Elegant 💎\nDelicate jewelry: small studs, thin rings, dainty bracelets.\nClassic watches, pearl earrings, sleek leather bags.\nTimeless sunglasses like aviators or cat-eye frames."),
      "B": QuizResult(
          image: "assets/quiz_results/bold_statement.jpeg",
          description:
              "🔥 Bold & Statement-Making 🔥\nChunky necklaces, oversized earrings, stacked bracelets.\nTrendy hats, bright sunglasses, patterned scarves.\nEye-catching handbags and layered jewelry."),
      "C": QuizResult(
          image: "assets/quiz_results/sporty_functional.jpeg",
          description:
              "🚀 Sporty & Functional 🚀\nSmartwatches, silicone wristbands, fitness trackers.\nBaseball caps, beanies, minimal sneakers.\nSleek backpacks and crossbody bags for practicality."),
      "D": QuizResult(
          image: "assets/quiz_results/edgy_experimental.jpeg",
          description:
              "🖤 Edgy & Experimental 🖤\nChunky chains, gothic rings, leather accessories.\nBold sunglasses, oversized hoodies, combat boots.\nUnique statement bags with studs or unusual designs."),
    },
  )
];
