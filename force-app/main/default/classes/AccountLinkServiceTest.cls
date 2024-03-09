@isTest
private with sharing class AccountLinkServiceTest {
    private static String successRequestBody = '{"items": [{"color": "red", "externalId": "test123", "accoundId":"001" }, {"color": "blue", "externalId": "123test", "accoundId":"002"}, {"color": "green", "externalId": "testing123","accoundId":"003"}]}';
    private static String diplicateExternalIdBody = '{"items": [{"color": "red", "externalId": "test123", "accoundId":"001" }, {"color": "blue", "externalId": "test123", "accoundId":"002"}, {"color": "green", "externalId": "testing123","accoundId":"003"}]}';
    private static String path = '/api/v1/accountLink';

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

        System.Assert.areEqual(AccountLinkService.CREATED, response.statusCode, 'Status code should be 201');
        System.Assert.areEqual(3, [SELECT COUNT() FROM AccountLink__c]);
    }

    @IsTest
    private static void testHandlePostRequestDuplicateExternalId() {
        RestRequest request = new RestRequest();
        request.requestURI = path;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(diplicateExternalIdBody);
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();
        AccountLinkRestResource.handlePostRequest();
        Test.stopTest();

        System.Assert.areEqual(
            AccountLinkService.INTERNAL_SERVER_ERROR,
            response.statusCode,
            'Status code should be 400'
        );
        System.Assert.areEqual(0, [SELECT COUNT() FROM AccountLink__c]);
    }
}
