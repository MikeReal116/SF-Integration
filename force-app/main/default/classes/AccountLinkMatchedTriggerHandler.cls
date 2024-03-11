public with sharing class AccountLinkMatchedTriggerHandler extends TriggerHandler {
    private List<AccountLinkMatched__e> matchedAccountLinks;
    public AccountLinkMatchedTriggerHandler() {
        matchedAccountLinks = (List<AccountLinkMatched__e>) Trigger.new;
    }

    public override void afterInsert() {
        System.debug('AccountLinkMatchedTriggerHandler.afterInsert');
        // remote site setting required for base url
        // String url = 'https://testapi.io/api/mikereal/matches';
        // Integration permission set needed for Automated Process user if using Named Credentials
        String url = 'callout:MatchedNotificationSys//v1/v2';
        String method = 'POST';
        String body = AccountLinkService.generateRequestBody(matchedAccountLinks);
        HttpCallout.makeFutureCallout(url, method, body);
    }
}
