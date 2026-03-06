/**
 * Invocable: Invokes Intent_Classifier prompt template and parses JSON into structured outputs.
 * Replaces Agent Script's inability to natively unpack JSON from prompt template responses.
 */
public with sharing class IntentClassifierAction {

    private static final String TEMPLATE_API_NAME = 'Intent_Classifier';
    private static final String DEFAULT_ROUTE = 'ROUTE_AMBIGUOUS';
    private static final Integer DEFAULT_CONFIDENCE = 0;

    @InvocableMethod(label='Intent Classifier Action' description='Invoke Intent_Classifier prompt template and return parsed Route, RestaurantHint, Acknowledgment, RouteConfidenceScore, RouteConfidenceLabel.')
    public static List<IntentClassifierResponse> invoke(List<IntentClassifierRequest> requests) {
        List<IntentClassifierResponse> results = new List<IntentClassifierResponse>();

        for (IntentClassifierRequest req : requests) {
            IntentClassifierResponse res = new IntentClassifierResponse();
            execute(req, res);
            results.add(res);
        }
        return results;
    }

    private static void execute(IntentClassifierRequest req, IntentClassifierResponse res) {
        try {
            Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

            ConnectApi.WrappedValue userMsg = new ConnectApi.WrappedValue();
            userMsg.value = String.isNotBlank(req.userMessage) ? req.userMessage : '';
            inputParams.put('user_message', userMsg);

            ConnectApi.WrappedValue contactSum = new ConnectApi.WrappedValue();
            contactSum.value = String.isNotBlank(req.contactSummary) ? req.contactSummary : '{}';
            inputParams.put('contact_summary', contactSum);

            ConnectApi.WrappedValue convCtx = new ConnectApi.WrappedValue();
            convCtx.value = String.isNotBlank(req.conversationContext) ? req.conversationContext : '';
            inputParams.put('conversation_context', convCtx);

            ConnectApi.EinsteinPromptTemplateGenerationsInput input = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            input.inputParams = inputParams;
            input.isPreview = false;
            input.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            input.additionalConfig.applicationName = 'PromptBuilderPreview';

            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(TEMPLATE_API_NAME, input);

            if (output == null || output.generations == null || output.generations.isEmpty()) {
                setDefaults(res);
                return;
            }

            String jsonText = output.generations[0].text;
            if (String.isBlank(jsonText)) {
                setDefaults(res);
                return;
            }

            parseAndSet(jsonText, res);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'IntentClassifierAction Error: ' + e.getMessage());
            setDefaults(res);
        }
    }

    private static void parseAndSet(String jsonText, IntentClassifierResponse res) {
        try {
            String cleaned = jsonText.trim();
            if (cleaned.startsWith('```')) {
                Integer startIdx = cleaned.indexOf('{');
                Integer endIdx = cleaned.lastIndexOf('}') + 1;
                if (startIdx >= 0 && endIdx > startIdx) {
                    cleaned = cleaned.substring(startIdx, endIdx);
                }
            }

            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(cleaned);

            res.route = getString(parsed, 'route');
            if (String.isBlank(res.route)) res.route = DEFAULT_ROUTE;

            res.restaurantHint = getString(parsed, 'restaurant_hint');
            if (res.restaurantHint == null) res.restaurantHint = 'NONE';

            res.acknowledgment = getString(parsed, 'acknowledgment');
            if (res.acknowledgment == null) res.acknowledgment = '';

            res.routeConfidenceLabel = getString(parsed, 'confidence_label');
            if (res.routeConfidenceLabel == null) res.routeConfidenceLabel = 'LOW';

            Object scoreObj = parsed.get('confidence_score_int');
            if (scoreObj != null) {
                try {
                    if (scoreObj instanceof Integer) {
                        res.routeConfidenceScore = (Integer) scoreObj;
                    } else if (scoreObj instanceof Decimal) {
                        res.routeConfidenceScore = ((Decimal) scoreObj).intValue();
                    } else {
                        res.routeConfidenceScore = Integer.valueOf(String.valueOf(scoreObj));
                    }
                } catch (Exception ex) {
                    res.routeConfidenceScore = DEFAULT_CONFIDENCE;
                }
            } else {
                res.routeConfidenceScore = DEFAULT_CONFIDENCE;
            }

        } catch (Exception e) {
            setDefaults(res);
        }
    }

    private static String getString(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v != null ? String.valueOf(v) : null;
    }

    private static void setDefaults(IntentClassifierResponse res) {
        res.route = DEFAULT_ROUTE;
        res.restaurantHint = 'NONE';
        res.acknowledgment = '';
        res.routeConfidenceScore = DEFAULT_CONFIDENCE;
        res.routeConfidenceLabel = 'LOW';
    }

    public class IntentClassifierRequest {
        @InvocableVariable(description='The diner\'s current message to classify.')
        public String userMessage;

        @InvocableVariable(description='JSON with Contact fields. Use {} when guest.')
        public String contactSummary;

        @InvocableVariable(description='Summary of prior conversation turns.')
        public String conversationContext;
    }

    public class IntentClassifierResponse {
        @InvocableVariable(description='Classified route: ROUTE_POLICY, ROUTE_MENU, ROUTE_DIRECTORY, etc.')
        public String route;

        @InvocableVariable(description='Restaurant name if mentioned, else NONE.')
        public String restaurantHint;

        @InvocableVariable(description='One sentence acknowledgment to the diner.')
        public String acknowledgment;

        @InvocableVariable(description='Confidence score 0-100. Integer.')
        public Integer routeConfidenceScore;

        @InvocableVariable(description='Confidence label: HIGH, MEDIUM, or LOW.')
        public String routeConfidenceLabel;
    }
}
