public with sharing class VerifyPasscode {

    @InvocableMethod(label='Verify Passcode' description='Verify diner passcode against Contact record. Used for escalation auth gate.')
    public static List<VerifyResult> verifyPasscode(List<VerifyRequest> requests) {
        List<VerifyResult> results = new List<VerifyResult>();

        for (VerifyRequest req : requests) {
            VerifyResult res = new VerifyResult();
            try {
                if (String.isBlank(req.contactId) || String.isBlank(req.passcodeProvided)) {
                    res.isMatch = false;
                    res.message = 'Contact ID and passcode are required.';
                    results.add(res);
                    continue;
                }

                List<Contact> contacts = [
                    SELECT Id, Passcode__c
                    FROM Contact
                    WHERE Id = :req.contactId
                    LIMIT 1
                ];

                if (contacts.isEmpty()) {
                    res.isMatch = false;
                    res.message = 'Contact not found.';
                    results.add(res);
                    continue;
                }

                String storedPasscode = contacts[0].Passcode__c;
                if (String.isBlank(storedPasscode)) {
                    res.isMatch = false;
                    res.message = 'No passcode on file. Please contact support.';
                    results.add(res);
                    continue;
                }

                res.isMatch = storedPasscode.trim().equals(req.passcodeProvided.trim());
                res.message = res.isMatch ? 'Passcode verified.' : 'Passcode does not match.';
            } catch (Exception e) {
                res.isMatch = false;
                res.message = 'Verification error: ' + e.getMessage();
            }
            results.add(res);
        }
        return results;
    }

    public class VerifyRequest {
        @InvocableVariable(description='Contact Id to verify passcode for')
        public String contactId;

        @InvocableVariable(description='Passcode provided by the user')
        public String passcodeProvided;
    }

    public class VerifyResult {
        @InvocableVariable(description='True if passcode matches Contact.Passcode__c')
        public Boolean isMatch;

        @InvocableVariable(description='Status message')
        public String message;
    }
}
