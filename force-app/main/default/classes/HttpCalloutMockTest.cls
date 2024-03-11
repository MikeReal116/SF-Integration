@isTest
public with sharing class HttpCalloutMockTest implements HttpCalloutMock {
    HttpResponse response;
    Boolean throwException = false;
    public HttpCalloutMockTest(Integer statusCode, String status, String body, Boolean throwException) {
        response = generateHttpResponse(statusCode, status, body);
        this.throwException = throwException;
    }

    public static HttpResponse generateHttpResponse(Integer statusCode, String status, String body) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setStatus(status);
        res.setBody(body);
        return res;
    }

    public HttpResponse respond(HttpRequest request) {
        if (throwException) {
            throw new CalloutException('Exception thrown');
        }
        return response;
    }
}
