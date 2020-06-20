public with sharing class SmsProviders {

    public static String serviceProviderName;
    public static String apiKey;
    public static String apiEndPoint;
    public static String senderId;
    
    public SmsProviders(){
        
        SMS_Provider__mdt mdt =  getCredential();
        apiKey 	=  mdt.api_key__c;
        apiEndPoint = mdt.api_url__c;
        serviceProviderName = mdt.DeveloperName;		
    }
    
    // Send sms
    @AuraEnabled(cacheable=true)
    public static String sendSMS(String mobile, String message){
        
        String status;
		String messageBody;
            
        
                Http p=new Http();
                String url= apiEndPoint+'bulk';
                String body='sender_id=FSTSM';
                body=body+'&message='+message;
                body=body+'&language=english';
                body=body+'&route=p';
                body=body+'&numbers='+mobile;
                //body=body+'&flash=0';
                
                HttpRequest request =new HttpRequest();
                request.setHeader('authorization',apiKey);
            	request.setHeader('cache-control','no-cache');
            	request.setHeader('content-type','application/x-www-form-urlencoded');
            
                request.setEndpoint(url);
                request.setMethod('POST');
                request.setBody(body);
                
                HttpResponse response =p.send(request);
                String jsonBody=response.getBody();
            	System.debug('jsonBody:------>'+jsonBody); 
                //String jsonString = '{"return": true,"request_id": "vrc5yp9k4sfze6t","message": ["Message sent successfully"]}';
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
                Boolean returnRes = (boolean)m.get('return');
            
            	sms_transaction__c smsTxn = new sms_transaction__c();
        		Map<String,String> balRsp = walletBalance(); 
        
                if(returnRes){
                   status = 'SUCCESS'; 
                   String smsProviderId = (String)m.get('request_id');
                   List<Object> messageList = (List<Object>)m.get('message'); 
                   messageBody = String.valueOf(messageList.get(0));
                   
                   smsTxn.balance__c = balRsp.get('balance'); 
                   smsTxn.sms_provider_id__c = smsProviderId; 
                }else{
                   status = 'FAILED';
                   messageBody = (String)m.get('message');
                   smsTxn.Error_Code__c = String.valueOf(m.get('status_code')); 
                }

        
        
        		try{
                    String requestURL = url+'?'+body;
                    smsTxn.request_body__c = EncodingUtil.urlEncode(requestURL,'UTF-8');
                    smsTxn.request_message__c = message;
                    smsTxn.mobile__c = mobile;
                    smsTxn.response_body__c = jsonBody;
                    smsTxn.response_message__c = messageBody;
                    smsTxn.sms_provider__c = serviceProviderName;
                    smsTxn.status__c = status;
                    
                    insert smsTxn;
                    String smsBalanceId = balRsp.get('smsBalanceId');
            		updateTransactionIdInwalletBalance(smsTxn.Id, smsBalanceId);
                    
                }catch(Exception e){
                        System.debug('Error:------>'+e.getMessage()); 
                }
        
        return status;
    }
    
    // Wallet balance
    public static Map<String,String> walletBalance(){
        
        String balance = null;
        Map<String,String> returnResp =new Map<String,String>();
        
        Http p=new Http();
        String url= apiEndPoint+'wallet';
        
        HttpRequest request =new HttpRequest();
        request.setHeader('Authorization',apiKey);
        request.setEndpoint(url);
        request.setMethod('POST');
        
      	HttpResponse response =p.send(request);
        String jsonBody=response.getBody();
        //String jsonString = '{"return": true,"wallet": 50.00}';
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
        Boolean returnRes = (boolean)m.get('return');
        
        SMS_Balance__c smsBalance = new SMS_Balance__c();
        if(returnRes){
            balance = (String)m.get('wallet');
            smsBalance.balance__c = balance;
            smsBalance.status__c = 'SUCCESS';
        }else{
            smsBalance.status__c = 'FAILED'; 
            smsBalance.error_code__c = String.valueOf(m.get('status_code')); 
            smsBalance.error_message__c = (String)m.get('message');
        }
        
        smsBalance.request_body__c = url;            
        smsBalance.response_body__c = jsonBody;
        insert smsBalance;
        
        System.debug('wallet-balance:------>'+balance);
        
		returnResp.put('balance',balance);
		returnResp.put('smsBalanceId',smsBalance.Id);
        
        return returnResp;
        
    }
    
    // update wallet balance transaction id
    public static void updateTransactionIdInwalletBalance(String smsTransactionId, String smsBalanceId){
        
        SMS_Balance__c upd = [select sms_transaction__c from SMS_Balance__c where id=:smsBalanceId];
        upd.sms_transaction__c = smsTransactionId;
        update upd;
        
    }
    
    public static SMS_Provider__mdt getCredential(){
        
        return [select active__c,api_key__c,api_url__c,sender_id__c,DeveloperName,MasterLabel from SMS_Provider__mdt where active__c = true];
        
    }
}