/**
 * Invocable: Returns the passcode request message for the escalation auth gate.
 * Replaces Auth_Passcode_Prompt (LLM) with deterministic logic — no LLM call needed.
 * Used by auth_required topic.
 */
public with sharing class GetAuthPasscodeMessage {

    @InvocableMethod(label='Get Auth Passcode Message' description='Returns passcode request message for auth gate. Replaces Auth_Passcode_Prompt.')
    public static List<GetAuthPasscodeMessageResult> getAuthPasscodeMessage(List<GetAuthPasscodeMessageRequest> requests) {
        List<GetAuthPasscodeMessageResult> results = new List<GetAuthPasscodeMessageResult>();

        for (GetAuthPasscodeMessageRequest req : requests) {
            GetAuthPasscodeMessageResult res = new GetAuthPasscodeMessageResult();
            res.message = buildMessage(
                req.isGuest == true,
                req.retryAfterFail == true,
                req.commStyle
            );
            results.add(res);
        }
        return results;
    }

    private static String buildMessage(Boolean isGuest, Boolean retryAfterFail, String commStyle) {
        String msg;
        if (isGuest) {
            msg = 'Escalation is available to registered diners. Please log in to your account to connect with our team.';
        } else if (retryAfterFail) {
            msg = 'That passcode doesn\'t match our records. Please try again, or say \'cancel\' to return to your question.';
        } else {
            msg = 'I\'d be happy to connect you with our team. To verify your identity and prioritize your request, please provide your account passcode.';
        }

        if ('Brief/Efficiency'.equalsIgnoreCase(commStyle) && !isGuest && !retryAfterFail) {
            msg = 'To connect with our team, please provide your account passcode.';
        }
        return msg;
    }

    public class GetAuthPasscodeMessageRequest {
        @InvocableVariable(description='True if user has no Contact record (Guest)')
        public Boolean isGuest;

        @InvocableVariable(description='True if previous passcode attempt failed')
        public Boolean retryAfterFail;

        @InvocableVariable(description='Contact.Comm_Style__c — Brief/Efficiency or Leisurely/Concierge')
        public String commStyle;
    }

    public class GetAuthPasscodeMessageResult {
        @InvocableVariable(description='The passcode request message to send to the diner')
        public String message;
    }
}
