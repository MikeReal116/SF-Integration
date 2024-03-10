@isTest
private with sharing class AccountLinkServiceTest {
    private static String successRequestBody = '{"items": [{"color": "red", "externalId": "test123", "accoundId":"001" }, {"color": "blue", "externalId": "123test", "accoundId":"002"}, {"color": "green", "externalId": "testing123","accoundId":"003"}]}';
    private static String noExternalIdBody = '{"items": [{"color": "red", "accoundId":"001" }, {"color": "blue", "accoundId":"002"}, {"color": "green", "externalId": "testing123","accoundId":"003"}]}';
    private static String path = '/api/v1/accountLink';

    @TestSetup
    static void makeData() {
        Account account = new Account(Name = 'Test Account', Color__c = 'red', External_Account_Link__c = 'test123');
        insert account;
    }

    @IsTest
    private static void testHandlePostRequestSuccess() {
        RestRequest request = new RestRequest();
        request.requestURI = path;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(successRequestBody);
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();
        AccountLinkRestResource.handlePostRequest();
        Test.stopTest();

        System.Assert.areEqual(Utils.CREATED, response.statusCode, 'Status code should be 201');
        System.Assert.areEqual(3, [SELECT COUNT() FROM AccountLink__c], '3 records should be created');
        System.Assert.areEqual(
            1,
            [SELECT COUNT() FROM AccountLink__c WHERE Account__c != NULL],
            '1 record should have an account'
        );
        System.Assert.areEqual(0, [SELECT COUNT() FROM Logger__c], 'No logs should be created');
    }

    @IsTest
    private static void testHandlePostRequestDuplicateExternalId() {
        RestRequest request = new RestRequest();
        request.requestURI = path;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(noExternalIdBody);
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();
        AccountLinkRestResource.handlePostRequest();
        Test.stopTest();

        System.Assert.areEqual(Utils.INTERNAL_SERVER_ERROR, response.statusCode, 'Status code should be 500');
        System.Assert.areEqual(0, [SELECT COUNT() FROM AccountLink__c], 'No records should be created');
        System.Assert.areEqual(0, [SELECT COUNT() FROM Logger__c], 'No logs should be created');
    }

    @IsTest
    private static void testFailedEventPublish() {
        AccountLink__c accountLink = new AccountLink__c(Color__c = 'red');

        Test.startTest();
        AccountLinkService.publishAccountLinkCreatedEvent(new List<AccountLink__c>{ accountLink });
        Test.stopTest();

        System.Assert.isTrue([SELECT COUNT() FROM Logger__c] > 0, 'Log should be created');
    }

    @IsTest
    private static void testGenerateResponseBody() {
        List<AccountLinkMatched__e> matchedAccountLinks = new List<AccountLinkMatched__e>();
        AccountLinkMatched__e matchedAccountLink = new AccountLinkMatched__e(
            Account_Link_Id__c = '001',
            Account_Id__c = '002'
        );
        matchedAccountLinks.add(matchedAccountLink);

        Test.startTest();
        String requestBody = AccountLinkService.generateRequestBody(matchedAccountLinks);
        Test.stopTest();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        System.Assert.isTrue(responseMap.containsKey('items'), 'Response should contain items key');
    }
}