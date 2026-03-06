/**
 * Invocable: Three-Stage Resolver — Entity Resolution for restaurant lookup.
 * Replaces native Get Record with fuzzy matching, MatchConfidence, and CandidateRestaurants.
 *
 * Resolver logic (agent script):
 *   RestaurantHint == NONE     → skip lookup, continue
 *   EXACT                      → auto-resolve, continue
 *   FUZZY_HIGH (≥0.85)        → auto-resolve, continue (user never sees correction, e.g. "petit bistro" → Le Petit Bistro)
 *   FUZZY_LOW (0.50–0.85)     → clarify via topic_ambiguous_question
 *   NONE (no match)            → clarify via topic_ambiguous_question
 */
public with sharing class GetRestaurant {

    private static final Decimal EXACT_MATCH_CONFIDENCE = 1.0;
    private static final Decimal FUZZY_HIGH_CONFIDENCE = 0.85;
    private static final Decimal FUZZY_LOW_CONFIDENCE = 0.50;
    private static final Integer MAX_CANDIDATES = 5;

    @InvocableMethod(
        label='Get Restaurant'
        description='Lookup restaurant Account by name with fuzzy matching. Returns MatchConfidence and CandidateRestaurants for Three-Stage Resolver.'
    )
    public static List<GetRestaurantResult> getRestaurant(List<GetRestaurantRequest> requests) {
        List<GetRestaurantResult> results = new List<GetRestaurantResult>();

        for (GetRestaurantRequest req : requests) {
            GetRestaurantResult res = new GetRestaurantResult();
            resolve(req.name, res);
            results.add(res);
        }
        return results;
    }

    private static void resolve(String nameHint, GetRestaurantResult res) {
        if (String.isBlank(nameHint) || 'NONE'.equalsIgnoreCase(nameHint.trim())) {
            return;
        }

        String normalizedHint = nameHint.trim().toLowerCase();
        List<Account> restaurants = queryAllRestaurants();

        if (restaurants == null || restaurants.isEmpty()) {
            res.matchConfidence = 0;
            res.matchConfidenceLabel = 'NONE';
            res.candidateRestaurants = '[]';
            return;
        }

        // Stage 1: Exact match (case-insensitive)
        for (Account a : restaurants) {
            if (a.Name != null && a.Name.equalsIgnoreCase(nameHint.trim())) {
                setResult(res, a, EXACT_MATCH_CONFIDENCE, restaurants);
                return;
            }
        }

        // Stage 2: Fuzzy match
        Account bestMatch = null;
        Decimal bestScore = 0;

        for (Account a : restaurants) {
            if (a.Name == null) continue;

            Decimal score = computeSimilarity(normalizedHint, a.Name.toLowerCase());
            if (score > bestScore) {
                bestScore = score;
                bestMatch = a;
            }
        }

        if (bestMatch != null && bestScore >= FUZZY_LOW_CONFIDENCE) {
            setResult(res, bestMatch, bestScore, restaurants);
            return;
        }

        // Stage 3: No match — return candidates for clarifier
        res.currentRestaurantId = null;
        res.currentRestaurantName = null;
        res.currentLogicState = null;
        res.matchConfidence = 0;
        res.matchConfidenceLabel = 'NONE';
        res.candidateRestaurants = buildCandidatesJson(restaurants);
    }

    private static void setResult(GetRestaurantResult res, Account a, Decimal confidence, List<Account> allRestaurants) {
        res.currentRestaurantId = a.Id;
        res.currentRestaurantName = a.Name;
        res.currentLogicState = getLogicState(a);
        res.matchConfidence = confidence;
        res.matchConfidenceLabel = getConfidenceLabel(confidence);
        res.candidateRestaurants = confidence < EXACT_MATCH_CONFIDENCE
            ? buildCandidatesJson(allRestaurants, a.Name)
            : '[]';
    }

    private static Decimal computeSimilarity(String nameHint, String name) {
        if (String.isBlank(nameHint) || String.isBlank(name)) return 0;

        // Exact match already handled
        if (nameHint.equals(name)) return EXACT_MATCH_CONFIDENCE;

        // Hint equals name (ignore case) — already handled above
        if (nameHint.equalsIgnoreCase(name)) return EXACT_MATCH_CONFIDENCE;

        // Name contains hint fully (e.g. "Le Petit Bistro" contains "petit bistro")
        if (name.contains(nameHint)) {
            return nameHint.length() >= name.length() * 0.8 ? FUZZY_HIGH_CONFIDENCE : 0.75;
        }

        // Hint contains name (e.g. "petit bistrow" contains "petit")
        if (nameHint.contains(name)) {
            return name.length() >= nameHint.length() * 0.8 ? FUZZY_HIGH_CONFIDENCE : 0.75;
        }

        // Word overlap: "petit bistrow" vs "le petit bistro"
        List<String> hintWords = nameHint.split('\\s+');
        List<String> nameWords = name.split('\\s+');
        Integer matches = 0;
        for (String hw : hintWords) {
            if (hw.length() < 2) continue;
            for (String nw : nameWords) {
                if (nw.length() < 2) continue;
                if (hw.equals(nw) || hw.contains(nw) || nw.contains(hw)) {
                    matches++;
                    break;
                }
            }
        }
        if (matches > 0) {
            Decimal wordRatio = (Decimal) matches / Math.max(hintWords.size(), nameWords.size());
            return 0.50 + (wordRatio * 0.35); // 0.50 to 0.85
        }

        // Partial character overlap (simple)
        Integer overlap = 0;
        for (Integer i = 0; i < Math.min(nameHint.length(), name.length()); i++) {
            if (nameHint.charAt(i) == name.charAt(i)) overlap++;
        }
        if (overlap > 0) {
            Decimal charRatio = (Decimal) overlap / Math.max(nameHint.length(), name.length());
            return 0.50 + (charRatio * 0.35);
        }

        return 0;
    }

    private static String getLogicState(Account a) {
        if (a == null) return null;
        return String.isNotBlank(a.Logic_State__c) ? a.Logic_State__c : 'DETERMINISTIC';
    }

    private static String getConfidenceLabel(Decimal confidence) {
        if (confidence == null || confidence < FUZZY_LOW_CONFIDENCE) return 'NONE';
        if (confidence >= EXACT_MATCH_CONFIDENCE) return 'EXACT';
        if (confidence >= FUZZY_HIGH_CONFIDENCE) return 'FUZZY_HIGH';
        return 'FUZZY_LOW';
    }

    private static List<Account> queryAllRestaurants() {
        try {
            return [
                SELECT Id, Name, Logic_State__c
                FROM Account
                WHERE Name != null
                ORDER BY Name
                LIMIT 50
            ];
        } catch (Exception e) {
            return new List<Account>();
        }
    }

    private static String buildCandidatesJson(List<Account> restaurants) {
        return buildCandidatesJson(restaurants, null);
    }

    private static String buildCandidatesJson(List<Account> restaurants, String excludeName) {
        List<String> names = new List<String>();
        Integer count = 0;
        for (Account a : restaurants) {
            if (a.Name == null) continue;
            if (excludeName != null && a.Name.equals(excludeName)) continue;
            names.add(a.Name);
            if (++count >= MAX_CANDIDATES) break;
        }
        return JSON.serialize(names);
    }

    public class GetRestaurantRequest {
        @InvocableVariable(description='Restaurant name or hint from Intent_Classifier (RestaurantHint).')
        public String name;
    }

    public class GetRestaurantResult {
        @InvocableVariable(description='Account Id when match found.')
        public String currentRestaurantId;
        @InvocableVariable(description='Account.Name when match found.')
        public String currentRestaurantName;
        @InvocableVariable(description='Account.Logic_State__c when match found.')
        public String currentLogicState;
        @InvocableVariable(description='Match confidence 0-1. Exact=1.0, fuzzy=0.50-0.85, no match=0.')
        public Decimal matchConfidence;
        @InvocableVariable(description='Label for confidence gate: EXACT, FUZZY_HIGH, FUZZY_LOW, NONE.')
        public String matchConfidenceLabel;
        @InvocableVariable(description='JSON array of restaurant names for clarifier when fuzzy or no match.')
        public String candidateRestaurants;
    }
}
