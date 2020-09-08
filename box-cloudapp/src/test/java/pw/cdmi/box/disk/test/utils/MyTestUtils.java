package pw.cdmi.box.disk.test.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.util.Calendar;
import java.util.Locale;
import java.util.ResourceBundle;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;

import pw.cdmi.box.disk.client.domain.user.RestUserloginRsp;
import pw.cdmi.common.util.signature.SignatureUtils;
import pw.cdmi.core.utils.DateUtils;
import pw.cdmi.core.utils.JsonUtils;

public class MyTestUtils
{
    private static final ResourceBundle bundle = ResourceBundle.getBundle("testData/testConfig",
        Locale.ENGLISH);
    
    public static final String SERVER_UFM_URL_V1 = bundle.getString("ufmv1");
    
    public static final String SERVER_URL_UAM_V1 = bundle.getString("uamv1");
    
    public static final String SERVER_URL_UAM_V2 = bundle.getString("uamv2");
    
    public static final String SERVER_URL_UFM_V2 = bundle.getString("ufmv2");
    
    private static String token1 = null;
    
    private static String token2 = null;
    
    private static RestUserloginRsp user1 = null;
    
    private static RestUserloginRsp user2 = null;
    
    private static Long userId1 = null;
    
    private static Long userId2;
    
    public static final String getAppAuthorization(String dateString)
    {
        StringBuilder sb = new StringBuilder();
        sb.append("account,");
        sb.append(bundle.getString("appid"));
        sb.append(",");
        sb.append(SignatureUtils.getSignature(bundle.getString("appSecurityKey"), dateString));
        return sb.toString();
    }
    
    public static final String getLinkAuthorization(String linkCode, String plainAccessCode, String dateStr)
    {
        StringBuilder sb = new StringBuilder();
        sb.append("link,");
        sb.append(bundle.getString(linkCode));
        if (StringUtils.isNotEmpty(plainAccessCode))
        {
            sb.append(",");
            sb.append(SignatureUtils.getSignature(plainAccessCode, dateStr));
        }
        return sb.toString();
    }
    
    public static final String getLinkSignature(String plainAccessCode, String dateStr)
    {
        return SignatureUtils.getSignature(plainAccessCode, dateStr);
    }
    
    public static final String getDateString(Calendar calendar)
    {
        return DateUtils.dateToString(DateUtils.RFC822_DATE_FORMAT, calendar.getTime(), null);
    }
    
    public static final String getDateString()
    {
        return getDateString(Calendar.getInstance());
    }
    
    public static Long getTestCloudUserId1() throws Exception
    {
        if (null == userId1)
        {
            userId1 = getTestUser1().getCloudUserId();
        }
        return userId1;
    }
    
    public static Long getTestCloudUserId2() throws Exception
    {
        if (null == userId2)
        {
            userId2 = getTestUser1().getCloudUserId();
        }
        return userId2;
    }
    
    public static RestUserloginRsp getTestUser1() throws Exception
    {
        if (user1 == null)
        {
            // user1 = LoginTest.getUser1();
        }
        return user1;
    }
    
    public static RestUserloginRsp getTestUser2() throws Exception
    {
        if (user2 == null)
        {
            // user2 = LoginTest.getUser2();
        }
        return user2;
    }
    
    public static String getTestUserToken1() throws Exception
    {
        if (null == token1)
        {
            token1 = getTestUser1().getToken();
        }
        return token1;
    }
    
    public static String getUserToken2() throws Exception
    {
        if (null == token2)
        {
            token2 = getTestUser1().getToken();
        }
        return token2;
    }
    
    public static void main(String[] args) throws Exception
    {
        
        long userToken = getTestCloudUserId1();
        System.out.println(userToken);
    }
    
    public static void output(HttpURLConnection openurl) throws Exception
    {
        System.out.println("Return status code is : " + openurl.getResponseCode());
        InputStream stream = null;
        try
        {
            System.out.println("message is " + openurl.getResponseMessage());
            stream = openurl.getInputStream();
            System.out.println("available is " + stream.available());
            BufferedReader in = new BufferedReader(new InputStreamReader(stream));
            System.out.println("Normal result is ------------------------------------------");
            System.out.println(openurl.getResponseCode());
            String re = in.readLine();
            System.out.println(re);
        }
        catch (IOException e)
        {
            System.err.println("Unnormal result is ------------------------------------------");
            stream = openurl.getErrorStream();
            if (null == stream)
            {
                System.err.println("There is not any return data.");
            }
            else
            {
                BufferedReader in = new BufferedReader(new InputStreamReader(stream));
                System.err.println(openurl.getResponseCode());
                String re = in.readLine();
                System.err.println(re);
                IOUtils.closeQuietly(in);
            }
            
        }
    }
    
    public static void outputWithCheck(HttpURLConnection openurl, Integer httpCode, String code)
        throws Exception
    {
        InputStream stream = null;
        try
        {
            stream = openurl.getInputStream();
            BufferedReader in = new BufferedReader(new InputStreamReader(stream));
            System.out.println("Normal result is ------------------------------------------");
            System.out.println(openurl.getResponseCode());
            String re = in.readLine();
            System.out.println(re);
        }
        catch (IOException e)
        {
            stream = openurl.getErrorStream();
            if (null == stream)
            {
                System.err.println("There is not any return data.");
            }
            else
            {
                BufferedReader in = new BufferedReader(new InputStreamReader(stream));
                if (httpCode != null && code != null)
                {
                    int returnhttpCode = openurl.getResponseCode();
                    String re = in.readLine();
                    RestErrorRsp resp = JsonUtils.stringToObject(re, RestErrorRsp.class);
                    
                    if (httpCode != null && returnhttpCode != httpCode)
                    {
                        System.err.println(openurl.getResponseCode());
                        System.err.println(re);
                        IOUtils.closeQuietly(in);
                    }
                    else if (code != null && !code.equals(resp.getCode()))
                    {
                        System.err.println(openurl.getResponseCode());
                        System.err.println(re);
                        IOUtils.closeQuietly(in);
                    }
                    else
                    {
                        System.out.println("Normal error result");
                        System.out.println(openurl.getResponseCode());
                        System.out.println(re);
                    }
                }
                else
                {
                    System.err.println(openurl.getResponseCode());
                    String re = in.readLine();
                    System.err.println(re);
                    IOUtils.closeQuietly(in);
                }
            }
        }
        
    }
    
}
