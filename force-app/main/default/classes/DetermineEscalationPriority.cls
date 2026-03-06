/**
 * Invocable: Determines escalation routing priority and flags from contact_summary and escalation_trigger.
 * Replaces LLM-based priority logic in Escalation_Handler — rule-based for consistency.
 * Used by escalation topic before invoking Escalation_Handler for AI summary + diner message.
 */
public with sharing class DetermineEscalationPriority {

    @InvocableMethod(label='Determine Escalation Priority' description='Returns CRITICAL/VIP/HIGH/STANDARD and flags from contact + trigger.')
    public static List<DetermineEscalationPriorityResult> determineEscalationPriority(List<DetermineEscalationPriorityRequest> requests) {
        List<DetermineEscalationPriorityResult> results = new List<DetermineEscalationPriorityResult>();

        for (DetermineEscalationPriorityRequest req : requests) {
            DetermineEscalationPriorityResult res = new DetermineEscalationPriorityResult();
            evaluate(req.contactSummary, req.escalationTrigger, res);
            results.add(res);
        }
        return results;
    }

    private static void evaluate(String contactSummary, String escalationTrigger, DetermineEscalationPriorityResult res) {
        Map<String, Object> contact = parseContactSummary(contactSummary);
        String escTrigger = String.isNotBlank(escalationTrigger) ? escalationTrigger.toUpperCase() : '';

        Boolean churnRisk = getBoolean(contact, 'Churn_Risk__c');
        Boolean allergyTrigger = 'HIGH_RISK_KEYWORD'.equals(escTrigger);
        Boolean sentimentLow = getDecimal(contact, 'Sentiment_Score__c') < -0.70;
        Boolean modificationLoop = 'MODIFICATION_LOOP'.equals(escTrigger);
        String membershipLevel = getString(contact, 'Membership_Level__c');
        Boolean allergyShellfish = getBoolean(contact, 'Allergy_Shellfish__c');
        Boolean allergyNuts = getBoolean(contact, 'Allergy_Nuts__c');

        List<String> flags = new List<String>();

        if (churnRisk) flags.add('CHURN_RISK');
        if (allergyTrigger || allergyShellfish || allergyNuts) flags.add('ALLERGY_CONCERN');
        if ('Platinum'.equalsIgnoreCase(membershipLevel)) flags.add('VIP');

        if (churnRisk || allergyTrigger) {
            res.priority = 'CRITICAL';
            flags.add('URGENT');
        } else if ('Platinum'.equalsIgnoreCase(membershipLevel)) {
            res.priority = 'VIP';
        } else if (sentimentLow || modificationLoop) {
            res.priority = 'HIGH';
        } else {
            res.priority = 'STANDARD';
        }

        res.flags = String.join(flags, ', ');
        res.queue = 'Tier_2_Human_Concierge';
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

    private static String getString(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v != null ? String.valueOf(v) : '';
    }

    public class DetermineEscalationPriorityRequest {
        @InvocableVariable(description='JSON with Contact fields: Churn_Risk__c, Sentiment_Score__c, Membership_Level__c, Allergy_Shellfish__c, Allergy_Nuts__c')
        public String contactSummary;

        @InvocableVariable(description='Escalation trigger: EXPLICIT_REQUEST, HIGH_RISK_KEYWORD, NEGATIVE_SENTIMENT, MODIFICATION_LOOP, TRUST_MISMATCH, STALE_DATA, NO_SHOW_BLOCK, CHURN_RISK')
        public String escalationTrigger;
    }

    public class DetermineEscalationPriorityResult {
        @InvocableVariable(description='CRITICAL, VIP, HIGH, or STANDARD')
        public String priority;

        @InvocableVariable(description='Comma-separated flags: URGENT, VIP, CHURN_RISK, ALLERGY_CONCERN')
        public String flags;

        @InvocableVariable(description='Queue name: Tier_2_Human_Concierge')
        public String queue;
    }
}
