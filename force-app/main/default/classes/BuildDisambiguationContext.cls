/**
 * Invocable: Builds ConversationContext for disambiguation flow.
 * Call from topic_ambiguous_question after_reasoning before transitioning to topic_selector.
 * Ensures Intent_Classifier receives original question + clarification context so the user's
 * response (e.g., "Bistro Verde") is understood in context of the prior question.
 */
public with sharing class BuildDisambiguationContext {

    @InvocableMethod(
        label='Build Disambiguation Context'
        description='Merge original question and followup into ConversationContext. Call from ambiguous_question after_reasoning before transition to topic_selector.'
    )
    public static List<BuildDisambiguationContextResult> build(List<BuildDisambiguationContextRequest> requests) {
        List<BuildDisambiguationContextResult> results = new List<BuildDisambiguationContextResult>();

        for (BuildDisambiguationContextRequest req : requests) {
            BuildDisambiguationContextResult res = new BuildDisambiguationContextResult();
            buildContext(req.existingContext, req.originalUserMessage, req.followupQuestion, res);
            Integer currentCount = req.currentClarificationCount != null ? req.currentClarificationCount : 0;
            res.newClarificationCount = currentCount + 1;
            results.add(res);
        }
        return results;
    }

    private static void buildContext(String existingContext, String originalUserMessage, String followupQuestion, BuildDisambiguationContextResult res) {
        String disambiguationBlock = 'Original question: ' + (String.isNotBlank(originalUserMessage) ? originalUserMessage : '(none)')
            + '. Clarification asked: ' + (String.isNotBlank(followupQuestion) ? followupQuestion : '(none)')
            + '. Awaiting user response.';

        if (String.isNotBlank(existingContext)) {
            res.conversationContext = existingContext + '\n\n' + disambiguationBlock;
        } else {
            res.conversationContext = disambiguationBlock;
        }
    }

    public class BuildDisambiguationContextRequest {
        @InvocableVariable(description='Existing ConversationContext to append to. Optional.')
        public String existingContext;
        @InvocableVariable(description='Original diner question before clarification (OriginalUserMessage).')
        public String originalUserMessage;
        @InvocableVariable(description='Clarifying question asked (FollowupQuestion).')
        public String followupQuestion;
        @InvocableVariable(description='Current clarification loop count. Optional; null on first pass treated as 0.')
        public Integer currentClarificationCount;
    }

    public class BuildDisambiguationContextResult {
        @InvocableVariable(description='Merged ConversationContext for Intent_Classifier.')
        public String conversationContext;
        @InvocableVariable(description='Incremented clarification count (currentClarificationCount + 1).')
        public Integer newClarificationCount;
    }
}
