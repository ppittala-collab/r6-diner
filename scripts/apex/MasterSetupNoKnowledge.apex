/**
 * MASTER SETUP — FILE-BASED DATA LIBRARY (No Knowledge)
 * Use when org has Restaurant Lib Data Library with 3 files instead of FAQ__kav.
 * Skips section 6 (Knowledge articles). Runs: Accounts, Tables, Slots, Contacts, Reservations, ContentVersion menus.
 */
System.debug('INITIATING MASTER DATA SEED (No Knowledge)...');

// ==========================================
// 0. CLEANUP (remove existing seed data to avoid duplicates)
// ==========================================
delete [SELECT Id FROM Reservation__c];
delete [SELECT Id FROM Restaurant_Slot__c];
delete [SELECT Id FROM Restaurant_Table__c];
delete [SELECT Id FROM Menu_Item__c];
delete [SELECT Id FROM Contact WHERE Cuisine_Preference__c != null];
delete [SELECT Id FROM Account WHERE Cuisine_Type__c != null];
System.debug('Cleanup complete.');

// ==========================================
// 1. ACCOUNTS (10 RESTAURANTS)
// ==========================================
List<Account> rests = new List<Account>();
rests.add(new Account(Name='Le Petit Bistro', Cuisine_Type__c='French', Vibe_Tags__c='Romantic;Upscale', Family_Friendly__c=false, Safe_For_Allergies__c='Shellfish-free', Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-10), Reliability_Reason__c='Direct POS API Sync', Price_Tier__c='$$$', Average_Turnover_Minutes__c=120, Grace_Period_Mins__c=15, Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-3), Blackout_Dates__c='["2026-12-25","2026-12-31","2026-01-01"]'));
rests.add(new Account(Name='Pasta Palace', Cuisine_Type__c='Italian', Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true, Safe_For_Allergies__c='Nut-free', Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-12), Reliability_Reason__c='Morning Manager Audit', Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15, Inventory_Buffer_Type__c=10, Last_Menu_Update__c=System.now().addDays(-7)));
rests.add(new Account(Name='Sushi Zen', Cuisine_Type__c='Japanese', Vibe_Tags__c='Business-Quiet;Upscale', Family_Friendly__c=false, Safe_For_Allergies__c='Nut-free', Reliability_Score__c=5, Data_Last_Verified__c=System.now().addDays(-2), Reliability_Reason__c='Live Integration (Stalled)', Price_Tier__c='$$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=10, Inventory_Buffer_Type__c=5, Last_Menu_Update__c=System.now().addDays(-14)));
rests.add(new Account(Name='The Burger Joint', Cuisine_Type__c='American', Vibe_Tags__c='Casual;Trendy', Family_Friendly__c=true, Reliability_Score__c=2, Data_Last_Verified__c=System.now().addHours(-2), Reliability_Reason__c='Hostess iPad Manual Entry', Price_Tier__c='$', Average_Turnover_Minutes__c=45, Grace_Period_Mins__c=5, Inventory_Buffer_Type__c=20, Last_Menu_Update__c=System.now().addDays(-30)));
rests.add(new Account(Name='Forgotten Fondue', Cuisine_Type__c='French', Vibe_Tags__c='Romantic', Family_Friendly__c=false, Reliability_Score__c=4, Data_Last_Verified__c=System.now().addDays(-10), Reliability_Reason__c='Legacy Vendor Sync', Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15, Inventory_Buffer_Type__c=50, Last_Menu_Update__c=System.now().addDays(-60)));
rests.add(new Account(Name='Vibe Vegan', Cuisine_Type__c='Vegan', Vibe_Tags__c='Trendy;Outdoor-Dining', Family_Friendly__c=false, Safe_For_Allergies__c='Nut-free;Shellfish-free', Primary_Safety_Tag__c='Nut-Free Certified', Reliability_Score__c=4, Data_Last_Verified__c=System.now().addHours(-5), Reliability_Reason__c='Owner Direct Update', Price_Tier__c='$$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10, Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-1)));
rests.add(new Account(Name='Taco Tequila', Cuisine_Type__c='Mexican', Vibe_Tags__c='Live-Music;Casual', Family_Friendly__c=true, Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-1), Reliability_Reason__c='Nightly Staff Check-In', Price_Tier__c='$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10, Inventory_Buffer_Type__c=15, Last_Menu_Update__c=System.now().addDays(-5)));
rests.add(new Account(Name='Curry House', Cuisine_Type__c='Indian', Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true, Primary_Safety_Tag__c='Certified Halal', Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-30), Reliability_Reason__c='Direct POS API Sync', Price_Tier__c='$$', Average_Turnover_Minutes__c=90, Grace_Period_Mins__c=15, Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addDays(-2)));
rests.add(new Account(Name='Steak & Stone', Cuisine_Type__c='Steakhouse', Vibe_Tags__c='Business-Quiet;Upscale', Family_Friendly__c=false, Primary_Safety_Tag__c='HACCP Compliant', Reliability_Score__c=5, Data_Last_Verified__c=System.now().addMinutes(-5), Reliability_Reason__c='Real-Time Resy Integration', Price_Tier__c='$$$$', Average_Turnover_Minutes__c=120, Grace_Period_Mins__c=20, Inventory_Buffer_Type__c=0, Last_Menu_Update__c=System.now().addHours(-6), Blackout_Dates__c='["2026-02-14","2026-12-24","2026-12-25","2026-12-31"]'));
rests.add(new Account(Name='Dim Sum Garden', Cuisine_Type__c='Chinese', Vibe_Tags__c='Family-Friendly;Casual', Family_Friendly__c=true, Reliability_Score__c=3, Data_Last_Verified__c=System.now().addHours(-23), Reliability_Reason__c='Weekly Manager Audit', Price_Tier__c='$$', Average_Turnover_Minutes__c=60, Grace_Period_Mins__c=10, Inventory_Buffer_Type__c=10, Last_Menu_Update__c=System.now().addDays(-4)));
insert rests;
System.debug('Accounts inserted: ' + rests.size());

// ==========================================
// 2. PHYSICAL TABLES
// ==========================================
List<Restaurant_Table__c> tables = new List<Restaurant_Table__c>();
Integer tNum = 1;
for(Integer i = 0; i < rests.size(); i++) {
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[i].Id, Capacity__c=2, Table_Type__c='Window', ADA_Accessible__c=true));  tNum++;
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[i].Id, Capacity__c=4, Table_Type__c='Booth', ADA_Accessible__c=false)); tNum++;
    tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[i].Id, Capacity__c=6, Table_Type__c='Standard', ADA_Accessible__c=true));  tNum++;
}
tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[5].Id, Capacity__c=4, Table_Type__c='Patio', ADA_Accessible__c=true));  tNum++;
tables.add(new Restaurant_Table__c(Name='T'+tNum, Restaurant__c=rests[6].Id, Capacity__c=4, Table_Type__c='Patio', ADA_Accessible__c=true));  tNum++;
insert tables;

// ==========================================
// 3. TEMPORAL SLOTS
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

// ==========================================
// 4. CONTACTS (Passcode: First3 + 123456)
// ==========================================
String passcodeFromName(String firstName) {
    if (String.isBlank(firstName)) return '123456';
    Integer len = Math.min(3, firstName.length());
    return firstName.substring(0, len) + '123456';
}
List<Contact> users = new List<Contact>();
users.add(new Contact(FirstName='Sofia', LastName='Rodriguez', Email='sofiarodriguez@example.com', Cuisine_Preference__c='French', Allergy_Shellfish__c=true, Allergy_Nuts__c=false, Comm_Style__c='Brief/Efficiency', Membership_Level__c='Gold', Trust_Tolerance__c=5, Sentiment_Score__c=0.90, Lifetime_No_Show_Count__c=0, Churn_Risk__c=false, Passcode__c=passcodeFromName('Sofia')));
users.add(new Contact(FirstName='Marcus', LastName='Chen', Email='marcuschen@example.com', Cuisine_Preference__c='Italian', Family_Status__c='Needs High Chair', Allergy_Shellfish__c=false, Allergy_Nuts__c=false, Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Silver', Trust_Tolerance__c=2, Sentiment_Score__c=0.50, Lifetime_No_Show_Count__c=1, Churn_Risk__c=false, Passcode__c=passcodeFromName('Marcus')));
users.add(new Contact(FirstName='Elena', LastName='Vance', Email='elenavance@example.com', Cuisine_Preference__c='Vegan', Allergy_Nuts__c=true, Allergy_Shellfish__c=false, Comm_Style__c='Brief/Efficiency', Membership_Level__c='Platinum', Trust_Tolerance__c=4, Sentiment_Score__c=-0.80, Lifetime_No_Show_Count__c=0, Churn_Risk__c=true, Passcode__c=passcodeFromName('Elena')));
users.add(new Contact(FirstName='James', LastName='Whitfield', Email='jameswhitfield@example.com', Cuisine_Preference__c='Steakhouse', Allergy_Shellfish__c=false, Allergy_Nuts__c=false, Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Platinum', Trust_Tolerance__c=3, Sentiment_Score__c=0.95, Lifetime_No_Show_Count__c=0, Churn_Risk__c=false, Passcode__c=passcodeFromName('James')));
users.add(new Contact(FirstName='Priya', LastName='Kapoor', Email='priyakapoor@example.com', Cuisine_Preference__c='Indian', Allergy_Shellfish__c=false, Allergy_Nuts__c=false, Comm_Style__c='Brief/Efficiency', Membership_Level__c='Gold', Trust_Tolerance__c=3, Sentiment_Score__c=0.20, Lifetime_No_Show_Count__c=4, Churn_Risk__c=true, Passcode__c=passcodeFromName('Priya')));
users.add(new Contact(FirstName='Alex', LastName='Rivera', Email='arivera@example.com', Cuisine_Preference__c='Mexican', Comm_Style__c='Brief/Efficiency', Membership_Level__c='Silver', Trust_Tolerance__c=3, Sentiment_Score__c=0.60, Passcode__c=passcodeFromName('Alex')));
users.add(new Contact(FirstName='Lin', LastName='Zhang', Email='lzhang@example.com', Cuisine_Preference__c='Chinese', Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Gold', Trust_Tolerance__c=4, Sentiment_Score__c=0.40, Family_Status__c='Stroller Access', Passcode__c=passcodeFromName('Lin')));
users.add(new Contact(FirstName='Sam', LastName='Okafor', Email='sokafor@example.com', Cuisine_Preference__c='American', Comm_Style__c='Brief/Efficiency', Membership_Level__c='Silver', Trust_Tolerance__c=2, Sentiment_Score__c=0.70, Passcode__c=passcodeFromName('Sam')));
users.add(new Contact(FirstName='Mia', LastName='Tanaka', Email='mtanaka@example.com', Cuisine_Preference__c='Japanese', Comm_Style__c='Brief/Efficiency', Membership_Level__c='Gold', Trust_Tolerance__c=5, Sentiment_Score__c=0.85, Allergy_Shellfish__c=true, Passcode__c=passcodeFromName('Mia')));
users.add(new Contact(FirstName='Omar', LastName='Hassan', Email='ohassan@example.com', Cuisine_Preference__c='Indian', Comm_Style__c='Leisurely/Concierge', Membership_Level__c='Platinum', Trust_Tolerance__c=3, Sentiment_Score__c=0.55, Passcode__c=passcodeFromName('Omar')));
insert users;
System.debug('Contacts inserted: ' + users.size());

// ==========================================
// 5. RESERVATIONS
// ==========================================
Map<Id, List<Restaurant_Slot__c>> slotsByTable = new Map<Id, List<Restaurant_Slot__c>>();
for(Restaurant_Slot__c s : slots) {
    if(!slotsByTable.containsKey(s.Table__c)) slotsByTable.put(s.Table__c, new List<Restaurant_Slot__c>());
    slotsByTable.get(s.Table__c).add(s);
}
List<Reservation__c> reservations = new List<Reservation__c>();
Restaurant_Slot__c lockedSlot = slotsByTable.get(tables[0].Id)[0];
reservations.add(new Reservation__c(Contact__c=users[0].Id, Restaurant__c=rests[0].Id, Reservation_DateTime__c=System.now().addMinutes(45), Status__c='Confirmed', Assigned_Table_Slot__c=lockedSlot.Id, Party_Size__c=2, Modification_Count__c=0));
Restaurant_Slot__c modSlot = slotsByTable.get(tables[6].Id)[4];
reservations.add(new Reservation__c(Contact__c=users[0].Id, Restaurant__c=rests[2].Id, Reservation_DateTime__c=System.now().addDays(7), Status__c='Confirmed', Assigned_Table_Slot__c=modSlot.Id, Party_Size__c=4, Modification_Count__c=1, Modification_History__c='2026-03-02 14:00 — Moved from 6 PM to 7 PM by diner request.'));
Restaurant_Slot__c specSlot = slotsByTable.get(tables[9].Id)[5];
reservations.add(new Reservation__c(Contact__c=users[7].Id, Restaurant__c=rests[3].Id, Reservation_DateTime__c=System.now().addDays(3), Status__c='Pending_Staff_Approval', Assigned_Table_Slot__c=specSlot.Id, Party_Size__c=2, Modification_Count__c=0));
Restaurant_Slot__c escSlot = slotsByTable.get(tables[3].Id)[5];
reservations.add(new Reservation__c(Contact__c=users[1].Id, Restaurant__c=rests[1].Id, Reservation_DateTime__c=System.now().addDays(5), Status__c='Modified', Assigned_Table_Slot__c=escSlot.Id, Party_Size__c=4, Modification_Count__c=4, Modification_History__c='2026-02-28 — Party 6->4.\n2026-03-01 — Moved 7PM->8PM.', AI_Summary__c='Diner has modified this reservation 4 times. Recommend human concierge outreach.'));
Restaurant_Slot__c vipSlot = slotsByTable.get(tables[24].Id)[5];
reservations.add(new Reservation__c(Contact__c=users[3].Id, Restaurant__c=rests[8].Id, Reservation_DateTime__c=System.now().addDays(14), Status__c='Confirmed', Assigned_Table_Slot__c=vipSlot.Id, Party_Size__c=2, Modification_Count__c=0));
insert reservations;
lockedSlot.Status__c = 'Reserved'; modSlot.Status__c = 'Reserved'; specSlot.Status__c = 'Reserved'; escSlot.Status__c = 'Reserved'; vipSlot.Status__c = 'Reserved';
update new List<Restaurant_Slot__c>{lockedSlot, modSlot, specSlot, escSlot, vipSlot};

// ==========================================
// 6. MENU CONTENT VERSIONS (SKIP KNOWLEDGE)
// ==========================================
List<ContentVersion> menuFiles = new List<ContentVersion>();
for(Account acc : rests) {
    String content = '--- ' + acc.Name + ' Full Menu 2026 ---\n\n';
    for(Integer i = 1; i <= 10; i++) {
        content += i + '. ' + acc.Name + ' Signature Dish ' + i + ' - $' + (10 + i * 2) + '\n';
    }
    menuFiles.add(new ContentVersion(Title = acc.Name + ' Full Menu 2026', PathOnClient = acc.Name.replaceAll('[^a-zA-Z0-9]', '') + '_Menu.txt', VersionData = Blob.valueOf(content), IsMajorVersion = true));
}
insert menuFiles;
System.debug('MASTER SETUP (No Knowledge) COMPLETE: ' + rests.size() + ' Accounts, ' + users.size() + ' Contacts, ' + tables.size() + ' Tables, ' + slots.size() + ' Slots, ' + reservations.size() + ' Reservations, ' + menuFiles.size() + ' Menus.');
System.debug('Data Library uses file-based grounding (3 files). Run seedMenuItems.apex next for Menu_Item__c.');
