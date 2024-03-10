@isTest
public with sharing class HttpCalloutMockTest implements HttpCalloutMock {
    HttpResponse response;
    public HttpCalloutMockTest(Integer statusCode, String status, String body) {
        response = generateHttpResponse(statusCode, status, body);
    }

    public static HttpResponse generateHttpResponse(Integer statusCode, String status, String body) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setStatus(status);
        res.setBody(body);
        return res;
    }

    public HttpResponse respond(HttpRequest request) {
        return response;
    }
}