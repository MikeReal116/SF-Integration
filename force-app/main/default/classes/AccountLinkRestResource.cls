@RestResource(urlMapping='/api/v1/accountLink/*')
global with sharing class AccountLinkRestResource {
    @HttpPost
    global static void handlePostRequest() {
        try {
            AccountLinkService.handlePostRequest();
        } catch (Exception ex) {
            AccountLinkService.generateErrorResponse(ex);
        }
    }
}