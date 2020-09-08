package pw.cdmi.box.disk.utils;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;

import pw.cdmi.core.exception.InvalidParamException;


public final class RequestUtils
{
    private RequestUtils()
    {
        
    }
    
    /**
     * 
     * @param request
     * @return
     */
    public static String getRealIP(HttpServletRequest request)
    {
        String ipAddress = request.getHeader("x-real-ip");
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("x-forwarded-for");
        }
        
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getRemoteAddr();
        }
        
        if (ipAddress != null && ipAddress.indexOf(",") != -1)
        {
            String[] ips = ipAddress.split(",");
            int i = 0;
            while (i < ips.length && "unknown".equalsIgnoreCase(ips[i]))
            {
                i++;
            }
            if (i >= ips.length)
            {
                throw new InvalidParamException("ips length is larger than ips.length");
            }
            ipAddress = ips[i];
        }
        return ipAddress;
    }
    
    /**
     * 
     * @param request
     * @return
     */
    public static String getProxyIP(HttpServletRequest request)
    {
        String ipAddress = request.getHeader("X-Proxy-IP");
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("x-forwarded-for");
        }
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getHeader("x-real-ip");
        }
        if (StringUtils.isBlank(ipAddress) || "unknown".equalsIgnoreCase(ipAddress))
        {
            ipAddress = request.getRemoteAddr();
        }
        
        if (ipAddress != null && ipAddress.indexOf(",") != -1)
        {
            String[] ips = ipAddress.split(",");
            int i = ips.length - 1;
            while (i > -1 && "unknown".equalsIgnoreCase(ips[i]))
            {
                i--;
            }
            ipAddress = ips[i];
        }
        return ipAddress;
    }
}
