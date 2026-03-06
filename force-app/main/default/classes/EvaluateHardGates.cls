/**
 * Invocable: Evaluates hard gates (NO_SHOW_BLOCK, NEGATIVE_SENTIMENT, CHURN_RISK) from contact_summary.
 * When a gate triggers, orchestrator skips Intent_Classifier and routes directly to escalation.
 * Replaces hard gate logic in Intent_Classifier prompt — deterministic, no LLM.
 */
public with sharing class EvaluateHardGates {

    @InvocableMethod(label='Evaluate Hard Gates' description='Check NO_SHOW, SENTIMENT, CHURN gates. Skip Intent_Classifier when gate triggers.')
    public static List<EvaluateHardGatesResult> evaluateHardGates(List<EvaluateHardGatesRequest> requests) {
        List<EvaluateHardGatesResult> results = new List<EvaluateHardGatesResult>();

        for (EvaluateHardGatesRequest req : requests) {
            EvaluateHardGatesResult res = new EvaluateHardGatesResult();
            evaluate(req.contactSummary, res);
            results.add(res);
        }
        return results;
    }

    private static void evaluate(String contactSummary, EvaluateHardGatesResult res) {
        Map<String, Object> contact = parseContactSummary(contactSummary);

        Integer noShowCount = getInteger(contact, 'Lifetime_No_Show_Count__c');
        Decimal sentiment = getDecimal(contact, 'Sentiment_Score__c');
        Boolean churnRisk = getBoolean(contact, 'Churn_Risk__c');

        if (churnRisk) {
            res.hardGate = 'CHURN_RISK';
            res.gateMessage = 'Let me connect you with our senior concierge team right away.';
            res.trustGap = false;
            return;
        }
        if (noShowCount != null && noShowCount >= 3) {
            res.hardGate = 'NO_SHOW_BLOCK';
            res.gateMessage = 'I\'d love to help, but your account requires staff-assisted booking. Let me connect you with our concierge team.';
            res.trustGap = false;
            return;
        }
        if (sentiment < -0.70) {
            res.hardGate = 'NEGATIVE_SENTIMENT';
            res.gateMessage = 'I can see this hasn\'t been the experience you deserve. Let me get you someone who can make this right.';
            res.trustGap = false;
            return;
        }

        res.hardGate = 'NONE';
        res.gateMessage = '';
        res.trustGap = false; // Trust mismatch requires restaurant; computed downstream when restaurant is known
    }

    private static Map<String, Object> parseContactSummary(String jsonStr) {
        if (String.isBlank(jsonStr)) return new Map<String, Object>();
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        } catch (Exception e) {
            return new Map<String, Object>();
        }
    }

    private static Boolean getBoolean(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v == null) return false;
        if (v instanceof Boolean) return (Boolean) v;
        return 'true'.equalsIgnoreCase(String.valueOf(v));
    }

    private static Integer getInteger(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v == null) return null;
        if (v instanceof Integer) return (Integer) v;
        if (v instanceof Decimal) return ((Decimal) v).intValue();
        try {
            return Integer.valueOf(String.valueOf(v));
        } catch (Exception e) {
            return null;
        }
    }

    private static Decimal getDecimal(Map<String, Object> m, String key) {
        Object v = m.get(key);
        if (v == null) return 0;
        if (v instanceof Decimal) return (Decimal) v;
        if (v instanceof Double) return (Decimal) v;
        if (v instanceof Integer) return (Decimal) v;
        try {
            return Decimal.valueOf(String.valueOf(v));
        } catch (Exception e) {
            return 0;
        }
    }

    public class EvaluateHardGatesRequest {
        @InvocableVariable(description='JSON with Contact fields: Lifetime_No_Show_Count__c, Sentiment_Score__c, Churn_Risk__c, Trust_Tolerance__c. Optional: Restaurant_Reliability_Score__c for trust_gap.')
        public String contactSummary;
    }

    public class EvaluateHardGatesResult {
        @InvocableVariable(description='NONE, NO_SHOW_BLOCK, NEGATIVE_SENTIMENT, or CHURN_RISK')
        public String hardGate;

        @InvocableVariable(description='Message to send when gate triggers; empty when NONE')
        public String gateMessage;

        @InvocableVariable(description='True if Trust_Tolerance__c > Restaurant reliability (pass to downstream)')
        public Boolean trustGap;
    }
}
