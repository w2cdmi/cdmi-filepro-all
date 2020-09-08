package pw.cdmi.box.uam.user.web;

import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.shiro.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import pw.cdmi.box.uam.user.domain.Admin;
import pw.cdmi.box.uam.user.service.AdminService;

public class UnauthorizeAccessInterceptor extends HandlerInterceptorAdapter
{
    @Autowired
    private AdminService adminService;
    
    private static final ThreadLocal<Boolean> EXCLUED = new ThreadLocal<Boolean>();
    
    private Set<Pattern> excludeUrl = new HashSet<Pattern>(10);
    
    /**
     * @param request
     * @param response
     * @param handler
     * @return
     * @throws Exception
     */
    @SuppressWarnings("PMD.SignatureDeclareThrowsException")
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
        throws Exception
    {
        EXCLUED.remove();
        if (exclude(request))
        {
            return super.preHandle(request, response, handler);
        }
        Admin sessAdmin = (Admin) SecurityUtils.getSubject().getPrincipal();
        
        if (sessAdmin == null)
        {
            return super.preHandle(request, response, handler);
        }
        
        Boolean isInitPwd = (Boolean) SecurityUtils.getSubject().getSession().getAttribute("isInitPwd");
        
        if (null != isInitPwd && isInitPwd)
        {
            return false;
        }
        
        if (null != isInitPwd && !isInitPwd)
        {
            return super.preHandle(request, response, handler);
        }
        Admin localAdmin = adminService.get(sessAdmin.getId());
        if (null == localAdmin || null == localAdmin.getLastLoginTime())
        {
            SecurityUtils.getSubject().getSession().setAttribute("isInitPwd", true);
            return false;
        }
        SecurityUtils.getSubject().getSession().setAttribute("isInitPwd", false);
        return true;
        
    }
    
    public void setExcludeUrl(Set<String> excludeUrlStr)
    {
        for (String str : excludeUrlStr)
        {
            excludeUrl.add(Pattern.compile(str));
        }
    }
    
    private boolean exclude(HttpServletRequest request)
    {
        Boolean exclude = EXCLUED.get();
        if (null != exclude)
        {
            return exclude;
        }
        
        String requestPath = StringUtils.trimToEmpty(request.getRequestURI());
        
        exclude = false;
        Matcher matcher = null;
        for (Pattern pattern : excludeUrl)
        {
            matcher = pattern.matcher(requestPath);
            if (matcher.matches())
            {
                exclude = true;
                break;
            }
        }
        
        EXCLUED.set(exclude);
        
        return exclude;
    }
    
}
