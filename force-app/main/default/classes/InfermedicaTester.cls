public class InfermedicaTester {
    public static void test(){
        APIInput input = new APIInput();
        input.sex = 'male';
        input.age = '30';
        List<Map<String, String>> Evidence = new List<Map<String, String>>();
        Evidence.add(new Map<String, String>{'id'=> 's_1193', 'choice_id'=> 'present'});
        Evidence.add(new Map<String, String>{'id'=> 's_488', 'choice_id'=> 'present'});
        Evidence.add(new Map<String, String>{'id'=> 's_418', 'choice_id'=> 'present'});
        input.Evidence = Evidence;
        List<Object> conditions = sendRequest(input);
         for (Object condition: conditions) {
             System.debug(conditions);
         }
    }
    public static List<Object> sendRequest(APIInput input){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // get static resources
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'API' LIMIT 1];
        // get body
		String apiBodyString = sr.Body.toString();
        // deserialize json string to map
		Map<String, Object> apiBodyMap = (Map<String, Object>) JSON.deserializeUntyped(apiBodyString);
        // set api id
        request.setHeader('App-Id', apiBodyMap.get('ApplicationID').toString());
        // set api key
        request.setHeader('App-Key', apiBodyMap.get('ApplicationKeys').toString());
        // set header
        request.setHeader('Content-Type', 'application/json');
        // serialize object to string and pass to http request
        request.setBody(JSON.serialize(input));
        // request.setBody('{"sex": "male", "age": 30, "evidence": [{"id": "s_1193", "choice_id": "present"},{"id": "s_488", "choice_id": "present"}, {"id": "s_418", "choice_id": "present"}]}'); 
        request.setEndpoint(apiBodyMap.get('EndPoint').toString());
        request.setMethod('POST');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            System.debug('success');
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> conditions = (List<Object>) results.get('conditions');
          
            return conditions;
        }
        else{
            System.debug('failure');
            return new List<Object>();
        }
    }
}