//https://gagan-integration-dev-ed--c.visualforce.com/services/apexrest/getReturnCode?
@RestResource(urlMapping='/getReturnCode/*')
global class DropBoxReturnURLCode{
    
    @HttpGet 
    global static String getCode() 
    {  
        System.debug('!!!!!!!!!!!!!!!!!!!----->');
        String code = RestContext.request.params.get('code'); 
        System.debug('!!!!!!!!!!!!!!!!!!!----->'+code);
        return code;
    }

}