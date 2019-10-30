public with sharing class InfermedicaTester {
  public static void test(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('App-Id', 'c1e5a7d6');
        request.setHeader('App-Key', 'f9cd32e19f27f7c72e91369d0b2d947c');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"sex": "male", "age": 30, "evidence": [{"id": "s_1193", "choice_id": "present"},{"id": "s_488", "choice_id": "present"},{"id": "s_418", "choice_id": "present"}]}');
    
        request.setEndpoint('https://api.infermedica.com/v2/diagnosis');
        request.setMethod('POST');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            System.debug('success');
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> conditions = (List<Object>) results.get('conditions');
            System.debug('Received the following conditions:');
            // print condtions
            for (Object condition: conditions) {
                System.debug(condition);
            }
        }
        else{
            System.debug('failure');
        }
    }
}