/**
 * ONE-TIME MASTER SETUP SCRIPT: DIGITAL MAÎTRE D' ECOSYSTEM (v3.0)
 * Environment: r6pitt1 (API 65.0)
 * Paths Covered: Transactional (1), Escalation (2), Concierge (3), RAG (4)
 * All 5 Logic States: DETERMINISTIC, PROBABILISTIC, DEGRADED, SPECULATIVE, STALE
 */

System.debug('INITIATING MASTER DATA SEED v3.0...');

// ==========================================
// 1. ACCOUNTS (10 RESTAURANTS — ALL LOGIC STATES)
// ==========================================
List<Account> rests = new List<Account>();

// [0] DETERMINISTIC — Score 5, verified 10 min ago
rests.add(new Account(
    Name='Le Petit Bistro', Cuisine_Type__c='French',
    Vibe_Tags__c='Romantic;Upscale', Family_Friendly__c=false,
    Safe_For_Allergies__c='Shellfish-free',
    Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-10),
    Reliability_Reason__c='Direct POS API Sync',
    Price_Tier__c='$$$', Average_Turnover_Minutes__c=120, Grace_Period_Mins__c=15,
    Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-3),
    Blackout_Dates__c='["2026-12-25","2026-12-31","2026-01-01"]'
));

// [1] PROBABILISTIC — Score 3, verified 12 hrs ago
rests.add(new Account(
    Name='Pasta Palace', Cuisine_Type__c='Italian',
    Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true,
    Safe_For_Allergies__c='Nut-free',
    Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-12),
    Reliability_Reason__c='Morning Manager Audit',
    Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15,
    Inventory_Buffer_Type__c=10, Last_Menu_Update__c=System.now().addDays(-7)
));

// [2] DEGRADED — Score 5, verified 2 days ago
rests.add(new Account(
    Name='Sushi Zen', Cuisine_Type__c='Japanese',
    Vibe_Tags__c='Business-Quiet;Upscale', Family_Friendly__c=false,
    Safe_For_Allergies__c='Nut-free',
    Reliability_Score__c=5, Data_Last_Verified__c=System.now().addDays(-2),
    Reliability_Reason__c='Live Integration (Stalled)',
    Price_Tier__c='$$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=10,
    Inventory_Buffer_Type__c=5, Last_Menu_Update__c=System.now().addDays(-14)
));

// [3] SPECULATIVE — Score 2, verified 2 hrs ago
rests.add(new Account(
    Name='The Burger Joint', Cuisine_Type__c='American',
    Vibe_Tags__c='Casual;Trendy', Family_Friendly__c=true,
    Reliability_Score__c=2, Data_Last_Verified__c=System.now().addHours(-2),
    Reliability_Reason__c='Hostess iPad Manual Entry',
    Price_Tier__c='$', Average_Turnover_Minutes__c=45, Grace_Period_Mins__c=5,
    Inventory_Buffer_Type__c=20, Last_Menu_Update__c=System.now().addDays(-30)
));

// [4] STALE — Score 4, verified 10 days ago
rests.add(new Account(
    Name='Forgotten Fondue', Cuisine_Type__c='French',
    Vibe_Tags__c='Romantic', Family_Friendly__c=false,
    Reliability_Score__c=4, Data_Last_Verified__c=System.now().addDays(-10),
    Reliability_Reason__c='Legacy Vendor Sync',
    Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15,
    Inventory_Buffer_Type__c=50, Last_Menu_Update__c=System.now().addDays(-60)
));

// [5] PROBABILISTIC — Score 4, verified 5 hrs ago
rests.add(new Account(
    Name='Vibe Vegan', Cuisine_Type__c='Vegan',
    Vibe_Tags__c='Trendy;Outdoor-Dining', Family_Friendly__c=false,
    Safe_For_Allergies__c='Nut-free;Shellfish-free',
    Primary_Safety_Tag__c='Nut-Free Certified',
    Reliability_Score__c=4, Data_Last_Verified__c=System.now().addHours(-5),
    Reliability_Reason__c='Owner Direct Update',
    Price_Tier__c='$$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10,
    Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-1)
));

// [6] PROBABILISTIC — Score 3, verified 1 hr ago
rests.add(new Account(
    Name='Taco Tequila', Cuisine_Type__c='Mexican',
    Vibe_Tags__c='Live-Music;Casual', Family_Friendly__c=true,
    Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-1),
    Reliability_Reason__c='Nightly Staff Check-In',
    Price_Tier__c='$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10,
    Inventory_Buffer_Type__c=15, Last_Menu_Update__c=System.now().addDays(-5)
));

// [7] DETERMINISTIC — Score 5, verified 30 min ago
rests.add(new Account(
    Name='Curry House', Cuisine_Type__c='Indian',
    Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true,
    Primary_Safety_Tag__c='Certified Halal',
    Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-30),
    Reliability_Reason__c='Direct POS API Sync',
    Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15,
    Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-2)
));

// [8] DETERMINISTIC — Score 5, verified 5 min ago
rests.add(new Account(
    Name='Steak & Stone', Cuisine_Type__c='Steakhouse',
    Vibe_Tags__c='Business-Quiet;Upscale', Family_Friendly__c=false,
    Primary_Safety_Tag__c='HACCP Compliant',
    Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-5),
    Reliability_Reason__c='Real-Time Resy Integration',
    Price_Tier__c='$$$$', Average_Turnover_Minutes__c=120, Grace_Period_Mins__c=20,
    Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addHours(-6),
    Blackout_Dates__c='["2026-02-14","2026-12-24","2026-12-25","2026-12-31"]'
));

// [9] PROBABILISTIC — Score 3, verified ~24 hrs ago
rests.add(new Account(
    Name='Dim Sum Garden', Cuisine_Type__c='Chinese',
    Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true,
    Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-23),
    Reliability_Reason__c='Weekly Manager Audit',
    Price_Tier__c='$$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10,
    Inventory_Buffer_Type__c=10, Last_Menu_Update__c=System.now().addDays(-4)
));

insert rests;
System.debug('Accounts inserted: ' + rests.size());


// ==========================================
// 2. PHYSICAL TABLES (ALL 10 RESTAURANTS)
// ==========================================
List<Restaurant_Table__c> tables = new List<Restaurant_Table__c>();
Integer tNum = 1;

for(Integer i = 0; i < rests.size(); i++) {
    Account acc = rests[i];
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=acc.Id, Capacity__c=2, Table_Type__c='Window',   ADA_Accessible__c=true));  tNum++;
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=acc.Id, Capacity__c=4, Table_Type__c='Booth',    ADA_Accessible__c=false)); tNum++;
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=acc.Id, Capacity__c=6, Table_Type__c='Standard', ADA_Accessible__c=true));  tNum++;
}
// Patio tables for outdoor-friendly restaurants
tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[5].Id, Capacity__c=4, Table_Type__c='Patio', ADA_Accessible__c=true));  tNum++;
tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[6].Id, Capacity__c=4, Table_Type__c='Patio', ADA_Accessible__c=true));  tNum++;

insert tables;
System.debug('Tables inserted: ' + tables.size());


// ==========================================
// 3. TEMPORAL SLOTS (TODAY + NEXT WEEK)
// ==========================================
List<Restaurant_Slot__c> slots = new List<Restaurant_Slot__c>();
DateTime todayWindow = DateTime.newInstance(System.today(), Time.newInstance(17, 0, 0, 0));
DateTime nextWeekWindow = DateTime.newInstance(System.today().addDays(7), Time.newInstance(17, 0, 0, 0));

for(Restaurant_Table__c t : tables) {
    for(Integer j = 0; j < 4; j++) {
        slots.add(new Restaurant_Slot__c(Table__c=t.Id, Slot_Start_Time__c=todayWindow.addHours(j*2), Status__c='Available'));
        slots.add(new Restaurant_Slot__c(Table__c=t.Id, Slot_Start_Time__c=nextWeekWindow.addHours(j*2), Status__c='Available'));
    }
}
insert slots;
System.debug('Slots inserted: ' + slots.size());


// ==========================================
// 4. CONTACTS (THE DINERS / UNIFIED PROFILES)
// ==========================================
// Passcode__c: first 3 letters of FirstName + 123456 (e.g., Sof123456, Mar123456)

String passcodeFromName(String firstName) {
    if (String.isBlank(firstName)) return '123456';
    Integer len = Math.min(3, firstName.length());
    return firstName.substring(0, len) + '123456';
}

List<Contact> users = new List<Contact>();

// [0] Sofia — Gold, French preference, shellfish allergy, high trust tolerance (triggers escalation at low-reliability restaurants)
users.add(new Contact(
    FirstName='Sofia', LastName='Rodriguez', Email='sofiarodriguez@example.com',
    Cuisine_Preference__c='French', Allergy_Shellfish__c=true, Allergy_Nuts__c=false,
    Comm_Style__c='Brief/Efficiency', Membership_Level__c='Gold',
    Trust_Tolerance__c=5, Sentiment_Score__c=0.90,
    Lifetime_No_Show_Count__c=0, Churn_Risk__c=false,
    Passcode__c=passcodeFromName('Sofia')
));

// [1] Marcus — Silver, family diner, concierge style, low trust tolerance
users.add(new Contact(
    FirstName='Marcus', LastName='Chen', Email='marcuschen@example.com',
    Cuisine_Preference__c='Italian', Family_Status__c='Needs High Chair',
    Allergy_Shellfish__c=false, Allergy_Nuts__c=false,
    Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Silver',
    Trust_Tolerance__c=2, Sentiment_Score__c=0.50,
    Lifetime_No_Show_Count__c=1, Churn_Risk__c=false,
    Passcode__c=passcodeFromName('Marcus')
));

// [2] Elena — Platinum, vegan, nut allergy, NEGATIVE sentiment + churn risk (Path 2 triggers)
users.add(new Contact(
    FirstName='Elena', LastName='Vance', Email='elenavance@example.com',
    Cuisine_Preference__c='Vegan', Allergy_Nuts__c=true, Allergy_Shellfish__c=false,
    Comm_Style__c='Brief/Efficiency', Membership_Level__c='Platinum',
    Trust_Tolerance__c=4, Sentiment_Score__c=-0.80,
    Lifetime_No_Show_Count__c=0, Churn_Risk__c=true,
    Passcode__c=passcodeFromName('Elena')
));

// [3] James — Platinum, steakhouse preference, positive sentiment (concierge upsell test)
users.add(new Contact(
    FirstName='James', LastName='Whitfield', Email='jameswhitfield@example.com',
    Cuisine_Preference__c='Steakhouse', Allergy_Shellfish__c=false, Allergy_Nuts__c=false,
    Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Platinum',
    Trust_Tolerance__c=3, Sentiment_Score__c=0.95,
    Lifetime_No_Show_Count__c=0, Churn_Risk__c=false,
    Passcode__c=passcodeFromName('James')
));

// [4] Priya — Serial no-show (Lifetime >= 3 blocks automated bookings)
users.add(new Contact(
    FirstName='Priya', LastName='Kapoor', Email='priyakapoor@example.com',
    Cuisine_Preference__c='Indian', Allergy_Shellfish__c=false, Allergy_Nuts__c=false,
    Comm_Style__c='Brief/Efficiency', Membership_Level__c='Gold',
    Trust_Tolerance__c=3, Sentiment_Score__c=0.20,
    Lifetime_No_Show_Count__c=4, Churn_Risk__c=true,
    Passcode__c=passcodeFromName('Priya')
));

// [5-9] Varied test diners
users.add(new Contact(FirstName='Alex',  LastName='Rivera',  Email='arivera@example.com',  Cuisine_Preference__c='Mexican',    Comm_Style__c='Brief/Efficiency',     Membership_Level__c='Silver',   Trust_Tolerance__c=3, Sentiment_Score__c=0.60, Passcode__c=passcodeFromName('Alex')));
users.add(new Contact(FirstName='Lin',   LastName='Zhang',   Email='lzhang@example.com',   Cuisine_Preference__c='Chinese',    Comm_Style__c='Leisurely/Concierge',  Membership_Level__c='Gold',     Trust_Tolerance__c=4, Sentiment_Score__c=0.40, Family_Status__c='Stroller Access', Passcode__c=passcodeFromName('Lin')));
users.add(new Contact(FirstName='Sam',   LastName='Okafor',  Email='sokafor@example.com',  Cuisine_Preference__c='American',   Comm_Style__c='Brief/Efficiency',     Membership_Level__c='Silver',   Trust_Tolerance__c=2, Sentiment_Score__c=0.70, Passcode__c=passcodeFromName('Sam')));
users.add(new Contact(FirstName='Mia',   LastName='Tanaka',  Email='mtanaka@example.com',  Cuisine_Preference__c='Japanese',   Comm_Style__c='Brief/Efficiency',     Membership_Level__c='Gold',     Trust_Tolerance__c=5, Sentiment_Score__c=0.85, Allergy_Shellfish__c=true, Passcode__c=passcodeFromName('Mia')));
users.add(new Contact(FirstName='Omar',  LastName='Hassan',  Email='ohassan@example.com',  Cuisine_Preference__c='Indian',     Comm_Style__c='Leisurely/Concierge',  Membership_Level__c='Platinum', Trust_Tolerance__c=3, Sentiment_Score__c=0.55, Passcode__c=passcodeFromName('Omar')));

insert users;
System.debug('Contacts inserted: ' + users.size());


// ==========================================
// 5. RESERVATIONS (ALL 4 PATH TEST SCENARIOS)
// ==========================================
// Build slot lookup: restaurant index -> list of slots for that restaurant
Map<Id, List<Restaurant_Slot__c>> slotsByTable = new Map<Id, List<Restaurant_Slot__c>>();
for(Restaurant_Slot__c s : slots) {
    if(!slotsByTable.containsKey(s.Table__c)) slotsByTable.put(s.Table__c, new List<Restaurant_Slot__c>());
    slotsByTable.get(s.Table__c).add(s);
}

List<Reservation__c> reservations = new List<Reservation__c>();

// Res [0]: LOCKED — Sofia at Le Petit Bistro, 45 min from now (Is_Locked = TRUE)
Restaurant_Slot__c lockedSlot = slotsByTable.get(tables[0].Id)[0];
reservations.add(new Reservation__c(
    Contact__c=users[0].Id, Restaurant__c=rests[0].Id,
    Reservation_DateTime__c=System.now().addMinutes(45),
    Status__c='Confirmed', Assigned_Table_Slot__c=lockedSlot.Id,
    Party_Size__c=2, Modification_Count__c=0
));

// Res [1]: MODIFIABLE — Sofia at Sushi Zen (DEGRADED), next week
Restaurant_Slot__c modSlot = slotsByTable.get(tables[6].Id)[4];
reservations.add(new Reservation__c(
    Contact__c=users[0].Id, Restaurant__c=rests[2].Id,
    Reservation_DateTime__c=System.now().addDays(7),
    Status__c='Confirmed', Assigned_Table_Slot__c=modSlot.Id,
    Party_Size__c=4, Modification_Count__c=1,
    Modification_History__c='2026-03-02 14:00 — Moved from 6 PM to 7 PM by diner request.'
));

// Res [2]: PENDING STAFF APPROVAL — Sam at Burger Joint (SPECULATIVE state, auto-creates as Pending)
Restaurant_Slot__c specSlot = slotsByTable.get(tables[9].Id)[5];
reservations.add(new Reservation__c(
    Contact__c=users[7].Id, Restaurant__c=rests[3].Id,
    Reservation_DateTime__c=System.now().addDays(3),
    Status__c='Pending_Staff_Approval', Assigned_Table_Slot__c=specSlot.Id,
    Party_Size__c=2, Modification_Count__c=0
));

// Res [3]: ESCALATION TRIGGER — Marcus at Pasta Palace, modification count > 3
Restaurant_Slot__c escSlot = slotsByTable.get(tables[3].Id)[5];
reservations.add(new Reservation__c(
    Contact__c=users[1].Id, Restaurant__c=rests[1].Id,
    Reservation_DateTime__c=System.now().addDays(5),
    Status__c='Modified', Assigned_Table_Slot__c=escSlot.Id,
    Party_Size__c=4, Modification_Count__c=4,
    Modification_History__c='2026-02-28 — Party 6->4.\n2026-03-01 — Moved 7PM->8PM.\n2026-03-01 — Moved 8PM->7PM.\n2026-03-02 — Party 4->3.',
    AI_Summary__c='Diner has modified this reservation 4 times. Pattern suggests indecision. Recommend human concierge outreach.'
));

// Res [4]: James at Steak & Stone (DETERMINISTIC, Platinum upsell scenario)
Restaurant_Slot__c vipSlot = slotsByTable.get(tables[24].Id)[5];
reservations.add(new Reservation__c(
    Contact__c=users[3].Id, Restaurant__c=rests[8].Id,
    Reservation_DateTime__c=System.now().addDays(14),
    Status__c='Confirmed', Assigned_Table_Slot__c=vipSlot.Id,
    Party_Size__c=2, Modification_Count__c=0
));

insert reservations;

// Mark booked slots as Reserved
List<Restaurant_Slot__c> bookedSlots = new List<Restaurant_Slot__c>();
lockedSlot.Status__c = 'Reserved'; bookedSlots.add(lockedSlot);
modSlot.Status__c = 'Reserved';    bookedSlots.add(modSlot);
specSlot.Status__c = 'Reserved';   bookedSlots.add(specSlot);
escSlot.Status__c = 'Reserved';    bookedSlots.add(escSlot);
vipSlot.Status__c = 'Reserved';    bookedSlots.add(vipSlot);
update bookedSlots;

System.debug('Reservations inserted: ' + reservations.size());


// ==========================================
// 6. RAG KNOWLEDGE (FAQ__kav - ORG SPECIFIC)
// ==========================================
List<FAQ__kav> articles = new List<FAQ__kav>();

// --- POLICY ARTICLES (one per restaurant, varying confidence & PII) ---
Map<String, String> policyContent = new Map<String, String>{
    'Le Petit Bistro' =>
        '<h2>Le Petit Bistro - Dining Policy</h2>' +
        '<p><b>Dress Code:</b> Formal attire required. Jackets preferred for gentlemen.</p>' +
        '<p><b>Grace Period:</b> 15 minutes. Reservations released after grace period.</p>' +
        '<p><b>Cancellation:</b> Free cancellation up to 24 hours in advance. Late cancellations incur a $50 per person fee.</p>' +
        '<p><b>Allergen Notice:</b> Shellfish-free kitchen. All dishes prepared in a shellfish-free environment.</p>' +
        '<p><b>Special Occasions:</b> Complimentary champagne toast for birthdays with 48-hour advance notice.</p>' +
        '<p><b>Vibe:</b> Romantic, upscale. Ideal for anniversaries and intimate dinners.</p>',
    'Pasta Palace' =>
        '<h2>Pasta Palace - Family Dining Guide</h2>' +
        '<p><b>Dress Code:</b> Casual. Come as you are!</p>' +
        '<p><b>Family Amenities:</b> High chairs, booster seats, coloring books, kids menu available.</p>' +
        '<p><b>Allergen Notice:</b> Nut-free preparation area available. Please notify staff of any allergies.</p>' +
        '<p><b>Group Bookings:</b> Parties of 8+ receive a complimentary antipasto platter.</p>' +
        '<p><b>Happy Hour:</b> Mon-Thu 4-6 PM, half-price appetizers.</p>',
    'Sushi Zen' =>
        '<h2>Sushi Zen - Guest Information</h2>' +
        '<p><b>Dress Code:</b> Smart casual.</p>' +
        '<p><b>Important Allergen Warning:</b> Our kitchen handles shellfish extensively. We cannot guarantee a shellfish-free environment. Guests with shellfish allergies should exercise caution.</p>' +
        '<p><b>Allergen Note:</b> Nut-free preparation available upon request.</p>' +
        '<p><b>Omakase:</b> Chef\'s tasting menu available at the sushi bar (reservation required, 2 guests max).</p>' +
        '<p><b>Sake Pairing:</b> Premium sake flight available for $45.</p>',
    'The Burger Joint' =>
        '<h2>The Burger Joint - House Rules</h2>' +
        '<p><b>Dress Code:</b> Casual.</p>' +
        '<p><b>Reservations:</b> We primarily accept walk-ins. Reservations are subject to staff confirmation.</p>' +
        '<p><b>Payment:</b> We accept all major credit cards and cash.</p>' +
        '<p><b>Wait Times:</b> Average 20-30 minutes during peak hours (Fri/Sat 6-8 PM).</p>',
    'Forgotten Fondue' =>
        '<h2>Forgotten Fondue - Dining Etiquette</h2>' +
        '<p><b>Dress Code:</b> Smart casual.</p>' +
        '<p><b>Seating Policy:</b> Full party must be present before seating. No partial seating.</p>' +
        '<p><b>Note:</b> Data for this restaurant may not be current. Please call ahead to confirm hours and availability.</p>',
    'Vibe Vegan' =>
        '<h2>Vibe Vegan - Plant-Based Dining</h2>' +
        '<p><b>Dress Code:</b> Casual.</p>' +
        '<p><b>Allergen Certifications:</b> 100% Nut-Free Certified kitchen. Shellfish-free. All dishes are vegan and free from the top 8 allergens.</p>' +
        '<p><b>Sourcing:</b> Organic, locally sourced produce. Carbon-neutral kitchen.</p>' +
        '<p><b>Patio:</b> Dog-friendly outdoor seating available.</p>',
    'Taco Tequila' =>
        '<h2>Taco Tequila - Cantina Guide</h2>' +
        '<p><b>Dress Code:</b> Casual.</p>' +
        '<p><b>Age Policy:</b> Adults only after 9 PM (live music events).</p>' +
        '<p><b>Specialty:</b> Tableside guacamole and margarita flights.</p>' +
        '<p><b>Patio:</b> Outdoor seating available, first-come first-served.</p>',
    'Curry House' =>
        '<h2>Curry House - Dining Information</h2>' +
        '<p><b>Dress Code:</b> Smart casual.</p>' +
        '<p><b>Certification:</b> Certified Halal kitchen. All meats are halal-sourced.</p>' +
        '<p><b>Spice Levels:</b> Dishes range from Mild (1) to Volcanic (10). Staff will guide you.</p>' +
        '<p><b>Vegetarian:</b> Extensive vegetarian and vegan menu section available.</p>' +
        '<p><b>Family:</b> Kids eat free on Sundays with a paying adult.</p>',
    'Steak & Stone' =>
        '<h2>Steak & Stone - Executive Dining</h2>' +
        '<p><b>Dress Code:</b> Formal. Jackets required. No athletic wear.</p>' +
        '<p><b>Private Dining:</b> Private booths available for business meetings (seats 2-6).</p>' +
        '<p><b>Wine Program:</b> Sommelier-curated wine list with 200+ selections.</p>' +
        '<p><b>Platinum Members:</b> Complimentary champagne and priority seating.</p>' +
        '<p><b>Wagyu:</b> A5 Japanese Wagyu available (market price, 48-hr advance order).</p>',
    'Dim Sum Garden' =>
        '<h2>Dim Sum Garden - Group Dining Guide</h2>' +
        '<p><b>Dress Code:</b> Casual.</p>' +
        '<p><b>Service Style:</b> Rapid dim sum cart service. Dishes arrive in 3-5 minute intervals.</p>' +
        '<p><b>Group Specialty:</b> Ideal for large parties (8+). Lazy Susan tables available.</p>' +
        '<p><b>Tea Service:</b> Complimentary jasmine tea with every table.</p>'
};

for(Integer i = 0; i < rests.size(); i++) {
    Account acc = rests[i];
    if(policyContent.containsKey(acc.Name)) {
        Decimal confidence = 0.95;
        String pii = 'Public';
        Date effectiveDate = System.today().addDays(-30);

        if(acc.Name == 'Forgotten Fondue') { confidence = 0.35; effectiveDate = System.today().addDays(-180); }
        if(acc.Name == 'The Burger Joint') { confidence = 0.60; }

        articles.add(new FAQ__kav(
            Title = acc.Name + ': Official Policy',
            UrlName = acc.Name.toLowerCase().replaceAll('[^a-z0-9]', '') + '-policy',
            Answer__c = policyContent.get(acc.Name),
            Restaurant_Lookup__c = acc.Id,
            Article_Type__c = 'Policy',
            AI_Confidence_Score__c = confidence,
            Policy_Effective_Date__c = effectiveDate,
            PII_Sensitivity__c = pii
        ));
    }
}

// --- PARKING ARTICLES ---
articles.add(new FAQ__kav(
    Title = 'Le Petit Bistro: Parking Guide',
    UrlName = 'lepetitbistro-parking',
    Answer__c = '<h2>Parking at Le Petit Bistro</h2><p>Complimentary valet parking available Thu-Sun evenings. Street parking on Elm St (metered until 8 PM). Nearest garage: City Center Garage, 2 blocks east ($12 flat rate after 5 PM).</p>',
    Restaurant_Lookup__c = rests[0].Id,
    Article_Type__c = 'Parking',
    AI_Confidence_Score__c = 0.90,
    Policy_Effective_Date__c = System.today().addDays(-15),
    PII_Sensitivity__c = 'Public'
));

articles.add(new FAQ__kav(
    Title = 'Steak & Stone: Parking & Arrival',
    UrlName = 'steakandstone-parking',
    Answer__c = '<h2>Parking at Steak & Stone</h2><p>Complimentary valet for all guests. Self-park available in the attached underground garage (Level B2, validated). Platinum members receive priority valet with dedicated lane.</p>',
    Restaurant_Lookup__c = rests[8].Id,
    Article_Type__c = 'Parking',
    AI_Confidence_Score__c = 0.92,
    Policy_Effective_Date__c = System.today().addDays(-10),
    PII_Sensitivity__c = 'Public'
));

// --- INTERNAL PII ARTICLE (Einstein Trust Layer test) ---
articles.add(new FAQ__kav(
    Title = 'VIP Guest Preferences: Internal Reference',
    UrlName = 'vip-internal-reference',
    Answer__c = '<h2>Internal: VIP Guest Handling Procedures</h2><p>Platinum members receive automatic champagne service. Gold members receive dessert upgrade. Staff must verify membership at check-in. Escalate any VIP complaints to Tier 2 immediately. Do not share member tier information externally.</p>',
    Article_Type__c = 'Policy',
    AI_Confidence_Score__c = 0.99,
    Policy_Effective_Date__c = System.today(),
    PII_Sensitivity__c = 'Internal'
));

// --- RESTRICTED PII ARTICLE ---
articles.add(new FAQ__kav(
    Title = 'Staff Emergency Protocols: Restricted',
    UrlName = 'staff-emergency-restricted',
    Answer__c = '<h2>Restricted: Emergency & Allergy Response</h2><p>In case of anaphylactic reaction: administer EpiPen from first-aid station, call 911, notify duty manager. Document incident in Salesforce Case with PII_Sensitivity=Restricted. Do not disclose medical details to other guests.</p>',
    Article_Type__c = 'Policy',
    AI_Confidence_Score__c = 1.00,
    Policy_Effective_Date__c = System.today(),
    PII_Sensitivity__c = 'Restricted'
));

insert articles;

// Publish all articles
for(FAQ__kav art : [SELECT KnowledgeArticleId FROM FAQ__kav WHERE Id IN :articles]) {
    KbManagement.PublishingService.publishArticle(art.KnowledgeArticleId, true);
}
System.debug('Knowledge articles inserted and published: ' + articles.size());


// ==========================================
// 7. MENU CONTENT VERSIONS (ALLERGEN-ENRICHED)
// ==========================================
List<ContentVersion> menuFiles = new List<ContentVersion>();

Map<String, String> menuData = new Map<String, String>{
    'Le Petit Bistro' =>
        '--- Le Petit Bistro Full Menu 2026 ---\n\n' +
        'STARTERS\n' +
        '1. French Onion Soup - $14 (Contains: Dairy, Gluten)\n' +
        '2. Escargot Bourguignon - $18 (Contains: Dairy, Gluten) [SHELLFISH-FREE]\n' +
        '3. Foie Gras Terrine - $24 (Contains: Gluten)\n\n' +
        'MAINS\n' +
        '4. Coq au Vin - $32 (Contains: Dairy) [Chef Recommendation]\n' +
        '5. Beef Bourguignon - $36 (Contains: Dairy, Gluten)\n' +
        '6. Duck Confit - $34\n' +
        '7. Pan-Seared Halibut - $38 [SHELLFISH-FREE]\n' +
        '8. Vegetable Ratatouille - $26 (Vegan option available)\n\n' +
        'DESSERTS\n' +
        '9. Crème Brûlée - $12 (Contains: Dairy, Eggs)\n' +
        '10. Tarte Tatin - $14 (Contains: Dairy, Gluten)\n',
    'Pasta Palace' =>
        '--- Pasta Palace Full Menu 2026 ---\n\n' +
        'ANTIPASTI\n' +
        '1. Bruschetta Trio - $12 (Contains: Gluten) [NUT-FREE]\n' +
        '2. Caprese Salad - $10 (Contains: Dairy) [NUT-FREE]\n\n' +
        'PASTA\n' +
        '3. Spaghetti Carbonara - $18 (Contains: Dairy, Eggs, Gluten) [NUT-FREE]\n' +
        '4. Penne Arrabbiata - $16 (Vegan) [NUT-FREE] [Chef Recommendation]\n' +
        '5. Fettuccine Alfredo - $18 (Contains: Dairy, Gluten) [NUT-FREE]\n' +
        '6. Lasagna Bolognese - $20 (Contains: Dairy, Gluten) [NUT-FREE]\n\n' +
        'KIDS MENU\n' +
        '7. Mini Margherita Pizza - $8 [NUT-FREE]\n' +
        '8. Mac & Cheese Bambini - $7 (Contains: Dairy) [NUT-FREE]\n',
    'Sushi Zen' =>
        '--- Sushi Zen Full Menu 2026 ---\n\n' +
        '** ALLERGEN WARNING: This kitchen handles shellfish extensively. **\n\n' +
        'SASHIMI\n' +
        '1. Salmon Sashimi (5pc) - $16 [NUT-FREE]\n' +
        '2. Tuna Tataki - $18 [NUT-FREE]\n\n' +
        'ROLLS\n' +
        '3. Dragon Roll - $22 (Contains: Shellfish - shrimp tempura) [NUT-FREE]\n' +
        '4. Spicy Tuna Roll - $16 [NUT-FREE]\n' +
        '5. Vegetable Roll - $12 (Vegan) [NUT-FREE] [SHELLFISH-FREE]\n\n' +
        'OMAKASE\n' +
        '6. Chef Omakase 12-Course - $120 (Contains: Shellfish) [Chef Recommendation]\n' +
        '7. Vegetarian Omakase - $80 [NUT-FREE] [SHELLFISH-FREE]\n',
    'Vibe Vegan' =>
        '--- Vibe Vegan Full Menu 2026 ---\n\n' +
        '** CERTIFIED: 100% Nut-Free, Shellfish-Free, Vegan **\n\n' +
        'STARTERS\n' +
        '1. Avocado Toast - $12 [NUT-FREE] [SHELLFISH-FREE]\n' +
        '2. Cauliflower Wings - $14 [NUT-FREE] [SHELLFISH-FREE] [Chef Recommendation]\n\n' +
        'MAINS\n' +
        '3. Beyond Burger Deluxe - $18 [NUT-FREE] [SHELLFISH-FREE]\n' +
        '4. Mushroom Risotto - $20 [NUT-FREE] [SHELLFISH-FREE]\n' +
        '5. Thai Coconut Curry - $16 [NUT-FREE] [SHELLFISH-FREE]\n\n' +
        'DESSERTS\n' +
        '6. Oat Milk Panna Cotta - $10 [NUT-FREE] [SHELLFISH-FREE]\n'
};

for(Account acc : rests) {
    String content;
    if(menuData.containsKey(acc.Name)) {
        content = menuData.get(acc.Name);
    } else {
        content = '--- ' + acc.Name + ' Full Menu 2026 ---\n\n';
        for(Integer i = 1; i <= 10; i++) {
            content += i + '. ' + acc.Name + ' Signature Dish ' + i + ' - $' + (10 + i * 2) + '\n';
        }
    }

    menuFiles.add(new ContentVersion(
        Title = acc.Name + ' Full Menu 2026',
        PathOnClient = acc.Name.replaceAll('[^a-zA-Z0-9]', '') + '_Menu.txt',
        VersionData = Blob.valueOf(content),
        IsMajorVersion = true
    ));
}
insert menuFiles;
System.debug('Menu ContentVersions inserted: ' + menuFiles.size());

System.debug('MASTER SETUP v3.0 COMPLETE: ' + rests.size() + ' Accounts, ' + users.size() + ' Contacts, ' + tables.size() + ' Tables, ' + slots.size() + ' Slots, ' + reservations.size() + ' Reservations, ' + articles.size() + ' Knowledge Articles, ' + menuFiles.size() + ' Menus.');
