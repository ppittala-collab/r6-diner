public with sharing class QueryMenuItems {

    @InvocableMethod(label='Query Menu Items' description='Search menu items for a restaurant with optional filters for availability, allergens, vegan, and chef recommendations.')
    public static List<MenuResult> queryMenuItems(List<MenuRequest> requests) {
        List<MenuResult> results = new List<MenuResult>();

        for (MenuRequest req : requests) {
            MenuResult res = new MenuResult();
            try {
                if (String.isBlank(req.restaurantName) && String.isBlank(req.restaurantId)) {
                    res.isSuccess = false;
                    res.message = 'Please provide a restaurant name or ID.';
                    res.menuData = '[]';
                    res.totalCount = 0;
                    results.add(res);
                    continue;
                }

                Id accId;
                if (String.isNotBlank(req.restaurantId)) {
                    accId = Id.valueOf(req.restaurantId);
                } else {
                    List<Account> accs = [SELECT Id FROM Account WHERE Name LIKE :('%' + req.restaurantName + '%') AND Cuisine_Type__c != null LIMIT 1];
                    if (accs.isEmpty()) {
                        res.isSuccess = true;
                        res.message = 'Restaurant "' + req.restaurantName + '" not found.';
                        res.menuData = '[]';
                        res.totalCount = 0;
                        results.add(res);
                        continue;
                    }
                    accId = accs[0].Id;
                }

                String query = 'SELECT Name, Category__c, Price__c, Is_Available__c, '
                    + 'Allergen_Tags__c, Is_Vegan__c, Is_Chef_Recommendation__c, '
                    + 'Description__c, Last_Inventory_Check__c '
                    + 'FROM Menu_Item__c WHERE Restaurant__c = :accId';

                if (req.availableOnly == true) {
                    query += ' AND Is_Available__c = true';
                }
                if (req.veganOnly == true) {
                    query += ' AND Is_Vegan__c = true';
                }
                if (req.chefPicksOnly == true) {
                    query += ' AND Is_Chef_Recommendation__c = true';
                }
                if (String.isNotBlank(req.category)) {
                    query += ' AND Category__c = :categoryFilter';
                }
                if (String.isNotBlank(req.excludeAllergen)) {
                    query += ' AND (Allergen_Tags__c EXCLUDES (:excludeFilter) OR Allergen_Tags__c = null)';
                }

                query += ' ORDER BY Category__c, Name ASC LIMIT 50';

                String categoryFilter = req.category;
                String excludeFilter = req.excludeAllergen;

                List<Menu_Item__c> items = Database.query(query);

                res.isSuccess = true;
                res.totalCount = items.size();

                if (items.isEmpty()) {
                    res.message = 'No menu items found matching your criteria.';
                    res.menuData = '[]';
                } else {
                    List<String> entries = new List<String>();
                    for (Menu_Item__c mi : items) {
                        String freshness = 'unknown';
                        if (mi.Last_Inventory_Check__c != null) {
                            Long hoursDiff = (System.now().getTime() - mi.Last_Inventory_Check__c.getTime()) / (1000 * 60 * 60);
                            freshness = hoursDiff <= 24 ? 'fresh' : hoursDiff + ' hours ago';
                        }

                        String entry = '{'
                            + '"dish":"' + String.escapeSingleQuotes(mi.Name) + '"'
                            + ',"category":"' + safeStr(mi.Category__c) + '"'
                            + ',"price":' + (mi.Price__c != null ? String.valueOf(mi.Price__c) : '0')
                            + ',"available":' + mi.Is_Available__c
                            + ',"allergens":"' + safeStr(mi.Allergen_Tags__c) + '"'
                            + ',"vegan":' + mi.Is_Vegan__c
                            + ',"chefPick":' + mi.Is_Chef_Recommendation__c
                            + ',"description":"' + safeStr(mi.Description__c) + '"'
                            + ',"inventoryFreshness":"' + freshness + '"'
                            + '}';
                        entries.add(entry);
                    }
                    res.menuData = '[' + String.join(entries, ',') + ']';
                    res.message = 'Found ' + items.size() + ' menu item(s).';
                }
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = 'SYSTEM_ERROR: ' + e.getMessage();
                res.menuData = '[]';
                res.totalCount = 0;
            }
            results.add(res);
        }
        return results;
    }

    private static String safeStr(String val) {
        return val != null ? String.escapeSingleQuotes(val) : '';
    }

    public class MenuRequest {
        @InvocableVariable(description='Restaurant name to look up menu items for (partial match)')
        public String restaurantName;

        @InvocableVariable(description='Restaurant Account ID (use this if you already have the ID)')
        public String restaurantId;

        @InvocableVariable(description='Set to true to only return available items (Is_Available__c = true)')
        public Boolean availableOnly;

        @InvocableVariable(description='Set to true to only return vegan items')
        public Boolean veganOnly;

        @InvocableVariable(description='Set to true to only return chef recommendations')
        public Boolean chefPicksOnly;

        @InvocableVariable(description='Optional category filter: Starter, Main, Dessert, Drink, Side, Kids')
        public String category;

        @InvocableVariable(description='Exclude items containing this allergen: Dairy, Gluten, Nuts, Shellfish, Eggs, Soy')
        public String excludeAllergen;
    }

    public class MenuResult {
        @InvocableVariable public Boolean isSuccess;
        @InvocableVariable public String message;
        @InvocableVariable public Integer totalCount;
        @InvocableVariable(description='JSON array of menu items with dish, category, price, available, allergens, vegan, chefPick, description, inventoryFreshness')
        public String menuData;
    }
}
