/**
 * ONE-TIME SCRIPT: Set Passcode__c = First3(FirstName) + '123456' for all existing R6 Diner contacts.
 * Run this after deploying Contact.Passcode__c if your org already has seed data.
 * Examples: Sofia -> Sof123456, Marcus -> Mar123456
 */
List<Contact> toUpdate = [
    SELECT Id, FirstName, Passcode__c
    FROM Contact
    WHERE Cuisine_Preference__c != null
    AND (Passcode__c = null OR Passcode__c = '' OR Passcode__c = '123456')
];

for (Contact c : toUpdate) {
    String first3 = String.isNotBlank(c.FirstName) && c.FirstName.length() >= 3
        ? c.FirstName.substring(0, 3)
        : (String.isNotBlank(c.FirstName) ? c.FirstName : '');
    c.Passcode__c = first3 + '123456';
}
update toUpdate;
System.debug('Updated Passcode__c for ' + toUpdate.size() + ' contact(s).');
