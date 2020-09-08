package pw.cdmi.box.disk.user.shiro;

import java.io.IOException;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.session.SessionException;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.web.filter.authc.LogoutFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import pw.cdmi.box.disk.openapi.rest.v1.service.UserAuthService;
import pw.cdmi.box.disk.sso.manager.SsoManager;
import pw.cdmi.box.disk.user.domain.User;
import pw.cdmi.box.disk.utils.CSRFTokenManager;
import pw.cdmi.core.exception.InternalServerErrorException;

public class MyLogoutAuthenticationFilter extends LogoutFilter
{
    private static Logger logger = LoggerFactory.getLogger(MyLogoutAuthenticationFilter.class);
    
    private UserAuthService userAuthService;
    
    private SsoManager ssoManager;
    
    public void setUserAuthService(UserAuthService userAuthService)
    {
        this.userAuthService = userAuthService;
    }
    
    public void setssoManager(SsoManager ssoManager)
    {
        this.ssoManager = ssoManager;
    }
    
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    @Override
    protected boolean preHandle(ServletRequest request, ServletResponse response) throws Exception {

		String token = (String) request.getParameter("token");
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse httpRsp = (HttpServletResponse) response;

		Object sessionToken = SecurityUtils.getSubject().getSession().getAttribute(CSRFTokenManager.CSRF_TOKEN_FOR_SESSION_ATTR_NAME);
		
		Subject subject = getSubject(request, response);
		User user = (User) subject.getPrincipal();
		if (user == null) {
			logger.error("session is null");
			jumpToLogin(response, req);
			return false;
		}

		if (token == null ||(null != sessionToken && !token.equals(sessionToken))) {
			logger.error("Bad Request for CSRF:");
			req.setAttribute("redirect", "CSRF-FLAG");
			httpRsp.sendError(401);
			return false;
		}

		try {
			String platToken = (String) SecurityUtils.getSubject().getSession().getAttribute("platToken");
			if (platToken!=null) {
				userAuthService.deleteToken(platToken);
			}
			subject.logout();
			subject.releaseRunAs();
			String ssoUrl = ssoManager.getUrlByLoginout();
			if (StringUtils.isNotBlank(ssoUrl)) {
				httpRsp.sendRedirect(ssoUrl);
			} else {
				//issueRedirect(request, response, redirectUrl);
				jumpToLogin(response, req);
			}
		} catch (SessionException ise) {
			logger.debug("Encountered session exception during logout.  This can generally safely be ignored.", ise);
		} catch (InternalServerErrorException e) {
			logger.warn("", e);
		} catch (IOException e) {
			logger.debug("", e);
		}
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
