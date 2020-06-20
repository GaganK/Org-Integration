/***************************
API: 		Lead Operation
Author: 	Gagan Khanapure
API URL:	https://ap17.lightning.force.com/services/apexrest/leadServices
Ref: 		https://opfocus.com/json-deserialization-techniques-in-salesforce/

					LEAD CREATION:
                        REQUEST URL: https://ap17.lightning.force.com/services/apexrest/leadServices
                        REQUEST BODY: 
                        {
                          "apiKey":"1ad29965d80f48409a2fef4dc191d4d6",
                          "status":"success",
                          "Lead": [{"Salutation":"Mr","FirstName":"abc","LastName":"xyz","Title":"API Web Service","Company":"Coded Brain","Phone":"123456789","Email":"test@test.com","MobilePhone":"1234567890","Industry":"Banking","Rating":"Warm","LeadSource":"Web"},
                                   {"Salutation":"Mrs","FirstName":"pqr","LastName":"ghi","Title":"API Web Service","Company":"Coded Program","Phone":"0987654321","Email":"test1@test1.com","MobilePhone":"1234567890","Industry":"Banking","Rating":"Cold","LeadSource":"Web"}]
                        }
                        RESPONSE BODY:
						{
						  "status":"Success",
						  "error":"Lead record inserted successfully!"
						}
        
                    LEAD UPDATION:
                        REQUEST URL: https://ap17.lightning.force.com/services/apexrest/leadServices
                        REQUEST BODY: 
                        {
                          "apiKey":"1ad29965d80f48409a2fef4dc191d4d6",
                          "status":"success",
                          "Lead": [{"Id":"00Q2x0000018r46EAA","Salutation":"Mr","FirstName":"U-abc","LastName":"xyz","Title":"API Web Service","Company":"Coded Brain","Phone":"123456789","Email":"test@test.com","MobilePhone":"1234567890","Industry":"Banking","Rating":"Warm","LeadSource":"Web"},
                                   {"Id":"00Q2x0000018r47EAA","Salutation":"Mrs","FirstName":"U-pqr","LastName":"ghi","Title":"API Web Service","Company":"Coded Program","Phone":"0987654321","Email":"test1@test1.com","MobilePhone":"1234567890","Industry":"Banking","Rating":"Cold","LeadSource":"Web"}]
                        }
						RESPONSE BODY:
						{
						  "status":"Success",
						  "error":"Lead record updated successfully!"
						}

                    LEAD DELETE:
                    	REQUEST URL: https://ap17.lightning.force.com/services/apexrest/leadServices?Id=00Q2x0000018r47EAA
                        REQUEST BODY: Null
						RESPONSE BODY:
						{
                          "status" : "Success",
                          "deletedId" : "00Q2x0000018r47EAA",
                          "error" : "Lead record deleted successfully against ID:00Q2x0000018r47EAA"
                        }

					LEAD GET ALL RECORDS:
                        REQUEST URL: https://ap17.lightning.force.com/services/apexrest/leadServices?type=getAllAccounts
                        REQUEST BODY: NULL
                        RESPONSE BODY:
						{
                          "status" : "Success",
                          "Count" : 2,
                          "Lead" : [ {
                            "Id" : "00Q2x0000018r46EAA",
                            "Salutation" : "Mr",
                            "Name" : "abc xyz",
                            "FirstName" : "abc",
                            "LastName" : "xyz",
                            "Title" : "API Web Service",
                            "Company" : "Coded Brain",
                            "Phone" : "123456789",
                            "Email" : "test@test.com",
                            "MobilePhone" : "1234567890",
                            "LeadSource" : "Web",
                            "Status" : "Open - Not Contacted",
                            "Industry" : "Banking",
                            "Rating" : "Warm",
                            "PhotoUrl" : "/services/images/photo/00Q2x0000018r46EAA"
                          }, {
                            "Id" : "00Q2x0000018r47EAA",
                            "Salutation" : "Mrs",
                            "Name" : "pqr ghi",
                            "FirstName" : "pqr",
                            "LastName" : "ghi",
                            "Title" : "API Web Service",
                            "Company" : "Coded Program",
                            "Phone" : "0987654321",
                            "Email" : "test1@test1.com",
                            "MobilePhone" : "1234567890",
                            "LeadSource" : "Web",
                            "Status" : "Open - Not Contacted",
                            "Industry" : "Banking",
                            "Rating" : "Cold",
                            "PhotoUrl" : "/services/images/photo/00Q2x0000018r47EAA"
                          } ]
                        }

                    
			
***************************/
@RestResource(urlmapping='/leadServices/*')
global class LeadWebServices{
   
    @HttpPost
    global static string createLead(){

        // get our api key from custom metadata types
        //API_Credentials__mdt customMetaData = [select apiKey__c from API_Credentials__mdt];
        //String custom_apiKey = customMetaData.apiKey__c;
        String custom_apiKey = getApiKey();
        
        // create json response body
        System.JSONGenerator js = JSON.createGenerator(true);
        js.writeStartObject();

        // Get body from request & check empty or not
        if(RestContext.request.requestBody != null){
            
            try{
                    String leadResponseBody = RestContext.request.requestBody.toString();
                    
                    // deserialized get response json body
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(leadResponseBody);
                    String response_status = (String)m.get('status');
                    String response_apiKey = (String)m.get('apiKey');
                    
                    System.debug('-----response_status--------->>>'+response_status);
                    System.debug('-----response_apiKey--------->>>'+response_apiKey);
                    
                    // check apiKey authentication
                    if(custom_apiKey == response_apiKey){
                        
                        List<Object> leadList = (List<Object>)m.get('Lead');
                        
                        List<Lead> ldList = new List<Lead>();
                        
                        for(Object obj: leadList){
                            
                            Map<String, Object> leadAttb = (Map<String, Object>)obj;
                            
                            Lead ld = new Lead();
                            ld.Salutation   =	(String)leadAttb.get('Salutation');
                            ld.FirstName	=	(String)leadAttb.get('FirstName');
                            ld.LastName		=	(String)leadAttb.get('LastName');
                            ld.Title		=	(String)leadAttb.get('Title');
                            ld.Company		=	(String)leadAttb.get('Company');
                            ld.Phone		=	(String)leadAttb.get('Phone');
                            ld.Email		=	(String)leadAttb.get('Email');
                            ld.MobilePhone	=	(String)leadAttb.get('MobilePhone');
                            ld.Industry		=	(String)leadAttb.get('Industry');
                            ld.Rating		=	(String)leadAttb.get('Rating');
                            ld.LeadSource	=	(String)leadAttb.get('LeadSource');
                            
                            ldList.add(ld);
                        }
                        
                        
                        // DML Operation: Insert
                        insert ldList;
                        
                        System.debug('------->>>>'+ldList);
                        // Give Successfull response in json
                        js.writeStringField('status','Success');
                        js.writeStringField('error','Lead record inserted successfully!');
                        
                        
                    }else{
                        // apiKey not matched
                        js.writeStringField('status','Failed');
                        js.writeStringField('error','Invalid/Empty API key');   
                    }
                
            }
            catch(Exception e){
            	js.writeStringField('status','Failed');
                js.writeStringField('error','------>'+e.getCause()); 
            }
            
        }else{
            
        	// check leadResponseBody empty
        	js.writeStringField('status','Failed');
            js.writeStringField('error','Empty response in request body');     
            
        }
        
        
        // get response in json format & return
        js.writeEndObject();
        String response = js.getAsString();
        return response;
    }
    
    @HttpGet
    global static string getAllLeads(){
        
        // get our api key from custom metadata types
        String custom_apiKey = getApiKey();
        
        // get type value from url parameter (url query string)
        // Ex: https://ap17.lightning.force.com/services/apexrest/leadServices?type=getAllAccounts
        String typeParam = RestContext.request.params.get('type'); // values: getAllAccounts
        System.debug('-----typeParam--------->>>'+typeParam);
        // create json response body
        System.JSONGenerator js = JSON.createGenerator(true);
        js.writeStartObject();

        // check url parameter "type" valid or invalid
        if(typeParam == 'getAllAccounts'){
            
            	try{
                            
                            String query = 'SELECT Id, LastName, FirstName, Salutation, Name, Title, Company, Phone, Street, City, State, PostalCode, Country, Address, MobilePhone, Email, Website, LeadSource, Status, Industry, Rating, Description, PhotoUrl, Fax, AnnualRevenue, NumberOfEmployees FROM Lead LIMIT 2';
        					List<Lead> leadList = Database.query(query);
                            
                            js.writeStringField('status','Success');
                            js.writeNumberField('Count',leadList.size());
                            js.writeFieldName('Lead');
                            js.writeStartArray();
                            for(Lead ld: leadList){
                                js.writeStartObject();
                                	js.writeStringField('Id',ld.Id);
                                	js.writeStringField('Salutation',ld.Salutation);
                                    js.writeStringField('Name',ld.Name);
                                	js.writeStringField('FirstName',ld.FirstName);
                                	js.writeStringField('LastName',ld.LastName);
                                    js.writeStringField('Title',ld.Title);
                                    js.writeStringField('Company',ld.Company);
                                    js.writeStringField('Phone',ld.Phone);
                                    js.writeStringField('Email',ld.Email);
                                    js.writeStringField('MobilePhone',ld.MobilePhone);
                                    js.writeStringField('LeadSource',ld.LeadSource);
                                    js.writeStringField('Status',ld.Status);
                                    //js.writeStringField('Website',ld.Website);
                                    js.writeStringField('Industry',ld.Industry);
                                    js.writeStringField('Rating',ld.Rating);
                                    js.writeStringField('PhotoUrl',ld.PhotoUrl);
                                    //js.writeStringField('Description',ld.Description);
                                js.writeEndObject();
                            }
                            js.writeEndArray();
                            
                            
               }catch(Exception e){
                    js.writeStringField('status','Failed');
                    js.writeStringField('error','Exception------>'+e.getMessage()); 
                }
                
            
        }else{
            	// invalid type parameter value
                js.writeStringField('status','Failed');
                js.writeStringField('error','Invalid type parameter in request url');
        }
        
        // get response in json format & return
        js.writeEndObject();
        String response = js.getAsString();
        return response;
    }
    
    @HttpPut
    global static string updateLead(){

        // get our api key from custom metadata types
        //API_Credentials__mdt customMetaData = [select apiKey__c from API_Credentials__mdt];
        //String custom_apiKey = customMetaData.apiKey__c;
        String custom_apiKey = getApiKey();
        
        // create json response body
        System.JSONGenerator js = JSON.createGenerator(true);
        js.writeStartObject();

        // Get body from request & check empty or not
        if(RestContext.request.requestBody != null){
            
            try{
                    String leadResponseBody = RestContext.request.requestBody.toString();
                    
                    // deserialized get response json body
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(leadResponseBody);
                    String response_status = (String)m.get('status');
                    String response_apiKey = (String)m.get('apiKey');
                    
                    System.debug('-----response_status--------->>>'+response_status);
                    System.debug('-----response_apiKey--------->>>'+response_apiKey);
                    
                    // check apiKey authentication
                    if(custom_apiKey == response_apiKey){
                        
                        List<Object> leadList = (List<Object>)m.get('Lead');
                        List<String> ldSet = new List<String>();
                        Map<String, Object> leadAttb = new Map<String, Object>();
                        Map<String, Object> leadAttb1 = new Map<String, Object>();
                        List<Lead> ldList = new List<Lead>();
                        
                        
                        for(Object obj: leadList){
                            
                            leadAttb = (Map<String, Object>)obj;
                            String ldIds   =	(String)leadAttb.get('Id');
                            ldSet.add(ldIds);
                            
                        }
                        
                        for(Lead ld: [SELECT Id, LastName, FirstName, Salutation, Name, Title, Company, Phone, Street, City, State, PostalCode, Country, Address, MobilePhone, Email, Website, LeadSource, Status, Industry, Rating, Description, PhotoUrl, Fax, AnnualRevenue, NumberOfEmployees FROM Lead WHERE Id IN:ldSet]){
                            
                            for(Object obj: leadList){
                                leadAttb1 = (Map<String, Object>)obj;
                                
                                if(ld.Id == (String)leadAttb1.get('Id')){
                                    
                                    ld.FirstName	=	(String)leadAttb1.get('FirstName');
                                    ld.LastName		=	(String)leadAttb1.get('LastName');
                                    ld.Title		=	(String)leadAttb1.get('Title');
                                    ld.Company		=	(String)leadAttb1.get('Company');
                                    ld.Phone		=	(String)leadAttb1.get('Phone');
                                    ld.Email		=	(String)leadAttb1.get('Email');
                                    ld.MobilePhone	=	(String)leadAttb1.get('MobilePhone');
                                    ld.Industry		=	(String)leadAttb1.get('Industry');
                                    ld.Rating		=	(String)leadAttb1.get('Rating');
                                    ld.LeadSource	=	(String)leadAttb1.get('LeadSource');
                                    
                                    ldList.add(ld);
                                }
                            }
                        }
                        
                        
                        
                        // DML Operation: Update
                        update ldList;
                        
                        System.debug('------->>>>'+ldList);
                        // Give Successfull response in json
                        js.writeStringField('status','Success');
                        js.writeStringField('error','Lead record updated successfully!');
                        
                        
                    }else{
                        // apiKey not matched
                        js.writeStringField('status','Failed');
                        js.writeStringField('error','Invalid/Empty API key');   
                    }
                
            }
            catch(Exception e){
            	js.writeStringField('status','Failed');
                js.writeStringField('error','------>'+e.getCause()); 
            }
            
        }else{
            
        	// check leadResponseBody empty
        	js.writeStringField('status','Failed');
            js.writeStringField('error','Empty response in request body');     
            
        }
        
        
        // get response in json format & return
        js.writeEndObject();
        String response = js.getAsString();
        return response;
    }
    
    @HttpDelete
    global static string deleteLead(){
        
        // get type value from url parameter (url query string)
        // Ex: https://ap17.lightning.force.com/services/apexrest/leadServices?Id=00Q2x0000018r47EAA
        String leadId = RestContext.request.params.get('Id'); // values: getAllAccounts
        System.debug('-----leadId--------->>>'+leadId);
        // create json response body
        System.JSONGenerator js = JSON.createGenerator(true);
        js.writeStartObject();

        // check url parameter "type" valid or invalid
        if(leadId != null){
            
            	try{
                            
                            String query = 'SELECT Id FROM Lead WHERE Id=:leadId';
        					List<Lead> leadList = Database.query(query);
                            
							// DML Operation: Delete
                        	delete leadList;

                            // Give Successfull response in json
                            js.writeStringField('status','Success');
                    		js.writeStringField('deletedId',leadId);
                            js.writeStringField('error','Lead record deleted successfully against ID:'+ leadId);                    
                            
                            
               }catch(Exception e){
                    js.writeStringField('status','Failed');
                    js.writeStringField('error','Exception------>'+e.getMessage()); 
                }
                
            
        }else{
            	// invalid type parameter value
                js.writeStringField('status','Failed');
                js.writeStringField('error','Invalid type parameter in request url');
        }
        
        // get response in json format & return
        js.writeEndObject();
        String response = js.getAsString();
        return response;
        
    }

    public static string getApiKey(){
        
        API_Credentials__mdt customMetaData = [select apiKey__c from API_Credentials__mdt];
        String custom_apiKey = customMetaData.apiKey__c;
        
        return custom_apiKey;
    }
    
}