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
            if (!securityDecision.getRecords().isEmpty()) {
                publishAccountLinkCreatedEvent(securityDecision.getRecords());
            }
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

    public static void publishAccountLinkCreatedEvent(List<AccountLink__c> accountLinks) {
        List<AccountLinkCreated__e> events = new List<AccountLinkCreated__e>();
        for (AccountLink__c accountLink : accountLinks) {
            AccountLinkCreated__e event = new AccountLinkCreated__e(
                Color__c = accountLink.Color__c,
                External_Id__c = accountLink.External_Id__c,
                Record_Id__c = accountLink.Id
            );
            events.add(event);
        }
        EventBus.publish(events);
    }

    public static void publishAccountLinkMatchedEvent(List<AccountLink__c> accountLinks) {
        List<AccountLinkMatched__e> events = new List<AccountLinkMatched__e>();
        for (AccountLink__c accountLink : accountLinks) {
            AccountLinkMatched__e event = new AccountLinkMatched__e(
                Account_Link_Id__c = accountLink.Id,
                Account_Id__c = accountLink.Account__c
            );
            events.add(event);
        }
        System.debug('pushbliing matched event');
        EventBus.publish(events);
    }

    public static String generateRequestBody(List<AccountLinkMatched__e> matchedAccountLinks) {
        List<Map<String, String>> items = new List<Map<String, String>>();
        for (AccountLinkMatched__e matchedAccountLink : matchedAccountLinks) {
            Map<String, String> item = new Map<String, String>();
            item.put('accountLinkId', matchedAccountLink.Account_Link_Id__c);
            item.put('accountId', matchedAccountLink.Account_Id__c);
            items.add(item);
        }
        Map<String, List<Map<String, String>>> requestBodyMap = new Map<String, List<Map<String, String>>>();
        requestBodyMap.put('items', items);
        return JSON.serialize(requestBodyMap);
    }

    public static void matchAccounts(List<AccountLinkCreated__e> createdAccountLinks) {
        Set<String> externalIds = new Set<String>();
        Set<String> colors = new Set<String>();
        String delimiter = '-';
        Map<String, Account> matchingKeytoAccountMap = new Map<String, Account>();

        for (AccountLinkCreated__e createAccountLink : createdAccountLinks) {
            if (createAccountLink.External_Id__c != null && createAccountLink.Color__c != null) {
                externalIds.add(createAccountLink.External_Id__c);
                colors.add(createAccountLink.Color__c);
            }
        }
        try {
            for (Account account : [
                SELECT Id, External_Account_Link__c, Color__c
                FROM Account
                WHERE External_Account_Link__c IN :externalIds AND Color__c IN :colors
            ]) {
                matchingKeytoAccountMap.put(account.External_Account_Link__c + delimiter + account.Color__c, account);
            }

            List<AccountLink__c> accountLinks = new List<AccountLink__c>();

            for (AccountLinkCreated__e createAccountLink : createdAccountLinks) {
                String matchingKey = createAccountLink.External_Id__c + delimiter + createAccountLink.Color__c;
                Account account = matchingKeytoAccountMap.get(matchingKey);
                if (account != null) {
                    AccountLink__c accountLink = new AccountLink__c(
                        Account__c = account.Id,
                        Id = createAccountLink.Record_Id__c
                    );
                    accountLinks.add(accountLink);
                }
            }

            if (!accountLinks.isEmpty()) {
                update accountLinks;
                publishAccountLinkMatchedEvent(accountLinks);
            }
        } catch (Exception ex) {
            // Log error with matchAccountLink
        }
    }
}