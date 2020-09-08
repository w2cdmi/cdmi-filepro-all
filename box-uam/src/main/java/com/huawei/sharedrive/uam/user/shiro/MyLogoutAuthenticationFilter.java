package com.huawei.sharedrive.uam.user.shiro;

import java.io.IOException;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.session.SessionException;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.web.filter.authc.LogoutFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.huawei.sharedrive.uam.enterpriseadminlog.domain.AdminLogType;
import com.huawei.sharedrive.uam.enterpriseadminlog.domain.LogOwner;
import com.huawei.sharedrive.uam.enterpriseadminlog.manager.AdminLogManager;
import com.huawei.sharedrive.uam.enterpriseuser.service.UserLdapService;
import com.huawei.sharedrive.uam.user.domain.Admin;
import com.huawei.sharedrive.uam.util.CSRFTokenManager;

import pw.cdmi.common.log.SystemLog;
import pw.cdmi.core.utils.EnvironmentUtils;
import pw.cdmi.core.utils.IpUtils;

public class MyLogoutAuthenticationFilter extends LogoutFilter
{
    private static Logger logger = LoggerFactory.getLogger(MyLogoutAuthenticationFilter.class);
    
    @Autowired
    private UserLdapService userLdapService;
    
    @Autowired
    private AdminLogManager adminLogManager;
    
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    @Override
    protected boolean preHandle(ServletRequest request, ServletResponse response) throws Exception
    {
        HttpSession session = ((HttpServletRequest) request).getSession();
        String sessionId = session.getId();
        
        String token = (String) request.getParameter("token");
        if (token == null)
        {
            token = "";
        }
        Object sessionToken = SecurityUtils.getSubject()
            .getSession()
            .getAttribute(CSRFTokenManager.CSRF_TOKEN_FOR_SESSION_ATTR_NAME);
        
        Subject subject = getSubject(request, response);
        String redirectUrl = getRedirectUrl(request, response, subject);
        Admin admin = (Admin) subject.getPrincipal();
        if (null == admin)
        {
            logger.error("session is null");
            HttpServletRequest req = (HttpServletRequest) request;
            jumpToLogin(response, req);
            return false;
        }
        LogOwner owner = new LogOwner();
        owner.setEnterpriseId(admin.getEnterpriseId());
        owner.setIp(IpUtils.getClientAddress((HttpServletRequest) request));
        if (StringUtils.isBlank(token) || (!token.equals(sessionToken) && null != sessionToken))
        {
            logger.error("Bad Request for CSRF:");
            HttpServletRequest req = (HttpServletRequest) request;
            HttpServletResponse httpRsp = (HttpServletResponse) response;
            req.setAttribute("redirect", "CSRF-FLAG");
            httpRsp.sendError(401);
            adminLogManager.saveAdminLog(owner, AdminLogType.KEY_ADMIN_LOUOUT_ERROR, new String[]{admin.getLoginName()});
            return false;
        }
        
        SystemLog systemLog = new SystemLog();
        systemLog.setLoginName(admin.getLoginName());
        systemLog.setShowName(admin.getLoginName() + "(" + admin.getName() + ")");
        systemLog.setClientAddress(IpUtils.getClientAddress((HttpServletRequest) request));
        systemLog.setClientDeviceName(EnvironmentUtils.getHostName());
        
        try
        {
            subject.logout();
            subject.releaseRunAs();
            adminLogManager.saveAdminLog(owner, AdminLogType.KEY_ADMIN_LOGOUT, new String[]{admin.getLoginName()});
        }
        catch (SessionException ise)
        {
            
            logger.debug("Encountered session exception during logout.  This can generally safely be ignored.",
                ise);
            adminLogManager.saveAdminLog(owner, AdminLogType.KEY_ADMIN_LOUOUT_ERROR, new String[]{admin.getLoginName()});
        }
        issueRedirect(request, response, redirectUrl);
        
        userLdapService.deleteBySessionId(sessionId);
        
        return false;
    }
    
    /**
     * 
     * @param response
     * @param req
     * @throws IOException
     */
    private void jumpToLogin(ServletResponse response, HttpServletRequest req) throws IOException
    {
        StringBuffer contextPath = new StringBuffer();
        contextPath.append(req.getContextPath());
        if (contextPath.length() > 0
            && contextPath.toString().charAt(contextPath.toString().length() - 1) != '/')
        {
            contextPath.append('/');
        }
        contextPath.append("/login");
        HttpServletResponse rsp = (HttpServletResponse) response;
        
        rsp.sendRedirect(contextPath.toString());
    }
}
