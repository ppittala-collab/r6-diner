/**
 * Invocable: Merges TrustGap from EvaluateHardGates into ContactContext.
 * Call in restaurant_information before Policy/Menu QA.
 */
public with sharing class BuildContactContext {

    private static final String DEFAULT_COMM_STYLE = 'Brief/Efficiency';

    @InvocableMethod(label='Build Contact Context' description='Merge trust_gap into ContactContext. Call before Policy/Menu QA with TrustGap from EvaluateHardGates.')
    public static List<BuildContactContextResult> buildContactContext(List<BuildContactContextRequest> requests) {
        List<BuildContactContextResult> results = new List<BuildContactContextResult>();

        for (BuildContactContextRequest req : requests) {
            BuildContactContextResult res = new BuildContactContextResult();
            mergeTrustGap(req.contactSummary, req.trustGap, req.allergyShellfish, req.allergyNuts, res);
            results.add(res);
        }
        return results;
    }

    private static void mergeTrustGap(String contactSummary, String trustGap, String allergyShellfish, String allergyNuts, BuildContactContextResult res) {
        Map<String, Object> contact = parseContactSummary(contactSummary);
        String commStyle = getString(contact, 'Comm_Style__c');
        if (String.isBlank(commStyle)) commStyle = DEFAULT_COMM_STYLE;
        String membershipLevel = getString(contact, 'Membership_Level__c');
        String firstName = getString(contact, 'FirstName');
        if (String.isBlank(firstName)) firstName = 'Guest';

        String trustGapStr = 'true'.equalsIgnoreCase(String.valueOf(trustGap)) ? 'true' : 'false';
        String allergyS = String.isNotBlank(allergyShellfish) && 'true'.equalsIgnoreCase(allergyShellfish) ? 'true' : 'false';
        String allergyN = String.isNotBlank(allergyNuts) && 'true'.equalsIgnoreCase(allergyNuts) ? 'true' : 'false';

        res.contactContext = JSON.serialize(new Map<String, String>{
            'trust_gap' => trustGapStr,
            'allergy_shellfish' => allergyS,
            'allergy_nuts' => allergyN,
            'comm_style' => commStyle,
            'membership_level' => membershipLevel,
            'first_name' => firstName
        });
    }

    private static Map<String, Object> parseContactSummary(String jsonStr) {
        if (String.isBlank(jsonStr)) return new Map<String, Object>();
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
        } catch (Exception e) {
            return new Map<String, Object>();
        }
    }

    private static String getString(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v != null ? String.valueOf(v) : '';
    }

    public class BuildContactContextRequest {
        @InvocableVariable(description='ContactSummary JSON from Build Contact Summary.')
        public String contactSummary;
        @InvocableVariable(description='TrustGap from EvaluateHardGates — "true" or "false".')
        public String trustGap;
        @InvocableVariable(description='Allergy_Shellfish__c as "true" or "false".')
        public String allergyShellfish;
        @InvocableVariable(description='Allergy_Nuts__c as "true" or "false".')
        public String allergyNuts;
    }

    public class BuildContactContextResult {
        @InvocableVariable(description='JSON: trust_gap, allergy_shellfish, allergy_nuts, comm_style, membership_level, first_name.')
        public String contactContext;
    }
}
