package pw.cdmi.box.uam.user.domain;

import java.io.Serializable;

public class UserCustom implements Serializable
{
    private static final long serialVersionUID = -3548013203147902743L;
    
    private long id;
    
    private String language;
    
    private String datePattern;
    
    private String timePattern;
    
    private String timeZone;
    
    private byte[] avatar;
    
    private boolean init;
    
    public long getId()
    {
        return id;
    }
    
    public void setId(long id)
    {
        this.id = id;
    }
    
    public String getLanguage()
    {
        return language;
    }
    
    public void setLanguage(String language)
    {
        this.language = language;
    }
    
    public String getDatePattern()
    {
        return datePattern;
    }
    
    public void setDatePattern(String datePattern)
    {
        this.datePattern = datePattern;
    }
    
    public String getTimePattern()
    {
        return timePattern;
    }
    
    public void setTimePattern(String timePattern)
    {
        this.timePattern = timePattern;
    }
    
    public String getTimeZone()
    {
        return timeZone;
    }
    
    public void setTimeZone(String timeZone)
    {
        this.timeZone = timeZone;
    }
    
    public byte[] getAvatar()
    {
        return avatar == null ? null : avatar.clone();
    }
    
    public void setAvatar(byte[] avatar)
    {
        this.avatar = (avatar == null ? null : avatar.clone());
    }
    
    public boolean isInit()
    {
        return init;
    }
    
    public void setInit(boolean init)
    {
        this.init = init;
    }
}
