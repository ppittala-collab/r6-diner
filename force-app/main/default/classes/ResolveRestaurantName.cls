/**
 * [DEPRECATED] Replaced by Data Library retrieval in Ambiguous_Clarifier.
 * The Policy, Menu, and Directory templates already use Agentforce Data Library (r6_restaurant_directory.txt, FAQ__kav).
 * Ambiguous_Clarifier now uses that same retrieval for restaurant resolution — no separate Apex needed.
 * Kept for reference; not deployed in package.xml.
 */
public with sharing class ResolveRestaurantName {

    private static final Map<String, String> RESTAURANT_MAP = new Map<String, String>{
        'le petit bistro' => 'Le Petit Bistro',
        'petit bistro' => 'Le Petit Bistro',
        'petit' => 'Le Petit Bistro',
        'bistro' => 'Le Petit Bistro',
        'french' => 'Le Petit Bistro',
        'pasta palace' => 'Pasta Palace',
        'pasta' => 'Pasta Palace',
        'palace' => 'Pasta Palace',
        'italian' => 'Pasta Palace',
        'sushi zen' => 'Sushi Zen',
        'sushi' => 'Sushi Zen',
        'zen' => 'Sushi Zen',
        'japanese' => 'Sushi Zen',
        'sakura' => 'Sushi Zen',
        'vibe vegan' => 'Vibe Vegan',
        'vibe' => 'Vibe Vegan',
        'vegan' => 'Vibe Vegan',
        'plant' => 'Vibe Vegan',
        'burger joint' => 'The Burger Joint',
        'burger' => 'The Burger Joint',
        'joint' => 'The Burger Joint',
        'american' => 'The Burger Joint',
        'taco tequila' => 'Taco Tequila',
        'taco' => 'Taco Tequila',
        'tequila' => 'Taco Tequila',
        'mexican' => 'Taco Tequila',
        'curry house' => 'Curry House',
        'curry' => 'Curry House',
        'indian' => 'Curry House',
        'spice' => 'Curry House',
        'steak stone' => 'Steak & Stone',
        'steak & stone' => 'Steak & Stone',
        'steak' => 'Steak & Stone',
        'stone' => 'Steak & Stone',
        'steakhouse' => 'Steak & Stone',
        'dim sum garden' => 'Dim Sum Garden',
        'dim sum' => 'Dim Sum Garden',
        'garden' => 'Dim Sum Garden',
        'chinese' => 'Dim Sum Garden',
        'dumpling' => 'Dim Sum Garden',
        'forgotten fondue' => 'Forgotten Fondue',
        'fondue' => 'Forgotten Fondue',
        'forgotten' => 'Forgotten Fondue',
        'salad' => 'Forgotten Fondue'
    };

    @InvocableMethod(label='Resolve Restaurant Name' description='Fuzzy-match user message to restaurant. Skip LLM when high confidence.')
    public static List<ResolveRestaurantNameResult> resolveRestaurantName(List<ResolveRestaurantNameRequest> requests) {
        List<ResolveRestaurantNameResult> results = new List<ResolveRestaurantNameResult>();

        for (ResolveRestaurantNameRequest req : requests) {
            ResolveRestaurantNameResult res = new ResolveRestaurantNameResult();
            resolve(req.userMessage, res);
            results.add(res);
        }
        return results;
    }

    private static void resolve(String userMessage, ResolveRestaurantNameResult res) {
        if (String.isBlank(userMessage)) {
            res.confidence = 'low';
            return;
        }

        String normalized = userMessage.trim().toLowerCase();
        String match = RESTAURANT_MAP.get(normalized);

        if (match != null) {
            res.bestMatch = match;
            res.confidence = 'high';
            res.suggestedQuestion = 'Do you mean ' + match + '?';
            return;
        }

        for (String key : RESTAURANT_MAP.keySet()) {
            if (normalized.contains(key) || key.contains(normalized)) {
                res.bestMatch = RESTAURANT_MAP.get(key);
                res.confidence = normalized.length() >= 4 ? 'high' : 'medium';
                res.suggestedQuestion = 'Do you mean ' + res.bestMatch + '?';
                return;
            }
        }

        res.confidence = 'low';
    }

    public class ResolveRestaurantNameRequest {
        @InvocableVariable(description='User message (e.g., "sushi", "pasta", "tell me about the bistro")')
        public String userMessage;
    }

    public class ResolveRestaurantNameResult {
        @InvocableVariable(description='Matched restaurant name or null')
        public String bestMatch;

        @InvocableVariable(description='high, medium, or low')
        public String confidence;

        @InvocableVariable(description='"Do you mean [X]?" when high/medium confidence')
        public String suggestedQuestion;
    }
}
