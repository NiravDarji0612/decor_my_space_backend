# frozen_string_literal: true

# Idempotent seed data for Decor My Space backend.
#
# Run with: bin/rails db:seed
#
# Targets ~30-40 records per entity so devs can exercise pagination, filters,
# search, sort, bookings flow, reviews, notifications, etc.

require "securerandom"

# Deterministic randomness so reruns produce the same data.
RNG = Random.new(42)
def pick(arr) = arr.sample(random: RNG)
def pick_n(arr, n) = arr.sample(n, random: RNG)

# ---------------------------------------------------------------------------
# Categories (~30)
# ---------------------------------------------------------------------------
puts "Seeding categories..."

CATEGORIES = [
  { slug: "wedding",        title: "Wedding",            icon_key: "celebration",   tint_hex: "#FCE4EC", icon_color_hex: "#C2185B", match_keys: %w[wedding sangeet engagement], cover_url: "https://images.unsplash.com/photo-1519741497674-611481863552?w=900" },
  { slug: "corporate",      title: "Corporate",          icon_key: "business",      tint_hex: "#E3F2FD", icon_color_hex: "#1565C0", match_keys: %w[corporate conference seminar], cover_url: "https://images.unsplash.com/photo-1515169067868-5387ec356754?w=900" },
  { slug: "birthday",       title: "Birthday",           icon_key: "cake",          tint_hex: "#FFF3E0", icon_color_hex: "#EF6C00", match_keys: %w[birthday kids], cover_url: "https://images.unsplash.com/photo-1464347744102-11db6282f854?w=900" },
  { slug: "anniversary",    title: "Anniversary",        icon_key: "favorite",      tint_hex: "#FBE9E7", icon_color_hex: "#D84315", match_keys: %w[anniversary couple], cover_url: "https://images.unsplash.com/photo-1530023367847-a683933f4172?w=900" },
  { slug: "festive",        title: "Festive",            icon_key: "auto_awesome",  tint_hex: "#FFF8E1", icon_color_hex: "#FF8F00", match_keys: %w[diwali festival], cover_url: "https://images.unsplash.com/photo-1604608672516-f1b9b1d6f5d2?w=900" },
  { slug: "haldi",          title: "Haldi",              icon_key: "spa",           tint_hex: "#FFFDE7", icon_color_hex: "#F9A825", match_keys: %w[haldi mehendi], cover_url: "https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=900" },
  { slug: "sangeet",        title: "Sangeet",            icon_key: "music_note",    tint_hex: "#F3E5F5", icon_color_hex: "#6A1B9A", match_keys: %w[sangeet music dance] },
  { slug: "engagement",     title: "Engagement",         icon_key: "diamond",       tint_hex: "#E8EAF6", icon_color_hex: "#283593", match_keys: %w[engagement ring proposal] },
  { slug: "mehendi",        title: "Mehendi",            icon_key: "brush",         tint_hex: "#F1F8E9", icon_color_hex: "#558B2F", match_keys: %w[mehendi henna] },
  { slug: "baby-shower",    title: "Baby Shower",        icon_key: "child_care",    tint_hex: "#E1F5FE", icon_color_hex: "#0277BD", match_keys: %w[baby shower godh-bharai] },
  { slug: "naming",         title: "Naming Ceremony",    icon_key: "child_friendly",tint_hex: "#F9FBE7", icon_color_hex: "#9E9D24", match_keys: %w[naming namkaran] },
  { slug: "house-warming",  title: "House Warming",      icon_key: "home",          tint_hex: "#EFEBE9", icon_color_hex: "#5D4037", match_keys: %w[house-warming griha-pravesh] },
  { slug: "graduation",     title: "Graduation",         icon_key: "school",        tint_hex: "#E0F7FA", icon_color_hex: "#00838F", match_keys: %w[graduation convocation] },
  { slug: "retirement",     title: "Retirement",         icon_key: "elderly",       tint_hex: "#ECEFF1", icon_color_hex: "#455A64", match_keys: %w[retirement farewell] },
  { slug: "product-launch", title: "Product Launch",     icon_key: "rocket_launch", tint_hex: "#FFEBEE", icon_color_hex: "#B71C1C", match_keys: %w[launch product brand] },
  { slug: "conference",     title: "Conference",         icon_key: "mic",           tint_hex: "#E8F5E9", icon_color_hex: "#2E7D32", match_keys: %w[conference summit] },
  { slug: "exhibition",     title: "Exhibition",         icon_key: "view_module",   tint_hex: "#FFF3E0", icon_color_hex: "#E65100", match_keys: %w[exhibition expo trade] },
  { slug: "concert",        title: "Concert",            icon_key: "library_music", tint_hex: "#EDE7F6", icon_color_hex: "#4527A0", match_keys: %w[concert live music] },
  { slug: "festival",       title: "Festival",           icon_key: "festival",      tint_hex: "#FFF8E1", icon_color_hex: "#FF6F00", match_keys: %w[festival cultural] },
  { slug: "kids-party",     title: "Kids Party",         icon_key: "toys",          tint_hex: "#FCE4EC", icon_color_hex: "#AD1457", match_keys: %w[kids party theme] },
  { slug: "bachelorette",   title: "Bachelorette",       icon_key: "wine_bar",      tint_hex: "#F8BBD0", icon_color_hex: "#880E4F", match_keys: %w[bachelorette hen] },
  { slug: "bachelor",       title: "Bachelor Party",     icon_key: "sports_bar",    tint_hex: "#D7CCC8", icon_color_hex: "#3E2723", match_keys: %w[bachelor stag] },
  { slug: "reception",      title: "Reception",          icon_key: "restaurant",    tint_hex: "#FFEBEE", icon_color_hex: "#C62828", match_keys: %w[reception dinner] },
  { slug: "pool-party",     title: "Pool Party",         icon_key: "pool",          tint_hex: "#E0F7FA", icon_color_hex: "#006064", match_keys: %w[pool summer] },
  { slug: "destination",    title: "Destination Event",  icon_key: "flight",        tint_hex: "#E8EAF6", icon_color_hex: "#1A237E", match_keys: %w[destination travel beach] },
  { slug: "religious",      title: "Religious Ceremony", icon_key: "self_improvement", tint_hex: "#FFF8E1", icon_color_hex: "#F57F17", match_keys: %w[puja religious havan] },
  { slug: "charity",        title: "Charity Event",      icon_key: "volunteer_activism", tint_hex: "#E8F5E9", icon_color_hex: "#1B5E20", match_keys: %w[charity fundraiser ngo] },
  { slug: "sports",         title: "Sports Event",       icon_key: "sports_soccer", tint_hex: "#E3F2FD", icon_color_hex: "#0D47A1", match_keys: %w[sports tournament] },
  { slug: "award-night",    title: "Award Night",        icon_key: "emoji_events",  tint_hex: "#FFF3E0", icon_color_hex: "#BF360C", match_keys: %w[awards gala] },
  { slug: "school-event",   title: "School Event",       icon_key: "menu_book",     tint_hex: "#F1F8E9", icon_color_hex: "#33691E", match_keys: %w[school college fest] },
  { slug: "religious-jain", title: "Jain Ceremony",      icon_key: "temple_buddhist", tint_hex: "#FFF8E1", icon_color_hex: "#EF6C00", match_keys: %w[jain pratishtha] },
  { slug: "religious-sikh", title: "Sikh Ceremony",      icon_key: "temple_hindu",  tint_hex: "#FBE9E7", icon_color_hex: "#BF360C", match_keys: %w[sikh anand-karaj] }
].freeze

CATEGORIES.each_with_index do |attrs, idx|
  Category.find_or_create_by!(slug: attrs[:slug]) do |c|
    c.assign_attributes(attrs.merge(position: idx + 1, active: true))
  end
end

# ---------------------------------------------------------------------------
# Add-ons (~30)
# ---------------------------------------------------------------------------
puts "Seeding add-ons..."

ADD_ONS = [
  ["photography",       "Photography Package",      "Professional photography & videography",        15_000],
  ["extended_hours",    "Extended Event Hours",     "Add 2 extra hours of service",                   5_000],
  ["premium_florals",   "Premium Florals",          "Imported & exotic floral arrangements",         10_000],
  ["drone_coverage",    "Drone Coverage",           "Aerial drone shots of the event",                8_500],
  ["live_streaming",    "Live Streaming",           "Multi-camera stream to YouTube/Zoom",            7_500],
  ["dj_console",        "DJ + Console",             "Professional DJ with sound console",            12_000],
  ["live_band",         "Live Band (4 pieces)",     "4-piece live band for 2 hours",                 35_000],
  ["dhol_player",       "Dhol Player",              "Traditional dhol player for baraat",             3_500],
  ["mehendi_artist",    "Mehendi Artist",           "Bridal mehendi artist (one bride)",              6_500],
  ["makeup_artist",     "Makeup Artist",            "Bridal HD makeup + draping",                    18_000],
  ["sound_system",      "Premium Sound System",     "Line-array PA with monitors",                   14_000],
  ["led_screens",       "LED Screens",              "Pair of 8x10 ft LED video walls",               22_000],
  ["fog_machine",       "Fog & Cold Pyro",          "Stage fog and cold pyro effects",                4_500],
  ["fireworks",         "Fireworks Show",           "10-minute professional fireworks display",      45_000],
  ["valet_parking",     "Valet Parking",            "Valet service for up to 100 cars",              11_000],
  ["security_team",     "Security Team",            "6 trained event security staff",                 9_000],
  ["catering_premium",  "Premium Catering",         "Multi-cuisine premium menu (per 100 guests)",   60_000],
  ["bar_setup",         "Bar Setup",                "Mocktail/cocktail bar with bartenders",         18_500],
  ["dessert_counter",   "Dessert Counter",          "Live dessert and chocolate fountain",            8_000],
  ["welcome_drinks",    "Welcome Drinks",           "Themed welcome drinks for guests",               3_000],
  ["return_gifts",      "Return Gifts",             "Curated return gift hampers (50 nos)",          12_500],
  ["wedding_invites",   "Designer Invites",         "Bespoke designer invitations (100 nos)",        15_000],
  ["car_decoration",    "Wedding Car Decor",        "Floral decor for bride/groom car",               5_500],
  ["entry_arch",        "Floral Entry Arch",        "Grand entry arch with seasonal florals",        14_000],
  ["photo_booth",       "Photo Booth",              "Themed photo booth with props",                  6_000],
  ["caricature_artist", "Caricature Artist",        "Live caricature artist for guests",              4_500],
  ["tarot_reader",      "Tarot Reader",             "Tarot/palm reading entertainment",               3_500],
  ["magician",          "Magician",                 "Close-up magic for cocktail hour",               5_500],
  ["anchor_emcee",      "Anchor / Emcee",           "Professional bilingual event anchor",            8_000],
  ["wedding_planner",   "Wedding Coordinator",      "Day-of wedding coordinator",                    20_000],
  ["choreographer",     "Choreographer",            "Sangeet choreographer (3 sessions)",            12_000],
  ["transport_shuttle", "Guest Shuttle",            "Air-conditioned guest shuttle service",         16_000]
].freeze

ADD_ONS.each do |key, label, desc, rupees|
  AddOn.find_or_create_by!(key: key) do |a|
    a.label = label
    a.description = desc
    a.price_cents = rupees * 100
    a.active = true
  end
end

# ---------------------------------------------------------------------------
# Skip transactional seeding outside development
# ---------------------------------------------------------------------------
unless Rails.env.development?
  puts "Done (catalogue only — skipped users/bookings outside development)."
  return
end

# ---------------------------------------------------------------------------
# Demo customer users (~35)
# ---------------------------------------------------------------------------
puts "Seeding customer users..."

CITIES = %w[Pune Mumbai Bengaluru Hyderabad Delhi Chennai Kolkata Jaipur Ahmedabad Indore Lucknow Chandigarh Surat Nagpur Kochi].freeze
FIRST_NAMES = %w[Aanya Aarav Arjun Diya Ishaan Kavya Krishna Meera Nisha Rahul Riya Rohan Saanvi Sahil Tanya Vihaan Anika Aditya Bhavna Chetan Devansh Esha Farhan Gauri Harsh Ira Jay Kabir Lavanya Manav Neha Om Pooja Quincy Rhea].freeze
LAST_NAMES  = %w[Shah Patel Iyer Reddy Mehta Sharma Gupta Kapoor Khanna Joshi Sinha Roy Bose Nair Pillai Desai Verma Singh Bhat Rao Menon Naik Trivedi].freeze

35.times do |i|
  first = FIRST_NAMES[i % FIRST_NAMES.size]
  last  = LAST_NAMES[(i * 3) % LAST_NAMES.size]
  email = "customer#{i + 1}@example.com"

  User.find_or_create_by!(email: email) do |u|
    u.full_name      = "#{first} #{last}"
    u.phone          = format("+9198%08d", 10_000_000 + i)
    u.password       = "password123"
    u.account_type   = :customer
    u.accepted_terms = true
    u.username       = "#{first.downcase}_#{last.downcase}#{i + 1}"
    u.city           = CITIES[i % CITIES.size]
    u.bio            = "Lover of well-curated events. Customer ##{i + 1}."
    u.avatar_url     = "https://i.pravatar.cc/200?img=#{(i % 70) + 1}"
    u.email_verified_at = Time.current
    u.phone_verified_at = Time.current
  end
end

customers = User.customer.where("email LIKE 'customer%@example.com'").order(:id).to_a

# ---------------------------------------------------------------------------
# Vendor users + decorators (~35)
# ---------------------------------------------------------------------------
puts "Seeding vendor users + decorators..."

STUDIO_PREFIXES = %w[Bloom Royal Magnolia Lotus Saffron Marigold Crimson Velvet Heritage Imperial Jasmine Orchid Pearl Indigo Twilight Aurora Mystic Celestial Coral Ember Mirage Opal Petal Sapphire Verve Whisper Zenith Mango Mosaic Nova Olive Plum Quartz Riviera Sunset].freeze
STUDIO_SUFFIXES = ["Decor Studio", "Events", "Designs", "Weddings Co.", "Concepts", "Atelier", "Productions", "Curators", "Collective"].freeze
SPECIALTIES = ["Wedding & Sangeet specialist", "Corporate & launch events", "Boutique birthdays", "Destination weddings", "Festive & cultural", "Modern luxury", "Traditional Indian", "Eco-friendly decor", "Floral storytelling", "Pastel & minimal"].freeze
TAGLINES = ["Where florals tell your story", "Crafting unforgettable moments", "Modern decor, timeless memories", "Designed around your story", "Every detail, designed", "Bringing vision to life"].freeze
AREAS = ["Koregaon Park", "Bandra West", "Indiranagar", "Banjara Hills", "Hauz Khas", "T. Nagar", "Park Street", "C-Scheme", "SG Highway", "Vijay Nagar"].freeze

35.times do |i|
  email       = "vendor#{i + 1}@example.com"
  city        = CITIES[i % CITIES.size]
  studio_name = "#{STUDIO_PREFIXES[i % STUDIO_PREFIXES.size]} #{STUDIO_SUFFIXES[i % STUDIO_SUFFIXES.size]}"

  user = User.find_or_create_by!(email: email) do |u|
    u.full_name      = studio_name
    u.phone          = format("+9199%08d", 20_000_000 + i)
    u.password       = "password123"
    u.account_type   = :vendor
    u.accepted_terms = true
    u.username       = "vendor_#{i + 1}"
    u.city           = city
    u.bio            = "#{studio_name} - boutique event design studio in #{city}."
    u.avatar_url     = "https://i.pravatar.cc/200?img=#{((i + 30) % 70) + 1}"
  end

  Decorator.find_or_create_by!(user: user) do |d|
    d.name              = studio_name
    d.specialty         = SPECIALTIES[i % SPECIALTIES.size]
    d.tagline           = pick(TAGLINES)
    d.bio               = "Award-winning event design studio with #{5 + (i % 15)}+ years of experience based in #{city}."
    d.avatar_url        = "https://i.pravatar.cc/200?img=#{((i + 10) % 70) + 1}"
    d.hourly_rate_cents = (1_500 + (i % 20) * 250) * 100
    d.area              = pick(AREAS)
    d.city              = city
    d.phone             = user.phone
    d.latitude          = (18.0 + RNG.rand * 10.0).round(6)
    d.longitude         = (72.0 + RNG.rand * 16.0).round(6)
    d.rating_avg        = (3.6 + RNG.rand * 1.4).round(2)
    d.review_count      = 10 + RNG.rand(200)
    d.active            = true
    d.category          = SPECIALTIES[i % SPECIALTIES.size].split(/[ &]/).first.downcase
    d.open              = (i % 5) != 0 # ~80% open
    d.location_updated_at = Time.current
  end
end

decorators = Decorator.order(:id).to_a
categories = Category.order(:position).to_a

# ---------------------------------------------------------------------------
# Designs (~40, with images + inclusions)
# ---------------------------------------------------------------------------
puts "Seeding designs..."

DESIGN_TITLES = [
  "Royal Mandap Floral Setup", "Pastel Pista Reception", "Boho Beach Wedding", "Crimson Velvet Sangeet",
  "Marigold Haldi Garden", "Mehendi Jharokha Lounge", "Corporate Keynote Stage", "Product Launch LED Wall",
  "Birthday Carnival Theme", "Princess Castle Birthday", "1st Birthday Pastel Cloud", "Anniversary Candlelight Dinner",
  "Silver Jubilee Decor", "Golden Anniversary Setup", "Diwali Diya & Rangoli", "Navratri Garba Stage",
  "Christmas Snowflake Setup", "New Year Gala Backdrop", "Engagement Floral Arch", "Reception Glasshouse Theme",
  "Destination Beach Mandap", "Rooftop Cocktail Lounge", "Sangeet Bollywood Stage", "Mehendi Boho Tent",
  "Conference Modern Stage", "Award Night Glamour", "Charity Gala Setup", "Baby Shower Cloud Theme",
  "Naming Ceremony Floral Setup", "House-Warming Traditional", "School Annual Day Stage", "Graduation Photo Wall",
  "Retirement Memory Lane", "Bachelorette Pink Theme", "Bachelor Casino Night", "Pool Party Tropical",
  "Kids Dinosaur Theme", "Kids Unicorn Theme", "Festive Pongal Decor", "Eid Crescent Theme"
].freeze

DESIGN_IMAGES = %w[
  https://images.unsplash.com/photo-1519741497674-611481863552?w=900
  https://images.unsplash.com/photo-1530023367847-a683933f4172?w=900
  https://images.unsplash.com/photo-1583394293214-28ded15ee548?w=900
  https://images.unsplash.com/photo-1464347744102-11db6282f854?w=900
  https://images.unsplash.com/photo-1515169067868-5387ec356754?w=900
  https://images.unsplash.com/photo-1604608672516-f1b9b1d6f5d2?w=900
  https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=900
  https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=900
  https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=900
  https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=900
].freeze

INCLUSION_PRESETS = [
  [["Floral mandap", "local_florist"], ["Lighting setup", "lightbulb"], ["Audio system", "speaker"], ["3 hours service", "schedule"]],
  [["Stage backdrop", "panorama"], ["Truss & lights", "lightbulb"], ["Sound system", "speaker"], ["DJ console", "music_note"]],
  [["Floral entry arch", "local_florist"], ["Welcome counter", "table_restaurant"], ["Carpet runner", "linear_scale"], ["Photo backdrop", "photo_camera"]],
  [["Theme props", "toys"], ["Balloon decor", "celebration"], ["Cake table", "cake"], ["Photo zone", "photo_camera"]],
  [["Drapes & lighting", "lightbulb"], ["Floral centerpieces", "local_florist"], ["Stage setup", "panorama"], ["4 hours service", "schedule"]]
].freeze

DESIGN_SUBTITLES = ["Hand-crafted for your big day", "Designed end-to-end", "Premium materials & florals", "Modern luxury setup", "Boutique signature design"].freeze

DESIGN_TITLES.each_with_index do |title, i|
  decorator = decorators[i % decorators.size]
  category  = categories[i % categories.size]

  design = Design.find_or_create_by!(decorator: decorator, title: title) do |d|
    d.category    = category
    d.subtitle    = pick(DESIGN_SUBTITLES)
    d.description = "A #{category.title.downcase} setup with curated florals, lighting and stage design. " \
                    "Includes setup, on-site coordination and tear-down. Customisable per venue."
    d.price_cents = (15_000 + RNG.rand(85) * 1_000) * 100
    d.rating_avg  = (3.8 + RNG.rand * 1.2).round(2)
    d.review_count = 5 + RNG.rand(100)
    d.hero_image_url = DESIGN_IMAGES[i % DESIGN_IMAGES.size]
    d.featured  = i.even?
    d.trending  = (i % 3).zero?
    d.available = true
    d.saved_count = RNG.rand(500)
  end

  if design.images.empty?
    pick_n(DESIGN_IMAGES, 4).each_with_index do |url, idx|
      design.images.create!(url: url, position: idx)
    end
  end

  if design.inclusions.empty?
    pick(INCLUSION_PRESETS).each_with_index do |(label, icon), idx|
      design.inclusions.create!(label: label, icon_key: icon, position: idx)
    end
  end
end

designs = Design.order(:id).to_a
add_ons = AddOn.active.order(:id).to_a

# ---------------------------------------------------------------------------
# Addresses (~2 per customer)
# ---------------------------------------------------------------------------
puts "Seeding addresses..."

LABELS  = %w[Home Work Parents Vacation].freeze
STREETS = ["MG Road", "Park Street", "Linking Road", "FC Road", "Brigade Road"].freeze
STATES  = %w[MH KA TN DL TS GJ WB RJ].freeze

customers.each_with_index do |user, i|
  2.times do |n|
    label = LABELS[(i + n) % LABELS.size]
    Address.find_or_create_by!(user: user, label: label) do |a|
      a.recipient_name = user.full_name
      a.line1          = "#{(i + 1) * 10 + n} #{pick(STREETS)}"
      a.line2          = ["Apt 4B", "Bldg 12", nil, "Floor 3", nil].sample(random: RNG)
      a.city           = user.city
      a.state          = pick(STATES)
      a.postal_code    = format("%06d", 400_000 + RNG.rand(99_999))
      a.country        = "IN"
      a.phone          = user.phone
      a.is_default     = n.zero?
    end
  end
end

# ---------------------------------------------------------------------------
# Payment methods (~3 per customer for the first 30)
# ---------------------------------------------------------------------------
puts "Seeding payment methods..."

WALLETS = ["Paytm Wallet", "Amazon Pay", "PhonePe Wallet"].freeze

customers.first(30).each_with_index do |user, i|
  %i[card upi wallet].each_with_index do |kind, j|
    title =
      case kind
      when :card   then "Visa ending #{format('%04d', 1000 + i * 7)}"
      when :upi    then "#{user.username}@upi"
      when :wallet then WALLETS[i % WALLETS.size]
      end

    PaymentMethod.find_or_create_by!(user: user, kind: kind, title: title) do |pm|
      pm.subtitle   = kind == :card ? "Expires 12/29" : nil
      pm.last4      = kind == :card ? format("%04d", 1000 + i * 7) : nil
      pm.expires_on = kind == :card ? Date.new(2029, 12, 1) : nil
      pm.is_default = j.zero?
    end
  end
end

# ---------------------------------------------------------------------------
# Saved designs / favorites (~3 per user)
# ---------------------------------------------------------------------------
puts "Seeding saved designs..."

customers.each_with_index do |user, i|
  3.times do |n|
    design = designs[(i * 3 + n * 7) % designs.size]
    SavedDesign.find_or_create_by!(user: user, design: design)
  end
end

# ---------------------------------------------------------------------------
# Bookings (~40 across statuses)
# ---------------------------------------------------------------------------
puts "Seeding bookings..."

EVENT_TYPES = ["Wedding", "Sangeet", "Mehendi", "Haldi", "Reception", "Birthday", "Anniversary", "Corporate", "Product Launch", "Baby Shower"].freeze
TIME_SLOTS  = %w[10:00-14:00 14:00-18:00 18:00-22:00 19:00-23:00].freeze
VENUES      = ["Taj Banquet Hall", "Marriott Grand", "The Leela Palace", "JW Marriott", "Hyatt Regency", "ITC Maratha", "The Westin", "Radisson Blu"].freeze
VENUE_STREETS = ["MG Road", "Linking Road", "FC Road", "Park Street", "SG Highway"].freeze
INSTRUCTIONS  = ["Please use pastel palette", "Allergic to lilies", "Vegan menu preferred", nil, nil].freeze

40.times do |i|
  reference = format("DMS-SEED%04d", i + 1)

  booking = Booking.find_or_create_by!(booking_reference: reference) do |b|
    user      = customers[i % customers.size]
    design    = designs[i % designs.size]
    decorator = design.decorator
    selected_addons = pick_n(add_ons, 1 + RNG.rand(3))

    subtotal = design.price_cents + selected_addons.sum(&:price_cents)
    gst      = (subtotal * Booking::GST_RATE).round
    total    = subtotal + gst
    advance  = (total * Booking::ADVANCE_RATE).round

    days_offset =
      case i % 4
      when 0 then 30 + i
      when 1 then 5 + (i % 20)
      when 2 then -(20 + (i % 60))
      else        -(80 + (i % 50))
      end

    status, payment_status, cancelled_at, cancellation_reason =
      if days_offset >= 0
        i.even? ? [:upcoming, :paid, nil, nil] : [:upcoming, :pending, nil, nil]
      elsif (i % 4) == 3 && (i % 8).zero?
        [:cancelled, :refunded, Time.current - 10.days, "Plans changed"]
      else
        [:completed, :paid, nil, nil]
      end

    b.user      = user
    b.design    = design
    b.decorator = decorator
    b.status    = status
    b.event_type = EVENT_TYPES[i % EVENT_TYPES.size]
    b.event_date = Date.current + days_offset.days
    b.time_slot  = TIME_SLOTS[i % TIME_SLOTS.size]
    b.expected_guests = 50 + (i % 12) * 25
    b.venue_name           = pick(VENUES)
    b.venue_address_line1  = "#{(i + 1) * 4} #{pick(VENUE_STREETS)}"
    b.venue_address_line2  = user.city
    b.contact_full_name    = user.full_name
    b.contact_phone        = user.phone
    b.contact_email        = user.email
    b.special_instructions = pick(INSTRUCTIONS)
    b.subtotal_cents     = subtotal
    b.gst_cents          = gst
    b.total_cents        = total
    b.advance_paid_cents = advance
    b.payment_method     = %i[card upi netbanking][i % 3]
    b.payment_status     = payment_status
    b.placed_on          = (b.event_date.to_time - 14.days)
    b.cancelled_at       = cancelled_at
    b.cancellation_reason = cancellation_reason
  end

  next if booking.booking_add_ons.any?

  pick_n(add_ons, 1 + RNG.rand(3)).each do |addon|
    booking.booking_add_ons.find_or_create_by!(add_on: addon) do |line|
      line.price_cents = addon.price_cents
    end
  end
end

# ---------------------------------------------------------------------------
# Reviews (one per completed booking, up to ~30)
# ---------------------------------------------------------------------------
puts "Seeding reviews..."

REVIEW_COMMENTS = [
  "Absolutely loved the setup, on-time and beautifully executed.",
  "Great team, very professional and easy to work with.",
  "Decor was stunning, guests are still talking about it.",
  "Good experience overall, would book again.",
  "Setup quality was excellent, communication could be better.",
  "Exceeded expectations. Worth every rupee.",
  "Beautiful decor, slightly delayed start but ended well."
].freeze
REVIEW_TAGS = %w[on-time creative responsive value floral lighting team].freeze

Booking.completed.order(:id).limit(30).each_with_index do |booking, i|
  Review.find_or_create_by!(booking: booking) do |r|
    r.user            = booking.user
    r.decorator       = booking.decorator
    r.design          = booking.design
    r.rating          = [3, 4, 4, 5, 5, 5][i % 6]
    r.comment         = REVIEW_COMMENTS[i % REVIEW_COMMENTS.size]
    r.tags            = pick_n(REVIEW_TAGS, 2 + RNG.rand(3))
    r.would_recommend = (i % 7) != 0
  end
end

# Recompute aggregate ratings now that reviews exist.
Decorator.find_each(&:recompute_rating!)
Design.find_each(&:recompute_rating!)

# ---------------------------------------------------------------------------
# Notifications (~4 per user, mixed kinds)
# ---------------------------------------------------------------------------
puts "Seeding notifications..."

NOTIF_TEMPLATES = [
  { kind: :system,    title: "Welcome to Decor My Space",    body: "Discover curated decor for every occasion." },
  { kind: :system,    title: "App updated",                  body: "We've improved search and added new categories." },
  { kind: :promotion, title: "Festive offer: 15% off",       body: "Use code FESTIVE15 on bookings above ₹50,000." },
  { kind: :promotion, title: "New designs added",            body: "Fresh wedding mandaps now available." },
  { kind: :booking,   title: "Booking reminder",             body: "Your event is coming up in 7 days." },
  { kind: :booking,   title: "Vendor on the way",            body: "Setup team has been dispatched." },
  { kind: :payment,   title: "Payment received",             body: "We've received your advance payment." },
  { kind: :payment,   title: "Refund processed",             body: "Your refund will reflect in 5-7 days." }
].freeze

customers.each_with_index do |user, i|
  NOTIF_TEMPLATES.each_with_index do |tpl, j|
    next unless ((i + j) % 2).zero?

    Notification.find_or_create_by!(user: user, title: tpl[:title], kind: Notification.kinds[tpl[:kind]]) do |n|
      n.body         = tpl[:body]
      n.payload      = { source: "seed" }
      n.delivered_at = Time.current - RNG.rand(30).days
      n.read_at      = j.even? ? nil : (Time.current - RNG.rand(15).days)
    end
  end
end

# ---------------------------------------------------------------------------
# Support tickets (~30)
# ---------------------------------------------------------------------------
puts "Seeding support tickets..."

TICKET_TEMPLATES = [
  { category: "Booking",  subject: "Cannot cancel my booking",          message: "I tried to cancel but received an error." },
  { category: "Booking",  subject: "Need to reschedule event date",     message: "Please help me change the event date." },
  { category: "Payment",  subject: "Payment failed but amount debited", message: "INR 21,000 was debited but booking shows pending." },
  { category: "Payment",  subject: "Refund not received",               message: "Cancelled booking 10 days ago, refund pending." },
  { category: "Vendor",   subject: "Vendor not responding",             message: "Trying to reach the vendor for 2 days." },
  { category: "Account",  subject: "Cannot update email",               message: "OTP for new email is not arriving." },
  { category: "Account",  subject: "Forgot password reset link",        message: "Reset email never came through." },
  { category: "App",      subject: "App crashes on opening booking",    message: "iOS app crashes when I tap My Bookings." }
].freeze

TICKET_STATUSES = SupportTicket.statuses.keys

customers.first(30).each_with_index do |user, i|
  tpl = TICKET_TEMPLATES[i % TICKET_TEMPLATES.size]

  SupportTicket.find_or_create_by!(user: user, subject: "#{tpl[:subject]} ##{i + 1}") do |t|
    t.category = tpl[:category]
    t.message  = tpl[:message]
    t.email    = user.email
    t.status   = TICKET_STATUSES[i % TICKET_STATUSES.size]
  end
end

# ---------------------------------------------------------------------------
# Diversify user preferences
# ---------------------------------------------------------------------------
puts "Diversifying user preferences..."

customers.each_with_index do |user, i|
  user.preferences.update!(
    dark_mode:         i.odd?,
    locale:            %w[en hi ar][i % 3],
    currency:          %w[INR USD AED][i % 3],
    notify_bookings:   true,
    notify_promotions: (i % 4) != 0,
    notify_system:     true
  )
end

puts "Done."
puts "Counts:"
puts "  categories:      #{Category.count}"
puts "  add_ons:         #{AddOn.count}"
puts "  customers:       #{User.customer.count}"
puts "  vendors:         #{User.vendor.count}"
puts "  decorators:      #{Decorator.count}"
puts "  designs:         #{Design.count}"
puts "  design_images:   #{DesignImage.count}"
puts "  inclusions:      #{DesignInclusion.count}"
puts "  addresses:       #{Address.count}"
puts "  payment_methods: #{PaymentMethod.count}"
puts "  saved_designs:   #{SavedDesign.count}"
puts "  bookings:        #{Booking.count}"
puts "  booking_add_ons: #{BookingAddOn.count}"
puts "  reviews:         #{Review.count}"
puts "  notifications:   #{Notification.count}"
puts "  support_tickets: #{SupportTicket.count}"
