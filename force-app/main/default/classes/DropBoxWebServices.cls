global class DropBoxWebServices {

    public String apiKey     {set;get;}
    public String apiSecretKey   {set;get;}
    public String apiOAuthEndPoint {set;get;}
    public String apiEndPoint {set;get;}
    public String redirectUrl  {set;get;}
    public String code      {set;get;}
    public String accessToken  {set;get;}
    public String state      {set;get;}
    public String result    {set;get;}
    public String responseCode {set;get;}
    public String paramvalue {set;get;}
    public String[] returnBackURL {set;get;}
    public String getHeaderURL {set;get;}
    
    public DropBoxWebServices(){
        
        redirectUrl		 =  'https://gagan-integration-dev-ed--c.visualforce.com/apex/DropBoxOAuth2';
        DropBox__mdt mdt =  getCredential();
        apiKey 			 =  mdt.App_key__c;
        apiSecretKey 	 =  mdt.App_secret__c;
        apiOAuthEndPoint =  mdt.OAuth_2_url__c;	
        apiEndPoint	 	 =	mdt.API_url__c;			
        
        /********************/
        /*DropBoxReturnURLCode aa = new DropBoxReturnURLCode();
        aa.requestCode();
        responseCode = aa.responseCode;
        System.debug('$$$$$$$$$$$$$$$$$$--------------->'+aa.requestCode());*/
        /********************/
        responseCode = Apexpages.currentPage().getParameters().get('code');
		//responseCode = 'V68ZeSjAEywAAAAAAAAdJc7iaC6-jpNyaw-M38sOW0c';
        
        if(responseCode!=null){
            code = responseCode;
            System.debug('--code->'+code);  
            requestToken();
            //createFolder();
            getFolderContent();
            //getThumbnailFile(); // NOT USE: For Image file
            //getTempFileLink(); // NOT USE: For Download file direcly
            //makeShredFileLink();
            //listAllShredFileLink();
            //deleteFile();
        }
    }
    
    public void  listAllShredFileLink(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://api.dropboxapi.com/2/sharing/list_shared_links');
        request.setMethod('POST');
        String body='{"path":"/Salesforce/testDoc.docx"}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response=p.send(request);
        result=response.getBody();
        System.debug('----result>'+result);
    }
    
    public void  makeShredFileLink(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings');
        request.setMethod('POST');
        String body='{"path":"/Salesforce/testDoc.docx","settings":{"requested_visibility":"team_only","audience":"public","access":"viewer"}}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response=p.send(request);
        result=response.getBody();
        System.debug('----result>'+result);
    }
    
    
      public void  getTempFileLink(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        //request.setEndPoint('https://api.dropboxapi.com/2/file_requests/get');
        //request.setEndPoint('https://api.dropboxapi.com/2/file_requests/list_v2');
        //request.setEndPoint('https://api.dropboxapi.com/2/file_requests/list/continue');
        //request.setEndPoint('https://content.dropboxapi.com/2/files/get_preview');
        request.setEndPoint('https://api.dropboxapi.com/2/files/get_temporary_link');
        request.setMethod('POST');
        //String body='{"id":"Fmdo05ZYLMsAAAAAAABXRA"}';
        //String body='{"limit":1000}';
        //String body='{"cursor": "AABdJ9mGvvf_eqIzJgSlv88aBgf5tq5U19SgjgHHo3VINCuTKprlN9Yn2M3eTCRk21jcQm-A760X0RItQxPoZFV1g5gsdvK8DiUX9lMOZVWeu1EwDyZAmWeJVKQs56_D2mWzKfA_-5eOWskJiCZFt7r3t_huxRwhfefKSfypnAFHXNsL0j1c1A8edYkiEZXdwsE"}';
        String body='{"path":"/Salesforce/testDoc.docx"}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');  
		//request.setHeader('Dropbox-API-Arg', body);
        HttpResponse response=p.send(request);
        result=response.getBody();
        System.debug('----result>'+result);
    }
    
    // Request the code 
    public PageReference requestCode(){
        
        
        
        
        if(responseCode==null){
            String url=apiOAuthEndPoint+'?response_type=code&client_id='+apiKey+'&redirect_uri='+redirectUrl;
        	PageReference p=new PageReference(url);
            return p;
        }
        return null;
        
        /*Http p=new Http();
        HttpRequest request =new HttpRequest();
        //String url=apiOAuthEndPoint+'?response_type=code&client_id='+apiKey+'&redirect_uri='+redirectUrl;
        String url='https://www.dropbox.com/oauth2/authorize?client_id=ro2w84gctybps0k&response_type=code&redirect_uri=https://gagan-integration-dev-ed--c.visualforce.com/services/apexrest/getReturnCode?';
        request.setEndPoint(url);
        request.setMethod('GET');
        HttpResponse response=p.send(request);
		String result=response.getBody();
		System.debug('=====>'+result);
        returnBackURL = response.getHeaderKeys();
		responseCode = response.getHeader('X-Dropbox-Request-Id');
        
        System.debug('----responseCode>'+responseCode);
        System.debug('----returnBackURL>'+returnBackURL);*/
        
    }
    
    
    
    
    public void requestToken(){
        Http p=new Http();
        String body='grant_type=authorization_code';
        body=body+'&code='+responseCode;
        body=body+'&client_id='+apiKey;
        body=body+'&client_secret='+apiSecretKey; 
        body=body+'&redirect_uri='+redirectUrl;
        HttpRequest request =new HttpRequest();
        request.setEndpoint(apiEndPoint);
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response =p.send(request);
        String jsonBody=response.getBody();
        //String jsonString = '{"access_token": "ABCDEFG", "token_type": "bearer", "account_id": "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc", "uid": "12345"}';
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        accessToken = (String)m.get('access_token');
        String token_type = (String)m.get('token_type');
        String account_id = (String)m.get('account_id');
        String uid 	= (String)m.get('uid');
        
        system.debug('----accessToken='+accessToken);
        //system.debug('----token_type='+token_type);
        //system.debug('----account_id='+account_id);
        //system.debug('----uid='+uid);
        
    }
    

    
    public void  createFolder(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://api.dropboxapi.com/2/files/create_folder_v2');
        request.setMethod('POST');
        String body='{"path":"/Salesforce", "autorename": false}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
		request.setHeader('Content-Type', 'application/json');
        HttpResponse response=p.send(request);
        result=response.getBody();
        System.debug('----result>'+result);
        System.debug('----accessToken>'+accessToken);
    }
    
    public void  getFolderContent(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://api.dropboxapi.com/2/files/list_folder');
        request.setMethod('POST');
        String body='{"path": "/Salesforce/","recursive": false,"include_media_info": true,"include_deleted": false,"include_has_explicit_shared_members": false,"include_mounted_folders": true,"include_non_downloadable_files": true}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
		request.setHeader('Content-Type', 'application/json');
        HttpResponse response=p.send(request);
        result=response.getBody();
        

        
    }
    
    public void  getThumbnailFile(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://content.dropboxapi.com/2/files/get_thumbnail_v2');
        request.setMethod('POST');
        String body='{"resource":{".tag":"path","path":"/Salesforce/test123.JPG"},"format":"jpeg","size":"w128h128","mode":"strict"}';
        request.setHeader('Authorization','Bearer '+accessToken);
		request.setHeader('Dropbox-API-Arg', body);
        HttpResponse response=p.send(request);
        result=response.getBody(); //getBodyAsBlob()
        Blob beforeblob = Blob.valueOf(result);
        // base64 encode the blob that contains our url param value
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        System.debug('----result>'+result);
    }
    
    
    public void  deleteFile(){
        Http p=new Http();
        HttpRequest request =new HttpRequest();
        request.setEndPoint('https://api.dropboxapi.com/2/files/delete_v2');
        request.setMethod('POST');
        String body='{"path":"/Salesforce/test123.JPG"}';
        request.setBody(body);
        request.setHeader('Authorization','Bearer '+accessToken);
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response=p.send(request);
        result=response.getBody();
        System.debug('----result>'+result);
    }
    
    
    public static DropBox__mdt getCredential(){
        
        return [select App_key__c,App_secret__c,OAuth_2_url__c,API_url__c from DropBox__mdt];
        
    }
    
     public string findObjectAPIName( String recordId ){
         
        if(recordId == null)
            return null;
        String objectAPIName = '';
        String keyPrefix = recordId.substring(0,3);
         for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
              String prefix = obj.getDescribe().getKeyPrefix();
               if(prefix == keyPrefix){
                         objectAPIName = obj.getDescribe().getName();
                          break;
                }
         }

         return objectAPIName;

	}
}