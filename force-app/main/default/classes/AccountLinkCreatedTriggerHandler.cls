public with sharing class AccountLinkCreatedTriggerHandler extends TriggerHandler {
    List<AccountLinkCreated__e> createdAccountLinks;

    public AccountLinkCreatedTriggerHandler() {
        createdAccountLinks = (List<AccountLinkCreated__e>) Trigger.new;
    }

    public override void afterInsert() {
        AccountLinkService.matchAccounts(createdAccountLinks);
    }
}
