package pw.cdmi.box.disk.client.api;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;

import pw.cdmi.box.disk.client.domain.user.RestAccountConfigList;
import pw.cdmi.box.disk.client.domain.user.RestUserConfigList;
import pw.cdmi.box.disk.httpclient.rest.common.Constants;
import pw.cdmi.core.exception.RestException;
import pw.cdmi.core.restrpc.RestClient;
import pw.cdmi.core.restrpc.domain.TextResponse;
import pw.cdmi.core.utils.JsonUtils;

public class AccountConfigClient {
	

    
	
    private RestClient uamClientService;
    
    public AccountConfigClient(RestClient uamClientService)
    {
        this.uamClientService = uamClientService;
    }
    
    public RestAccountConfigList getAccountConfig(long accountId, String token) throws RestException
    {
        StringBuffer uri = new StringBuffer();
        uri.append(Constants.RESOURCE_ACCOUNTS);
        uri.append('/');
        uri.append(accountId);
        uri.append("/config"); 
        
        Map<String, String> headers = new HashMap<String, String>(1);
        headers.put("Authorization", token);
        
        TextResponse response = uamClientService.performGetText(uri.toString(), headers);
        
        if (response.getStatusCode() != HttpStatus.OK.value())
        {
            RestException exception = JsonUtils.stringToObject(response.getResponseBody(),
                RestException.class);
            throw exception;
        }
        return JsonUtils.stringToObject(response.getResponseBody(), RestAccountConfigList.class);
    }
    


}
