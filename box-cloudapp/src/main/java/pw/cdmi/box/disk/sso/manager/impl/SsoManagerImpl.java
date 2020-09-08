package pw.cdmi.box.disk.sso.manager.impl;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;

import pw.cdmi.box.disk.sso.manager.SsoManager;

@Component
public class SsoManagerImpl implements SsoManager
{
    public static final String SSO_PATH = "sso/ssocmb";
    
    @Override
    public boolean isSSORedirectd(HttpServletRequest request, HttpServletResponse response, String ssotoken,
        String nextAction) throws IOException
    {
        return false;
    }
    
    @Override
    public boolean isSSORedirectdWithSession(HttpServletRequest request, HttpServletResponse response,
        String ssotoken, String nextAction) throws IOException
    {
        return false;
    }
    
    @Override
    public boolean isCanRedirectLogin(HttpServletResponse response)
    {
        return true;
    }
    
    @Override
    public String getUrlByLoginout()
    {
        return "";
    }
}
