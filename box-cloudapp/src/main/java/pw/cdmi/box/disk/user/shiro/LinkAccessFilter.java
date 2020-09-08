package pw.cdmi.box.disk.user.shiro;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import pw.cdmi.box.disk.share.service.LinkService;
import pw.cdmi.box.disk.system.service.CustomizeLogoService;
import pw.cdmi.common.domain.CustomizeLogo;
import pw.cdmi.core.exception.InternalServerErrorException;
import pw.cdmi.core.utils.SpringContextUtil;

public class LinkAccessFilter implements Filter
{
    
    private static final String FORWORD_JSP = "/WEB-INF/views/share/linkForword.jsp";
    
    private static final Logger LOGGER = LoggerFactory.getLogger(LinkAccessFilter.class);
    
    @Override
    public void destroy()
    {
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException
    {
    	chain.doFilter(request, response);
        LinkService linkService = (LinkService) SpringContextUtil.getBean("linkService");
//        if (linkService.allowAnonyAccess())
//        {
//            chain.doFilter(request, response);
//        }
//        else
//        {
//            HttpServletRequest req = (HttpServletRequest) request;
//            String path = req.getRequestURL().toString();
//            path = path.substring(path.indexOf("/p/"));
//            path = getBasePath() + path;
//            path = path.replaceAll("/p/", "/v/");
//            request.setAttribute("forwordUrl", path);
//            request.getRequestDispatcher(FORWORD_JSP).forward(request, response);
//        }
    }
    
    private String getBasePath()
    {
        CustomizeLogoService customizeLogoService = (CustomizeLogoService) SpringContextUtil.getBean("customizeLogoServiceImpl");
        CustomizeLogo temp = customizeLogoService.getCustomize();
        if (null != temp)
        {
            StringBuffer webDomain = new StringBuffer(StringUtils.trimToEmpty(temp.getDomainName()));
            if ('/' == webDomain.charAt(webDomain.length() - 1))
            {
                webDomain.deleteCharAt(webDomain.length() - 1);
            }
            return webDomain.toString();
        }
        
        String message = "Please Config WebDomain Name In ISystem.";
        LOGGER.warn(message);
        throw new InternalServerErrorException(message);
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException
    {
        // TODO Auto-generated method stub
        
    }
    
}
