public class InfermedicaTester {
    public static void test(){
        APIInput input = new APIInput();
        input.sex = 'male';
        input.age = '30';
        List<Map<String, String>> Evidence = new List<Map<String, String>>();
        Evidence.add(new Map<String, String>{'id'=> 's_1277', 'choice_id'=> 'present'});
        Evidence.add(new Map<String, String>{'id'=> 's_478', 'choice_id'=> 'present'});
        Evidence.add(new Map<String, String>{'id'=> 's_1183', 'choice_id'=> 'present'});
        input.Evidence = Evidence;
        List<Object> conditions = sendRequest(input);
         for (Object condition: conditions) {
             System.debug(condition);
         }
    }
    public static List<Object> sendRequest(APIInput input, String endpoint){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'API' LIMIT 1];
		String apiBodyString = sr.Body.toString();
		Map<String, Object> apiBodyMap = (Map<String, Object>) JSON.deserializeUntyped(apiBodyString);
        
        request.setHeader('App-Id', apiBodyMap.get('ApplicationID').toString());
        request.setHeader('App-Key', apiBodyMap.get('ApplicationKeys').toString());
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(input));
        request.setEndpoint(apiBodyMap.get('EndPoint').toString() + endpoint);
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