package pw.cdmi.box.disk.user.shiro;

import java.io.IOException;
import java.net.URLDecoder;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.web.filter.authc.UserFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import pw.cdmi.box.disk.authapp.service.AuthAppService;
import pw.cdmi.box.disk.enterprisecontrol.EnterpriseAuthControlManager;
import pw.cdmi.box.disk.oauth2.domain.UserToken;
import pw.cdmi.box.disk.sso.manager.SsoManager;
import pw.cdmi.box.disk.system.service.SecurityService;
import pw.cdmi.box.disk.user.service.UserLoginService;
import pw.cdmi.box.disk.utils.RequestUtils;
import pw.cdmi.common.domain.SecurityConfig;
import pw.cdmi.common.useragent.UserAgent;

public class AutoLoginAuthenticationFilter extends UserFilter {
	private UserLoginService             userLoginService;
	
	private SecurityService              securityService;
	
	private EnterpriseAuthControlManager enterpriseAuthControlManager;
	
	private AuthAppService               authAppService;
	
	private SsoManager                   ssoManager;
	
	public static final String           REFRESH_COOKIE = "/login/refreshLoginCookie";
	
	public static final String           AUTH_FORWORD   = "/login/authforword";
	
	public static final String           AUTH_FOR       = "/login/authfor";
	
	private static Logger                logger         = LoggerFactory.getLogger(AutoLoginAuthenticationFilter.class);
	
	public void setUserLoginService(UserLoginService userLoginService) {
		this.userLoginService = userLoginService;
	}

	public void setSecurityService(SecurityService securityService) {
		this.securityService = securityService;
	}

	public void setEnterpriseAuthControlManager(EnterpriseAuthControlManager enterpriseAuthControlManager) {
		this.enterpriseAuthControlManager = enterpriseAuthControlManager;
	}

	public void setAuthAppService(AuthAppService authAppService) {
		this.authAppService = authAppService;
	}

	public void setssoManager(SsoManager ssoManager) {
		this.ssoManager = ssoManager;
	}

	@Override
	protected boolean isAccessAllowed(ServletRequest req, ServletResponse resp, Object mappedValue) {
		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) resp;
		SecurityConfig securityConfig = securityService.getSecurityConfig();
		String protocolType = getProtocolType(securityConfig);
		request.getSession().setAttribute("reqProtocol", protocolType);

		// 版本过低直接跳转至版本过低提示页面
		if (!userLoginService.checkBrowser(request, response)) {
			return false;
		}
		if (isLoginRequest(req, resp)) {
			return ssoManager.isCanRedirectLogin(response);
		}
		Subject subject = getSubject(req, resp);
		String ssotoken = request.getParameter("ssotoken");
		String nextAction = request.getParameter("nextAction");

		if (subject.getPrincipal() != null) {
			return isAccessAllowedFroNonNullPrincipal(request, response, subject, ssotoken, nextAction);
		}

		boolean isSSORedirectd = checkSSORedirectd(request, response, ssotoken, nextAction);
		if (isSSORedirectd) {
			return false;
		}
		String path = getPathWithinApplication(req);
		if (StringUtils.isNotBlank(path) && pathsMatch(path, REFRESH_COOKIE)) {
			return true;
		}
		if (StringUtils.isBlank(path)) {
			return false;
		}

		try {

			String contentPath = request.getContextPath();
			String basePath = protocolType + "://" + request.getServerName()
					+ securityService.changePort(String.valueOf(request.getServerPort()), protocolType) + contentPath;
			String deviceType = request.getHeader("deviceType");
			if (StringUtils.isBlank(deviceType)) {
				UserAgent userAgent = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));
				String deviceAgent = userAgent.getBrowser().getName();
				if (("Firefox").equals(deviceAgent)) {
					response.sendRedirect(basePath + "/login");
					return false;
				}
				if (!enterpriseAuthControlManager.isCanNtlm(authAppService.getCurrentAppId())) {
					// write last url to session
					if (ssotoken == null) {
						Cookie[] cookies = request.getCookies();
						String hrefUrl = "";

						String requestPath = protocolType + "://" + request.getServerName()
								+ securityService.changePort(String.valueOf(request.getServerPort()), protocolType)
								+ request.getRequestURI();
						if (requestPath.contains("/v/") || requestPath.endsWith("/teamspace")
								|| requestPath.contains("/trash")) {
							request.getSession().setAttribute("savedRequestStr", requestPath);
							response.sendRedirect(basePath + "/login");
							return false;
						}
						if(null!=cookies){
							for (Cookie cookie : cookies) {
								if (cookie.getName().equals("hrefUrl")) {
									hrefUrl = URLDecoder.decode(cookie.getValue(), "UTF-8");
									logger.debug("autoLoginAuthenticationfilter hrefUrl:" + hrefUrl);
									if (hrefUrl.equals(requestPath)) {
										hrefUrl = requestPath;
										break;
									}
								}
							}
						}

						request.getSession().setAttribute("savedRequestStr", hrefUrl);
					}
					response.sendRedirect(basePath + "/login");
					return false;
				}
			}
			if (pathsMatch(path, AUTH_FORWORD) || isDevicePC(deviceType)) {
				boolean isAccess = userLoginService.ntlmAuthen(request, response, basePath);
				if (isAccess && null == deviceType) {
					String savedRequestURI = request.getSession().getAttribute("savedRequestStr") == null
							? basePath + '/' : request.getSession().getAttribute("savedRequestStr").toString();
					response.sendRedirect(savedRequestURI);
				}
				return false;
			}
			String servletPath = request.getServletPath();
			request.getSession().setAttribute("savedRequestStr", basePath + servletPath);
			response.sendRedirect(basePath + AUTH_FOR);
			return false;
		} catch (IOException e) {
			logger.error("ntlm auth failed ");
			return false;
		}
	}

	private boolean isDevicePC(String deviceType) {
		return null != deviceType && "1".equals(deviceType);
	}

	private String getProtocolType(SecurityConfig securityConfig) {
		String protocolType = securityConfig.getProtocolType();
		if (StringUtils.isBlank(protocolType)) {
			protocolType = "https";
		}
		return protocolType;
	}

	private boolean checkSSORedirectd(HttpServletRequest request, HttpServletResponse response, String ssotoken,
			String nextAction) {
		boolean isSSORedirectd = false;
		try {
			isSSORedirectd = ssoManager.isSSORedirectd(request, response, ssotoken, nextAction);
		} catch (IOException e1) {
			logger.error("sso redirect failed ssotoken nextAction:" + nextAction);
		}
		return isSSORedirectd;
	}

	private boolean isAccessAllowedFroNonNullPrincipal(HttpServletRequest request, HttpServletResponse response,
			Subject subject, String ssotoken, String nextAction) {
		boolean isSSORedirectd = false;
		UserToken userToken = (UserToken) subject.getPrincipal();
		userToken.setDeviceAddress(RequestUtils.getRealIP(request));
		userToken.setProxyAddress(RequestUtils.getProxyIP(request));
		try {
			isSSORedirectd = ssoManager.isSSORedirectdWithSession(request, response, ssotoken, nextAction);
		} catch (IOException e1) {
			logger.error("sso redirect failed ssotoken nextAction:" + nextAction);
		}
		if (isSSORedirectd) {
			return false;
		}
		return true;
	}

	@Override
	protected boolean onAccessDenied(ServletRequest request, ServletResponse response) throws IOException {
		if (response != null && response.isCommitted()) {
			return false;
		}
		if (response != null) {
			HttpServletResponse httpResponse = (HttpServletResponse) response;
			if (httpResponse.getStatus() != HttpServletResponse.SC_BAD_REQUEST) {
				saveRequestAndRedirectToLogin(request, response);
			}
		}
		return false;
	}
}
