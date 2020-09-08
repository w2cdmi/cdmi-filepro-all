package pw.cdmi.box.disk.system.web;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.util.HtmlUtils;

import pw.cdmi.box.disk.system.service.ClientManageService;
import pw.cdmi.box.disk.system.service.CustomizeLogoService;
import pw.cdmi.common.domain.ClientManage;
import pw.cdmi.common.domain.CustomizeLogo;
import pw.cdmi.common.domain.ClientManage.ClientType;
import pw.cdmi.core.exception.BaseRunException;
import pw.cdmi.core.exception.NoSuchClientException;

@Controller
@RequestMapping(value = "/client")
public class ClientManageController
{
    @Autowired
    private ClientManageService clientManageService;
    
    @Autowired
    private CustomizeLogoService customizeLogoService;
    
    @RequestMapping(value = "/downloadUrl", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<String> getClientDownloadUrl(@RequestParam String type, Model model,
        HttpServletRequest request) throws BaseRunException
    {
        CustomizeLogo temp = customizeLogoService.getCustomize();
        String domainName = temp.getDomainName();
        if (StringUtils.isEmpty(domainName))
        {
            model.addAttribute("urlPrefix", request.getContextPath());
        }
        else
        {
            StringBuffer sb = new StringBuffer(StringUtils.trimToEmpty(domainName));
            if ('/' != sb.charAt(sb.length() - 1))
            {
                sb.append('/');
            }
            model.addAttribute("urlPrefix", sb.toString());
        }
        
        ClientManage client;
        switch (ClientType.valueOf(type))
        {
            case PC:
                client = clientManageService.getPcClient();
                break;
            case Android:
                client = clientManageService.getAndroidClient();
                break;
            case IOS:
                client = clientManageService.getIOSClient();
                break;
            default:
                throw new NoSuchClientException("No such client: " + type);
        }
        return new ResponseEntity<String>(HtmlUtils.htmlEscape(client.getDownloadUrl()), HttpStatus.OK);
    }
    
}
