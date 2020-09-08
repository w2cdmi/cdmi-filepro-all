package pw.cdmi.box.disk.user.web;

import javax.servlet.http.HttpServletRequest;

import org.apache.shiro.web.filter.authc.FormAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import pw.cdmi.box.disk.user.service.UserLoginService;
import pw.cdmi.box.disk.utils.CustomUtils;

@Controller
@RequestMapping(value = "/login")
public class LoginController
{
    @Autowired
    private UserLoginService userLoginService;
    
    @RequestMapping(method = RequestMethod.GET)
    public String login(HttpServletRequest request)
    {
        if (!userLoginService.checkBrowser(request))
        {
            return "user/browserVersionTips";
        }
        
        if ("true".equals(CustomUtils.getValue("cloudapp.login")))
        {
            return "user/" + CustomUtils.getParams("cloudapp.login");
        }
        return "user/login";
    }
    
    /**
     * 
     * @param userName
     * @param model
     * @return
     */
    @RequestMapping(method = RequestMethod.POST)
    public String fail(@RequestParam(FormAuthenticationFilter.DEFAULT_USERNAME_PARAM) String userName,
        Model model)
    {
        model.addAttribute(FormAuthenticationFilter.DEFAULT_USERNAME_PARAM, userName);
        return "user/login";
    }
    
    @RequestMapping(value = "/turnToError", method = RequestMethod.GET)
    public String goToErrorPage()
    {
        return "error";
    }
    
    @SuppressWarnings("rawtypes")
    @RequestMapping(value = "/refreshLoginCookie", method = RequestMethod.GET)
    public ResponseEntity refreshLoginCookie()
    {
        return new ResponseEntity(HttpStatus.OK);
    }
    
    @RequestMapping(value = "/authfor", method = RequestMethod.GET)
    public String loginAuthfor()
    {
        return "user/loginAuth";
    }
}
