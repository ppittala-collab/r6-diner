/**
 * Invocable: Retrieves diner's historical reservations for transactional and escalation context.
 * Call when Path 1 (Transactional) or escalation needs recent activity.
 */
public with sharing class GetDinerHistory {

    private static final Integer DEFAULT_LIMIT = 10;

    @InvocableMethod(label='Get Diner History' description='Query recent reservations for Contact. Use for transactional path or escalation handoff context.')
    public static List<GetDinerHistoryResult> getDinerHistory(List<GetDinerHistoryRequest> requests) {
        List<GetDinerHistoryResult> results = new List<GetDinerHistoryResult>();

        for (GetDinerHistoryRequest req : requests) {
            GetDinerHistoryResult res = new GetDinerHistoryResult();
            queryHistory(req.contactId, req.limitCount, res);
            results.add(res);
        }
        return results;
    }

    private static void queryHistory(String contactId, Integer limitCount, GetDinerHistoryResult res) {
        if (String.isBlank(contactId)) {
            res.reservationSummary = '[]';
            res.reservationCount = 0;
            return;
        }

        Integer limitVal = (limitCount != null && limitCount > 0) ? Math.min(limitCount, 20) : DEFAULT_LIMIT;

        try {
            List<Reservation__c> reservations = [
                SELECT Id, Name, Reservation_DateTime__c, Status__c, Party_Size__c,
                       Restaurant__r.Name, Modification_Count__c
                FROM Reservation__c
                WHERE Contact__c = :contactId
                ORDER BY Reservation_DateTime__c DESC
                LIMIT :limitVal
            ];

            List<Map<String, Object>> items = new List<Map<String, Object>>();
            for (Reservation__c r : reservations) {
                items.add(new Map<String, Object>{
                    'id' => r.Id,
                    'name' => r.Name,
                    'restaurant' => r.Restaurant__r != null ? r.Restaurant__r.Name : '',
                    'dateTime' => r.Reservation_DateTime__c != null ? String.valueOf(r.Reservation_DateTime__c) : '',
                    'status' => r.Status__c,
                    'partySize' => r.Party_Size__c,
                    'modificationCount' => r.Modification_Count__c
                });
            }

            res.reservationSummary = JSON.serialize(items);
            res.reservationCount = reservations.size();

        } catch (Exception e) {
            res.reservationSummary = '[]';
            res.reservationCount = 0;
        }
    }

    public class GetDinerHistoryRequest {
        @InvocableVariable(description='Contact Id.')
        public String contactId;

        @InvocableVariable(description='Max reservations to return (default 10, max 20).')
        public Integer limitCount;
    }

    public class GetDinerHistoryResult {
        @InvocableVariable(description='JSON array of recent reservations: id, name, restaurant, dateTime, status, partySize, modificationCount.')
        public String reservationSummary;

        @InvocableVariable(description='Number of reservations returned.')
        public Integer reservationCount;
    }
}
