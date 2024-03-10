trigger AccountLinkMatchedTrigger on AccountLinkMatched__e(after insert) {
    new AccountLinkMatchedTriggerHandler().run();
}