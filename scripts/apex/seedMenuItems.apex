/**
 * MENU ITEM SEED SCRIPT: Structured inventory for all 10 restaurants
 * Run AFTER MasterSetup.apex (requires Account records to exist)
 * Creates ~80 menu items with allergen tags, availability, and chef recommendations
 */

Map<String, Account> restMap = new Map<String, Account>();
for (Account a : [SELECT Id, Name FROM Account WHERE Cuisine_Type__c != null]) {
    restMap.put(a.Name, a);
}
System.debug('Found ' + restMap.size() + ' restaurants');

List<Menu_Item__c> items = new List<Menu_Item__c>();
DateTime freshCheck = System.now().addHours(-1);
DateTime staleCheck = System.now().addDays(-3);

// ============================================================
// LE PETIT BISTRO (French, $$$, Shellfish-free kitchen)
// ============================================================
Id lpb = restMap.get('Le Petit Bistro').Id;

items.add(new Menu_Item__c(Name='French Onion Soup',       Restaurant__c=lpb, Category__c='Starter',  Price__c=14, Allergen_Tags__c='Dairy;Gluten',   Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Classic gratinéed onion soup with Gruyère crouton'));
items.add(new Menu_Item__c(Name='Escargot Bourguignon',    Restaurant__c=lpb, Category__c='Starter',  Price__c=18, Allergen_Tags__c='Dairy;Gluten',   Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Burgundy snails in garlic-herb butter'));
items.add(new Menu_Item__c(Name='Foie Gras Terrine',       Restaurant__c=lpb, Category__c='Starter',  Price__c=24, Allergen_Tags__c='Gluten',         Is_Available__c=false, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Seasonal terrine with fig compote — SOLD OUT'));
items.add(new Menu_Item__c(Name='Coq au Vin',              Restaurant__c=lpb, Category__c='Main',     Price__c=32, Allergen_Tags__c='Dairy',          Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Braised chicken in Burgundy wine sauce'));
items.add(new Menu_Item__c(Name='Beef Bourguignon',        Restaurant__c=lpb, Category__c='Main',     Price__c=36, Allergen_Tags__c='Dairy;Gluten',   Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Slow-braised beef in red wine with root vegetables'));
items.add(new Menu_Item__c(Name='Duck Confit',             Restaurant__c=lpb, Category__c='Main',     Price__c=34,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Confit duck leg with Sarladaise potatoes'));
items.add(new Menu_Item__c(Name='Pan-Seared Halibut',      Restaurant__c=lpb, Category__c='Main',     Price__c=38,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Wild halibut with beurre blanc — shellfish-free'));
items.add(new Menu_Item__c(Name='Vegetable Ratatouille',   Restaurant__c=lpb, Category__c='Main',     Price__c=26,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Provençal vegetable medley'));
items.add(new Menu_Item__c(Name='Crème Brûlée',            Restaurant__c=lpb, Category__c='Dessert',  Price__c=12, Allergen_Tags__c='Dairy;Eggs',     Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Vanilla bean custard with caramelized sugar'));
items.add(new Menu_Item__c(Name='Tarte Tatin',             Restaurant__c=lpb, Category__c='Dessert',  Price__c=14, Allergen_Tags__c='Dairy;Gluten',   Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Upside-down caramelized apple tart'));

// ============================================================
// PASTA PALACE (Italian, $$, Nut-free prep area, Family-friendly)
// ============================================================
Id pp = restMap.get('Pasta Palace').Id;

items.add(new Menu_Item__c(Name='Bruschetta Trio',         Restaurant__c=pp, Category__c='Starter',  Price__c=12, Allergen_Tags__c='Gluten',          Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Tomato, mushroom, and olive tapenade'));
items.add(new Menu_Item__c(Name='Caprese Salad',           Restaurant__c=pp, Category__c='Starter',  Price__c=10, Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Fresh mozzarella, vine tomatoes, basil'));
items.add(new Menu_Item__c(Name='Spaghetti Carbonara',     Restaurant__c=pp, Category__c='Main',     Price__c=18, Allergen_Tags__c='Dairy;Eggs;Gluten', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Classic egg and guanciale'));
items.add(new Menu_Item__c(Name='Penne Arrabbiata',        Restaurant__c=pp, Category__c='Main',     Price__c=16, Allergen_Tags__c='Gluten',          Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Spicy tomato sauce with chili flakes'));
items.add(new Menu_Item__c(Name='Fettuccine Alfredo',      Restaurant__c=pp, Category__c='Main',     Price__c=18, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Rich cream and parmesan'));
items.add(new Menu_Item__c(Name='Lasagna Bolognese',       Restaurant__c=pp, Category__c='Main',     Price__c=20, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=false, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Layered beef ragu — SOLD OUT for tonight'));
items.add(new Menu_Item__c(Name='Mini Margherita Pizza',   Restaurant__c=pp, Category__c='Kids',     Price__c=8,  Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Kids portion'));
items.add(new Menu_Item__c(Name='Mac & Cheese Bambini',    Restaurant__c=pp, Category__c='Kids',     Price__c=7,  Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Kids portion'));

// ============================================================
// SUSHI ZEN (Japanese, $$$, Shellfish-heavy kitchen)
// ============================================================
Id sz = restMap.get('Sushi Zen').Id;

items.add(new Menu_Item__c(Name='Salmon Sashimi 5pc',      Restaurant__c=sz, Category__c='Starter',  Price__c=16,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Fresh Atlantic salmon'));
items.add(new Menu_Item__c(Name='Tuna Tataki',             Restaurant__c=sz, Category__c='Starter',  Price__c=18,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Seared tuna with ponzu'));
items.add(new Menu_Item__c(Name='Dragon Roll',             Restaurant__c=sz, Category__c='Main',     Price__c=22, Allergen_Tags__c='Shellfish',       Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Shrimp tempura, avocado, eel sauce'));
items.add(new Menu_Item__c(Name='Spicy Tuna Roll',         Restaurant__c=sz, Category__c='Main',     Price__c=16,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Spicy tuna with sriracha mayo'));
items.add(new Menu_Item__c(Name='Vegetable Roll',          Restaurant__c=sz, Category__c='Main',     Price__c=12,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Avocado, cucumber, asparagus — shellfish-free'));
items.add(new Menu_Item__c(Name='Chef Omakase 12-Course',  Restaurant__c=sz, Category__c='Main',     Price__c=120, Allergen_Tags__c='Shellfish',      Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Chef\'s tasting — sushi bar only, 2 guests max'));
items.add(new Menu_Item__c(Name='Vegetarian Omakase',      Restaurant__c=sz, Category__c='Main',     Price__c=80,                                    Is_Available__c=false, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=staleCheck, Description__c='8-course vegetarian tasting — UNAVAILABLE (chef off tonight)'));

// ============================================================
// THE BURGER JOINT (American, $, SPECULATIVE data)
// ============================================================
Id bj = restMap.get('The Burger Joint').Id;

items.add(new Menu_Item__c(Name='Classic Smash Burger',    Restaurant__c=bj, Category__c='Main',     Price__c=12, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=staleCheck, Description__c='Double smash patty, American cheese, pickles'));
items.add(new Menu_Item__c(Name='Bacon BBQ Burger',        Restaurant__c=bj, Category__c='Main',     Price__c=14, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=staleCheck, Description__c='Smoked bacon, cheddar, BBQ sauce'));
items.add(new Menu_Item__c(Name='Veggie Burger',           Restaurant__c=bj, Category__c='Main',     Price__c=11, Allergen_Tags__c='Gluten',          Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=staleCheck, Description__c='Black bean patty with avocado'));
items.add(new Menu_Item__c(Name='Loaded Fries',            Restaurant__c=bj, Category__c='Side',     Price__c=8,  Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=staleCheck, Description__c='Cheese, bacon bits, ranch'));
items.add(new Menu_Item__c(Name='Milkshake',               Restaurant__c=bj, Category__c='Drink',    Price__c=7,  Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=staleCheck, Description__c='Vanilla, chocolate, or strawberry'));

// ============================================================
// FORGOTTEN FONDUE (French, $$, STALE data — 10 days unverified)
// ============================================================
Id ff = restMap.get('Forgotten Fondue').Id;

items.add(new Menu_Item__c(Name='Classic Cheese Fondue',   Restaurant__c=ff, Category__c='Main',     Price__c=28, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=System.now().addDays(-12), Description__c='Gruyère and Emmental blend — availability unconfirmed'));
items.add(new Menu_Item__c(Name='Chocolate Fondue',        Restaurant__c=ff, Category__c='Dessert',  Price__c=22, Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=System.now().addDays(-12), Description__c='Dark chocolate with seasonal fruits — availability unconfirmed'));
items.add(new Menu_Item__c(Name='Raclette Platter',        Restaurant__c=ff, Category__c='Main',     Price__c=32, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=System.now().addDays(-12), Description__c='Melted raclette with charcuterie — availability unconfirmed'));

// ============================================================
// VIBE VEGAN (Vegan, $$, Nut-free + Shellfish-free certified)
// ============================================================
Id vv = restMap.get('Vibe Vegan').Id;

items.add(new Menu_Item__c(Name='Avocado Toast',           Restaurant__c=vv, Category__c='Starter',  Price__c=12,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Sourdough, smashed avocado, cherry tomatoes, microgreens'));
items.add(new Menu_Item__c(Name='Cauliflower Wings',       Restaurant__c=vv, Category__c='Starter',  Price__c=14,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Buffalo-glazed with ranch dip'));
items.add(new Menu_Item__c(Name='Beyond Burger Deluxe',    Restaurant__c=vv, Category__c='Main',     Price__c=18,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Plant-based patty, vegan cheese, special sauce'));
items.add(new Menu_Item__c(Name='Mushroom Risotto',        Restaurant__c=vv, Category__c='Main',     Price__c=20,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Wild mushroom medley with truffle oil'));
items.add(new Menu_Item__c(Name='Thai Coconut Curry',      Restaurant__c=vv, Category__c='Main',     Price__c=16,                                    Is_Available__c=false, Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Red curry with seasonal vegetables — SOLD OUT'));
items.add(new Menu_Item__c(Name='Oat Milk Panna Cotta',    Restaurant__c=vv, Category__c='Dessert',  Price__c=10,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Vanilla bean with berry compote'));

// ============================================================
// TACO TEQUILA (Mexican, $, Live music, Family until 9 PM)
// ============================================================
Id tt = restMap.get('Taco Tequila').Id;

items.add(new Menu_Item__c(Name='Street Tacos (3pc)',      Restaurant__c=tt, Category__c='Main',     Price__c=10, Allergen_Tags__c='Gluten',          Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Al pastor, carne asada, or carnitas'));
items.add(new Menu_Item__c(Name='Tableside Guacamole',     Restaurant__c=tt, Category__c='Starter',  Price__c=12,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Made fresh at your table'));
items.add(new Menu_Item__c(Name='Burrito Grande',          Restaurant__c=tt, Category__c='Main',     Price__c=14, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Rice, beans, cheese, choice of protein'));
items.add(new Menu_Item__c(Name='Churros con Chocolate',   Restaurant__c=tt, Category__c='Dessert',  Price__c=8,  Allergen_Tags__c='Dairy;Gluten;Eggs', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Cinnamon sugar with dark chocolate dip'));
items.add(new Menu_Item__c(Name='Margarita Flight',        Restaurant__c=tt, Category__c='Drink',    Price__c=18,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Classic, mango, spicy jalapeño'));

// ============================================================
// CURRY HOUSE (Indian, $$, Certified Halal, Family-friendly)
// ============================================================
Id ch = restMap.get('Curry House').Id;

items.add(new Menu_Item__c(Name='Chicken Tikka Masala',    Restaurant__c=ch, Category__c='Main',     Price__c=18, Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Tandoori chicken in creamy tomato sauce'));
items.add(new Menu_Item__c(Name='Lamb Rogan Josh',         Restaurant__c=ch, Category__c='Main',     Price__c=22, Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Slow-cooked lamb in Kashmiri spices'));
items.add(new Menu_Item__c(Name='Chana Masala',            Restaurant__c=ch, Category__c='Main',     Price__c=14,                                    Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Chickpea curry with cumin and coriander'));
items.add(new Menu_Item__c(Name='Garlic Naan',             Restaurant__c=ch, Category__c='Side',     Price__c=4,  Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Tandoor-baked with garlic butter'));
items.add(new Menu_Item__c(Name='Mango Lassi',             Restaurant__c=ch, Category__c='Drink',    Price__c=5,  Allergen_Tags__c='Dairy',           Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Sweet yogurt mango smoothie'));
items.add(new Menu_Item__c(Name='Gulab Jamun',             Restaurant__c=ch, Category__c='Dessert',  Price__c=8,  Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=false, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Rose syrup dumplings — SOLD OUT'));

// ============================================================
// STEAK & STONE (Steakhouse, $$$$, HACCP, Formal)
// ============================================================
Id ss = restMap.get('Steak & Stone').Id;

items.add(new Menu_Item__c(Name='Wagyu A5 Ribeye',         Restaurant__c=ss, Category__c='Main',     Price__c=185,                                   Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Japanese A5 Wagyu, 8oz — 48-hr advance order required'));
items.add(new Menu_Item__c(Name='Dry-Aged NY Strip',       Restaurant__c=ss, Category__c='Main',     Price__c=68,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='45-day dry-aged, bone-in, 16oz'));
items.add(new Menu_Item__c(Name='Filet Mignon',            Restaurant__c=ss, Category__c='Main',     Price__c=58,                                    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Center-cut tenderloin, 10oz'));
items.add(new Menu_Item__c(Name='Caesar Salad',            Restaurant__c=ss, Category__c='Starter',  Price__c=16, Allergen_Tags__c='Dairy;Eggs;Gluten', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Tableside prepared, white anchovy'));
items.add(new Menu_Item__c(Name='Lobster Bisque',          Restaurant__c=ss, Category__c='Starter',  Price__c=22, Allergen_Tags__c='Shellfish;Dairy', Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Cognac-flamed Maine lobster'));
items.add(new Menu_Item__c(Name='Truffle Mac & Cheese',    Restaurant__c=ss, Category__c='Side',     Price__c=18, Allergen_Tags__c='Dairy;Gluten',    Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Black truffle, aged Gruyère'));
items.add(new Menu_Item__c(Name='Chocolate Lava Cake',     Restaurant__c=ss, Category__c='Dessert',  Price__c=16, Allergen_Tags__c='Dairy;Eggs;Gluten', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Valrhona chocolate, molten center'));

// ============================================================
// DIM SUM GARDEN (Chinese, $$, Family-friendly, Groups)
// ============================================================
Id dsg = restMap.get('Dim Sum Garden').Id;

items.add(new Menu_Item__c(Name='Har Gow (Shrimp Dumpling)', Restaurant__c=dsg, Category__c='Starter', Price__c=8, Allergen_Tags__c='Shellfish;Gluten', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Crystal skin prawn dumplings, 4pc'));
items.add(new Menu_Item__c(Name='Siu Mai (Pork Dumpling)',   Restaurant__c=dsg, Category__c='Starter', Price__c=7, Allergen_Tags__c='Gluten;Soy',      Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Open-top pork and shrimp dumpling, 4pc'));
items.add(new Menu_Item__c(Name='Char Siu Bao',             Restaurant__c=dsg, Category__c='Starter', Price__c=6, Allergen_Tags__c='Gluten;Soy',      Is_Available__c=true,  Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='BBQ pork steamed buns, 3pc'));
items.add(new Menu_Item__c(Name='Peking Duck',               Restaurant__c=dsg, Category__c='Main',   Price__c=48, Allergen_Tags__c='Gluten;Soy',     Is_Available__c=false, Is_Vegan__c=false, Is_Chef_Recommendation__c=true,  Last_Inventory_Check__c=freshCheck, Description__c='Half duck, carved tableside — requires 24-hr preorder, SOLD OUT'));
items.add(new Menu_Item__c(Name='Mapo Tofu',                 Restaurant__c=dsg, Category__c='Main',   Price__c=14, Allergen_Tags__c='Soy',            Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Silken tofu in chili bean sauce'));
items.add(new Menu_Item__c(Name='Egg Custard Tarts',         Restaurant__c=dsg, Category__c='Dessert', Price__c=6, Allergen_Tags__c='Dairy;Eggs;Gluten', Is_Available__c=true, Is_Vegan__c=false, Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Flaky pastry, smooth custard, 3pc'));
items.add(new Menu_Item__c(Name='Jasmine Tea Pot',           Restaurant__c=dsg, Category__c='Drink',  Price__c=0,                                     Is_Available__c=true,  Is_Vegan__c=true,  Is_Chef_Recommendation__c=false, Last_Inventory_Check__c=freshCheck, Description__c='Complimentary with every table'));

insert items;
System.debug('Menu items inserted: ' + items.size());

// Summary stats
Integer available = 0;
Integer unavailable = 0;
Integer vegan = 0;
Integer chefPicks = 0;
for (Menu_Item__c mi : items) {
    if (mi.Is_Available__c) available++; else unavailable++;
    if (mi.Is_Vegan__c) vegan++;
    if (mi.Is_Chef_Recommendation__c) chefPicks++;
}
System.debug('MENU SEED COMPLETE: ' + items.size() + ' items (' + available + ' available, ' + unavailable + ' sold out, ' + vegan + ' vegan, ' + chefPicks + ' chef picks)');
