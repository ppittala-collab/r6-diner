/**
 * Invocable: Builds ContactSummary JSON and derived fields from Contact.
 * Call at first step when ContactId exists; returns defaults when guest (ContactId null).
 * Use downstream for contextual grounding (Intent_Classifier, EvaluateHardGates, Policy/Menu QA).
 */
public with sharing class BuildContactSummary {

    private static final String DEFAULT_GUEST_JSON = '{}';
    private static final String DEFAULT_COMM_STYLE = 'Brief/Efficiency';

    @InvocableMethod(label='Build Contact Summary' description='Query Contact and return ContactSummary JSON + comm_style, allergy flags. Use at first step; defaults when guest.')
    public static List<BuildContactSummaryResult> buildContactSummary(List<BuildContactSummaryRequest> requests) {
        List<BuildContactSummaryResult> results = new List<BuildContactSummaryResult>();

        for (BuildContactSummaryRequest req : requests) {
            BuildContactSummaryResult res = new BuildContactSummaryResult();
            build(req.contactId, res);
            results.add(res);
        }
        return results;
    }

    private static void build(String contactId, BuildContactSummaryResult res) {
        if (String.isBlank(contactId)) {
            res.contactSummary = DEFAULT_GUEST_JSON;
            res.contactContext = '{"trust_gap":"false","allergy_shellfish":"false","allergy_nuts":"false","comm_style":"' + DEFAULT_COMM_STYLE + '","membership_level":"","first_name":"Guest"}';
            res.commStyle = DEFAULT_COMM_STYLE;
            res.allergyShellfish = 'false';
            res.allergyNuts = 'false';
            return;
        }

        List<Contact> contacts;
        try {
            contacts = [
                SELECT Id, FirstName, LastName, Email,
                       Membership_Level__c, Comm_Style__c, Cuisine_Preference__c, Family_Status__c,
                       Allergy_Shellfish__c, Allergy_Nuts__c,
                       Lifetime_No_Show_Count__c, Sentiment_Score__c, Churn_Risk__c,
                       Trust_Tolerance__c
                FROM Contact
                WHERE Id = :contactId
                LIMIT 1
            ];
        } catch (QueryException e) {
            res.contactSummary = DEFAULT_GUEST_JSON;
            res.contactContext = '{"trust_gap":"false","allergy_shellfish":"false","allergy_nuts":"false","comm_style":"' + DEFAULT_COMM_STYLE + '","membership_level":"","first_name":"Guest"}';
            res.commStyle = DEFAULT_COMM_STYLE;
            res.allergyShellfish = 'false';
            res.allergyNuts = 'false';
            return;
        }

        if (contacts == null || contacts.isEmpty()) {
            res.contactSummary = DEFAULT_GUEST_JSON;
            res.contactContext = '{"trust_gap":"false","allergy_shellfish":"false","allergy_nuts":"false","comm_style":"' + DEFAULT_COMM_STYLE + '","membership_level":"","first_name":"Guest"}';
            res.commStyle = DEFAULT_COMM_STYLE;
            res.allergyShellfish = 'false';
            res.allergyNuts = 'false';
            return;
        }

        Contact c = contacts[0];
        Map<String, Object> summary = new Map<String, Object>{
            'Id' => c.Id,
            'FirstName' => c.FirstName,
            'LastName' => c.LastName,
            'Email' => c.Email,
            'Membership_Level__c' => c.Membership_Level__c,
            'Comm_Style__c' => c.Comm_Style__c,
            'Cuisine_Preference__c' => c.Cuisine_Preference__c,
            'Family_Status__c' => c.Family_Status__c,
            'Allergy_Shellfish__c' => c.Allergy_Shellfish__c,
            'Allergy_Nuts__c' => c.Allergy_Nuts__c,
            'Lifetime_No_Show_Count__c' => c.Lifetime_No_Show_Count__c,
            'Sentiment_Score__c' => c.Sentiment_Score__c,
            'Churn_Risk__c' => c.Churn_Risk__c,
            'Trust_Tolerance__c' => c.Trust_Tolerance__c
        };

        res.contactSummary = JSON.serialize(summary);
        res.allergyShellfish = toBoolString(c.Allergy_Shellfish__c);
        res.allergyNuts = toBoolString(c.Allergy_Nuts__c);
        res.commStyle = String.isNotBlank(c.Comm_Style__c) ? c.Comm_Style__c : DEFAULT_COMM_STYLE;

        String firstName = String.isNotBlank(c.FirstName) ? c.FirstName : 'Guest';
        String membershipLevel = String.isNotBlank(c.Membership_Level__c) ? c.Membership_Level__c : '';

        res.contactContext = JSON.serialize(new Map<String, String>{
            'trust_gap' => 'false',
            'allergy_shellfish' => res.allergyShellfish,
            'allergy_nuts' => res.allergyNuts,
            'comm_style' => res.commStyle,
            'membership_level' => membershipLevel,
            'first_name' => firstName
        });
    }

    private static String toBoolString(Boolean b) {
        return (b != null && b) ? 'true' : 'false';
    }

    public class BuildContactSummaryRequest {
        @InvocableVariable(description='Contact Id. When null/blank, returns guest defaults.')
        public String contactId;
    }

    public class BuildContactSummaryResult {
        @InvocableVariable(description='JSON with Contact fields for EvaluateHardGates, Intent_Classifier.')
        public String contactSummary;

        @InvocableVariable(description='JSON: trust_gap, allergy_shellfish, allergy_nuts, comm_style, membership_level, first_name. Update trust_gap from EvaluateHardGates before Policy/Menu QA.')
        public String contactContext;

        @InvocableVariable(description='Contact.Comm_Style__c — Brief/Efficiency or Leisurely/Concierge.')
        public String commStyle;

        @InvocableVariable(description='Allergy_Shellfish__c as "true" or "false".')
        public String allergyShellfish;

        @InvocableVariable(description='Allergy_Nuts__c as "true" or "false".')
        public String allergyNuts;
    }
}
