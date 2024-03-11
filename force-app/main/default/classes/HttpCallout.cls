public with sharing class HttpCallout {
    public static String makeCallout(String url, String method, String body) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(body);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response.getBody();
    }

    @future(callout=true)
    public static void makeFutureCallout(String url, String method, String body) {
        try {
            makeCallout(url, method, body);
        } catch (Exception ex) {
            Logger__c log = Utils.createLog(Utils.LogType.ERROR, ex.getMessage(), ex.getStackTraceString());
            Logger__c stateLog = Utils.createLog(Utils.LogType.ERROR, body, null);
            insert new List<Logger__c>{ log, stateLog };
        }
    }
}
