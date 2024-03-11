trigger AccountLinkCreatedTrigger on AccountLinkCreated__e(after insert) {
    new AccountLinkCreatedTriggerHandler().run();
}
