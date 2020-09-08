package pw.cdmi.box.disk.sso.manager;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public interface SsoManager
{
    boolean isCanRedirectLogin(HttpServletResponse response);
    
    boolean isSSORedirectd(HttpServletRequest request, HttpServletResponse response, String ssotoken,
        String nextAction) throws IOException;
    
    boolean isSSORedirectdWithSession(HttpServletRequest request, HttpServletResponse response,
        String ssotoken, String nextAction) throws IOException;
    
    String getUrlByLoginout();
}
