# Salesforce Integration

This solution includes a RESTful API endpoint, automation for matching accounts, and outbound integration with an external system.

## Detail
This solution uses an event-driven approach. A permission set called 'Integrations' should be assigned to the integration user to allow them to publish events successfully.
To create account links, send a POST request to the /api/v1/accountLink/ endpoint with a payload format:
```JSON
{
 "items": [
    {
      "color" : "blue",
      "externalId": "12345"
    },
    {
      "color" : "red",
      "externalId": "54321"
    }
  ]
}
```

The field mapping is controlled at runtime with a custom metadata type AccountLink_API_Mapping__mdt. This custom metadata defined how the fields in the request body should be mapped to fields on the object in Salesforce. AccountLinkRestResource is the request handler class.

Once AccountLink__c records are created from the request, the client or called receives a response. We then asynchronously publish the AccountLinkCreated__e event.
A trigger is used to subscribe to this event. Once the event is received, there is matching logic to find the related account record. If a match is found, we update the Account lookup on the AccountLink__c record and publish a new event AccountLinkMatched__e.

The AccountLinkMatched__e is also being subscribed to in the Apex trigger. When an account is received, a callout is made to another external system with the Account Id and the AccountLink__c Id. We are using a named credential MatchedNotificationSys to define the receiving endpoint url credential. 

The Automated Process should have access to this named credential to make the callout so the Integration permission set should be granted.

