@isTest
private with sharing class HttpCalloutTest {
    @IsTest
    private static void testMakeCallout() {
        List<AccountLinkMatched__e> matchedAccountLinks = new List<AccountLinkMatched__e>();
        AccountLinkMatched__e matchedAccountLink = new AccountLinkMatched__e(
            Account_Link_Id__c = '001',
            Account_Id__c = '002'
        );
        matchedAccountLinks.add(matchedAccountLink);
        String requestBody = AccountLinkService.generateRequestBody(matchedAccountLinks);
        HttpCalloutMockTest mock = new HttpCalloutMockTest(200, 'OK', requestBody, false);
        Test.setMock(HttpCalloutMock.class, mock);
        String url = 'https://testapi.io/api/mikereal';
        String method = 'POST';

        Test.startTest();
        String response = HttpCallout.makeCallout(url, method, requestBody);
        HttpCallout.makeFutureCallout(url, method, requestBody);
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        System.Assert.isTrue(responseMap.containsKey('items'), 'Response should contain items key');
        List<Object> items = (List<Object>) responseMap.get('items');
        System.Assert.areEqual(1, items.size(), 'Response should contain 1 item');
    }

    @IsTest
    private static void testMakeFutureCalloutException() {
        String url = 'https://testapi.io/api/mikereal';
        String method = 'POST';
        String body = 'test';
        HttpCalloutMockTest mock = new HttpCalloutMockTest(Utils.INTERNAL_SERVER_ERROR, 'ERROR', body, true);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpCallout.makeFutureCallout(url, method, body);
        Test.stopTest();

        System.Assert.isTrue([SELECT COUNT() FROM Logger__c] > 0, 'Log should be created');
    }
}
