public with sharing class InfermedicaAPIConsumer {

    public static void requestAPI(String endpoint, String method) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'API' LIMIT 1];
		String apiBodyString = staticResource.Body.toString();
		Map<String, Object> apiBodyMap = (Map<String, Object>) JSON.deserializeUntyped(apiBodyString);
        
        request.setHeader('App-Id', apiBodyMap.get('ApplicationID').toString());
        request.setHeader('App-Key', apiBodyMap.get('ApplicationKeys').toString());
        request.setHeader('Accept', 'application/json');
        request.setHeader('Dev-Mode', 'true');
        request.setEndpoint(apiBodyMap.get('EndPoint').toString() + endpoint);
        request.setMethod(method);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            handleResponse(response, endpoint);
        }
    }

    /**
        Handle a successful HttpResponse.

        Parse the JSON returned into a Map<String, String>
        containing key=Id, value=Name of symptoms and export to 
        a CSV file.

        String path specifies where to save the CSV file. 
     */
    private static void handleResponse(HttpResponse response, String path) {
                
        List<Object> api = (List<Object>)JSON.deserializeUntyped(response.getBody());

        List<Map<String, Object>> apiValues = new List<Map<String, Object>>();
        for (Object a : api) {
            apiValues.add(convertToMap(a));
        }

        // Get the name and id of each symptom and put them in a map
        Map<String, String> symptomMap = extractIdAndName(apiValues);

        exportCSV(symptomMap, path);
    }

    /**
        Extract a Map<String, String>--where key is the Infermedica Id for a symptom
        and value is the name of the symptom--from a List<Map<String, Object>>
     */
    private static Map<String, String> extractIdAndName(List<Map<String, Object>> inputMaps) {
         
        Map<String, String> resultMap = new Map<String, String>();
        String id, name;

        for (Map<String, Object> mapVal : inputMaps) {
            id = (String)mapVal.get('id');
            name = (String)mapVal.get('name');
            resultMap.put(id, name);
        }        
        return resultMap;
    }

    /**
        Given a Map<String, String> where the key is an Infermedica Id
        for a symptom and the value is the name of the symptom,
        export a csv file with the header Id,Common Name
     */
    private static void exportCSV(Map<String, String> symptomMap, String path) {

        Set<String> symptomIds = symptomMap.keySet();
        String csv = 'Id,Common Name\n';

        // Remove any commas in the name
        for (String id : symptomIds) {
           if (symptomMap.get(Id).contains(',')) {

                String withoutComma = symptomMap.get(Id).replace(', ', '/');
                csv += id + ',' + withoutComma + '\n';

            } else {
                csv += id + ',' + symptomMap.get(id) + '\n';
            }  
        }

        ContentVersion file = new ContentVersion(
            title = path + '.csv',
            // VersionData is the body of the document (base64)
            // Blob is a collection of binary data stored as a single object. 
            VersionData = Blob.valueOf( csv ),
            pathOnClient = '/' + path + '.csv' // complete path of the document
        );    
        insert file;
    }

    /**
        Cast an Object to Map<String, Object>
     */
    private static Map<String, Object> convertToMap(Object obj) {
        return (Map<String, Object>)obj;
    }
}
