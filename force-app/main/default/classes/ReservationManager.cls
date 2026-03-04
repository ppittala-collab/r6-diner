/**
 * RE-USABLE AGENT ACTION: The Digital Maître d' Limb
 * Path 1: Transactional (Modify/Cancel)
 * PRD v2.1 Compliant: Handles Party Size, Lock Gates, and Audit Linking
 */
public with sharing class ReservationManager {

    @InvocableMethod(label='Modify Reservation Slot' description='Swaps an existing reservation to a new temporal slot, creating an audit trail.')
    public static List<ActionResult> modifySlot(List<ActionRequest> requests) {
        List<ActionResult> results = new List<ActionResult>();
        
        for (ActionRequest req : requests) {
            ActionResult res = new ActionResult();
            try {
                Reservation__c oldRes = [SELECT Id, Status__c, Assigned_Table_Slot__c, Is_Locked__c, 
                                                Modification_Count__c, Contact__c, Restaurant__c, Party_Size__c
                                         FROM Reservation__c 
                                         WHERE Id = :req.reservationId LIMIT 1];
                
                // GATE 1: 1-Hour Lockout Check
                if (oldRes.Is_Locked__c) {
                    res.isSuccess = false;
                    res.message = 'MODIFICATION_DENIED: Reservation is within the lockout period. Please escalate to human staff.';
                    results.add(res);
                    continue;
                }

                // GATE 2: Modification Loop Abuse Check (>= 3)
                if (oldRes.Modification_Count__c >= 3) {
                    res.isSuccess = false;
                    res.message = 'ESCALATION_REQUIRED: Modification count exceeded. Please route to human concierge.';
                    results.add(res);
                    continue;
                }

                List<Restaurant_Slot__c> availableSlots = [SELECT Id, Status__c 
                                            FROM Restaurant_Slot__c 
                                            WHERE Slot_Start_Time__c = :req.newStartTime 
                                            AND Table__r.Restaurant__c = :oldRes.Restaurant__c
                                            AND Table__r.Capacity__c >= :oldRes.Party_Size__c
                                            AND Status__c = 'Available' 
                                            ORDER BY Table__r.Capacity__c ASC
                                            LIMIT 1];

                if (availableSlots.isEmpty()) {
                    res.isSuccess = false;
                    res.message = 'NO_AVAILABILITY: No tables available for party of ' + oldRes.Party_Size__c + ' at the requested time.';
                    results.add(res);
                    continue;
                }

                Restaurant_Slot__c newSlot = availableSlots[0];

                // ATOMIC SWAP & AUDIT TRAIL
                update new Restaurant_Slot__c(Id = oldRes.Assigned_Table_Slot__c, Status__c = 'Available');
                update new Restaurant_Slot__c(Id = newSlot.Id, Status__c = 'Reserved');
                update new Reservation__c(Id = oldRes.Id, Status__c = 'Cancelled');

                Reservation__c newRes = new Reservation__c(
                    Contact__c = oldRes.Contact__c,
                    Restaurant__c = oldRes.Restaurant__c,
                    Reservation_DateTime__c = req.newStartTime,
                    Party_Size__c = oldRes.Party_Size__c,
                    Assigned_Table_Slot__c = newSlot.Id,
                    Status__c = 'Confirmed',
                    Modification_Count__c = oldRes.Modification_Count__c + 1,
                    Original_Reservation_Id__c = oldRes.Id,
                    Modification_History__c = 'Automated Agent modification from original reservation: ' + oldRes.Id
                );
                insert newRes;

                res.isSuccess = true;
                res.message = 'SUCCESS: Reservation moved. New Reservation ID: ' + newRes.Id;
                
            } catch (Exception e) {
                res.isSuccess = false;
                res.message = 'SYSTEM_ERROR: ' + e.getMessage();
            }
            results.add(res);
        }
        return results;
    }

    public class ActionRequest {
        @InvocableVariable(required=true description='The Salesforce ID of the current Reservation__c record.') 
        public Id reservationId;
        
        @InvocableVariable(required=true description='The exact DateTime the user wishes to move to.') 
        public DateTime newStartTime;
    }

    public class ActionResult {
        @InvocableVariable public Boolean isSuccess;
        @InvocableVariable public String message;
    }
}
