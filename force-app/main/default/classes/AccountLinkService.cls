public with sharing class AccountLinkService {
    public static final Integer CREATED = 201;
    public static final Integer INTERNAL_SERVER_ERROR = 500;

    public static void handlePostRequest() {
        Blob requestBody = RestContext.request.requestBody;
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody.toString());
        List<Object> items = (List<Object>) requestBodyMap.get('items');
        if (items != null && !items.isEmpty()) {
            List<AccountLink__c> accountLinks = new List<AccountLink__c>();
            Map<String, String> apiMappingMap = getApiMappingMap();

            for (Object item : items) {
                Map<String, Object> itemMap = (Map<String, Object>) item;
                AccountLink__c accountLink = createAccountLink(itemMap, apiMappingMap);
                accountLinks.add(accountLink);
            }
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, accountLinks);

            insert securityDecision.getRecords();
            String message = 'Successully created. ';
            if (!securityDecision.getRemovedFields().isEmpty()) {
                message +=
                    'The following fields were not saved due to access issue : ' + securityDecision.getRemovedFields();
            }
            generateSuccessResponse(securityDecision.getRecords().size(), message);
        } else {
            generateSuccessResponse(0, 'No records to created.');
        }
    }

    private static void generateSuccessResponse(Integer numRecordsCreated, String message) {
        RestResponse response = RestContext.response;
        response.statusCode = CREATED;
        response.responseBody = Blob.valueOf(
            '{"status": "success" , "numRecordsCreated": ' + numRecordsCreated + ', "message": "' + message + '"}'
        );
    }

    public static void generateErrorResponse(Exception ex) {
        RestResponse response = RestContext.response;
        response.statusCode = INTERNAL_SERVER_ERROR;
        response.responseBody = Blob.valueOf('{"status": "error" , "message": "' + ex.getMessage() + '"}');
    }

    private static Map<String, String> getApiMappingMap() {
        Map<String, String> apiMappingMap = new Map<String, String>();
        for (AccountLink_API_Mapping__mdt mapping : [
            SELECT DeveloperName, Salesforce_Field__c
            FROM AccountLink_API_Mapping__mdt
        ]) {
            apiMappingMap.put(mapping.DeveloperName, mapping.Salesforce_Field__c);
        }
        return apiMappingMap;
    }

    private static AccountLink__c createAccountLink(Map<String, Object> input, Map<String, String> apiMappingMap) {
        AccountLink__c accountLink = new AccountLink__c();
        // externalId is populated
        for (String key : input.keySet()) {
            String fieldName = apiMappingMap.get(key);
            if (fieldName != null) {
                accountLink.put(fieldName, input.get(key));
            }
        }
        return accountLink;
    }
}
